extends Node3D

const MIN_SPAWN_DISTANCE := 8.0
const SPAWN_LANE_JITTER := 1.1
const SPAWN_DEPTH_JITTER := 1.6
const MAX_SPAWN_CORRIDOR_X := 3.8

@export var zombie_scene: PackedScene
@export var spawn_points: Array[Node3D]
@export var wave_delay: float = 6.0
@export var max_active_zombies: int = 8

var mission: MissionData
var current_wave: int = 0
var zombies_to_spawn: int = 0
var zombies_alive: int = 0
var is_spawning_wave: bool = false
var is_wave_ending: bool = false
var player_ref: Node3D = null
var is_endless_mode: bool = false
var endless_active: bool = false
var wave_elapsed_time: float = 0.0
var watchdog_timer: float = 0.0

func _ready():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.GAMEPLAY)
		
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr and mission_mgr.current_mission:
		mission = mission_mgr.current_mission
		mission_mgr._is_finishing = false
		if mission and mission.is_endless:
			is_endless_mode = true
			endless_active = true
	else:
		mission = load("res://resources/missions/mission_01.tres")
		if mission_mgr:
			mission_mgr.current_mission = mission
			mission_mgr.kill_count = 0
			mission_mgr.wave_count = 0
			mission_mgr.boss_kill_count = 0
			mission_mgr.score = 0
			mission_mgr._is_finishing = false
	
	current_wave = 0
	zombies_alive = 0
	is_spawning_wave = false
	is_wave_ending = false
	wave_elapsed_time = 0.0
		
	var q_mgr = get_node_or_null("/root/QualityManager")
	if q_mgr:
		match q_mgr.current_quality:
			q_mgr.Profile.ANDROID_LEGACY:
				max_active_zombies = 6
			q_mgr.Profile.ANDROID_BALANCED:
				max_active_zombies = 8
			q_mgr.Profile.ANDROID_HIGH:
				max_active_zombies = 10
			_:
				max_active_zombies = 8
	else:
		max_active_zombies = 10
		
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		if not event_bus.enemy_killed.is_connected(_on_enemy_killed_event):
			event_bus.enemy_killed.connect(_on_enemy_killed_event)
			
	player_ref = get_tree().get_first_node_in_group("player")
	start_next_wave()

func _get_campaign_wave_budget() -> int:
	var q_mgr = get_node_or_null("/root/QualityManager")
	var base_budget := 8
	if q_mgr:
		match q_mgr.current_quality:
			q_mgr.Profile.ANDROID_LEGACY:
				base_budget = 6
			q_mgr.Profile.ANDROID_BALANCED:
				base_budget = 8
			q_mgr.Profile.ANDROID_HIGH:
				base_budget = 10
	return base_budget + mini(maxi(current_wave - 1, 0), 2) * 2

func _process(delta):
	wave_elapsed_time += delta
	watchdog_timer += delta
	if watchdog_timer >= 1.2:
		watchdog_timer = 0.0
		_enforce_wave_watchdog()

func _enforce_wave_watchdog():
	if not is_inside_tree() or not get_tree():
		return
	
	var living: Array[Node] = []
	for z in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(z) and not z.get("is_dead"):
			if z.global_position.y < -4.0:
				if z.has_method("_on_died"):
					z._on_died()
				else:
					z.queue_free()
				continue
			living.append(z)
			
	zombies_alive = living.size()
	
	# If a zombie is stranded far away, return it to the playable area without
	# placing it directly beside the player.
	if not is_spawning_wave and wave_elapsed_time > 35.0 and living.size() <= 2 and player_ref:
		for z in living:
			if is_instance_valid(z) and z.global_position.distance_to(player_ref.global_position) > 18.0:
				var fwd = -player_ref.global_transform.basis.z.normalized()
				fwd.y = 0.0
				z.global_position = player_ref.global_position + fwd * 14.0 + Vector3(randf_range(-2, 2), 0.05, randf_range(-2, 2))
				
	# If wave completed or hit absolute maximum duration timeout (only after 4.0s grace period)
	if not is_spawning_wave and not is_wave_ending and wave_elapsed_time >= 4.0 and (zombies_alive <= 0 or wave_elapsed_time > 75.0):
		if wave_elapsed_time > 75.0 and not living.is_empty():
			for z in living:
				if is_instance_valid(z) and z.has_method("_on_died"):
					z._on_died()
		_check_wave_end()

func start_next_wave():
	is_wave_ending = false
	is_spawning_wave = true
	current_wave += 1
	wave_elapsed_time = 0.0
	var total_waves = mission.wave_count if mission else 3
	if is_endless_mode:
		total_waves = 0  # Signal infinite mode to HUD
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.wave_started.emit(current_wave, total_waves)
	
	# Check if structured waves are defined in mission (not in endless)
	if not is_endless_mode and mission and not mission.waves.is_empty() and current_wave <= mission.waves.size():
		var wave_data = mission.waves[current_wave - 1]
		var groups = wave_data.get("groups", [])
		zombies_to_spawn = 0
		for g in groups:
			zombies_to_spawn += g.get("count", 1)
		spawn_structured_wave(groups)
		return
	
	if not is_endless_mode and mission and mission.objective_type == MissionData.ObjectiveType.BOSS_KILL:
		zombies_to_spawn = max(1, mission.target_count)
		spawn_wave()
		return
	
	# Endless or dynamic wave scaling
	if is_endless_mode:
		var base = mission.endless_base_count if mission else 8
		var sc = mission.endless_scale_per_wave if mission else 5
		# Keep later rounds tense without letting wave size grow into a long, slow grind.
		zombies_to_spawn = mini(base + (current_wave * sc), 32)
	else:
		# Controlled campaign ramp: readable opening, then a measured rise in pressure.
		zombies_to_spawn = _get_campaign_wave_budget()
		
		var mission_mgr = get_node_or_null("/root/MissionManager")
		if mission and mission.objective_type == MissionData.ObjectiveType.KILL_COUNT and mission_mgr:
			var remaining = mission.target_count - mission_mgr.kill_count
			zombies_to_spawn = mini(zombies_to_spawn, maxi(remaining, 0))
		
		if zombies_to_spawn <= 0 and not (mission and mission.objective_type == MissionData.ObjectiveType.KILL_COUNT):
			zombies_to_spawn = _get_campaign_wave_budget()
	
	spawn_wave()

func _resolve_wave_variety(base_arch: String, wave: int) -> String:
	# Keep authored enemy roles intact; only vary groups authored as walkers.
	if base_arch in ["boss", "dog", "heavy", "fast", "spitter"]:
		return base_arch
		
	match wave:
		1:
			# WAVE 1 QUALITY: Walkers & Photorealistic Decayed Civilians
			return "realistic" if randf() < 0.5 else "normal"
		2:
			# Introduce runners gradually instead of making the whole wave a rush.
			var r = randf()
			if r < 0.65:
				return "normal"
			elif r < 0.92:
				return "fast"
			elif r < 0.97:
				return "dog"
			return "spitter"
		_:
			# Later waves add special enemies without replacing every walker.
			var r = randf()
			if r < 0.18:
				return "heavy"
			elif r < 0.43:
				return "fast"
			elif r < 0.50:
				return "spitter"
			return "realistic" if randf() < 0.5 else "normal"

func spawn_structured_wave(groups: Array):
	is_spawning_wave = true
	var base_total = 0
	for g in groups:
		base_total += g.get("count", 1)
	var wave_budget = _get_campaign_wave_budget()
	if mission and mission.objective_type == MissionData.ObjectiveType.KILL_COUNT:
		var mission_mgr = get_node_or_null("/root/MissionManager")
		if mission_mgr:
			wave_budget = mini(wave_budget, maxi(mission.target_count - mission_mgr.kill_count, 0))
	if wave_budget <= 0:
		is_spawning_wave = false
		return
	var scale_factor = minf(1.0, float(wave_budget) / float(max(1, base_total)))
	var total_count := 0
	for group in groups:
		total_count += maxi(1, int(round(float(group.get("count", 1)) * scale_factor)))
	var spawned_count = 0
	var boss_spawned = false

	for group in groups:
		if not is_inside_tree():
			return
		var base_arch = group.get("enemy_type", "normal")
		var raw_count = group.get("count", 1)
		var count = maxi(1, int(round(float(raw_count) * scale_factor)))
		var dir = group.get("spawn_direction", "")
		var delay = group.get("delay", 0.8) * 1.15
		for i in range(count):
			while zombies_alive >= max_active_zombies:
				if not is_inside_tree() or not get_tree():
					return
				await get_tree().create_timer(0.6).timeout
				if not is_inside_tree():
					return
					
			var arch = _resolve_wave_variety(base_arch, current_wave)
			# Guarantee 1 Boss in Wave 3 near the end if not already spawned
			if current_wave >= 3 and not boss_spawned and spawned_count >= total_count - 2:
				arch = "boss"
				boss_spawned = true
				
			spawn_zombie(arch, dir)
			spawned_count += 1
			
			if delay > 0 and (i < count - 1 or group != groups.back()):
				if not is_inside_tree() or not get_tree():
					return
				await get_tree().create_timer(delay).timeout
				if not is_inside_tree():
					return
	is_spawning_wave = false
	if zombies_alive <= 0 and wave_elapsed_time >= 4.0:
		_check_wave_end()

func spawn_wave():
	is_spawning_wave = true
	var count = zombies_to_spawn
	var special_spawned = false
	var endless_special := ""
	if is_endless_mode:
		if current_wave % 10 == 0:
			endless_special = "boss"
		elif current_wave % 5 == 0:
			endless_special = "heavy"
	var spawned_so_far = 0
	
	while spawned_so_far < count:
		if not is_inside_tree() or not get_tree():
			return
			
		# Throttle spawning if max active reached
		while zombies_alive >= max_active_zombies:
			if not is_inside_tree() or not get_tree():
				return
			await get_tree().create_timer(0.6).timeout
		# One readable spawn at a time avoids unfair instant crowding on touch screens.
		if mission and mission.objective_type == MissionData.ObjectiveType.BOSS_KILL:
			spawn_zombie("boss", "SpawnFront")
		elif endless_special != "" and not special_spawned and spawned_so_far >= count - 2:
			spawn_zombie(endless_special, "SpawnFront" if endless_special == "boss" else "")
			special_spawned = true
		elif not is_endless_mode and current_wave >= 3 and not special_spawned and spawned_so_far >= count - 2:
			spawn_zombie("boss", "SpawnFront")
			special_spawned = true
		else:
			spawn_zombie()
		spawned_so_far += 1
		
		if spawned_so_far < count:
			if not is_inside_tree() or not get_tree():
				return
			await get_tree().create_timer(1.35).timeout
			
	is_spawning_wave = false
	if zombies_alive <= 0 and wave_elapsed_time >= 4.0:
		_check_wave_end()

func spawn_zombie(specific_archetype: String = "", direction: String = ""):
	if spawn_points.is_empty() or not zombie_scene:
		return
		
	if not player_ref and get_tree():
		player_ref = get_tree().get_first_node_in_group("player")
	var player_pos = player_ref.global_position if player_ref else Vector3.ZERO
	
	# Authored points sit roughly 8.5-16m from the starting player. The former
	# 14m cutoff rejected nearly every point on early missions and forced every
	# zombie onto the single farthest marker.
	var safe_points: Array[Node3D] = []
	var farthest_point: Node3D = null
	var farthest_distance := -1.0
	for sp in spawn_points:
		if not sp:
			continue
		var distance = sp.global_position.distance_to(player_pos)
		if distance > farthest_distance:
			farthest_distance = distance
			farthest_point = sp
		if distance >= MIN_SPAWN_DISTANCE:
			safe_points.append(sp)
	var point_pool: Array[Node3D] = safe_points.duplicate()
	if point_pool.is_empty() and farthest_point:
		point_pool.append(farthest_point)

	var candidate_points: Array[Node3D] = []
	if direction != "":
		for sp in point_pool:
			if sp and sp.name.to_lower().contains(direction.to_lower()):
				candidate_points.append(sp)
	if candidate_points.is_empty():
		candidate_points = point_pool.duplicate()
				
	# Prioritize spawn points in front of the player (within shooter's viewcone)
	if player_ref and not candidate_points.is_empty():
		var fwd = -player_ref.global_transform.basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()
		var in_front: Array[Node3D] = []
		for sp in candidate_points:
			if sp:
				var to_sp = (sp.global_position - player_pos)
				to_sp.y = 0.0
				if to_sp.length() > 0.1 and to_sp.normalized().dot(fwd) > -0.1:
					in_front.append(sp)
		if not in_front.is_empty():
			candidate_points = in_front
		else:
			for sp in point_pool:
				if sp:
					var to_sp = (sp.global_position - player_pos)
					to_sp.y = 0.0
					if to_sp.length() > 0.1 and to_sp.normalized().dot(fwd) > -0.1:
						in_front.append(sp)
			if not in_front.is_empty():
				candidate_points = in_front
			
	var spawn_point = candidate_points.pick_random() if not candidate_points.is_empty() else farthest_point
	var spawn_pos: Vector3 = Vector3.ZERO
	if spawn_point:
		spawn_pos = spawn_point.global_position
	elif player_ref:
		var fwd = -player_ref.global_transform.basis.z.normalized()
		fwd.y = 0.0
		spawn_pos = player_ref.global_position + fwd * 14.0 + Vector3(randf_range(-1.5, 1.5), 0.0, randf_range(-1, 1))
	else:
		spawn_pos = Vector3(randf_range(-1.5, 1.5), 0.0, -14.0)

	# Scatter each spawn in a shallow fan and stagger its depth. This breaks up
	# the single-file look while keeping the horde inside the authored encounter.
	var forward := Vector3.FORWARD
	var right := Vector3.RIGHT
	if player_ref:
		forward = -player_ref.global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		right = player_ref.global_transform.basis.x
		right.y = 0.0
		right = right.normalized()
	spawn_pos += right * randf_range(-SPAWN_LANE_JITTER, SPAWN_LANE_JITTER)
	spawn_pos += forward * randf_range(-SPAWN_DEPTH_JITTER, SPAWN_DEPTH_JITTER)
	spawn_pos.y = 0.05
	# Keep spawns within the playable corridor without squeezing side markers
	# back into the same narrow center lane.
	spawn_pos.x = clamp(spawn_pos.x, -MAX_SPAWN_CORRIDOR_X, MAX_SPAWN_CORRIDOR_X)
	if player_ref:
		var player_to_spawn: Vector3 = spawn_pos - player_pos
		player_to_spawn.y = 0.0
		if player_to_spawn.length() < MIN_SPAWN_DISTANCE:
			if player_to_spawn.length() < 0.01:
				player_to_spawn = forward
			spawn_pos = player_pos + player_to_spawn.normalized() * MIN_SPAWN_DISTANCE
			spawn_pos.y = 0.05

	var arch = specific_archetype if specific_archetype != "" else _pick_archetype()
	var zombie = null
	if arch == "dog":
		var dog_res = load("res://scenes/zombies/InfectedDog.tscn")
		if dog_res is PackedScene:
			zombie = dog_res.instantiate()
	elif arch == "boss":
		var boss_res = load("res://scenes/zombies/BossZombie.tscn")
		if boss_res is PackedScene:
			zombie = boss_res.instantiate()
	if not zombie:
		if zombie_scene:
			zombie = zombie_scene.instantiate()
		else:
			var default_z_res = load("res://scenes/zombies/Zombie.tscn")
			if default_z_res is PackedScene:
				zombie = default_z_res.instantiate()
	if not zombie:
		return
	if "archetype" in zombie:
		zombie.archetype = arch
	add_child(zombie)
	if not zombie.is_in_group("zombies"):
		zombie.add_to_group("zombies")
	if is_endless_mode:
		_apply_endless_scaling(zombie)
	zombie.global_position = spawn_pos
	
	zombies_alive += 1
	zombie.tree_exited.connect(_on_zombie_death)
	print("[%d ms] [WAVE:SPAWN] Wave %d: Spawned %s at %s (Alive: %d)" % [Time.get_ticks_msec(), current_wave, arch, str(spawn_pos), zombies_alive])

func _apply_endless_scaling(zombie: Node3D):
	var hp_mult = 1.0 + mini(current_wave - 1, 50) * 0.08
	var dmg_mult = clamp(1.0 + (current_wave - 1) * 0.06, 1.0, 3.0)
	var spd_mult = clamp(1.0 + (current_wave - 1) * 0.015, 1.0, 1.45)
	
	if "health_component" in zombie and zombie.health_component:
		zombie.health_component.max_health = round(zombie.health_component.max_health * hp_mult)
		zombie.health_component.current_health = zombie.health_component.max_health
	elif "health" in zombie:
		zombie.health = round(zombie.health * hp_mult)
	if "attack_damage" in zombie:
		zombie.attack_damage = round(zombie.attack_damage * dmg_mult)
	if "move_speed" in zombie:
		zombie.move_speed = zombie.move_speed * spd_mult

func _pick_archetype() -> String:
	var rand = randf()
	var cumulative_weight = 0.0
	if not is_endless_mode and mission and not mission.spawn_config.is_empty():
		for entry in mission.spawn_config:
			cumulative_weight += entry.weight
			if rand <= cumulative_weight:
				return entry.type
	
	# Endless mode escalation
	if is_endless_mode:
		# Dogs start at wave 3
		if current_wave >= 3 and randf() < 0.20:
			return "dog"
		# Spitters start at wave 6
		if current_wave >= 6 and randf() < 0.25:
			return "spitter"
		# Heavy from wave 4
		if current_wave >= 4 and randf() < 0.25:
			return "heavy"
		# Fast from wave 2
		if current_wave >= 2 and randf() < 0.35:
			return "fast"
		return "normal"
	
	# Campaign ramp: mostly walkers, with special enemies introduced in measured numbers.
	if current_wave >= 3:
		var r = randf()
		if r < 0.12:
			return "heavy"
		elif r < 0.37:
			return "fast"
		elif r < 0.45:
			return "spitter"
		return "realistic" if randf() < 0.5 else "normal"
	elif current_wave == 2:
		var r = randf()
		if r < 0.68:
			return "normal"
		elif r < 0.93:
			return "fast"
		elif r < 0.97:
			return "dog"
		return "spitter"
	else:
		# WAVE 1: INFECTED CIVILIANS & SCARY WALKERS (Tension, Headshots & Distinct Decayed Humans)
		var r = randf()
		if r < 0.50:
			return "normal"
		else:
			return "realistic"

func _on_enemy_killed_event(_archetype: String, _is_headshot: bool, _pos: Vector3):
	call_deferred("_check_living_zombies")

func _check_living_zombies():
	if not is_inside_tree() or not get_tree():
		return
	var living_count = 0
	for z in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(z) and not z.get("is_dead"):
			living_count += 1
	zombies_alive = living_count
	if not is_spawning_wave and not is_wave_ending and wave_elapsed_time >= 4.0 and zombies_alive <= 0:
		_check_wave_end()

func _on_zombie_death():
	_check_living_zombies()

func _check_wave_end():
	if not is_inside_tree() or not get_tree():
		return
	if is_wave_ending:
		return
	is_wave_ending = true
	
	# Pro-type cinematic bullet-time on wave clear
	_trigger_bullet_time(1.2)
	
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		mission_mgr.on_wave_completed()
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.wave_completed.emit(current_wave)
		
	if not mission:
		is_wave_ending = false
		return
	
	# Endless mode: always continue to next wave
	if is_endless_mode and endless_active:
		await get_tree().create_timer(wave_delay).timeout
		if is_inside_tree():
			start_next_wave()
		return
		
	var total_waves = mission.wave_count if mission else 3
	if current_wave < total_waves:
		if mission_mgr and mission_mgr.get("_is_finishing") == true:
			return
		await get_tree().create_timer(wave_delay).timeout
		if is_inside_tree() and (not mission_mgr or not mission_mgr.get("_is_finishing")):
			start_next_wave()
	else:
		is_wave_ending = false
		if mission_mgr and not mission_mgr.get("_is_finishing") and mission_mgr.current_mission != null:
			mission_mgr.finish_mission(true)

func _trigger_bullet_time(duration_real: float = 1.2):
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_slowmo_enter"):
		audio.play_slowmo_enter()
		
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(Engine, "time_scale", 0.25, 0.12).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(duration_real, false, false, true).timeout
	
	if audio and audio.has_method("play_slowmo_exit"):
		audio.play_slowmo_exit()
		
	var tw_exit = create_tween()
	tw_exit.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_exit.tween_property(Engine, "time_scale", 1.0, 0.2).set_ease(Tween.EASE_IN)

func _exit_tree():
	Engine.time_scale = 1.0
