class_name DrivableCar
extends VehicleBody3D

@export var max_engine_force: float = 16000.0
@export var max_brake_force: float = 95.0
@export var handbrake_force: float = 180.0
@export var max_steer_angle: float = 0.50
@export var steer_speed: float = 6.5

@export_group("4x4 Mountain Climbing Physics")
@export var suspension_rest_len: float = 0.28
@export var suspension_trav: float = 0.38
@export var suspension_stiff: float = 35.0
@export var wheel_rad: float = 0.44
@export var custom_com: Vector3 = Vector3(0.0, -0.32, -0.20)
@export var crawl_base_force: float = 8000.0

@export_group("Speed & Physics Limits")
@export var max_top_speed_kmh: float = 190.0 # Realistic sports car cruise top speed
@export var nitro_top_speed_kmh: float = 230.0 # Realistic nitro top speed

@export_group("Vehicle Health & Damage")
@export var max_health: float = 650.0
var current_health: float = 650.0
var is_destroyed: bool = false
@export var max_nitro: float = 100.0
@export var nitro_boost_force: float = 14000.0
var current_nitro: float = 100.0
var is_boosting: bool = false
var _was_boosting: bool = false
var nitro_exhaust_l: CPUParticles3D = null
var nitro_exhaust_r: CPUParticles3D = null

var _physics_helper: RefCounted = null

var touch_steer: float = 0.0
var touch_throttle: float = 0.0
var touch_boost: bool = false
var touch_handbrake: bool = false

var is_occupied: bool = false
var player_ref: Node3D = null
var current_steer: float = 0.0
var speed_kmh: float = 0.0
var current_speed_kmh: float = 0.0
var cam_orbit_h: float = 0.0
var cam_orbit_v: float = 0.0

@onready var wheel_fl: VehicleWheel3D = get_node_or_null("WheelFL")
@onready var wheel_fr: VehicleWheel3D = get_node_or_null("WheelFR")
@onready var wheel_bl: VehicleWheel3D = get_node_or_null("WheelBL")
@onready var wheel_br: VehicleWheel3D = get_node_or_null("WheelBR")

@onready var engine_audio: AudioStreamPlayer3D = get_node_or_null("EngineAudio")
@onready var impact_audio: AudioStreamPlayer3D = get_node_or_null("ImpactAudio")
@onready var horn_audio: AudioStreamPlayer3D = get_node_or_null("HornAudio")
@onready var chase_camera: Camera3D = get_node_or_null("ChaseCamera") if has_node("ChaseCamera") else get_node_or_null("SpringArm3D/ChaseCamera")
@onready var enter_prompt_ui: CanvasLayer = get_node_or_null("EnterPromptUI")
@onready var prompt_label: Label = get_node_or_null("EnterPromptUI/CenterContainer/PromptLabel")
@onready var exit_button: Button = get_node_or_null("DriveHUD/ExitButton")
@onready var drive_hud: CanvasLayer = get_node_or_null("DriveHUD")
@onready var speed_label: Label = get_node_or_null("DriveHUD/SpeedLabel")

@onready var headlight_left: SpotLight3D = get_node_or_null("HeadlightL")
@onready var headlight_right: SpotLight3D = get_node_or_null("HeadlightR")

var headlight_state: int = 1 # 0 = Off, 1 = On

var nearby_player: Node3D = null
var saved_player_layer: int = 1
var saved_player_mask: int = 1

func _ready():
	add_to_group("vehicles")
	mass = 1450.0
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = custom_com
	
	# 4x4 Off-Road Suspension Calibration
	for w in [wheel_fl, wheel_fr, wheel_bl, wheel_br]:
		if w:
			w.wheel_radius = wheel_rad
			if "wheel_rest_length" in w:
				w.wheel_rest_length = suspension_rest_len
			if "suspension_rest_length" in w:
				w.set("suspension_rest_length", suspension_rest_len)
			w.suspension_travel = suspension_trav
			w.suspension_stiffness = suspension_stiff
			w.suspension_max_force = 24000.0
			w.damping_compression = 2.0
			w.damping_relaxation = 2.8
			w.wheel_friction_slip = 8.5
			w.use_as_traction = true

	# Connect C# VehiclePhysicsHelper (.NET 8)
	var helper_script = load("res://scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs")
	if helper_script and helper_script.can_instantiate():
		_physics_helper = helper_script.new()
		
	# Setup Twin Exhaust Nitro Boost Flame Particles (Ultra-compact unshaded quads to prevent GPU fill-rate throttling)
	for offset_x in [-0.55, 0.55]:
		var emitter = CPUParticles3D.new()
		emitter.name = "NitroExhaust_" + ("L" if offset_x < 0 else "R")
		emitter.position = Vector3(offset_x, 0.28, 2.3)
		emitter.emitting = false
		emitter.amount = 3 # 3 quads per side: ultra-low fill rate
		emitter.lifetime = 0.05 # Short 0.05s lifetime keeps flame tight at tailpipe, never reaches chase camera
		emitter.direction = Vector3(0, 0.02, 1.0)
		emitter.spread = 2.0
		emitter.gravity = Vector3.ZERO
		emitter.initial_velocity_min = 3.0
		emitter.initial_velocity_max = 4.5
		emitter.scale_amount_min = 0.05
		emitter.scale_amount_max = 0.08
		
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		mat.disable_receive_shadows = true
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		mat.albedo_color = Color(0.2, 0.85, 1.0, 0.75)
		
		var quad = QuadMesh.new()
		quad.size = Vector2(0.06, 0.06)
		quad.material = mat
		emitter.mesh = quad
		emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(emitter)
		
		if offset_x < 0:
			nitro_exhaust_l = emitter
		else:
			nitro_exhaust_r = emitter
	
	if chase_camera:
		chase_camera.current = false
	if drive_hud:
		drive_hud.visible = false
	if enter_prompt_ui:
		enter_prompt_ui.visible = false
		
	# Setup headlights (shadows disabled for zero fill-rate overhead)
	if headlight_left:
		headlight_left.visible = false
		headlight_left.shadow_enabled = false
	if headlight_right:
		headlight_right.visible = false
		headlight_right.shadow_enabled = false
		
	_optimize_vehicle_meshes()
		
	# Connect door interaction
	var door_zone = get_node_or_null("DoorZone")
	if door_zone:
		if not door_zone.body_entered.is_connected(_on_door_body_entered):
			door_zone.body_entered.connect(_on_door_body_entered)
		if not door_zone.body_exited.is_connected(_on_door_body_exited):
			door_zone.body_exited.connect(_on_door_body_exited)
		
	# Connect bumper smash zone (Target Layer 2: enemies only; avoid costly Layer 1 trimesh queries)
	var smash_zone = get_node_or_null("SmashZone")
	if smash_zone:
		smash_zone.collision_mask = 2
		if not smash_zone.body_entered.is_connected(_on_smash_hit):
			smash_zone.body_entered.connect(_on_smash_hit)
		if not smash_zone.area_entered.is_connected(_on_smash_area_hit):
			smash_zone.area_entered.connect(_on_smash_area_hit)
		
	if exit_button:
		if not exit_button.pressed.is_connected(exit_vehicle):
			exit_button.pressed.connect(exit_vehicle)
		
	call_deferred("_check_initial_overlap")

func _check_initial_overlap():
	var door_zone = get_node_or_null("DoorZone")
	if door_zone:
		for b in door_zone.get_overlapping_bodies():
			if b.is_in_group("player"):
				_on_door_body_entered(b)
				break

func get_contact_wheel_count() -> int:
	var count = 0
	for w in [wheel_fl, wheel_fr, wheel_bl, wheel_br]:
		if w and w.is_in_contact():
			count += 1
	return count

func _is_car_grounded() -> bool:
	return get_contact_wheel_count() >= 2

func _can_apply_drive_force() -> bool:
	var contact_wheels = get_contact_wheel_count()
	# At speed or while boosting, require at least 2 wheels firmly planted on the ground
	if speed_kmh > 15.0 or is_boosting:
		return contact_wheels >= 2
	# At crawl speeds (rock climbing / unsticking), 1 wheel contact suffices
	return contact_wheels >= 1

func _physics_process(delta):
	# 1. Exact calibrated speed conversion from m/s to KM/H
	speed_kmh = linear_velocity.length() * 3.6
	current_speed_kmh = speed_kmh
	var contact_count = get_contact_wheel_count()
	var is_grounded = contact_count >= 2
	
	# 2. Strict realistic top speed clamp (cruise capped at 190 km/h, nitro capped at 230 km/h)
	# Absolutely prevents 918 KM/H runaway velocity under all conditions (jumping, rolling, falling, uphill/downhill)
	var max_allowed = nitro_top_speed_kmh if is_boosting else max_top_speed_kmh
	if speed_kmh > max_allowed:
		var max_allowed_ms = max_allowed / 3.6
		# Strictly clamp full 3D velocity vector to prevent runaway linear momentum
		linear_velocity = linear_velocity.normalized() * max_allowed_ms
		speed_kmh = max_allowed
		current_speed_kmh = max_allowed
		
	# Secondary horizontal velocity clamp to prevent lateral or forward sliding runaway
	var max_allowed_ms = max_allowed / 3.6
	var horiz_vel = Vector2(linear_velocity.x, linear_velocity.z)
	if horiz_vel.length() > max_allowed_ms:
		var clamped_h = horiz_vel.normalized() * max_allowed_ms
		linear_velocity.x = clamped_h.x
		linear_velocity.z = clamped_h.y
		
	# 3. Aerodynamic Downforce & Anti-Flip Curb/Barrier Stabilization
	if is_grounded:
		# Active roll & pitch stabilization against asymmetrical curb impacts and barrier scrapes
		if abs(angular_velocity.z) > 1.2:
			angular_velocity.z = move_toward(angular_velocity.z, 0.0, delta * 6.0)
		if abs(angular_velocity.x) > 1.5:
			angular_velocity.x = move_toward(angular_velocity.x, 0.0, delta * 6.0)
			
		# Gentle anti-rollover upright torque if tilted significantly while grounded
		var cur_up = transform.basis.y
		if cur_up.dot(Vector3.UP) < 0.88 and cur_up.dot(Vector3.UP) > 0.3:
			var roll_axis = cur_up.cross(Vector3.UP)
			if roll_axis.length_squared() > 0.001:
				apply_torque(roll_axis.normalized() * clampf(roll_axis.length() * 1800.0, 0.0, 3000.0))

		if speed_kmh > 15.0:
			# Downforce directed down through car chassis to maintain tire adhesion
			var down_dir = -transform.basis.y.normalized()
			# Only apply chassis downforce if car is right-side up
			if down_dir.dot(Vector3.DOWN) > 0.2:
				var downforce_mag = clampf(speed_kmh * 12.0, 0.0, 2400.0)
				apply_central_force(down_dir * downforce_mag)
	elif not is_grounded:
		# Airborne aerodynamic stabilization: damp roll & pitch, gently restore upright horizon
		angular_velocity.x = move_toward(angular_velocity.x, 0.0, delta * 4.0)
		angular_velocity.z = move_toward(angular_velocity.z, 0.0, delta * 4.0)
		
		# Gentle self-righting torque in mid-air to land upright on wheels
		var current_up = transform.basis.y
		var tilt_axis = current_up.cross(Vector3.UP)
		if tilt_axis.length_squared() > 0.005:
			apply_torque(tilt_axis.normalized() * clampf(tilt_axis.length() * 1200.0, 0.0, 2200.0))
			
		# High-speed airborne downforce prevents launching into space over crests
		if speed_kmh > 35.0:
			var air_downforce = clampf((speed_kmh / max_top_speed_kmh) * 2200.0, 0.0, 3200.0)
			apply_central_force(Vector3.DOWN * air_downforce)
	
	if is_occupied:
		if is_instance_valid(player_ref):
			player_ref.global_position = global_position
		_handle_driving_input(delta, speed_kmh, is_grounded)
		_update_engine_audio(speed_kmh)
		_update_smooth_camera(delta, speed_kmh)
		if speed_label:
			if is_boosting:
				speed_label.text = "⚡ NITRO BOOST: %d KM/H [%d%%]" % [int(speed_kmh), int(current_nitro)]
				if not _was_boosting:
					speed_label.add_theme_color_override("font_color", Color(0.1, 0.95, 1.0))
			else:
				speed_label.text = "%d KM/H  |  NITRO: %d%% [HOLD SHIFT]" % [int(speed_kmh), int(current_nitro)]
				if _was_boosting:
					speed_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		_was_boosting = is_boosting
	else:
		# Parked: Apply slight braking to prevent rolling away
		brake = 25.0
		engine_force = 0.0
		steering = move_toward(steering, 0.0, delta * steer_speed)
		if engine_audio and engine_audio.playing:
			engine_audio.stop()
		if chase_camera and chase_camera.top_level:
			chase_camera.top_level = false
			chase_camera.transform = Transform3D(Basis(), Vector3(0, 2.3, 5.8))
			
		# Check nearby player distance for prompt
		var tree = get_tree() if is_inside_tree() else null
		var p = tree.get_first_node_in_group("player") if tree else null
		if p and is_instance_valid(p):
			var dist = global_position.distance_to(p.global_position)
			if dist < 4.5:
				nearby_player = p
				if enter_prompt_ui and not enter_prompt_ui.visible:
					enter_prompt_ui.visible = true
					if prompt_label:
						prompt_label.text = "PRESS [F] TO DRIVE POLICE CRUISER"
			elif dist > 5.5 and nearby_player == p:
				nearby_player = null
				if enter_prompt_ui and enter_prompt_ui.visible:
					enter_prompt_ui.visible = false

func _update_smooth_camera(delta: float, cur_speed_kmh: float):
	if not chase_camera or not is_instance_valid(chase_camera):
		return
	if not chase_camera.top_level:
		chase_camera.top_level = true
		chase_camera.global_position = global_position + (-transform.basis.z * -6.5) + Vector3(0, 2.5, 0)
	
	# Desired position smoothly placed behind vehicle with upright horizon stabilization
	var fwd = -transform.basis.z.normalized()
	var horiz_fwd = Vector3(fwd.x, 0.0, fwd.z).normalized()
	if horiz_fwd.length_squared() < 0.01:
		horiz_fwd = Vector3.FORWARD
		
	# Apply mouse orbit offset if rotated
	var cam_dir = horiz_fwd.rotated(Vector3.UP, cam_orbit_h)
	
	var cam_dist = 6.2 + clampf(cur_speed_kmh / 80.0, 0.0, 1.8)
	var cam_height = 2.4 + clampf(cur_speed_kmh / 120.0, 0.0, 0.8) + sin(cam_orbit_v) * cam_dist * 0.5
	var target_cam_pos = global_position - cam_dir * cam_dist + Vector3(0, maxf(cam_height, 0.8), 0)
	
	# Smoothly track position with speed-adaptive responsiveness
	var lerp_weight = clampf(delta * (8.0 + (cur_speed_kmh / 40.0)), 0.0, 1.0)
	chase_camera.global_position = chase_camera.global_position.lerp(target_cam_pos, lerp_weight)
	
	# Aim camera smoothly at car center with upright horizon stabilization (Vector3.UP)
	var look_target = global_position + Vector3(0, 1.1, 0) + (cam_dir * 1.5)
	if chase_camera.is_inside_tree():
		chase_camera.look_at(look_target, Vector3.UP)
	else:
		chase_camera.look_at_from_position(chase_camera.global_position, look_target, Vector3.UP)
		
	# Lock camera offsets to eliminate jitter, sub-pixel churn, and temporal dirtying
	chase_camera.h_offset = 0.0
	chase_camera.v_offset = 0.0
	
	# Smooth return orbit to center when driving forward
	if cur_speed_kmh > 20.0 and abs(cam_orbit_h) > 0.01:
		cam_orbit_h = move_toward(cam_orbit_h, 0.0, delta * 1.5)
	if abs(cam_orbit_v) > 0.01:
		cam_orbit_v = move_toward(cam_orbit_v, 0.0, delta * 1.5)

func _handle_driving_input(delta: float, cur_speed_kmh: float, is_grounded: bool):
	# Steering
	var steer_target = 0.0
	if touch_steer != 0.0:
		steer_target = touch_steer * max_steer_angle
	elif Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		steer_target = max_steer_angle
	elif Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		steer_target = -max_steer_angle
		
	# High-speed steering stability
	var speed_steer_factor = clampf(1.0 - (cur_speed_kmh / 240.0), 0.35, 1.0)
	current_steer = move_toward(current_steer, steer_target * speed_steer_factor, delta * steer_speed)
	steering = current_steer

	# Throttle / Gas
	var throttle = 0.0
	if touch_throttle != 0.0:
		throttle = touch_throttle
	elif Input.is_action_pressed("move_forward") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		throttle = 1.0
	elif Input.is_action_pressed("move_backward") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		throttle = -0.75

	# Handbrake
	var is_handbrake = Input.is_key_pressed(KEY_SPACE) or touch_handbrake
	var can_drive = _can_apply_drive_force()
	
	if is_handbrake:
		brake = handbrake_force
		engine_force = 0.0
		# Drifting friction drop on rear wheels
		if wheel_bl: wheel_bl.wheel_friction_slip = 1.8
		if wheel_br: wheel_br.wheel_friction_slip = 1.8
	elif throttle > 0.0 and can_drive:
		brake = 0.0
		var forward_dir = -transform.basis.z
		
		# Smooth uphill climb assist
		var slope_pitch = forward_dir.y
		var hill_climb_mult = 1.0
		if slope_pitch > 0.04 and cur_speed_kmh < 50.0:
			hill_climb_mult = 1.8 + clampf(slope_pitch * 2.5, 0.0, 2.0)
			apply_central_force(forward_dir * (crawl_base_force * clampf(slope_pitch * 2.0, 0.0, 1.0)))
		
		# Progressive torque curve with realistic high-speed air drag
		var max_allowed = nitro_top_speed_kmh if is_boosting else max_top_speed_kmh
		var torque_mult = clampf(1.0 - (cur_speed_kmh / max_allowed), 0.0, 1.0)
		engine_force = throttle * max_engine_force * torque_mult * hill_climb_mult
		
		# Tire grip
		for w in [wheel_fl, wheel_fr, wheel_bl, wheel_br]:
			if w:
				w.wheel_friction_slip = 6.5
				
		# AAA Nitro Boost (Shift) - Ground contact verified via wheel checks (2+ wheels) before applying forward forces
		var wants_boost = (Input.is_key_pressed(KEY_SHIFT) or touch_boost) and current_nitro > 0.0 and is_grounded
		if wants_boost:
			is_boosting = true
			current_nitro = maxf(current_nitro - delta * 22.0, 0.0)
			if cur_speed_kmh < (nitro_top_speed_kmh - 1.0):
				var boost_scale = clampf(1.0 - (cur_speed_kmh / nitro_top_speed_kmh), 0.1, 1.0)
				apply_central_force(forward_dir * (nitro_boost_force * boost_scale))
			if chase_camera and chase_camera.fov != 77.0:
				chase_camera.fov = 77.0
			if nitro_exhaust_l and not nitro_exhaust_l.emitting: nitro_exhaust_l.emitting = true
			if nitro_exhaust_r and not nitro_exhaust_r.emitting: nitro_exhaust_r.emitting = true
		else:
			is_boosting = false
			current_nitro = minf(current_nitro + delta * 15.0, max_nitro)
			if chase_camera and chase_camera.fov != 75.0:
				chase_camera.fov = 75.0
			if nitro_exhaust_l and nitro_exhaust_l.emitting: nitro_exhaust_l.emitting = false
			if nitro_exhaust_r and nitro_exhaust_r.emitting: nitro_exhaust_r.emitting = false
	elif throttle < 0.0 and can_drive:
		is_boosting = false
		current_nitro = minf(current_nitro + delta * 15.0, max_nitro)
		if chase_camera and chase_camera.fov != 75.0:
			chase_camera.fov = 75.0
		if nitro_exhaust_l and nitro_exhaust_l.emitting: nitro_exhaust_l.emitting = false
		if nitro_exhaust_r and nitro_exhaust_r.emitting: nitro_exhaust_r.emitting = false
		
		# If moving forward fast, S acts as brake first, then reverse
		var fwd_dot = -transform.basis.z.dot(linear_velocity)
		if fwd_dot > 2.0:
			brake = max_brake_force * 3.0
			engine_force = 0.0
		else:
			brake = 0.0
			engine_force = throttle * max_engine_force * 0.65
	else:
		# Airborne or Coasting: NO forward engine force applied! Prevents wheel runaway in mid-air
		engine_force = 0.0
		brake = 4.0 if is_grounded else 0.0
		is_boosting = false
		current_nitro = minf(current_nitro + delta * 15.0, max_nitro)
		if chase_camera and chase_camera.fov != 75.0:
			chase_camera.fov = 75.0
		if nitro_exhaust_l: nitro_exhaust_l.emitting = false
		if nitro_exhaust_r: nitro_exhaust_r.emitting = false
		
	# Horn
	if Input.is_key_pressed(KEY_H):
		if horn_audio and not horn_audio.playing:
			horn_audio.play()

func _update_engine_audio(speed_kmh: float):
	if not engine_audio:
		return
	if not engine_audio.playing:
		engine_audio.play()
	# Pitch increases with speed (idle 0.85 -> top speed 1.95)
	var target_pitch = clampf(0.85 + (speed_kmh / 120.0) * 1.05, 0.85, 2.1)
	engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, target_pitch, 0.12)

func enter_vehicle(player: Node3D):
	if is_occupied:
		return
	is_occupied = true
	player_ref = player
	
	# Hide and disable player
	player_ref.visible = false
	player_ref.process_mode = Node.PROCESS_MODE_DISABLED
	if player_ref is CharacterBody3D:
		saved_player_layer = player_ref.collision_layer
		saved_player_mask = player_ref.collision_mask
		player_ref.collision_layer = 0
		player_ref.collision_mask = 0
		
	var player_hud = player_ref.find_child("HUD", true, false)
	if player_hud and player_hud is CanvasLayer:
		player_hud.visible = false
		
	# Activate Car Chase Camera
	if chase_camera:
		chase_camera.current = true
		
	if drive_hud:
		drive_hud.visible = true
	if enter_prompt_ui:
		enter_prompt_ui.visible = false
		
	# Headlights on (clean illumination, shadows disabled for zero fill-rate hit)
	headlight_state = 1
	if headlight_left:
		headlight_left.visible = true
		headlight_left.shadow_enabled = false
	if headlight_right:
		headlight_right.visible = true
		headlight_right.shadow_enabled = false
	
	if engine_audio and is_inside_tree():
		engine_audio.play()
		
	# Update ChunkManager streaming target to follow active car
	var tree_car = get_tree() if is_inside_tree() else null
	if tree_car:
		var cm = tree_car.get_first_node_in_group("chunk_manager")
		if not cm and tree_car.current_scene:
			cm = tree_car.current_scene.get_node_or_null("ChunkManager")
		if cm:
			cm.set("target_node", self)
			print("[STREAMING] ChunkManager now tracking active vehicle!")
		
	print("[CAR] Player entered vehicle. Drive mode ACTIVE!")

func exit_vehicle():
	if not is_occupied:
		return
		
	is_occupied = false
	
	if is_instance_valid(player_ref):
		# Position player on the left side of the vehicle safely
		var exit_pos = global_position + (-transform.basis.x * 2.2) + Vector3(0, 0.2, 0)
		player_ref.global_position = exit_pos
		player_ref.visible = true
		player_ref.process_mode = Node.PROCESS_MODE_INHERIT
		if player_ref is CharacterBody3D:
			player_ref.collision_layer = saved_player_layer
			player_ref.collision_mask = saved_player_mask
			
		var player_hud = player_ref.find_child("HUD", true, false)
		if player_hud and player_hud is CanvasLayer:
			player_hud.visible = true
			
		var player_cam = player_ref.find_child("Camera3D", true, false)
		if player_cam and player_cam is Camera3D:
			player_cam.current = true
			
		# Restore ChunkManager streaming target to follow player
		var tree_exit = get_tree() if is_inside_tree() else null
		if tree_exit:
			var cm = tree_exit.get_first_node_in_group("chunk_manager")
			if not cm and tree_exit.current_scene:
				cm = tree_exit.current_scene.get_node_or_null("ChunkManager")
			if cm:
				cm.set("target_node", player_ref)
				print("[STREAMING] ChunkManager restored to player tracking!")
				
		player_ref = null
		
	# Always restore vehicle chase camera and HUD state
	if chase_camera:
		chase_camera.current = false
		chase_camera.top_level = false
		chase_camera.transform = Transform3D(Basis(), Vector3(0, 2.3, 5.8))
	cam_orbit_h = 0.0
	cam_orbit_v = 0.0
		
	if drive_hud:
		drive_hud.visible = false
	if engine_audio:
		engine_audio.stop()
		
	# Turn off headlights on exit
	headlight_state = 0
	if headlight_left:
		headlight_left.visible = false
	if headlight_right:
		headlight_right.visible = false
		
	brake = 30.0
	engine_force = 0.0
	
	print("[CAR] Player exited vehicle. Shooter mode restored!")

func _toggle_headlight():
	headlight_state = 1 - headlight_state
	var is_on = (headlight_state == 1)
	if headlight_left:
		headlight_left.visible = is_on
	if headlight_right:
		headlight_right.visible = is_on

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		var is_f_key = event.keycode in [KEY_F, KEY_ENTER] or event.physical_keycode in [KEY_F, KEY_ENTER]
		var is_l_key = event.keycode == KEY_L or event.physical_keycode == KEY_L
		if is_f_key:
			if is_occupied:
				exit_vehicle()
			else:
				var p = nearby_player if nearby_player else get_tree().get_first_node_in_group("player")
				if p and is_instance_valid(p) and p.visible and p.process_mode != Node.PROCESS_MODE_DISABLED and global_position.distance_to(p.global_position) < 6.0:
					enter_vehicle(p)
		elif is_l_key and is_occupied:
			_toggle_headlight()

func _unhandled_input(event: InputEvent):
	if not is_occupied:
		return
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED) or event is InputEventScreenDrag:
		cam_orbit_h -= event.relative.x * 0.0035
		cam_orbit_v = clampf(cam_orbit_v - event.relative.y * 0.0035, deg_to_rad(-35.0), deg_to_rad(25.0))
		var arm = get_node_or_null("SpringArm3D")
		if arm:
			arm.rotation.y = cam_orbit_h
			arm.rotation.x = cam_orbit_v

func _on_door_body_entered(body: Node):
	if body.is_in_group("player") and not is_occupied:
		nearby_player = body
		if enter_prompt_ui:
			enter_prompt_ui.visible = true
			if prompt_label:
				prompt_label.text = "PRESS [F] TO DRIVE POLICE CRUISER"

func _on_door_body_exited(body: Node):
	if body == nearby_player:
		nearby_player = null
		if enter_prompt_ui:
			enter_prompt_ui.visible = false

# Bumper Smash: Run over zombies at high speed!
func _on_smash_hit(body: Node):
	var speed_kmh = linear_velocity.length() * 3.6
	if speed_kmh < 8.0:
		return
		
	if body.has_method("explode"):
		body.explode()
		return
		
	if body.is_in_group("enemies") or body.is_in_group("zombies") or body.is_in_group("zombie") or body.has_method("take_damage"):
		_execute_roadkill(body, speed_kmh)

func _on_smash_area_hit(area: Area3D):
	var speed_kmh = linear_velocity.length() * 3.6
	if speed_kmh < 8.0:
		return
		
	if area.has_method("explode"):
		area.explode()
		return
		
	var target = null
	if area.has_method("take_damage"):
		target = area
	elif "parent_entity" in area and area.parent_entity:
		target = area.parent_entity
	elif area.get_parent() and (area.get_parent().is_in_group("zombies") or area.get_parent().has_method("take_damage")):
		target = area.get_parent()
		
	if target:
		_execute_roadkill(target, speed_kmh)

func _execute_roadkill(target: Node, speed_kmh: float):
	var smash_dmg = maxf(speed_kmh * 50.0, 500.0) # Instant lethal gore obliteration
	var forward_hit = -transform.basis.z.normalized()
	
	if target.has_method("take_damage"):
		target.take_damage(smash_dmg, false, forward_hit * 15.0)
		
	if impact_audio and not impact_audio.playing:
		impact_audio.pitch_scale = randf_range(0.85, 1.15)
		impact_audio.play()
		
	# Blood splatter from impact pool if available
	var impact_pool = get_tree().get_first_node_in_group("impact_pool")
	if impact_pool and impact_pool.has_method("spawn_impact"):
		impact_pool.spawn_impact("blood", target.global_position + Vector3(0, 0.8, 0), Vector3.UP)
		
	# Award cash & notify arena
	var sm = get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("add_cash"):
		sm.add_cash(150)
		
	var arena = get_tree().current_scene
	if arena and arena.has_method("_on_zombie_roadkilled"):
		arena._on_zombie_roadkilled(target, speed_kmh)
		
	print("[ROADKILL] Smashed zombie at %d KM/H for %.1f damage!" % [int(speed_kmh), smash_dmg])

func take_damage(amount: float, _is_critical: Variant = false, _dir: Variant = null):
	if is_destroyed:
		return
	current_health = maxf(0.0, current_health - amount)
	print("[VEHICLE DAMAGE] Car took %.1f damage. Remaining HP: %.1f/%.1f" % [amount, current_health, max_health])
	
	if impact_audio and not impact_audio.playing:
		impact_audio.play()
		
	if current_health <= 0.0:
		_destroy_vehicle()

func _destroy_vehicle():
	is_destroyed = true
	print("[VEHICLE] Car has been DESTROYED!")
	if is_occupied:
		exit_vehicle()
	brake = 500.0
	engine_force = 0.0
	if engine_audio and engine_audio.playing:
		engine_audio.stop()

func _optimize_vehicle_meshes():
	var stack: Array[Node] = [self]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node is MeshInstance3D:
			var p_node = node.get_parent()
			var p_name = p_node.name.to_lower() if p_node else ""
			var full_id = (node.name + " " + p_name).to_lower()
			
			var mat_name = ""
			if node.material_override and node.material_override.resource_name != "":
				mat_name = node.material_override.resource_name.to_lower()
			elif node.mesh and node.mesh.get_surface_count() > 0:
				var m = node.mesh.surface_get_material(0)
				if m and m.resource_name != "":
					mat_name = m.resource_name.to_lower()
				else:
					mat_name = node.mesh.resource_name.to_lower()
					
			var vol = 0.0
			if node.mesh:
				var aabb = node.mesh.get_aabb()
				vol = aabb.size.x * aabb.size.y * aabb.size.z
				
			var is_internal_bit = false
			for kw in ["suspension", "pipe", "brake", "engine", "caliper", "honeycomb", "metalstainlesssteel", "metal_-_black"]:
				if kw in mat_name or kw in full_id:
					is_internal_bit = true
					break
					
			var is_tiny = (vol > 0.0 and vol < 0.04 and not ("paint" in mat_name or "glass" in mat_name or "wheel" in full_id))
			
			if is_internal_bit or is_tiny:
				node.visible = false
				node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			else:
				var is_sub_part = false
				for part in ["interior", "glass", "windshield", "seat", "dashboard", "frame", "exhaust", "detach", "door", "bumper", "hood", "trunk", "details", "wheel"]:
					if part in full_id or part in mat_name:
						is_sub_part = true
						break
				if is_sub_part:
					node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				else:
					var is_main_body = ("unibody" in full_id) or ("body" in full_id) or (node.name.to_lower() == "skinned_mesh_chassis")
					if is_main_body:
						node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
					else:
						node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for child in node.get_children():
			stack.append(child)
