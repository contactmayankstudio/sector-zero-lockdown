class_name DrivableBike
extends CharacterBody3D

## High-Performance Drivable Superbike (Suzuki Hayabusa 1300R)
## Designed for GTA 5 Open World / Sector Zero in Godot 4.
## Features dynamic 2-wheel lean physics, high-speed drifting, roadkill smash mechanics,
## headlight high-beam system, realistic engine pitch modulation, and seamless mount/dismount.

@export_group("Performance & Speed Limits")
@export var max_top_speed_kmh: float = 190.0 # Realistic sports superbike cruise top speed
@export var nitro_top_speed_kmh: float = 230.0 # Realistic nitro top speed
@export var top_speed_kmh: float = 190.0
@export var reverse_speed_kmh: float = 25.0
@export var acceleration_rate: float = 32.0 # m/s^2 forward pull
@export var braking_rate: float = 38.0 # m/s^2 front/rear brake stopping power
@export var handbrake_drift_rate: float = 48.0 # m/s^2 rear brake drift bite
@export var coasting_drag: float = 6.5 # rolling resistance
@export var max_nitro: float = 100.0
@export var nitro_boost_force: float = 18.0
var current_nitro: float = 100.0
var is_boosting: bool = false
var _was_boosting: bool = false

var touch_steer: float = 0.0
var touch_throttle: float = 0.0
var touch_boost: bool = false
var touch_handbrake: bool = false

@export_group("Handling & Lean Physics")
@export var steer_speed: float = 3.8 # Rad/s turning response
@export var max_lean_angle_deg: float = 34.0 # Maximum lean angle in turns
@export var lean_smooth: float = 8.5 # Smoothness factor for leaning into turns
@export var drift_steer_multiplier: float = 1.65 # Extra turning agility during handbrake drift
@export var fork_steer_angle_deg: float = 22.0 # Visual front fork turn angle

@export_group("Environment & Gravity")
@export var gravity: float = 24.0
@export var mount_distance: float = 6.5

# Runtime State
var is_occupied: bool = false
var player_ref: Node3D = null
var nearby_player: Node3D = null
var saved_player_layer: int = 1
var saved_player_mask: int = 1
var current_forward_velocity: float = 0.0 # m/s
var speed_kmh: float = 0.0
var current_speed_kmh: float = 0.0
var current_steer_input: float = 0.0
var is_handbraking: bool = false
var headlight_state: int = 0 # 0 = Off, 1 = Low Beam, 2 = High Beam

var cam_orbit_h: float = 0.0
var cam_orbit_v: float = 0.0

var front_wheel_ray: RayCast3D = null
var rear_wheel_ray: RayCast3D = null
var _ground_normal: Vector3 = Vector3.UP

# Expose linear_velocity property matching VehicleBody3D/RigidBody3D interface
var linear_velocity: Vector3:
	get:
		return velocity
	set(val):
		velocity = val

# Node References
@onready var visual_wrapper: Node3D = get_node_or_null("VisualWrapper")
@onready var chase_camera: Camera3D = get_node_or_null("SpringArm3D/ChaseCamera") if has_node("SpringArm3D/ChaseCamera") else get_node_or_null("ChaseCamera")
@onready var spring_arm: SpringArm3D = get_node_or_null("SpringArm3D")

@onready var headlight: SpotLight3D = get_node_or_null("Headlight")
@onready var headlight_glow: OmniLight3D = get_node_or_null("HeadlightGlow")
@onready var taillight: OmniLight3D = get_node_or_null("Taillight")

@onready var engine_audio: AudioStreamPlayer3D = get_node_or_null("EngineAudio")
@onready var impact_audio: AudioStreamPlayer3D = get_node_or_null("ImpactAudio")
@onready var horn_audio: AudioStreamPlayer3D = get_node_or_null("HornAudio")

@onready var mount_zone: Area3D = get_node_or_null("MountZone")
@onready var smash_zone: Area3D = get_node_or_null("SmashZone")

@onready var enter_prompt_ui: CanvasLayer = get_node_or_null("EnterPromptUI")
@onready var prompt_label: Label = get_node_or_null("EnterPromptUI/CenterContainer/PromptLabel")

@onready var drive_hud: CanvasLayer = get_node_or_null("DriveHUD")
@onready var speed_label: Label = get_node_or_null("DriveHUD/SpeedLabel")
@onready var gear_label: Label = get_node_or_null("DriveHUD/GearLabel")
@onready var beam_label: Label = get_node_or_null("DriveHUD/BeamLabel")
@onready var exit_button: Button = get_node_or_null("DriveHUD/ExitButton")

# Dynamic internal model references (found dynamically in Hayabusa tree)
var fork_steer_node: Node3D = null
var front_wheel_node: Node3D = null
var rear_wheel_node: Node3D = null
var rider_soldier: Node3D = null

# Pro Real FX Nodes
var tire_smoke_emitter: CPUParticles3D = null
var exhaust_flame_left: MeshInstance3D = null
var exhaust_flame_right: MeshInstance3D = null
var exhaust_flame_light: OmniLight3D = null
var backfire_timer: float = 0.0
var last_throttle: float = 0.0

func _ready():
	add_to_group("vehicles")
	add_to_group("bikes")
	
	# Off-road mountain climbing and curb collision physics (up to 85 degree steep inclines)
	floor_max_angle = deg_to_rad(85.0)
	floor_constant_speed = true
	floor_snap_length = 0.35
	floor_stop_on_slope = false
	floor_block_on_wall = false
	
	# Cache visual steer & wheel nodes
	_find_bike_mesh_nodes()
	
	# Initialize high-detail tactical soldier rider
	_init_rider_soldier()
	
	# Initialize Pro Real Tire Smoke & Exhaust Flame Backfires
	_setup_bike_fx()
	
	if chase_camera:
		chase_camera.current = false
	if drive_hud:
		drive_hud.visible = false
	if enter_prompt_ui:
		enter_prompt_ui.visible = false
		
	# Setup initial headlight state (Low beam active)
	_apply_headlight_state()
	
	_setup_wheel_raycasts()
	
	_optimize_bike_meshes()
	
	# Connect interaction zones safely
	if mount_zone:
		if not mount_zone.body_entered.is_connected(_on_mount_body_entered):
			mount_zone.body_entered.connect(_on_mount_body_entered)
		if not mount_zone.body_exited.is_connected(_on_mount_body_exited):
			mount_zone.body_exited.connect(_on_mount_body_exited)
		
	if smash_zone:
		# Target Layer 2: enemies only; avoid costly Layer 1 trimesh collision checks
		smash_zone.collision_mask = 2
		if not smash_zone.body_entered.is_connected(_on_smash_hit):
			smash_zone.body_entered.connect(_on_smash_hit)
		if not smash_zone.area_entered.is_connected(_on_smash_area_hit):
			smash_zone.area_entered.connect(_on_smash_area_hit)
		
	if exit_button and not exit_button.pressed.is_connected(exit_vehicle):
		exit_button.pressed.connect(exit_vehicle)
		
	call_deferred("_check_initial_overlap")

func _find_bike_mesh_nodes():
	if not visual_wrapper:
		return
	fork_steer_node = visual_wrapper.find_child("bone_wheel_F_steer", true, false)
	front_wheel_node = visual_wrapper.find_child("Wheel_F", true, false)
	rear_wheel_node = visual_wrapper.find_child("Wheel_B", true, false)

func _check_initial_overlap():
	if mount_zone:
		for b in mount_zone.get_overlapping_bodies():
			if b.is_in_group("player"):
				_on_mount_body_entered(b)
				break

func _setup_wheel_raycasts():
	if not front_wheel_ray:
		front_wheel_ray = RayCast3D.new()
		front_wheel_ray.name = "FrontWheelRay"
		front_wheel_ray.position = Vector3(0.0, 0.45, -0.75)
		front_wheel_ray.target_position = Vector3(0.0, -0.75, 0.0)
		front_wheel_ray.collision_mask = collision_mask
		front_wheel_ray.add_exception(self)
		add_child(front_wheel_ray)
	if not rear_wheel_ray:
		rear_wheel_ray = RayCast3D.new()
		rear_wheel_ray.name = "RearWheelRay"
		rear_wheel_ray.position = Vector3(0.0, 0.45, 0.75)
		rear_wheel_ray.target_position = Vector3(0.0, -0.75, 0.0)
		rear_wheel_ray.collision_mask = collision_mask
		rear_wheel_ray.add_exception(self)
		add_child(rear_wheel_ray)

func _is_bike_grounded() -> bool:
	var f_hit = front_wheel_ray != null and front_wheel_ray.is_colliding()
	var r_hit = rear_wheel_ray != null and rear_wheel_ray.is_colliding()
	return f_hit or r_hit or is_on_floor()

func _has_solid_traction() -> bool:
	# Requires both wheels or solid floor contact for high-speed stability and nitro
	var f_hit = front_wheel_ray != null and front_wheel_ray.is_colliding()
	var r_hit = rear_wheel_ray != null and rear_wheel_ray.is_colliding()
	return (f_hit and r_hit) or is_on_floor()

func _physics_process(delta: float):
	# 1. Exact calibrated speed conversion from m/s to KM/H
	speed_kmh = linear_velocity.length() * 3.6
	current_speed_kmh = speed_kmh
	
	# 2. Strict realistic top speed clamp (cruise capped at 190 km/h, nitro capped at 230 km/h)
	# Absolutely prevents 918 KM/H runaway velocity under all conditions (parked, riding, airborne, downhill)
	var max_allowed = nitro_top_speed_kmh if is_boosting else max_top_speed_kmh
	if speed_kmh > max_allowed:
		var max_allowed_ms = max_allowed / 3.6
		linear_velocity = linear_velocity.normalized() * max_allowed_ms
		speed_kmh = max_allowed
		current_speed_kmh = max_allowed
		
	var max_allowed_ms = max_allowed / 3.6
	var horiz_vel = Vector2(linear_velocity.x, linear_velocity.z)
	if horiz_vel.length() > max_allowed_ms:
		var clamped_h = horiz_vel.normalized() * max_allowed_ms
		linear_velocity.x = clamped_h.x
		linear_velocity.z = clamped_h.y
		
	if abs(current_forward_velocity) > max_allowed_ms:
		current_forward_velocity = signf(current_forward_velocity) * max_allowed_ms
	
	if is_occupied:
		_handle_riding_physics(delta)
		_update_engine_sound(delta)
		_update_hud()
		_update_rider_posture(delta)
		_update_smooth_camera(delta, current_speed_kmh)
	else:
		_handle_parked_physics(delta)
		_check_nearby_player_proximity()

func _update_smooth_camera(delta: float, cur_speed_kmh: float):
	if not chase_camera or not is_instance_valid(chase_camera):
		return
	if not chase_camera.top_level:
		chase_camera.top_level = true
		chase_camera.global_position = global_position + (transform.basis.z * 4.2) + Vector3(0, 1.8, 0)

	var fwd = -transform.basis.z.normalized()
	var horiz_fwd = Vector3(fwd.x, 0.0, fwd.z).normalized()
	if horiz_fwd.length_squared() < 0.01:
		horiz_fwd = Vector3.FORWARD

	# Apply mouse orbit offset
	var cam_dir = horiz_fwd.rotated(Vector3.UP, cam_orbit_h)

	var cam_dist = 4.2 + clampf(cur_speed_kmh / 85.0, 0.0, 1.6)
	var cam_height = 1.8 + clampf(cur_speed_kmh / 120.0, 0.0, 0.6) + sin(cam_orbit_v) * cam_dist * 0.5
	var target_cam_pos = global_position - cam_dir * cam_dist + Vector3(0, maxf(cam_height, 0.6), 0)

	# Smooth speed-adaptive responsiveness
	var lerp_weight = clampf(delta * (9.0 + (cur_speed_kmh / 35.0)), 0.0, 1.0)
	chase_camera.global_position = chase_camera.global_position.lerp(target_cam_pos, lerp_weight)

	# Aim camera at bike center with upright horizon stabilization (Vector3.UP)
	var look_target = global_position + Vector3(0, 0.95, 0) + (cam_dir * 1.2)
	if chase_camera.is_inside_tree():
		chase_camera.look_at(look_target, Vector3.UP)
	else:
		chase_camera.look_at_from_position(chase_camera.global_position, look_target, Vector3.UP)

	# Smooth return orbit to center when riding forward
	if cur_speed_kmh > 15.0 and abs(cam_orbit_h) > 0.01:
		cam_orbit_h = move_toward(cam_orbit_h, 0.0, delta * 1.6)
	if abs(cam_orbit_v) > 0.01:
		cam_orbit_v = move_toward(cam_orbit_v, 0.0, delta * 1.6)

func _handle_riding_physics(delta: float):
	var is_grounded = _is_bike_grounded()
	var solid_traction = _has_solid_traction()
	
	# 1. Steering & Handlebar Inputs (A/D or Left/Right or Touch)
	var steer_target = 0.0
	if touch_steer != 0.0:
		steer_target = touch_steer
	elif Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		steer_target = -1.0 # Steer left
	elif Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		steer_target = 1.0 # Steer right
		
	current_steer_input = move_toward(current_steer_input, steer_target, delta * 7.0)

	# 2. Throttle & Braking Inputs (W/S or Up/Down or Touch)
	var throttle = 0.0
	if touch_throttle != 0.0:
		throttle = touch_throttle
	elif Input.is_action_pressed("move_forward") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		throttle = 1.0
	elif Input.is_action_pressed("move_backward") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		throttle = -1.0

	# 3. Rear Handbrake Drift (SPACE or Touch)
	is_handbraking = Input.is_key_pressed(KEY_SPACE) or touch_handbrake

	# Nitro Boost (Shift) - Strictly requires solid ground contact and nitro available
	var wants_boost = (Input.is_key_pressed(KEY_SHIFT) or touch_boost) and current_nitro > 0.0 and solid_traction and (throttle > 0.0 or touch_throttle > 0.0)
	if wants_boost:
		is_boosting = true
		current_nitro = maxf(current_nitro - delta * 25.0, 0.0)
	else:
		is_boosting = false
		current_nitro = minf(current_nitro + delta * 15.0, max_nitro)

	# 2. Strict realistic top speed clamp (Cruise capped at 190 km/h, Nitro capped at 230 km/h)
	var max_allowed_kmh = nitro_top_speed_kmh if is_boosting else max_top_speed_kmh
	var max_fwd_ms = max_allowed_kmh / 3.6
	var max_rev_ms = reverse_speed_kmh / 3.6

	if is_handbraking:
		# Rapid rear bite drift deceleration
		current_forward_velocity = move_toward(current_forward_velocity, 0.0, handbrake_drift_rate * delta)
	elif throttle > 0.0 and is_grounded:
		# 3. Forward acceleration ONLY when ground contact is verified via wheel checks
		var speed_ratio = clampf(abs(current_forward_velocity) / max_fwd_ms, 0.0, 1.0)
		var torque_curve = clampf(1.0 - (speed_ratio * 0.4), 0.15, 1.0)
		var effective_accel = acceleration_rate * torque_curve
		if is_boosting:
			effective_accel += nitro_boost_force * clampf(1.0 - (current_speed_kmh / nitro_top_speed_kmh), 0.2, 1.0)
		current_forward_velocity = move_toward(current_forward_velocity, max_fwd_ms, effective_accel * delta)
	elif throttle < 0.0 and is_grounded:
		if current_forward_velocity > 1.5:
			# Firm front/rear disc braking
			current_forward_velocity = move_toward(current_forward_velocity, 0.0, braking_rate * delta)
		else:
			# Slow reverse gear
			current_forward_velocity = move_toward(current_forward_velocity, -max_rev_ms, acceleration_rate * 0.5 * delta)
	else:
		# Rolling resistance / coasting (also applied when airborne)
		var drag = coasting_drag if is_grounded else (coasting_drag * 0.5)
		current_forward_velocity = move_toward(current_forward_velocity, 0.0, drag * delta)

	# Strict clamp on forward velocity variable to ensure speed never exceeds cap
	current_forward_velocity = clampf(current_forward_velocity, -max_rev_ms, max_fwd_ms)

	# 4. Yaw Steering Rotation (Only turns when moving)
	if abs(current_forward_velocity) > 0.3:
		var turn_mult = drift_steer_multiplier if is_handbraking else 1.0
		# High-speed stability: slightly tighten steering ratio at top speeds for control
		var speed_steer_ratio = clampf(1.15 - (current_speed_kmh / 240.0), 0.45, 1.25)
		var fwd_sign = 1.0 if current_forward_velocity >= 0.0 else -1.0
		rotate_y(-current_steer_input * steer_speed * turn_mult * speed_steer_ratio * delta * fwd_sign)

	# 5. Dynamic 2-Wheel Lean Physics (Rolls smoothly into turn)
	var max_lean_rad = deg_to_rad(max_lean_angle_deg)
	var speed_lean_ratio = clampf(current_speed_kmh / 45.0, 0.0, 1.0)
	var target_lean = -current_steer_input * max_lean_rad * speed_lean_ratio
	if is_handbraking and abs(current_steer_input) > 0.2:
		target_lean *= 1.2 # Exaggerate drift lean angle

	if visual_wrapper:
		visual_wrapper.rotation.z = lerpf(visual_wrapper.rotation.z, target_lean, delta * lean_smooth)

	if rider_soldier and rider_soldier.visible:
		var rider_lean = -current_steer_input * deg_to_rad(10.0)
		rider_soldier.rotation.z = lerpf(rider_soldier.rotation.z, rider_lean, delta * 7.0)

	# 6. Steer visual handlebars/fork and spin wheels
	_update_visual_wheels(delta)

	# 7. Apply Motion & Mountain Slope Climbing with strict velocity clamping
	var forward_dir = -transform.basis.z.normalized()
	if is_grounded:
		var raw_norm = get_floor_normal() if is_on_floor() else Vector3.UP
		if (not is_on_floor()) and front_wheel_ray and front_wheel_ray.is_colliding():
			raw_norm = front_wheel_ray.get_collision_normal()
		elif (not is_on_floor()) and rear_wheel_ray and rear_wheel_ray.is_colliding():
			raw_norm = rear_wheel_ray.get_collision_normal()
			
		if raw_norm.length_squared() < 0.1:
			raw_norm = Vector3.UP
		
		# Smooth normal interpolation eliminates high-speed 230 KM/H seam micro-stutters
		_ground_normal = _ground_normal.lerp(raw_norm, clampf(delta * 24.0, 0.0, 1.0)).normalized()
		var surf_norm = _ground_normal
		
		# Project forward vector onto surface plane
		var slope_dir = (forward_dir - surf_norm * forward_dir.dot(surf_norm)).normalized()
		# If pointing upward, ensure positive Y component so bike never slides down
		if slope_dir.y < 0.1 and forward_dir.dot(surf_norm) < -0.1:
			slope_dir.y = maxf(slope_dir.y, 0.45)
			slope_dir = slope_dir.normalized()
			
		velocity = slope_dir * current_forward_velocity
		
		# Aerodynamic Downforce: keeps tires planted firmly on asphalt / terrain at speed
		if current_speed_kmh > 20.0:
			var downforce_mag = clampf(current_speed_kmh * 0.12, 0.0, 15.0)
			velocity.y -= downforce_mag * delta
	else:
		# Airborne: carry forward horizontal momentum, apply gravity, stabilize pitch/roll
		velocity.x = forward_dir.x * current_forward_velocity
		velocity.z = forward_dir.z * current_forward_velocity
		velocity.y -= gravity * delta
		
		# High-speed airborne aerodynamic downforce prevents endless flight
		if current_speed_kmh > 40.0:
			velocity.y -= clampf((current_speed_kmh / max_top_speed_kmh) * 12.0, 0.0, 18.0) * delta
			
		# Mid-air roll stabilization keeps bike upright
		if visual_wrapper:
			visual_wrapper.rotation.z = lerpf(visual_wrapper.rotation.z, 0.0, delta * 6.0)

	# Strict 3D Velocity Cap: strictly enforces max_allowed speed (cruise 190 km/h, nitro 230 km/h)
	# Absolutely prevents runaway 918 KM/H velocity under all terrain and slope conditions
	var max_velocity_ms = max_allowed_kmh / 3.6
	var horiz_vel = Vector2(velocity.x, velocity.z)
	if horiz_vel.length() > max_velocity_ms:
		var clamped_h = horiz_vel.normalized() * max_velocity_ms
		velocity.x = clamped_h.x
		velocity.z = clamped_h.y
	if velocity.length() > max_velocity_ms:
		velocity = velocity.normalized() * max_velocity_ms

	move_and_slide()

	# Recalculate calibrated speed after move_and_slide
	speed_kmh = linear_velocity.length() * 3.6
	current_speed_kmh = speed_kmh

	# 8. Pro Real FX (Tire smoke, backfire flames, speed FOV & micro-rumble)
	_update_riding_fx(throttle, delta)

	# Horn (H key)
	if Input.is_key_pressed(KEY_H):
		if horn_audio and not horn_audio.playing:
			horn_audio.play()

func _update_visual_wheels(delta: float):
	# Steer front fork
	if fork_steer_node:
		var fork_rad = deg_to_rad(-current_steer_input * fork_steer_angle_deg)
		fork_steer_node.rotation.y = lerpf(fork_steer_node.rotation.y, fork_rad, delta * 12.0)
		
	# Spin wheels based on forward motion
	var roll_angle = -(current_forward_velocity / 0.30) * delta
	if front_wheel_node:
		front_wheel_node.rotate_x(roll_angle)
	if rear_wheel_node:
		rear_wheel_node.rotate_x(roll_angle)

func _handle_parked_physics(delta: float):
	if not is_inside_tree():
		return
	current_forward_velocity = 0.0
	if tire_smoke_emitter and tire_smoke_emitter.emitting:
		tire_smoke_emitter.emitting = false
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, 18.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 18.0 * delta)
		velocity.y = -0.5
		
	move_and_slide()
	
	# Keep bike upright when parked
	if visual_wrapper:
		visual_wrapper.rotation.z = lerpf(visual_wrapper.rotation.z, 0.0, delta * 6.0)
		
	if engine_audio and engine_audio.playing:
		engine_audio.stop()

func _check_nearby_player_proximity():
	var tree = get_tree() if is_inside_tree() else null
	var p = tree.get_first_node_in_group("player") if tree else null
	if p and is_instance_valid(p):
		var dist = global_position.distance_to(p.global_position)
		if dist <= mount_distance:
			nearby_player = p
			if enter_prompt_ui and not enter_prompt_ui.visible:
				enter_prompt_ui.visible = true
				if prompt_label:
					prompt_label.text = "PRESS [F] TO RIDE HAYABUSA SUPERBIKE"
		elif dist > (mount_distance + 1.2) and nearby_player == p:
			nearby_player = null
			if enter_prompt_ui and enter_prompt_ui.visible:
				enter_prompt_ui.visible = false

func _update_engine_sound(delta: float):
	if not engine_audio or not is_inside_tree():
		return
	if not engine_audio.playing:
		engine_audio.play()
		
	# Superbike RPM pitch scaling: 0.88 at idle to 2.25 screaming top speed
	var target_pitch = clampf(0.88 + (current_speed_kmh / 140.0) * 1.15, 0.88, 2.35)
	if is_handbraking and current_speed_kmh > 30.0:
		target_pitch += 0.25 # Engine revs during skid
		
	engine_audio.pitch_scale = lerpf(engine_audio.pitch_scale, target_pitch, delta * 8.0)

func _update_hud():
	if speed_label:
		if is_boosting:
			speed_label.text = "⚡ NITRO BOOST: %d KM/H [%d%%]" % [int(current_speed_kmh), int(current_nitro)]
			speed_label.add_theme_color_override("font_color", Color(0.1, 0.95, 1.0))
		else:
			speed_label.text = "%d KM/H  |  NITRO: %d%% [HOLD SHIFT]" % [int(current_speed_kmh), int(current_nitro)]
			speed_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		
	if gear_label:
		var gear_str = "N"
		if current_forward_velocity < -0.2:
			gear_str = "R"
		elif current_speed_kmh < 5.0:
			gear_str = "1"
		elif current_speed_kmh < 55.0:
			gear_str = "1"
		elif current_speed_kmh < 95.0:
			gear_str = "2"
		elif current_speed_kmh < 135.0:
			gear_str = "3"
		elif current_speed_kmh < 170.0:
			gear_str = "4"
		elif current_speed_kmh < 205.0:
			gear_str = "5"
		else:
			gear_str = "6"
		gear_label.text = "GEAR: %s | TACHO: %d RPM" % [gear_str, int(clampf(2000 + (current_speed_kmh * 55.0), 1200, 13500))]

func enter_vehicle(player: Node3D):
	if is_occupied:
		return
	is_occupied = true
	player_ref = player

	# Show seated tactical soldier rider on bike
	if rider_soldier:
		rider_soldier.visible = true
		_apply_superbike_riding_pose(rider_soldier)

	# Hide and disable player character
	player_ref.visible = false
	player_ref.global_position = Vector3(0.0, -100.0, 0.0)
	player_ref.process_mode = Node.PROCESS_MODE_DISABLED
	if player_ref is CharacterBody3D:
		saved_player_layer = player_ref.collision_layer
		saved_player_mask = player_ref.collision_mask
		player_ref.collision_layer = 0
		player_ref.collision_mask = 0

	var player_hud = player_ref.find_child("HUD", true, false)
	if player_hud and player_hud is CanvasLayer:
		player_hud.visible = false

	# Activate Superbike Chase Camera
	if chase_camera:
		chase_camera.current = true

	# Enable Superbike Drive HUD
	if drive_hud:
		drive_hud.visible = true
	if enter_prompt_ui:
		enter_prompt_ui.visible = false

	# Turn on Headlights (Low beam)
	headlight_state = 1
	_apply_headlight_state()

	# Start engine audio
	if engine_audio and is_inside_tree():
		engine_audio.pitch_scale = 0.9
		engine_audio.play()

	# Update ChunkManager target to bike
	var tree_bike = get_tree() if is_inside_tree() else null
	if tree_bike:
		var cm = tree_bike.get_first_node_in_group("chunk_manager")
		if not cm and tree_bike.current_scene:
			cm = tree_bike.current_scene.get_node_or_null("ChunkManager")
		if cm:
			cm.set("target_node", self)

	print("[SUPERBIKE] Player mounted Hayabusa. High-speed superbike mode ACTIVE!")

func exit_vehicle():
	if not is_occupied:
		return

	is_occupied = false

	if is_instance_valid(player_ref):
		# Restore ChunkManager target to player
		var tree_exit = get_tree() if is_inside_tree() else null
		if tree_exit:
			var cm = tree_exit.get_first_node_in_group("chunk_manager")
			if not cm and tree_exit.current_scene:
				cm = tree_exit.current_scene.get_node_or_null("ChunkManager")
			if cm:
				cm.set("target_node", player_ref)

		# Position player safely on the left side of the bike
		var exit_pos = global_position + (-transform.basis.x * 1.5) + Vector3(0, 0.25, 0)
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

		player_ref = null

	# Hide rider soldier when player dismounts
	if rider_soldier:
		rider_soldier.visible = false
		rider_soldier.rotation.z = 0.0

	# Restore Player's Camera
	if chase_camera:
		chase_camera.current = false
		chase_camera.top_level = false
		chase_camera.transform = Transform3D(Basis(), Vector3.ZERO)
	cam_orbit_h = 0.0
	cam_orbit_v = 0.0

	# Hide Drive HUD & Stop Engine
	if drive_hud:
		drive_hud.visible = false
	if engine_audio:
		engine_audio.stop()

	# Turn off headlights on dismount
	headlight_state = 0
	_apply_headlight_state()

	current_forward_velocity = 0.0
	velocity = Vector3.ZERO
	if visual_wrapper:
		visual_wrapper.rotation.z = 0.0

	print("[SUPERBIKE] Player exited Hayabusa. Shooter mode restored!")

func _toggle_headlight():
	headlight_state = (headlight_state + 1) % 3
	_apply_headlight_state()

func _apply_headlight_state():
	if not headlight:
		return
	headlight.shadow_enabled = false
	if headlight_glow:
		headlight_glow.shadow_enabled = false
	match headlight_state:
		0: # Off
			headlight.visible = false
			if headlight_glow: headlight_glow.visible = false
			if beam_label: beam_label.text = "LIGHTS: OFF [L]"
		1: # Low Beam
			headlight.visible = true
			headlight.light_energy = 3.5
			headlight.spot_range = 50.0
			headlight.spot_angle = 36.0
			headlight.light_color = Color(1.0, 0.96, 0.90)
			if headlight_glow: headlight_glow.visible = true
			if beam_label: beam_label.text = "LOW BEAM [L]"
		2: # High Beam
			headlight.visible = true
			headlight.light_energy = 6.0
			headlight.spot_range = 80.0
			headlight.spot_angle = 45.0
			headlight.light_color = Color(0.95, 0.98, 1.0)
			if headlight_glow: headlight_glow.visible = true
			if beam_label: beam_label.text = "HIGH BEAM [L]"

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		var is_f_key = event.keycode in [KEY_F, KEY_ENTER] or event.physical_keycode in [KEY_F, KEY_ENTER]
		var is_l_key = event.keycode == KEY_L or event.physical_keycode == KEY_L
		if is_f_key:
			if is_occupied:
				exit_vehicle()
			else:
				var p = nearby_player if nearby_player else get_tree().get_first_node_in_group("player")
				if p and is_instance_valid(p) and global_position.distance_to(p.global_position) <= mount_distance:
					enter_vehicle(p)
		elif is_l_key and is_occupied:
			_toggle_headlight()

func _unhandled_input(event: InputEvent):
	# Camera Orbit Control with mouse motion or mobile touch drag when driving
	if not is_occupied:
		return
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED) or event is InputEventScreenDrag:
		cam_orbit_h -= event.relative.x * 0.0035
		cam_orbit_v = clampf(cam_orbit_v - event.relative.y * 0.0035, deg_to_rad(-40.0), deg_to_rad(22.0))
		if spring_arm:
			spring_arm.rotation.y = cam_orbit_h
			spring_arm.rotation.x = cam_orbit_v

func _on_mount_body_entered(body: Node):
	if body.is_in_group("player") and not is_occupied:
		nearby_player = body
		if enter_prompt_ui:
			enter_prompt_ui.visible = true
			if prompt_label:
				prompt_label.text = "PRESS [F] TO RIDE HAYABUSA SUPERBIKE"

func _on_mount_body_exited(body: Node):
	if body == nearby_player:
		nearby_player = null
		if enter_prompt_ui:
			enter_prompt_ui.visible = false

# -----------------------------------------------------------------------------
# Roadkill Gore & Smash Collision Mechanics
# -----------------------------------------------------------------------------
func _on_smash_hit(body: Node):
	if current_speed_kmh < 12.0:
		return
	if body.is_in_group("enemies") or body.has_method("take_damage"):
		_execute_roadkill(body, current_speed_kmh)

func _on_smash_area_hit(area: Area3D):
	if current_speed_kmh < 12.0:
		return
	if "parent_entity" in area and area.parent_entity:
		_execute_roadkill(area.parent_entity, current_speed_kmh)
	elif area.get_parent() and (area.get_parent().is_in_group("enemies") or area.get_parent().has_method("take_damage")):
		_execute_roadkill(area.get_parent(), current_speed_kmh)

func _execute_roadkill(target: Node, speed_kmh: float):
	var smash_dmg = speed_kmh * 42.0 # 100 KM/H = 4200 damage (total obliteration)
	var forward_hit = -transform.basis.z.normalized()

	if target.has_method("take_damage"):
		target.take_damage(smash_dmg, false, forward_hit * 14.0)

	if is_inside_tree():
		if impact_audio and not impact_audio.playing:
			impact_audio.pitch_scale = randf_range(0.95, 1.20)
			impact_audio.play()

		# Blood splatter from impact pool if present
		var tree = get_tree()
		if tree:
			var impact_pool = tree.get_first_node_in_group("impact_pool")
			if impact_pool and impact_pool.has_method("spawn_impact"):
				impact_pool.spawn_impact("blood", target.global_position + Vector3(0, 0.75, 0), Vector3.UP)

		# Score / Bounty bonus via SaveManager if active
		var sm = get_node_or_null("/root/SaveManager")
		if sm and sm.has_method("add_cash"):
			sm.add_cash(150)

		# Dispatch to PUBG Tactical Killfeed on HUD
		var hud = tree.get_first_node_in_group("hud")
		if hud and hud.has_method("add_killfeed_entry"):
			hud.add_killfeed_entry("COMBAT SOLDIER", "🏍️", "Zombie (%d KM/H)" % int(speed_kmh), true)

	print("[SUPERBIKE ROADKILL] Smashed zombie at %d KM/H for %.1f damage!" % [int(speed_kmh), smash_dmg])

# -----------------------------------------------------------------------------
# High-Detail Tactical Soldier Rider Initialization & Posture
# -----------------------------------------------------------------------------
func _init_rider_soldier():
	if rider_soldier and is_instance_valid(rider_soldier):
		return
	var soldier_scene = load("res://scenes/characters/RealSoldier.scn")
	if not soldier_scene:
		soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	if not soldier_scene:
		push_warning("[SUPERBIKE] Could not load RealSoldier for bike rider!")
		return
	rider_soldier = soldier_scene.instantiate()
	rider_soldier.name = "RiderSoldier"
	# RealSoldier has realistic human scale 1.0 (1.83m tall)
	rider_soldier.scale = Vector3(1.0, 1.0, 1.0)
	# Position squarely onto Hayabusa saddle:
	rider_soldier.position = Vector3(0.0, -0.42, -0.22)

	if visual_wrapper:
		visual_wrapper.add_child(rider_soldier)
	else:
		add_child(rider_soldier)

	# Ensure skeleton is linked for all mesh instances
	for child in rider_soldier.find_children("*", "MeshInstance3D"):
		child.skeleton = NodePath("..")

	var anim: AnimationPlayer = rider_soldier.find_child("AnimationPlayer", true, false)
	if anim:
		anim.stop()
		anim.active = false

	# Attach Combat Rifle slung diagonally on the soldier's back
	var skel: Skeleton3D = rider_soldier.find_child("Skeleton3D", true, false)
	if skel:
		var existing_attach = skel.find_child("BackWeaponAttach", true, false)
		if not existing_attach:
			var back_attach = BoneAttachment3D.new()
			back_attach.name = "BackWeaponAttach"
			back_attach.bone_name = "mixamorig_Spine2"
			var rifle_scene = load("res://scenes/weapons/models/akx_scifi.scn")
			if rifle_scene:
				var rifle = rifle_scene.instantiate()
				rifle.scale = Vector3(55.0, 55.0, 55.0)
				rifle.position = Vector3(0.0, 8.0, -12.0)
				rifle.rotation_degrees = Vector3(25.0, 140.0, 45.0)
				back_attach.add_child(rifle)
			skel.add_child(back_attach)

	_update_rider_posture(0.0)
	rider_soldier.visible = is_occupied

func _apply_superbike_riding_pose(_soldier: Node3D):
	_update_rider_posture(0.0)

func _update_rider_posture(_delta: float):
	if not rider_soldier or not is_instance_valid(rider_soldier) or not rider_soldier.visible:
		return
	var skel: Skeleton3D = rider_soldier.find_child("Skeleton3D", true, false)
	if not skel:
		return

	# Dynamic lean and speed tuck:
	var steer_rad = deg_to_rad(current_steer_input)
	var speed_ratio = clampf(current_speed_kmh / top_speed_kmh, 0.0, 1.0)
	var tuck_angle = lerpf(0.0, 6.0, speed_ratio) # Aerodynamic tuck at top speed
	var fork_steer_rad = deg_to_rad(-current_steer_input * fork_steer_angle_deg)

	# 1. Hips (slight forward rotation onto saddle)
	var hips = skel.find_bone("mixamorig_Hips")
	if hips != -1:
		skel.set_bone_pose_rotation(hips, Quaternion(Vector3.RIGHT, deg_to_rad(24.0 + tuck_angle * 0.5)))

	# 2. Spine - lean forward over fuel tank with dynamic cornering lean
	var spine = skel.find_bone("mixamorig_Spine")
	if spine != -1:
		skel.set_bone_pose_rotation(spine, Quaternion.from_euler(Vector3(deg_to_rad(36.0 + tuck_angle), steer_rad * 0.22, -steer_rad * 0.12)))
	var spine1 = skel.find_bone("mixamorig_Spine1")
	if spine1 != -1:
		skel.set_bone_pose_rotation(spine1, Quaternion.from_euler(Vector3(deg_to_rad(24.0 + tuck_angle * 0.5), steer_rad * 0.18, -steer_rad * 0.08)))
	var spine2 = skel.find_bone("mixamorig_Spine2")
	if spine2 != -1:
		skel.set_bone_pose_rotation(spine2, Quaternion(Vector3.RIGHT, deg_to_rad(16.0)))

	# 3. Head & Neck - looking forward through windshield, banking slightly into turn
	var neck = skel.find_bone("mixamorig_Neck")
	if neck != -1:
		skel.set_bone_pose_rotation(neck, Quaternion.from_euler(Vector3(deg_to_rad(-28.0 - tuck_angle * 0.5), steer_rad * 0.15, 0.0)))
	var head = skel.find_bone("mixamorig_Head")
	if head != -1:
		skel.set_bone_pose_rotation(head, Quaternion.from_euler(Vector3(deg_to_rad(-38.0 - tuck_angle * 0.5), steer_rad * 0.20, 0.0)))

	# 4. Legs - straddling bike firmly onto rear footpegs
	var l_up = skel.find_bone("mixamorig_LeftUpLeg")
	if l_up != -1:
		skel.set_bone_pose_rotation(l_up, Quaternion.from_euler(Vector3(deg_to_rad(-70.0), deg_to_rad(-16.0), deg_to_rad(22.0))))
	var l_leg = skel.find_bone("mixamorig_LeftLeg")
	if l_leg != -1:
		skel.set_bone_pose_rotation(l_leg, Quaternion.from_euler(Vector3(deg_to_rad(120.0), 0.0, 0.0)))
	var l_foot = skel.find_bone("mixamorig_LeftFoot")
	if l_foot != -1:
		skel.set_bone_pose_rotation(l_foot, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0.0, deg_to_rad(-10.0))))

	var r_up = skel.find_bone("mixamorig_RightUpLeg")
	if r_up != -1:
		skel.set_bone_pose_rotation(r_up, Quaternion.from_euler(Vector3(deg_to_rad(-70.0), deg_to_rad(16.0), deg_to_rad(-22.0))))
	var r_leg = skel.find_bone("mixamorig_RightLeg")
	if r_leg != -1:
		skel.set_bone_pose_rotation(r_leg, Quaternion.from_euler(Vector3(deg_to_rad(120.0), 0.0, 0.0)))
	var r_foot = skel.find_bone("mixamorig_RightFoot")
	if r_foot != -1:
		skel.set_bone_pose_rotation(r_foot, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0.0, deg_to_rad(10.0))))

	# 5. Arms - Hand grips firmly positioned on left and right handlebars
	# Left Arm & Hand
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	if l_arm != -1:
		skel.set_bone_pose_rotation(l_arm, Quaternion.from_euler(Vector3(deg_to_rad(-98.0), deg_to_rad(28.0) + fork_steer_rad * 0.35, deg_to_rad(-25.0))))
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	if l_fore != -1:
		skel.set_bone_pose_rotation(l_fore, Quaternion.from_euler(Vector3(deg_to_rad(-35.0), deg_to_rad(-15.0), deg_to_rad(-15.0))))
	var l_hand = skel.find_bone("mixamorig_LeftHand")
	if l_hand != -1:
		skel.set_bone_pose_rotation(l_hand, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0.0, deg_to_rad(25.0))))

	# Right Arm & Hand
	var r_arm = skel.find_bone("mixamorig_RightArm")
	if r_arm != -1:
		skel.set_bone_pose_rotation(r_arm, Quaternion.from_euler(Vector3(deg_to_rad(98.0), deg_to_rad(-28.0) + fork_steer_rad * 0.35, deg_to_rad(-25.0))))
	var r_fore = skel.find_bone("mixamorig_RightForeArm")
	if r_fore != -1:
		skel.set_bone_pose_rotation(r_fore, Quaternion.from_euler(Vector3(deg_to_rad(35.0), deg_to_rad(15.0), deg_to_rad(15.0))))
	var r_hand = skel.find_bone("mixamorig_RightHand")
	if r_hand != -1:
		skel.set_bone_pose_rotation(r_hand, Quaternion.from_euler(Vector3(deg_to_rad(20.0), 0.0, deg_to_rad(-25.0))))

# -----------------------------------------------------------------------------
# Pro Real FX: Tire Smoke, Exhaust Backfires, Speed FOV & Micro-Rumble
# -----------------------------------------------------------------------------
func _setup_bike_fx():
	# 1. Tire Smoke Particle Emitter (Ultra low overhead)
	tire_smoke_emitter = CPUParticles3D.new()
	tire_smoke_emitter.name = "TireSmoke"
	tire_smoke_emitter.emitting = false
	tire_smoke_emitter.amount = 4 # Reduced to 4 quads to eliminate APU fill-rate bottleneck
	tire_smoke_emitter.lifetime = 0.20
	tire_smoke_emitter.speed_scale = 1.0
	tire_smoke_emitter.position = Vector3(0.0, 0.15, 0.95)
	tire_smoke_emitter.direction = Vector3(0.0, 0.35, 1.0).normalized()
	tire_smoke_emitter.spread = 15.0
	tire_smoke_emitter.initial_velocity_min = 2.0
	tire_smoke_emitter.initial_velocity_max = 3.5
	tire_smoke_emitter.gravity = Vector3(0.0, 0.8, 0.0)
	tire_smoke_emitter.scale_amount_min = 0.25
	tire_smoke_emitter.scale_amount_max = 0.50
	tire_smoke_emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var smoke_mat = StandardMaterial3D.new()
	smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smoke_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	smoke_mat.disable_receive_shadows = true
	smoke_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	smoke_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	smoke_mat.albedo_color = Color(0.92, 0.92, 0.94, 0.20)

	var quad = QuadMesh.new()
	quad.size = Vector2(0.15, 0.15)
	quad.material = smoke_mat
	tire_smoke_emitter.mesh = quad

	if visual_wrapper:
		visual_wrapper.add_child(tire_smoke_emitter)
	else:
		add_child(tire_smoke_emitter)

	# 2. Dual Exhaust Backfire Flame Meshes (Low overhead unshaded quads, no dynamic lights)
	var flame_mat = StandardMaterial3D.new()
	flame_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	flame_mat.disable_receive_shadows = true
	flame_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	flame_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	flame_mat.albedo_color = Color(1.0, 0.55, 0.12, 0.85)

	var flame_quad = QuadMesh.new()
	flame_quad.size = Vector2(0.06, 0.06)
	flame_quad.material = flame_mat

	exhaust_flame_left = MeshInstance3D.new()
	exhaust_flame_left.name = "ExhaustFlameL"
	exhaust_flame_left.mesh = flame_quad
	exhaust_flame_left.position = Vector3(-0.30, 0.35, 0.95)
	exhaust_flame_left.visible = false
	exhaust_flame_left.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	exhaust_flame_right = MeshInstance3D.new()
	exhaust_flame_right.name = "ExhaustFlameR"
	exhaust_flame_right.mesh = flame_quad
	exhaust_flame_right.position = Vector3(0.30, 0.35, 0.95)
	exhaust_flame_right.visible = false
	exhaust_flame_right.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	exhaust_flame_light = OmniLight3D.new()
	exhaust_flame_light.name = "ExhaustFlameLight"
	exhaust_flame_light.position = Vector3(0.0, 0.35, 0.98)
	exhaust_flame_light.light_color = Color(1.0, 0.55, 0.12)
	exhaust_flame_light.light_energy = 0.0
	exhaust_flame_light.omni_range = 0.0
	exhaust_flame_light.visible = false

	if visual_wrapper:
		visual_wrapper.add_child(exhaust_flame_left)
		visual_wrapper.add_child(exhaust_flame_right)
		visual_wrapper.add_child(exhaust_flame_light)
	else:
		add_child(exhaust_flame_left)
		add_child(exhaust_flame_right)
		add_child(exhaust_flame_light)

func _update_riding_fx(throttle: float, delta: float):
	# Tire smoke during handbrake drift or hard stop
	var should_smoke = (is_handbraking and current_speed_kmh > 10.0) or (throttle < 0.0 and current_speed_kmh > 35.0)
	if tire_smoke_emitter and tire_smoke_emitter.emitting != should_smoke:
		tire_smoke_emitter.emitting = should_smoke

	# Nitro Boost Flames or Backfire on downshift / sudden throttle release from high speed
	if is_boosting:
		if exhaust_flame_left and not exhaust_flame_left.visible: exhaust_flame_left.visible = true
		if exhaust_flame_right and not exhaust_flame_right.visible: exhaust_flame_right.visible = true
		if exhaust_flame_light and exhaust_flame_light.visible: exhaust_flame_light.visible = false
	elif backfire_timer > 0.0:
		backfire_timer -= delta
	elif last_throttle > 0.6 and throttle <= 0.0 and current_speed_kmh > 55.0:
		_trigger_backfire_pop()
		backfire_timer = 1.1
	else:
		if exhaust_flame_left and not (backfire_timer > 0.0):
			exhaust_flame_left.visible = false
		if exhaust_flame_right and not (backfire_timer > 0.0):
			exhaust_flame_right.visible = false
		if exhaust_flame_light and exhaust_flame_light.visible:
			exhaust_flame_light.visible = false
	last_throttle = throttle

	# Dynamic Speed FOV: eliminate frame-by-frame projection matrix churning and micro-rumble jitter
	if chase_camera:
		var target_fov = 77.0 if is_boosting else 75.0
		if chase_camera.fov != target_fov:
			chase_camera.fov = target_fov
		chase_camera.h_offset = 0.0
		chase_camera.v_offset = 0.0

func _trigger_backfire_pop():
	if exhaust_flame_left:
		exhaust_flame_left.visible = true
	if exhaust_flame_right:
		exhaust_flame_right.visible = true
	# Keep dynamic exhaust light strictly off to eliminate GPU forward light pass
	if exhaust_flame_light:
		exhaust_flame_light.visible = false

	var tree = get_tree()
	if tree:
		var t = tree.create_timer(0.065)
		t.timeout.connect(func():
			if exhaust_flame_left and is_instance_valid(exhaust_flame_left):
				exhaust_flame_left.visible = false
			if exhaust_flame_right and is_instance_valid(exhaust_flame_right):
				exhaust_flame_right.visible = false
			if exhaust_flame_light and is_instance_valid(exhaust_flame_light):
				exhaust_flame_light.visible = false
		)

var max_health: float = 350.0
var current_health: float = 350.0
var is_destroyed: bool = false

func take_damage(amount: float, _is_crit: Variant = false, _dir: Variant = null):
	if is_destroyed: return
	current_health = maxf(0.0, current_health - amount)
	print("[SUPERBIKE DAMAGE] Bike took %.1f damage. Remaining: %.1f/%.1f" % [amount, current_health, max_health])
	if impact_audio and not impact_audio.playing:
		impact_audio.play()
	if current_health <= 0.0:
		is_destroyed = true
		if is_occupied:
			exit_vehicle()
		current_forward_velocity = 0.0
		if engine_audio and engine_audio.playing:
			engine_audio.stop()

func _optimize_bike_meshes():
	var stack: Array[Node] = [self]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node is MeshInstance3D:
			var vol = 0.0
			if node.mesh:
				var aabb = node.mesh.get_aabb()
				vol = aabb.size.x * aabb.size.y * aabb.size.z
			if vol > 0.0 and vol < 0.004:
				node.visible = false
				node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			else:
				var is_large = (vol > 0.08) or ("body" in node.name.to_lower()) or ("fairing" in node.name.to_lower())
				if is_large:
					node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
				else:
					node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for child in node.get_children():
			stack.append(child)

