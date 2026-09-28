extends Node3D

const BlastVFX = preload("res://scripts/Objects/BlastVFX.gd")

@onready var raycast: RayCast3D = $RayCast3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_flash = $MuzzleFlash
@onready var muzzle_light = get_node_or_null("MuzzleLight")
@onready var fire_timer: Timer = $FireTimer
@onready var sfx_shoot = $SfxShoot
@onready var sfx_empty = $SfxEmpty
@onready var sfx_reload = $SfxReload
@onready var impact_pool = get_tree().get_first_node_in_group("impact_pool") if (is_inside_tree() and get_tree()) else null

@export var weapon_data: WeaponData
@export var recoil_rotation: float = 5.0

var damage: float
var fire_rate: float
var max_ammo: int
var reload_time: float
var current_ammo: int
var spread: float = 0.0
var pellet_count: int = 1
var recoil_kick: float = 1.0

var can_shoot: bool = true
var is_reloading: bool = false
var aim_raycast: RayCast3D = null

signal ammo_changed(current_ammo, max_ammo)
signal weapon_reloaded
signal weapon_reload_started(reload_time: float)
signal fired(weapon_id)

func _ready():
	apply_upgrades()
	current_ammo = max_ammo
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	if not fire_timer.timeout.is_connected(_on_fire_timer_timeout):
		fire_timer.timeout.connect(_on_fire_timer_timeout)
	var socket = find_child("MuzzleSocket", true, false)
	if socket:
		if muzzle_flash:
			muzzle_flash.global_position = socket.global_position
		if muzzle_light:
			muzzle_light.global_position = socket.global_position
	if muzzle_flash:
		muzzle_flash.hide()
	if muzzle_light:
		muzzle_light.visible = false
		muzzle_light.light_energy = 0.35
		muzzle_light.omni_range = 2.0
	
	_load_sound_set()

func _load_audio(base_path: String, fallback_path: String = "") -> AudioStream:
	if ResourceLoader.exists(base_path):
		var s = load(base_path)
		if s: return s
	var clean_path = base_path.trim_suffix(".wav").trim_suffix(".tres").trim_suffix(".ogg")
	var tres_path = clean_path + ".tres"
	var wav_path = clean_path + ".wav"
	var ogg_path = clean_path + ".ogg"
	if ResourceLoader.exists(tres_path):
		var s = load(tres_path)
		if s: return s
	if ResourceLoader.exists(wav_path):
		var s = load(wav_path)
		if s: return s
	if ResourceLoader.exists(ogg_path):
		var s = load(ogg_path)
		if s: return s
	if fallback_path != "" and ResourceLoader.exists(fallback_path):
		var s_fb = load(fallback_path)
		if s_fb: return s_fb
	return null

func _load_sound_set():
	if not weapon_data: return
	if not sfx_shoot: sfx_shoot = get_node_or_null("SfxShoot")
	if not sfx_empty: sfx_empty = get_node_or_null("SfxEmpty")
	if not sfx_reload: sfx_reload = get_node_or_null("SfxReload")
	if not sfx_shoot:
		sfx_shoot = AudioStreamPlayer.new()
		sfx_shoot.name = "SfxShoot"
		add_child(sfx_shoot)
	sfx_shoot.bus = "SFX"

	if not sfx_empty:
		sfx_empty = AudioStreamPlayer.new()
		sfx_empty.name = "SfxEmpty"
		add_child(sfx_empty)
	sfx_empty.bus = "SFX"

	if not sfx_reload:
		sfx_reload = AudioStreamPlayer.new()
		sfx_reload.name = "SfxReload"
		add_child(sfx_reload)
	sfx_reload.bus = "SFX"

	var snd = weapon_data.sound_set if weapon_data.sound_set != "" else weapon_data.weapon_id
	var w_id = weapon_data.weapon_id

	match w_id:
		# Heavy Machine Guns & Chainguns (NG7, Minigun)
		"negev_ng7", "minigun", "heavy_m134", "heavy_m134_minigun":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/minigun.ogg", "res://audio/weapons/sfx_minigun_shoot.wav")
		# High-Caliber Assault Rifles
		"akx_scifi", "ak74u", "ak74":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rifle.ogg", "res://audio/weapons/sfx_ak47_shoot.wav")
		"primordium_vandal", "flatline", "vk47_flatline":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rifle3.ogg", "res://audio/weapons/sfx_flatline_shoot.wav")
		# Tactical Submachine Guns
		"prowler_smg":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rifle2.ogg", "res://audio/weapons/sfx_mp5_shoot.wav")
		"car_smg", "car", "apex_car":
			sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_car_shoot.wav", "res://audio/weapons/downloaded/q009/rifle.ogg")
		# Explosives & Heavy Launchers
		"grenade_mk2":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/explosion.ogg", "res://audio/weapons/sfx_grenade_launcher_shoot.wav")
		"rocket_launcher":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rlauncher.ogg", "res://audio/weapons/downloaded/q009/explosion.ogg")
		"axon_cannon":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/glauncher3.ogg", "res://audio/weapons/downloaded/q009/rlauncher3.ogg")
		# Exotic Sci-Fi & Energy Weapons
		"ray_gun_cod":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/quaddamage_shoot.ogg", "res://audio/weapons/downloaded/q009/ren.ogg")
		"vaccinator_energy":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/teleport.ogg", "res://audio/weapons/downloaded/q009/ren3.ogg")
		"arcade_gun":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/ren2.ogg", "res://audio/weapons/sfx_pistol_shoot.wav")
		"retro_ray_gun":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/ren3.ogg", "res://audio/weapons/downloaded/q009/quaddamage_shoot.ogg")
		"prowl_blaster":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/ren.ogg", "res://audio/weapons/downloaded/q009/rifle2.ogg")
		# Hand Cannons & Pistols
		"pestilence_handgun", "deagle", "desert_eagle":
			sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_deagle_shoot.wav", "res://audio/weapons/sfx_pistol_shoot.wav")
		# Shotguns
		"hawk_shotgun", "hawk", "combat_shotgun", "shotgun", "remington870", "spas12":
			sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/shotgun.ogg", "res://audio/weapons/sfx_shotgun_shoot.wav")
		# Snipers
		"sniper", "awp_sniper", "vantage_sniper", "vantage", "awp":
			sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_sniper_shoot.wav", "res://audio/weapons/sfx_awp_shoot.wav")
		_:
			match snd:
				"pistol", "usp45":
					sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_pistol_shoot.wav")
				"rifle", "m4a1":
					sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rifle.ogg", "res://audio/weapons/sfx_rifle_shoot.wav")
				"shotgun", "remington870":
					sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/shotgun.ogg", "res://audio/weapons/sfx_shotgun_shoot.wav")
				"ak47", "ak74u":
					sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rifle.ogg", "res://audio/weapons/sfx_ak47_shoot.wav")
				"deagle", "desert_eagle":
					sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_deagle_shoot.wav", "res://audio/weapons/sfx_pistol_shoot.wav")
				"mp5":
					sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/rifle2.ogg", "res://audio/weapons/sfx_mp5_shoot.wav")
				"awp":
					sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_awp_shoot.wav", "res://audio/weapons/sfx_rifle_shoot.wav")
				"knife", "combat_knife":
					sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_knife_slash.wav")
				"crossbow":
					sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_crossbow_shoot.wav")
				"grenade_launcher":
					sfx_shoot.stream = _load_audio("res://audio/weapons/downloaded/q009/glauncher3.ogg", "res://audio/weapons/sfx_grenade_launcher_shoot.wav")
				_:
					sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_pistol_shoot.wav")
			
	sfx_empty.stream = _load_audio("res://audio/weapons/sfx_empty", "res://audio/weapons/sfx_empty.wav")
	
	# Mechanical reload sounds per weapon archetype
	match w_id:
		"shotgun", "remington870", "hawk_shotgun", "spas12":
			sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_shotgun", "res://audio/weapons/sfx_reload.wav")
		"sniper", "awp", "svd", "vantage_sniper":
			sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_bolt", "res://audio/weapons/sfx_reload.wav")
		"pistol", "usp45", "pestilence_handgun", "deagle", "desert_eagle":
			sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_slide", "res://audio/weapons/sfx_reload.wav")
		_:
			sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_mag", "res://audio/weapons/sfx_reload.wav")
	
	if not sfx_reload.stream:
		sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload", "res://audio/weapons/sfx_reload.wav")


func apply_upgrades():
	if not weapon_data: return
	
	var save_mgr = get_node_or_null("/root/SaveManager") if is_inside_tree() else null
	var levels = {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0}
	if save_mgr and save_mgr.data.has("weapon_upgrades"):
		var w_id = weapon_data.weapon_id
		if save_mgr.data.weapon_upgrades.has(w_id):
			levels = save_mgr.data.weapon_upgrades[w_id]
		elif w_id == "pistol" and save_mgr.data.weapon_upgrades.has("usp45"):
			levels = save_mgr.data.weapon_upgrades["usp45"]
		elif w_id == "usp45" and save_mgr.data.weapon_upgrades.has("pistol"):
			levels = save_mgr.data.weapon_upgrades["pistol"]
		elif w_id == "rifle" and save_mgr.data.weapon_upgrades.has("m4a1"):
			levels = save_mgr.data.weapon_upgrades["m4a1"]
		elif w_id == "m4a1" and save_mgr.data.weapon_upgrades.has("rifle"):
			levels = save_mgr.data.weapon_upgrades["rifle"]
		elif w_id == "shotgun" and save_mgr.data.weapon_upgrades.has("remington870"):
			levels = save_mgr.data.weapon_upgrades["remington870"]
		elif w_id == "remington870" and save_mgr.data.weapon_upgrades.has("shotgun"):
			levels = save_mgr.data.weapon_upgrades["shotgun"]
		
	damage = weapon_data.get_damage(levels.get("damage", 0))
	fire_rate = weapon_data.base_fire_rate
	max_ammo = weapon_data.get_mag_size(levels.get("mag", 0))
	reload_time = weapon_data.get_reload_time(levels.get("reload", 0))
	if weapon_data.has_method("get_spread"):
		spread = weapon_data.get_spread(levels.get("accuracy", 0))
	else:
		spread = weapon_data.spread
	pellet_count = max(1, weapon_data.pellet_count)
	recoil_kick = weapon_data.recoil

func shoot():
	if not can_shoot or is_reloading:
		return
	
	var is_knife = weapon_data and (weapon_data.weapon_id == "combat_knife" or weapon_data.sound_set == "knife")
	
	if current_ammo <= 0 and not is_knife:
		if sfx_empty: sfx_empty.play()
		if not is_reloading:
			reload()
		return
		
	if is_knife:
		current_ammo = 1
	else:
		current_ammo -= 1
		if current_ammo == 0:
			reload()
		
	can_shoot = false
	if fire_timer:
		fire_timer.wait_time = fire_rate
		fire_timer.start()
	ammo_changed.emit(current_ammo, max_ammo)
	fired.emit(weapon_data.weapon_id if weapon_data else "")
	
	if is_inside_tree():
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus:
			event_bus.weapon_fired.emit(weapon_data.weapon_id if weapon_data else "", current_ammo, max_ammo)
	
	# Synchronized Pipeline Execution:
	# 1. Visual & Audio Flash in lockstep
	muzzle_flash_fx()
	if sfx_shoot:
		var wid = weapon_data.weapon_id if weapon_data else ""
		if wid in ["rocket_launcher", "axon_cannon", "grenade_mk2"] or (weapon_data and weapon_data.sound_set == "grenade_launcher"):
			sfx_shoot.pitch_scale = randf_range(0.90, 0.98)
			sfx_shoot.volume_db = 9.5
		elif wid in ["negev_ng7", "primordium_vandal", "pestilence_handgun", "akx_scifi", "minigun", "heavy_m134", "heavy_m134_minigun"]:
			sfx_shoot.pitch_scale = randf_range(0.93, 1.01)
			sfx_shoot.volume_db = 8.5
		else:
			sfx_shoot.pitch_scale = randf_range(0.95, 1.03)
			sfx_shoot.volume_db = 7.5
		sfx_shoot.play()
	
	# 2. Viewmodel Recoil
	apply_recoil()
	
	# 3. Bullet Casing Ejection
	eject_casing()
	
	# 4. Physics Raycast & Hit Resolution
	_fire_projectiles()

func _fire_projectiles():
	var target_ray = aim_raycast if aim_raycast else raycast
	if not target_ray:
		return
		
	var world_3d = get_world_3d()
	if not world_3d or not world_3d.direct_space_state:
		return
	var space_state = world_3d.direct_space_state
	var ray_origin = target_ray.global_position
	var base_forward = -target_ray.global_transform.basis.z.normalized()
	var ray_range = weapon_data.range if weapon_data else 100.0
	var damage_per_pellet = damage / float(pellet_count) if pellet_count > 1 else damage
	
	var total_hit_enemy = false
	var had_headshot = false

	for p in range(pellet_count):
		# Apply spread cone
		var spread_offset = Vector3.ZERO
		if spread > 0.0001:
			spread_offset = (target_ray.global_transform.basis.x * randf_range(-spread, spread) +
							 target_ray.global_transform.basis.y * randf_range(-spread, spread))
		
		var ray_dir = (base_forward + spread_offset).normalized()
		var ray_target = ray_origin + (ray_dir * ray_range)
		
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
		query.exclude = [self, get_parent()]
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		var end_pt = ray_target
		if result:
			var hit_collider = result.collider
			var hit_point = result.position
			var hit_normal = result.normal
			end_pt = hit_point
			
			var impact_type = "concrete"
			
			# Check HitZone first
			if hit_collider is HitZone:
				var res = hit_collider.take_hit(damage_per_pellet, ray_dir)
				total_hit_enemy = true
				if res.is_headshot:
					had_headshot = true
				impact_type = "blood"
			elif hit_collider and (hit_collider is ExplosiveBarrel or hit_collider.is_in_group("explosives")):
				hit_collider.take_damage(damage_per_pellet, false, ray_dir)
				impact_type = "concrete"
			elif hit_collider and hit_collider.has_method("take_damage"):
				var is_head = false
				var final_dmg = damage_per_pellet
				var mult = weapon_data.headshot_multiplier if weapon_data else 2.0
				# Head detection: top segment
				if hit_point.y > hit_collider.global_position.y + 1.2:
					final_dmg *= mult
					is_head = true
					had_headshot = true
				hit_collider.take_damage(final_dmg, is_head, ray_dir)
				total_hit_enemy = true
				impact_type = "blood"
			
			# Explosive area damage for Grenade Launcher
			if weapon_data and (weapon_data.weapon_id == "grenade_launcher" or weapon_data.sound_set == "grenade_launcher"):
				_apply_area_explosion(hit_point, damage)
				impact_type = "concrete"
			
			_spawn_impact(impact_type, hit_point, hit_normal)
		elif p == 0 and target_ray.is_colliding():
			# Target raycast fallback
			var col = target_ray.get_collider()
			var pt = target_ray.get_collision_point()
			var norm = target_ray.get_collision_normal()
			end_pt = pt
			var impact_type = "concrete"
			if col and (col is ExplosiveBarrel or col.is_in_group("explosives")):
				col.take_damage(damage, false, base_forward)
				impact_type = "concrete"
			elif col and col.has_method("take_damage"):
				var is_head = (pt.y > col.global_position.y + 1.2)
				var final_dmg = damage * (weapon_data.headshot_multiplier if (is_head and weapon_data) else 1.0)
				col.take_damage(final_dmg, is_head, base_forward)
				total_hit_enemy = true
				if is_head: had_headshot = true
				impact_type = "blood"
			if weapon_data and (weapon_data.weapon_id == "grenade_launcher" or weapon_data.sound_set == "grenade_launcher"):
				_apply_area_explosion(pt, damage)
			_spawn_impact(impact_type, pt, norm)
	
	if total_hit_enemy:
		var hud_node = get_tree().get_first_node_in_group("hud")
		if not hud_node:
			var player_node = get_tree().get_first_node_in_group("player")
			if player_node and "hud" in player_node:
				hud_node = player_node.hud
		if hud_node and hud_node.has_method("show_hitmarker"):
			hud_node.show_hitmarker(had_headshot)
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus:
			event_bus.damage_dealt.emit(damage, had_headshot, "head" if had_headshot else "body", null)

func _apply_area_explosion(epicenter: Vector3, blast_dmg: float):
	if not is_inside_tree() or not get_tree():
		return
	var blast_radius: float = 7.0
	var world := get_tree().current_scene as Node3D
	if world:
		BlastVFX.spawn(world, epicenter, blast_radius, Color(1.0, 0.48, 0.14, 0.96))
	var zombies: Array = []
	for z in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(z) and not zombies.has(z):
			zombies.append(z)
	for z in get_tree().get_nodes_in_group("zombie"):
		if is_instance_valid(z) and not zombies.has(z):
			zombies.append(z)
	for z in zombies:
		if is_instance_valid(z) and z.has_method("take_damage"):
			var dist = z.global_position.distance_to(epicenter)
			if dist <= blast_radius:
				var falloff = 1.0 - (dist / blast_radius)
				var applied_dmg = blast_dmg * max(0.2, falloff)
				var dir = (z.global_position - epicenter).normalized()
				z.take_damage(applied_dmg, false, dir, 0.5)

func _spawn_impact(type: String, pos: Vector3, normal: Vector3):
	if not impact_pool and is_inside_tree() and get_tree():
		impact_pool = get_tree().get_first_node_in_group("impact_pool")
	if impact_pool:
		impact_pool.spawn_impact(type, pos, normal)

var reload_timer: SceneTreeTimer = null

func reload():
	if is_reloading or current_ammo == max_ammo:
		return
		
	var is_knife = weapon_data and (weapon_data.weapon_id == "combat_knife" or weapon_data.sound_set == "knife")
	if is_knife:
		current_ammo = 1
		ammo_changed.emit(current_ammo, max_ammo)
		weapon_reloaded.emit()
		return
		
	is_reloading = true
	sfx_reload.play()
	weapon_reload_started.emit(reload_time)
	var cur_timer = get_tree().create_timer(reload_time)
	reload_timer = cur_timer
	await cur_timer.timeout
	if reload_timer == cur_timer and is_reloading:
		current_ammo = max_ammo
		is_reloading = false
		can_shoot = true
		reload_timer = null
		ammo_changed.emit(current_ammo, max_ammo)
		weapon_reloaded.emit()
		
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus:
			event_bus.weapon_reloaded.emit(weapon_data.weapon_id if weapon_data else "")

func cancel_reload():
	if is_reloading:
		is_reloading = false
		reload_timer = null
		can_shoot = true
		if sfx_reload and sfx_reload.playing:
			sfx_reload.stop()

func muzzle_flash_fx():
	if weapon_data and weapon_data.muzzle_fx == "none":
		return
	if muzzle_light:
		muzzle_light.visible = true
		var wid = weapon_data.weapon_id if weapon_data else ""
		match wid:
			"ray_gun_cod", "retro_ray_gun":
				muzzle_light.light_color = Color(0.2, 1.0, 0.45) # Neon Green
				muzzle_light.light_energy = 6.0
				muzzle_light.omni_range = 7.5
			"plasma_gun", "vaccinator_energy", "axon_cannon":
				muzzle_light.light_color = Color(0.2, 0.75, 1.0) # Cyan / Electric Blue
				muzzle_light.light_energy = 6.5
				muzzle_light.omni_range = 8.0
			"rocket_launcher", "grenade_mk2":
				muzzle_light.light_color = Color(1.0, 0.45, 0.1) # Fire Orange
				muzzle_light.light_energy = 8.5
				muzzle_light.omni_range = 10.0
			_:
				muzzle_light.light_color = Color(1.0, 0.85, 0.45) # Warm Gold Amber
				muzzle_light.light_energy = 5.5
				muzzle_light.omni_range = 7.0
	if muzzle_flash:
		if muzzle_flash.has_method("play_flash"):
			muzzle_flash.play_flash()
		else:
			muzzle_flash.show()
			if muzzle_flash is GPUParticles3D:
				muzzle_flash.restart()
				muzzle_flash.emitting = true
	if not is_inside_tree() or not get_tree():
		return
	await get_tree().create_timer(0.06).timeout
	if muzzle_light:
		muzzle_light.visible = false
	if muzzle_flash and not muzzle_flash.has_method("play_flash"):
		muzzle_flash.hide()

func apply_recoil():
	var kick = recoil_kick
	position.z = 0.038 * kick # Gun kicks back 3.8 cm
	position.y = 0.010 * kick # Gun rises 1 cm
	rotation.x = deg_to_rad(3.6 * kick) # Gun climbs 3.6 degrees
	rotation.z = deg_to_rad(randf_range(-1.2, 1.2) * kick) # slight roll
	rotation.y = deg_to_rad(randf_range(-0.6, 0.6) * kick) # slight yaw

func eject_casing():
	if not is_inside_tree() or not get_tree():
		return
	if weapon_data and (weapon_data.weapon_id in ["combat_knife", "crossbow", "grenade_launcher", "grenade_mk2", "rocket_launcher", "ray_gun_cod", "retro_ray_gun", "arcade_gun", "vaccinator_energy", "axon_cannon"]):
		return
		
	var casing_pool = get_tree().get_first_node_in_group("casing_pool")
	if not casing_pool:
		return
		
	var c_type = "rifle"
	if weapon_data:
		var wid = weapon_data.weapon_id
		match wid:
			"shotgun", "remington870", "hawk_shotgun", "spas12":
				c_type = "shotgun"
			"pestilence_handgun", "pistol", "usp45", "desert_eagle", "deagle":
				c_type = "pistol"
			_:
				c_type = "rifle"
				
	var start_pos = global_position + global_transform.basis.x * 0.08 + global_transform.basis.y * 0.03 - global_transform.basis.z * 0.10
	var player = get_tree().get_first_node_in_group("player")
	var floor_y = player.global_position.y if player else (global_position.y - 1.4)
	casing_pool.spawn_casing(c_type, start_pos, global_transform.basis, floor_y)
	
func _process(delta):
	var recover_speed = 18.0 * delta
	position.z = lerp(position.z, 0.0, recover_speed)
	position.y = lerp(position.y, 0.0, recover_speed)
	rotation.x = lerp(rotation.x, 0.0, recover_speed)
	rotation.y = lerp(rotation.y, 0.0, recover_speed)
	rotation.z = lerp(rotation.z, 0.0, recover_speed)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(visible)

func _on_fire_timer_timeout():
	can_shoot = true
