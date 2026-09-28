extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D
@onready var fps_arms: Node3D = $Camera3D/FPSArms
@onready var weapon_manager: Node3D = $Camera3D/WeaponManager
@onready var aim_raycast: RayCast3D = $Camera3D/RayCast3D
@onready var hud: CanvasLayer = $HUD
@onready var anim_player = get_node_or_null("AnimationPlayer")
@onready var sfx_footstep = get_node_or_null("SfxFootstep")

signal gameplay_ready
var is_gameplay_ready: bool = false

@export var sensitivity: float = 0.048
@export var aim_sensitivity: float = 0.024
@export var invert_y: bool = false
@export var min_pitch: float = -65.0
@export var max_pitch: float = 65.0

@export var move_speed: float = 4.8
@export var is_stationary: bool = false # Free movement enabled (WASD + virtual joystick)
@export var acceleration: float = 24.0
@export var deceleration: float = 32.0
@export var move_limit: float = 12.0
@export var sway_amount: float = 0.04
@export var bob_speed: float = 8.5
@export var bob_amount: float = 0.022
@export var breathing_speed: float = 1.8
@export var breathing_amount: float = 0.006

var virtual_move: Vector2 = Vector2.ZERO
var shake_intensity: float = 0.0
var shake_fade: float = 5.0
var time: float = 0.0
var step_timer: float = 0.0
var camera_kick: float = 0.0

var max_health: float = 250.0
var current_health: float = 250.0
var is_dead: bool = false
var is_firing: bool = false
var is_aiming: bool = false
var is_tactical_reloading: bool = false
var damage_cooldown: float = 0.0
@export var auto_pilot: bool = false # AI Combat Pilot (Plays the game automatically)

var weapon_prefab: PackedScene = preload("res://scenes/weapons/Weapon.tscn")
var weapon_configs = [
	{
		"id": "negev_ng7", 
		"path": "res://resources/weapons/negev_ng7.tres", 
		"model": "res://scenes/weapons/models/negev_ng7.scn",
		"offset": Vector3(0.04, -0.07, 0.06),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(0.048, 0.048, 0.048)
	},
	{
		"id": "akx_scifi", 
		"path": "res://resources/weapons/akx_scifi.tres", 
		"model": "res://scenes/weapons/models/akx_scifi.scn",
		"offset": Vector3(-0.05, -0.22, 0.18),
		"rot": Vector3(1.5, 181.5, 0.0),
		"scale": Vector3(0.85, 0.85, 0.85)
	},
	{
		"id": "car_smg", 
		"path": "res://resources/weapons/car_smg.tres", 
		"model": "res://scenes/weapons/models/car_smg.scn",
		"offset": Vector3(-0.02, -0.08, 0.05),
		"rot": Vector3(94.0, 27.0, 12.0),
		"scale": Vector3(1.0, 1.0, 1.0)
	},
	{
		"id": "grenade_mk2", 
		"path": "res://resources/weapons/grenade_mk2.tres", 
		"model": "res://scenes/weapons/models/grenade_mk2.scn",
		"offset": Vector3(-0.03, -0.02, 0.0),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(1.2, 1.2, 1.2)
	},
	{
		"id": "primordium_vandal", 
		"path": "res://resources/weapons/primordium_vandal.tres", 
		"model": "res://scenes/weapons/models/primordium_vandal.scn",
		"offset": Vector3(-0.03, 0.02, -0.05),
		"rot": Vector3(1.0, 1.5, 0.0),
		"scale": Vector3(0.85, 0.85, 0.85)
	},
	{
		"id": "prowler_smg", 
		"path": "res://resources/weapons/prowler_smg.tres", 
		"model": "res://scenes/weapons/models/prowler_smg.scn",
		"offset": Vector3(-0.16, 1.4, 0.28),
		"rot": Vector3(1.0, 1.5, 0.0),
		"scale": Vector3(0.038, 0.038, 0.038)
	},
	{
		"id": "ray_gun_cod", 
		"path": "res://resources/weapons/ray_gun_cod.tres", 
		"model": "res://scenes/weapons/models/ray_gun_cod.scn",
		"offset": Vector3(-0.04, -0.18, 0.05),
		"rot": Vector3(1.0, 1.5, 0.0),
		"scale": Vector3(0.35, 0.35, 0.35)
	},
	{
		"id": "rocket_launcher", 
		"path": "res://resources/weapons/rocket_launcher.tres", 
		"model": "res://scenes/weapons/models/rocket_launcher.scn",
		"offset": Vector3(-0.04, 0.02, -0.18),
		"rot": Vector3(0.0, -88.5, 0.0),
		"scale": Vector3(0.75, 0.75, 0.75)
	},
	{
		"id": "pestilence_handgun", 
		"path": "res://resources/weapons/pestilence_handgun.tres", 
		"model": "res://scenes/weapons/models/pestilence_handgun.scn",
		"offset": Vector3(-0.04, -0.01, 0.02),
		"rot": Vector3(0.0, -88.5, 0.0),
		"scale": Vector3(0.008, 0.008, 0.008)
	},
	{
		"id": "arcade_gun", 
		"path": "res://resources/weapons/arcade_gun.tres", 
		"model": "res://scenes/weapons/models/arcade_gun.scn",
		"offset": Vector3(-0.05, -0.02, 0.0),
		"rot": Vector3(0.0, -88.5, 0.0),
		"scale": Vector3(0.09, 0.09, 0.09)
	},
	{
		"id": "retro_ray_gun", 
		"path": "res://resources/weapons/retro_ray_gun.tres", 
		"model": "res://scenes/weapons/models/retro_ray_gun.scn",
		"offset": Vector3(-0.04, -0.28, 0.05),
		"rot": Vector3(0.0, 180.0, 0.0),
		"scale": Vector3(4.8, 4.8, 4.8)
	},
	{
		"id": "prowl_blaster", 
		"path": "res://resources/weapons/prowl_blaster.tres", 
		"model": "res://scenes/weapons/models/prowl_blaster.scn",
		"offset": Vector3(-0.04, 0.02, 0.0),
		"rot": Vector3(90.0, 0.0, 0.0),
		"scale": Vector3(42.0, 42.0, 42.0)
	},
	{
		"id": "vaccinator_energy", 
		"path": "res://resources/weapons/vaccinator_energy.tres", 
		"model": "res://scenes/weapons/models/vaccinator_energy.scn",
		"offset": Vector3(-0.02, -0.15, 0.0),
		"basis": Basis(Vector3(-1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, -1.0)),
		"scale": Vector3(0.0093, 0.0093, 0.0093)
	},
	{
		"id": "axon_cannon", 
		"path": "res://resources/weapons/axon_cannon.tres", 
		"model": "res://scenes/weapons/models/axon_cannon.scn",
		"offset": Vector3(-0.04, -0.26, 0.0),
		"rot": Vector3(6.0, 87.0, -6.0),
		"scale": Vector3(2.4, 2.4, 2.4)
	}
]
var weapons: Array = []
var current_weapon_index: int = 0

func _get_autoload(autoload_name: String) -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/" + autoload_name)
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null(autoload_name)
	return null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_init_character_models()
	_init_casing_pool()
	_init_weapons()
	if not anim_player:
		anim_player = find_child("AnimationPlayer", true, false)
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")

	if OS.get_cmdline_args().has("--ai-play") or OS.get_cmdline_user_args().has("--ai-play"):
		auto_pilot = true
		print("[PLAYER] Auto-Pilot enabled via command line flag.")

	if get_tree():
		await get_tree().process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	_update_hud()
	
	var save_mgr = _get_autoload("SaveManager")
	if save_mgr and save_mgr.data.has("settings"):
		var st = save_mgr.data.settings
		if st.has("sensitivity"):
			var s_val = float(st.sensitivity)
			sensitivity = 0.048 if s_val >= 0.08 else s_val
		if st.has("aim_sensitivity"):
			var a_val = float(st.aim_sensitivity)
			aim_sensitivity = 0.024 if a_val >= 0.05 else a_val
		if st.has("invert_y"):
			invert_y = bool(st.invert_y)
			
	var mission_mgr = _get_autoload("MissionManager")
	var game_state_mgr = _get_autoload("GameStateManager")
	
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.GAMEPLAY)
		
	if hud and is_instance_valid(hud):
		hud.update_health(current_health, max_health)
		if save_mgr and save_mgr.data.has("cash"):
			hud.update_cash(save_mgr.data.cash)
			
	if mission_mgr and mission_mgr.current_mission and hud and is_instance_valid(hud):
		hud.update_objective(mission_mgr.current_mission.display_name, "Eliminate " + str(mission_mgr.current_mission.target_count) + " Zombies")
		if not mission_mgr.mission_completed.is_connected(_on_mission_completed):
			mission_mgr.mission_completed.connect(_on_mission_completed)
			
	is_gameplay_ready = true
	gameplay_ready.emit()
	print("[%d ms] [PLAYER] Gameplay & Arsenal Ready! (Weapons: %d)" % [Time.get_ticks_msec(), weapons.size()])

func _extract_mesh_from_scene(packed_scene: PackedScene) -> Mesh:
	if not packed_scene: return null
	var inst = packed_scene.instantiate()
	var mesh_nodes = inst.find_children("*", "MeshInstance3D", true, false)
	var result_mesh: Mesh = null
	if not mesh_nodes.is_empty() and mesh_nodes[0].mesh:
		result_mesh = mesh_nodes[0].mesh
	inst.free()
	return result_mesh

func _init_character_models():
	if has_node("PlayerBody/MeshInstance3D"):
		var soldier_res = load("res://assets/3d/characters/player_soldier.glb")
		if soldier_res is PackedScene:
			var sm = _extract_mesh_from_scene(soldier_res)
			if sm:
				$PlayerBody/MeshInstance3D.mesh = sm
				$PlayerBody/MeshInstance3D.material_override = null
		$PlayerBody/MeshInstance3D.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

	if fps_arms:
		var arms_res = load("res://scenes/weapons/models/fps_arms.tscn")
		if arms_res is PackedScene:
			if fps_arms.has_node("MeshInstance3D"):
				fps_arms.get_node("MeshInstance3D").visible = false
			for c in fps_arms.get_children():
				if c.name == "CombatArmsModel":
					c.queue_free()
			var arms_inst = arms_res.instantiate()
			arms_inst.name = "CombatArmsModel"
			arms_inst.position = Vector3.ZERO
			fps_arms.add_child(arms_inst)

func _init_casing_pool():
	if not has_node("CasingPool"):
		var pool_script = preload("res://scenes/weapons/CasingPool.gd")
		var pool = pool_script.new()
		pool.name = "CasingPool"
		add_child(pool)

func _init_weapons():
	for child in weapon_manager.get_children():
		child.queue_free()
	weapons.clear()

	var save_mgr = _get_autoload("SaveManager")
	var unlocked_ids = save_mgr.data.unlocked_weapons if save_mgr and save_mgr.data.has("unlocked_weapons") else ["negev_ng7", "akx_scifi", "car_smg", "grenade_mk2", "primordium_vandal", "prowler_smg", "ray_gun_cod", "rocket_launcher", "pestilence_handgun", "arcade_gun", "retro_ray_gun", "prowl_blaster", "vaccinator_energy", "axon_cannon"]
	for cfg in weapon_configs:
		if not cfg.id in unlocked_ids:
			unlocked_ids.append(cfg.id)

	# We will dynamically build the list from unlocked IDs
	var all_possible_weapons = weapon_configs.duplicate()

	for cfg in all_possible_weapons:
		if not cfg.id in unlocked_ids:
			continue
		# Prevent loading duplicate alias weapons
		var already_have = false
		for w_inst in weapons:
			if w_inst.weapon_data:
				var wid = w_inst.weapon_data.weapon_id
				if wid == cfg.id:
					already_have = true
					break
				if (wid in ["pistol", "usp45"]) and (cfg.id in ["pistol", "usp45"]):
					already_have = true
					break
				if (wid in ["rifle", "m4a1"]) and (cfg.id in ["rifle", "m4a1"]):
					already_have = true
					break
				if (wid in ["shotgun", "remington870"]) and (cfg.id in ["shotgun", "remington870"]):
					already_have = true
					break
		if already_have:
			continue

		var w = weapon_prefab.instantiate()
		var w_res = load(cfg.path)
		if "weapon_data" in w:
			w.weapon_data = w_res
		if "aim_raycast" in w:
			w.aim_raycast = aim_raycast
		weapon_manager.add_child(w)
		
		# Set 3D model on weapon
		if w.has_node("MeshInstance3D"):
			w.get_node("MeshInstance3D").visible = false
		var model_res = load(cfg.model) if ResourceLoader.exists(cfg.model) else null
		if model_res is PackedScene:
			var model_inst = model_res.instantiate()
			model_inst.name = "WeaponModel"
			if cfg.has("basis"):
				model_inst.transform.basis = cfg.basis
			elif cfg.has("rot"):
				model_inst.rotation_degrees = cfg.rot
			if cfg.has("scale"):
				model_inst.scale = cfg.scale
			if cfg.has("offset"):
				model_inst.position = cfg.offset
			else:
				model_inst.position = Vector3.ZERO
			w.add_child(model_inst)
		elif model_res is Mesh and w.has_node("MeshInstance3D"):
			w.get_node("MeshInstance3D").mesh = model_res
			w.get_node("MeshInstance3D").visible = true
			
		w.ammo_changed.connect(func(_c, _m): _update_hud())
		if w.has_signal("weapon_reload_started"):
			w.weapon_reload_started.connect(func(rt): _reload_arms(rt))
			
		var w_anims = w.find_children("*", "AnimationPlayer", true, false)
		if not w_anims.is_empty():
			var w_ap: AnimationPlayer = w_anims[0]
			w.fired.connect(func(_id):
				if w_ap.has_animation("SHOOT"):
					w_ap.stop()
					w_ap.play("SHOOT")
			)
			if w.has_signal("weapon_reload_started"):
				w.weapon_reload_started.connect(func(_rt):
					if w_ap.has_animation("RELOAD1"):
						w_ap.play("RELOAD1")
				)
		weapons.append(w)
		print("[PLAYER] Spawned weapon: ", w.weapon_data.display_name if w.weapon_data else "no_data")

	print("[PLAYER] Total weapons initialized: ", weapons.size())
	current_weapon_index = 0
	if save_mgr and save_mgr.has_method("get_equipped_weapon"):
		var eq_id = save_mgr.get_equipped_weapon()
		for i in range(weapons.size()):
			if weapons[i].weapon_data and (weapons[i].weapon_data.weapon_id == eq_id or 
				(eq_id in ["pistol", "usp45"] and weapons[i].weapon_data.weapon_id in ["pistol", "usp45"]) or
				(eq_id in ["rifle", "m4a1"] and weapons[i].weapon_data.weapon_id in ["rifle", "m4a1"]) or
				(eq_id in ["shotgun", "remington870"] and weapons[i].weapon_data.weapon_id in ["shotgun", "remington870"])):
				current_weapon_index = i
				break
	_apply_active_weapon()


func _apply_active_weapon():
	for i in range(weapons.size()):
		var is_active = (i == current_weapon_index)
		weapons[i].visible = is_active
		if not is_active:
			if weapons[i].has_method("cancel_reload"):
				weapons[i].cancel_reload()
		else:
			weapons[i].apply_upgrades()
			if not weapons[i].is_reloading:
				weapons[i].can_shoot = true
				if weapons[i].current_ammo == 0 and weapons[i].has_method("reload"):
					weapons[i].reload()
	if fps_arms and weapon_manager:
		fps_arms.position.y = -0.36
		weapon_manager.position.y = -0.36
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(fps_arms, "position:y", -0.18, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(weapon_manager, "position:y", -0.18, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# Tactical weapon draw sound
		var sfx_draw = get_node_or_null("SfxWeaponDraw")
		if not sfx_draw:
			sfx_draw = AudioStreamPlayer.new()
			sfx_draw.name = "SfxWeaponDraw"
			sfx_draw.bus = "SFX"
			sfx_draw.volume_db = -1.5
			add_child(sfx_draw)
			if ResourceLoader.exists("res://audio/weapons/sfx_reload_slide.wav"):
				sfx_draw.stream = load("res://audio/weapons/sfx_reload_slide.wav")
		if sfx_draw and sfx_draw.stream:
			sfx_draw.pitch_scale = randf_range(1.15, 1.30)
			sfx_draw.play()
		
		var arms_model = fps_arms.get_node_or_null("CombatArmsModel")
		if arms_model:
			var active_w = get_current_weapon()
			var wid = active_w.weapon_data.weapon_id if (active_w and active_w.weapon_data) else ""
			var arms_inst = arms_model.get_node_or_null("ArmsModel")
			if arms_inst:
				match wid:
					"minigun", "heavy_m134":
						arms_inst.position = Vector3(-0.16, -0.09, 0.12)
						arms_inst.rotation_degrees = Vector3(5, 6, 2)
					"pistol", "usp45", "desert_eagle", "deagle":
						arms_inst.position = Vector3(-0.17, -0.06, 0.15)
						arms_inst.rotation_degrees = Vector3(2, 0, 0)
					_:
						arms_inst.position = Vector3(-0.18, -0.05, 0.12)
						arms_inst.rotation_degrees = Vector3(0, 0, 0)
			var r_hand = arms_model.get_node_or_null("RightHand")
			var l_hand = arms_model.get_node_or_null("LeftHand")
			if r_hand and l_hand:
				match wid:
					"minigun", "heavy_m134":
						r_hand.position = Vector3(0.08, -0.14, -0.02)
						r_hand.rotation_degrees = Vector3(25, -120, -50)
						l_hand.position = Vector3(-0.04, -0.08, -0.20)
						l_hand.rotation_degrees = Vector3(-20, 45, 35)
					"pistol", "usp45", "desert_eagle", "deagle":
						r_hand.position = Vector3(0.0, -0.08, 0.0)
						r_hand.rotation_degrees = Vector3(10, -115, -60)
						l_hand.position = Vector3(-0.02, -0.09, -0.03)
						l_hand.rotation_degrees = Vector3(5, -100, -50)
					_:
						r_hand.position = Vector3(0.04, -0.10, 0.02)
						r_hand.rotation_degrees = Vector3(10, -115, -60)
						l_hand.position = Vector3(0.015, -0.075, -0.18)
						l_hand.rotation_degrees = Vector3(-15, 60, 50)
	_update_hud()

func switch_weapon():
	if weapons.is_empty() or is_dead:
		return
	current_weapon_index = (current_weapon_index + 1) % weapons.size()
	_apply_active_weapon()

func switch_to_weapon(index: int):
	if index >= 0 and index < weapons.size() and not is_dead:
		current_weapon_index = index
		_apply_active_weapon()

func get_current_weapon():
	if current_weapon_index >= 0 and current_weapon_index < weapons.size():
		return weapons[current_weapon_index]
	return null

func set_virtual_movement(vec: Vector2):
	virtual_move = vec

var _smooth_look: Vector2 = Vector2.ZERO

func rotate_camera(rot_x: float, rot_y: float):
	if is_dead: return
	var delta_vec = Vector2(rot_x, rot_y)
	var len = delta_vec.length()
	
	# Micro-jitter deadzone filter (< 1.2 px) - completely eliminates finger tremor
	if len < 1.2:
		return
		
	var effective_len = len - 1.2
	var dir_norm = delta_vec / len
	
	# Silky smooth precision curve:
	# Fine aiming adjustments (< 6px): 0.25x to 0.55x multiplier for rock-solid headshot holding
	# Tracking adjustments (6-18px): smooth 0.55x to 0.95x
	# Fast turning (> 18px): up to 1.35x for swift 180° awareness
	var dynamic_curve: float
	if effective_len < 6.0:
		dynamic_curve = lerp(0.25, 0.55, effective_len / 6.0)
	elif effective_len < 18.0:
		dynamic_curve = lerp(0.55, 0.95, (effective_len - 6.0) / 12.0)
	else:
		dynamic_curve = clampf(0.95 + (effective_len - 18.0) * 0.02, 0.95, 1.35)
		
	var current_sens = (aim_sensitivity if is_aiming else sensitivity) * dynamic_curve
	var target_delta = dir_norm * effective_len * current_sens
	
	# Exponential smoothing filter to prevent sharp discrete jumps
	_smooth_look = _smooth_look.lerp(target_delta, 0.65) if _smooth_look.length_squared() > 0.001 else target_delta
	
	var pitch_mult = -1.0 if invert_y else 1.0
	rotate_y(deg_to_rad(-_smooth_look.x))
	camera.rotate_x(deg_to_rad(_smooth_look.y * pitch_mult))
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	# Responsive weapon sway
	var sway = deg_to_rad(-_smooth_look.x * sway_amount)
	weapon_manager.rotation.y = lerp(weapon_manager.rotation.y, sway, 0.15)
	if fps_arms:
		fps_arms.rotation.y = lerp(fps_arms.rotation.y, sway, 0.15)

func apply_kick(amount: float):
	camera_kick += amount
	camera.rotate_x(deg_to_rad(amount))
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _input(event):
	if is_dead or get_tree().paused: return

	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			if event.pressed and not event.echo:
				start_fire()
			elif not event.pressed:
				stop_fire()
		elif event.keycode == KEY_G and event.pressed and not event.echo:
			throw_grenade()
		elif event.pressed:
			if event.keycode == KEY_1:
				switch_to_weapon(0)
			elif event.keycode == KEY_2:
				switch_to_weapon(1)
			elif event.keycode == KEY_3:
				switch_to_weapon(2)
			elif event.keycode == KEY_R:
				_trigger_reload()
			elif event.keycode == KEY_E:
				switch_to_weapon((current_weapon_index + 1) % weapons.size())
			elif event.keycode == KEY_Q:
				switch_to_weapon((current_weapon_index - 1 + weapons.size()) % weapons.size())
			elif event.keycode == KEY_B:
				auto_pilot = not auto_pilot
				print("[PLAYER] AI Auto-Pilot toggled: ", auto_pilot)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_aiming = event.pressed
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				switch_to_weapon((current_weapon_index + 1) % weapons.size())
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				switch_to_weapon((current_weapon_index - 1 + weapons.size()) % weapons.size())

func start_fire():
	is_firing = true
	_trigger_shoot()

func stop_fire():
	is_firing = false

func _trigger_shoot():
	if is_dead: return
	var weapon = get_current_weapon()
	if weapon and not weapon.is_reloading:
		if weapon.can_shoot or weapon.current_ammo == 0:
			weapon.shoot()
			var kick_factor = weapon.weapon_data.recoil if weapon.weapon_data else 1.0
			apply_shake(0.032 * kick_factor)
			apply_kick(-0.48 * kick_factor)
			_recoil_arms(kick_factor)
			_update_hud()
			if weapon.current_ammo <= 0 and not weapon.is_reloading:
				_trigger_reload()

func _trigger_reload():
	if is_dead: return
	var weapon = get_current_weapon()
	if weapon and not weapon.is_reloading:
		var r_time = weapon.reload_time if "reload_time" in weapon else 1.5
		weapon.reload()
		_reload_arms(r_time)
		_update_hud()

func _recoil_arms(factor: float = 1.0):
	if fps_arms:
		fps_arms.position.z += 0.026 * factor
		fps_arms.position.y += 0.008 * factor
		fps_arms.rotation.x += deg_to_rad(2.2 * factor)

func _reload_arms(duration: float = 1.5):
	if not fps_arms or not weapon_manager: return
	is_tactical_reloading = true
	var tw = create_tween()
	# Phase 1: drop and cant left
	tw.tween_property(weapon_manager, "position:y", -0.28, duration * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(weapon_manager, "rotation:z", deg_to_rad(14.0), duration * 0.25)
	tw.parallel().tween_property(fps_arms, "position:y", -0.28, duration * 0.25)
	tw.parallel().tween_property(fps_arms, "rotation:z", deg_to_rad(14.0), duration * 0.25)
	
	# Phase 2: mag insertion jerk
	tw.tween_interval(duration * 0.35)
	tw.tween_property(weapon_manager, "position:y", -0.25, 0.08)
	tw.parallel().tween_property(fps_arms, "position:y", -0.25, 0.08)
	
	# Phase 3: return to ready
	tw.tween_interval(duration * 0.15)
	tw.tween_property(weapon_manager, "position:y", -0.18, duration * 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(weapon_manager, "rotation:z", 0.0, duration * 0.25)
	tw.parallel().tween_property(fps_arms, "position:y", -0.18, duration * 0.25)
	tw.parallel().tween_property(fps_arms, "rotation:z", 0.0, duration * 0.25)
	tw.tween_callback(func(): is_tactical_reloading = false)

var grenade_prefab = preload("res://scenes/weapons/Grenade.tscn")
var last_grenade_time: float = 0.0

func throw_grenade():
	if is_dead or time - last_grenade_time < 3.0:
		return
	last_grenade_time = time
	if grenade_prefab:
		var g = grenade_prefab.instantiate()
		get_tree().current_scene.add_child(g)
		g.global_position = camera.global_position + (-camera.global_transform.basis.z * 1.5)
		if g is RigidBody3D:
			g.linear_velocity = (-camera.global_transform.basis.z * 15.0) + (Vector3.UP * 4.0)

func auto_aim(delta):
	if not is_inside_tree() or not get_tree():
		return
	var zombies: Array = []
	for z in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(z) and not zombies.has(z):
			zombies.append(z)
	for z in get_tree().get_nodes_in_group("zombie"):
		if is_instance_valid(z) and not zombies.has(z):
			zombies.append(z)
	var best_zombie = null
	var best_dot = 0.96 # Magnet threshold
	var best_aim_pos = Vector3.ZERO
	
	for z in zombies:
		if not is_instance_valid(z) or z.get("is_dead") == true: continue
		var aim_offset = Vector3(0, 0.4, 0) if (z.get("archetype") in ["dog", "rat", "rats"]) else Vector3(0, 1.2, 0)
		var z_head = z.get_node_or_null("HeadHitZone")
		var aim_pos = z_head.global_position if z_head else (z.global_position + aim_offset)
		var dir_to_z = (aim_pos - camera.global_position).normalized()
		var forward = -camera.global_transform.basis.z
		var dot = forward.dot(dir_to_z)
		if dot > best_dot:
			best_dot = dot
			best_zombie = z
			best_aim_pos = aim_pos
			
	if best_zombie:
		var current_transform = camera.global_transform
		var target_transform = current_transform.looking_at(best_aim_pos, Vector3.UP)
		var t = current_transform.interpolate_with(target_transform, 5.0 * delta)
		
		# Apply rotations back with proper pitch clamping
		var euler = t.basis.get_euler()
		rotation.y = euler.y
		camera.rotation.x = clamp(euler.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		camera.rotation.z = 0.0

func _handle_auto_pilot(delta):
	if not auto_pilot or is_dead or not is_inside_tree():
		return
		
	var living_zombies: Array = []
	for z in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(z) and not z.get("is_dead"):
			living_zombies.append(z)
			
	if living_zombies.is_empty():
		return
		
	# Find nearest living zombie
	var target_zombie = null
	var min_dist = 9999.0
	for z in living_zombies:
		var d = global_position.distance_to(z.global_position)
		if d < min_dist:
			min_dist = d
			target_zombie = z
			
	if not target_zombie or not is_instance_valid(target_zombie):
		return
		
	# Aim at head
	var z_head = target_zombie.get_node_or_null("HeadHitZone")
	var aim_offset = Vector3(0, 0.4, 0) if (target_zombie.get("archetype") in ["dog", "rat", "rats"]) else Vector3(0, 1.7, 0)
	var target_pos = z_head.global_position if z_head else (target_zombie.global_position + aim_offset)
	
	var dir_to_target = (target_pos - camera.global_position).normalized()
	var forward = -camera.global_transform.basis.z
	var dot = forward.dot(dir_to_target)
	
	# Smoothly rotate player and camera towards target head
	var target_tf = camera.global_transform.looking_at(target_pos, Vector3.UP)
	var t = camera.global_transform.interpolate_with(target_tf, 14.0 * delta)
	var euler = t.basis.get_euler()
	rotation.y = euler.y
	camera.rotation.x = clamp(euler.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	camera.rotation.z = 0.0
	
	# Fire when locked onto target
	if dot > 0.94:
		var w = get_current_weapon()
		if w and not w.is_reloading:
			if w.can_shoot:
				_trigger_shoot()
			elif w.current_ammo == 0:
				_trigger_reload()
	elif dot > 0.88 and min_dist < 5.0:
		_trigger_shoot()
		
	# Auto-reload if magazine empty
	var curr_w = get_current_weapon()
	if curr_w and curr_w.current_ammo == 0 and not curr_w.is_reloading:
		_trigger_reload()
		
	# Tactical movement / kiting
	if min_dist < 4.5:
		virtual_move.y = 1.0 # Back up
		virtual_move.x = 0.5 if (int(time * 2.0) % 2 == 0) else -0.5
	elif min_dist > 11.0:
		virtual_move.y = -0.7 # Advance
		virtual_move.x = 0.0
	else:
		virtual_move = Vector2.ZERO

func _physics_process(delta):
	if is_dead: return
	time += delta
	if damage_cooldown > 0.0:
		damage_cooldown -= delta
	elif current_health < max_health:
		current_health = min(max_health, current_health + 8.0 * delta)
		if hud:
			hud.update_health(current_health, max_health)
	
	if auto_pilot:
		_handle_auto_pilot(delta)

	
	# Continuous fire while FIRE button is held down (Dead Target mobile mechanic)
	if is_firing:
		var weapon = get_current_weapon()
		if weapon and not weapon.is_reloading and (weapon.can_shoot or weapon.current_ammo == 0):
			_trigger_shoot()
	
	# Movement calculation combining input axes and virtual joystick
	var move_input = Vector3.ZERO
	if not is_stationary:
		if Input.is_action_pressed("move_forward") or Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			move_input.z -= 1
		if Input.is_action_pressed("move_backward") or Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			move_input.z += 1
		if Input.is_action_pressed("move_left") or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			move_input.x -= 1
		if Input.is_action_pressed("move_right") or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			move_input.x += 1
			
		move_input.x += virtual_move.x
		move_input.z += virtual_move.y
	
	var is_moving = move_input.length() > 0.05
	if is_moving:
		if move_input.length() > 1.0:
			move_input = move_input.normalized()
		var move_dir = (global_transform.basis * move_input)
		move_dir.y = 0.0
		var target_vel = move_dir * move_speed
		# Smooth acceleration
		velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta)
		
		# Footstep sound
		step_timer -= delta
		if step_timer <= 0.0:
			if sfx_footstep:
				sfx_footstep.play()
			step_timer = 0.42
			
		if anim_player and anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		# Smooth deceleration
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)
		if anim_player and anim_player.current_animation != "idle":
			anim_player.play("idle")
			
	move_and_slide()
	
	# Boundary Clamping
	global_position.x = clamp(global_position.x, -move_limit, move_limit)
	global_position.z = clamp(global_position.z, -move_limit, move_limit)
	
	# Dynamic ADS FOV zoom
	var target_fov = 52.0 if is_aiming else 75.0
	camera.fov = lerp(camera.fov, target_fov, 12.0 * delta)

	# Figure-8 Lissajous breathing & walk sway
	var vel_ratio = clamp(velocity.length() / move_speed, 0.0, 1.0) if move_speed > 0.001 else 0.0
	var breath_x = sin(time * breathing_speed * 0.7) * breathing_amount * 0.7
	var breath_y = sin(time * breathing_speed * 1.4) * breathing_amount
	var walk_bob_x = cos(time * bob_speed * 0.5) * bob_amount * 0.6 * vel_ratio
	var walk_bob_y = sin(time * bob_speed) * bob_amount * (1.4 * vel_ratio if is_moving else 0.2)
	
	var base_x = 0.06 if is_aiming else 0.16
	var base_y = -0.12 if is_aiming else -0.15
	var target_bob_x = base_x + (breath_x + walk_bob_x) * (0.3 if is_aiming else 1.0)
	var target_bob_y = base_y + (breath_y + walk_bob_y) * (0.3 if is_aiming else 1.0)
	var target_roll = -deg_to_rad(virtual_move.x * 2.5)
	
	if not is_tactical_reloading:
		weapon_manager.position.x = lerp(weapon_manager.position.x, target_bob_x, 0.18)
		weapon_manager.position.y = lerp(weapon_manager.position.y, target_bob_y, 0.18)
		weapon_manager.rotation.x = lerp(weapon_manager.rotation.x, 0.0, 14.0 * delta)
		weapon_manager.rotation.y = lerp(weapon_manager.rotation.y, 0.0, 14.0 * delta)
		weapon_manager.rotation.z = lerp(weapon_manager.rotation.z, target_roll, 8.0 * delta)
		
		if fps_arms:
			fps_arms.position.x = lerp(fps_arms.position.x, target_bob_x, 0.18)
			fps_arms.position.y = lerp(fps_arms.position.y, target_bob_y, 0.18)
			fps_arms.position.z = lerp(fps_arms.position.z, -0.42, 14.0 * delta)
			fps_arms.rotation.x = lerp(fps_arms.rotation.x, 0.0, 14.0 * delta)
			fps_arms.rotation.y = lerp(fps_arms.rotation.y, 0.0, 14.0 * delta)
			fps_arms.rotation.z = lerp(fps_arms.rotation.z, target_roll, 8.0 * delta)
	
	# Camera shake recovery
	if shake_intensity > 0:
		camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		camera.v_offset = randf_range(-shake_intensity, shake_intensity)
		shake_intensity = lerp(shake_intensity, 0.0, shake_fade * delta)
	else:
		camera.h_offset = 0
		camera.v_offset = 0

	# Smooth camera recoil recovery
	if abs(camera_kick) > 0.005:
		var recover = camera_kick * 12.0 * delta
		camera.rotate_x(deg_to_rad(-recover))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		camera_kick -= recover
	else:
		camera_kick = 0.0

func apply_shake(intensity: float):
	shake_intensity = max(shake_intensity, intensity)

func _update_hud():
	if not hud: return
	var weapon = get_current_weapon()
	if weapon and weapon.weapon_data:
		var next_name = ""
		if weapons.size() > 1:
			var next_w = weapons[(current_weapon_index + 1) % weapons.size()]
			if next_w and next_w.weapon_data:
				next_name = next_w.weapon_data.display_name
		hud.update_ammo(weapon.current_ammo, weapon.max_ammo, weapon.weapon_data.display_name, next_name)
	hud.update_health(current_health, max_health)
	var save_mgr = _get_autoload("SaveManager")
	if save_mgr and save_mgr.data.has("cash"):
		hud.update_cash(save_mgr.data.cash)

func take_damage(amount: float):
	if is_dead: return
	if damage_cooldown > 0.0 and amount < current_health: return
	damage_cooldown = 0.60
	current_health = max(0.0, current_health - amount)
	apply_shake(0.08)
	if hud and hud.has_method("trigger_damage_effect"):
		hud.trigger_damage_effect(clamp(amount / 25.0, 0.8, 2.0))
	_update_hud()
	
	var event_bus = _get_autoload("EventBus")
	if event_bus:
		event_bus.player_health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		is_dead = true
		if anim_player and anim_player.has_animation("death"):
			anim_player.play("death")
		var audio_mgr = _get_autoload("AudioManager")
		if audio_mgr:
			audio_mgr.play_defeat()
		var mission_mgr = _get_autoload("MissionManager")
		if mission_mgr and mission_mgr.current_mission:
			mission_mgr.finish_mission(false)
		else:
			if hud:
				hud.update_objective("OUTCOME", "You were overrun")

func _on_mission_completed(_m):
	var audio_mgr = _get_autoload("AudioManager")
	if audio_mgr:
		audio_mgr.play_victory()
