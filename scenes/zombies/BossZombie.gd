class_name BossZombie
extends "res://scripts/Zombies/EnemyBase.gd"

@export var ground_slam_radius: float = 6.0
@export var ground_slam_damage: float = 28.0
@export var ground_slam_cooldown: float = 8.5

var slam_timer: float = 4.0
var is_slamming: bool = false
var has_enraged: bool = false

@onready var sfx_slam: AudioStreamPlayer3D = $SfxAttack
@onready var sfx_roar: AudioStreamPlayer3D = $SfxGrowl

func _init():
	super._init()
	archetype = "boss"
	move_speed = 1.1
	attack_range = 2.7
	attack_damage = 38.0
	attack_interval = 2.2
	reward_on_kill = 5000

func _ready():
	archetype = "boss"
	super._ready()
	_setup_boss_model()
	_setup_hit_zones()
	
	var max_hp = health_component.max_health if health_component else 35000.0
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("boss_spawned"):
		event_bus.boss_spawned.emit("TITAN MUTANT", max_hp)
		
	if get_tree():
		for h in get_tree().get_nodes_in_group("hud"):
			if h and h.has_method("show_boss_health"):
				h.show_boss_health("TITAN MUTANT", max_hp)
		
	# Find player and trigger camera screen shake on entrance
	var p = player
	if not p and get_tree():
		p = get_tree().get_first_node_in_group("player")
		if not p:
			p = get_tree().get_first_node_in_group("players")
	if not p and get_parent():
		p = get_parent().find_child("Player", true, false)
	if p and p.has_method("apply_shake"):
		p.apply_shake(0.42)
		
	# Initial roar (attenuated positional + unattenuated stinger on SFX bus)
	if sfx_roar:
		sfx_roar.play()
	var unattenuated_roar = AudioStreamPlayer.new()
	unattenuated_roar.stream = load("res://audio/zombies/sfx_boss_roar.wav")
	unattenuated_roar.bus = "SFX"
	unattenuated_roar.volume_db = 4.0
	add_child(unattenuated_roar)
	unattenuated_roar.play()
	unattenuated_roar.finished.connect(unattenuated_roar.queue_free)
	
	_play_anim("roar")

func _setup_boss_model():
	if not model_instance:
		model_instance = find_child("SkeletalModel", true, false)
	if model_instance:
		var anims = model_instance.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			active_anim_player = anims[0]
			active_anim_player.speed_scale = 1.0

	# Enable biohazard red/green emission veins across all meshes
	var meshes = find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		if not m or not m.mesh:
			continue
		for s in range(m.mesh.get_surface_count()):
			var mat = m.get_surface_override_material(s)
			if not mat:
				var active_mat = m.get_active_material(s)
				if active_mat:
					mat = active_mat.duplicate()
				else:
					mat = StandardMaterial3D.new()
			else:
				mat = mat.duplicate()
			if mat is StandardMaterial3D:
				mat.emission_enabled = true
				mat.emission = Color(1.0, 0.15, 0.05)
				mat.emission_energy_multiplier = 3.8
				mat.rim_enabled = true
				mat.rim = 1.0
				mat.rim_tint = 0.6
				m.set_surface_override_material(s, mat)

	# Chest OmniLight3D for glowing biohazard veins aura
	if not get_node_or_null("ChestLight"):
		var chest_light = OmniLight3D.new()
		chest_light.name = "ChestLight"
		chest_light.light_color = Color(1.0, 0.2, 0.05)
		chest_light.light_energy = 2.0
		chest_light.omni_range = 5.0
		chest_light.position = Vector3(0, 1.8, 0.3)
		add_child(chest_light)

func _setup_hit_zones():
	for child in get_children():
		if child is HitZone:
			child.parent_entity = self

func _physics_process(delta):
	if is_dead:
		return
		
	slam_timer -= delta
	
	# Check enrage at 50% HP
	if not has_enraged and health_component and health_component.current_health <= health_component.max_health * 0.5:
		has_enraged = true
		move_speed = 1.3
		attack_interval = 1.8
		if sfx_roar:
			sfx_roar.play()
		_play_anim("roar")
		
	# Special attack check: Ground Slam when player in proximity and cooldown ready
	if not is_slamming and slam_timer <= 0 and player:
		var dist = global_position.distance_to(player.global_position)
		if dist <= ground_slam_radius:
			_perform_ground_slam()
			return
			
	super._physics_process(delta)

func _perform_ground_slam():
	is_slamming = true
	slam_timer = ground_slam_cooldown
	velocity = Vector3.ZERO
	ai_state = AIState.ATTACK
	
	_play_anim("attack_windup")
	await get_tree().create_timer(0.6).timeout
	if is_dead:
		is_slamming = false
		return
		
	_play_anim("heavy_attack")
	if sfx_slam:
		sfx_slam.play()
		
	# Shockwave ground slam: radial damage & screen shake
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist <= ground_slam_radius:
			var falloff = clamp(1.0 - (dist / ground_slam_radius) * 0.5, 0.5, 1.0)
			if player.has_method("take_damage"):
				player.take_damage(ground_slam_damage * falloff)
			if player.has_method("apply_recoil"):
				player.apply_recoil(0.2)
				
	# Ground slam VFX dust / ring
	_spawn_slam_vfx()
	
	await get_tree().create_timer(0.8).timeout
	is_slamming = false
	if not is_dead:
		ai_state = AIState.CHASE

func _spawn_slam_vfx():
	var vfx = Node3D.new()
	vfx.name = "GroundSlamVFX"
	get_parent().add_child(vfx)
	vfx.global_position = global_position
	
	var mesh_inst = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.5
	torus.outer_radius = 1.0
	mesh_inst.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.4, 0.1, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.3, 0.05)
	mat.emission_energy_multiplier = 3.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_inst.material_override = mat
	vfx.add_child(mesh_inst)
	
	var tw = vfx.create_tween()
	tw.tween_property(mesh_inst, "scale", Vector3(ground_slam_radius, 1.0, ground_slam_radius), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.5)
	tw.tween_callback(vfx.queue_free)

func _on_health_changed(hp):
	var max_hp = health_component.max_health if health_component else 35000.0
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("boss_health_changed"):
		event_bus.boss_health_changed.emit(hp, max_hp)
		
	if get_tree():
		for h in get_tree().get_nodes_in_group("hud"):
			if h and h.has_method("update_boss_health"):
				h.update_boss_health(hp)

func _on_died():
	if is_dead: return
	is_dead = true
	ai_state = AIState.DEAD
	_remove_from_zombie_groups()
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	for child in get_children():
		if child is HitZone:
			for col in child.find_children("*", "CollisionShape3D", true, false):
				col.set_deferred("disabled", true)
				
	velocity = Vector3.ZERO
	_play_anim("death")
	
	if sfx_death:
		sfx_death.play()
		
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.enemy_killed.emit("boss", last_hit_was_headshot, global_position)
		if event_bus.has_signal("boss_health_changed"):
			event_bus.boss_health_changed.emit(0.0, health_component.max_health)
			
	if get_tree():
		for h in get_tree().get_nodes_in_group("hud"):
			if h and h.has_method("update_boss_health"):
				h.update_boss_health(0.0)
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.add_cash(int(round(reward_on_kill * last_hit_cash_multiplier)))
		
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		mission_mgr.on_boss_killed()
		
	await get_tree().create_timer(3.5).timeout
	queue_free()
