@tool
extends SceneTree

func _init():
	print("--- Building Optimized DrivableCar.tscn with Kenney HD Police Cruiser ---")
	var car = VehicleBody3D.new()
	car.name = "DrivableCar"
	car.set_script(load("res://scripts/Vehicles/DrivableCar.gd"))
	car.mass = 1450.0
	car.collision_layer = 1
	car.collision_mask = 3
	
	# Main Car Body Collision Shape
	var col = CollisionShape3D.new()
	col.name = "BodyCollision"
	var box = BoxShape3D.new()
	box.size = Vector3(1.95, 1.35, 3.8)
	col.shape = box
	col.position = Vector3(0, 0.72, 0)
	car.add_child(col)
	col.owner = car

	# Visual Police Car Body Mesh
	var police_scene = load("res://assets/3d/vehicles/police.glb")
	if police_scene:
		var police_inst = police_scene.instantiate()
		police_inst.name = "CarMeshWrapper"
		# Hide/remove loose wheels from GLB since VehicleWheel3D will render separate wheels
		for w_name in ["wheel-front-left", "wheel-front-right", "wheel-back-left", "wheel-back-right"]:
			var w_node = police_inst.find_child(w_name, true, false)
			if w_node:
				w_node.visible = false
		# Rotate 180 on Y so front faces -Z (Godot forward)
		police_inst.rotation_degrees = Vector3(0, 180, 0)
		police_inst.scale = Vector3(1.3, 1.3, 1.3)
		police_inst.position = Vector3(0, 0.12, 0)
		car.add_child(police_inst)
		police_inst.owner = car
		_set_owner_recursive(police_inst, car)

	# 4 VehicleWheel3D nodes with rotating Wheel meshes
	var wheel_scene = load("res://assets/3d/vehicles/wheel-racing.glb")
	var wheel_configs = [
		{"name": "WheelFL", "pos": Vector3(-0.75, 0.38, -1.05), "steer": true, "traction": true, "y_rot": 180.0},
		{"name": "WheelFR", "pos": Vector3(0.75, 0.38, -1.05), "steer": true, "traction": true, "y_rot": 0.0},
		{"name": "WheelBL", "pos": Vector3(-0.75, 0.38, 1.05), "steer": false, "traction": true, "y_rot": 180.0},
		{"name": "WheelBR", "pos": Vector3(0.75, 0.38, 1.05), "steer": false, "traction": true, "y_rot": 0.0},
	]

	for w_cfg in wheel_configs:
		var wheel = VehicleWheel3D.new()
		wheel.name = w_cfg.name
		wheel.position = w_cfg.pos
		wheel.use_as_steering = w_cfg.steer
		wheel.use_as_traction = w_cfg.traction
		wheel.wheel_radius = 0.38
		wheel.wheel_rest_length = 0.15
		wheel.wheel_friction_slip = 3.2
		wheel.suspension_stiffness = 35.0
		wheel.suspension_max_force = 9000.0
		wheel.damping_compression = 1.4
		wheel.damping_relaxation = 2.0
		car.add_child(wheel)
		wheel.owner = car

		if wheel_scene:
			var w_mesh_inst = wheel_scene.instantiate()
			w_mesh_inst.name = "WheelMesh"
			w_mesh_inst.scale = Vector3(1.3, 1.3, 1.3)
			w_mesh_inst.rotation_degrees = Vector3(0, w_cfg.y_rot, 0)
			wheel.add_child(w_mesh_inst)
			w_mesh_inst.owner = car
			_set_owner_recursive(w_mesh_inst, car)

	# Audio Players
	var engine_p = AudioStreamPlayer3D.new()
	engine_p.name = "EngineAudio"
	var engine_stream = load("res://audio/vehicles/engine.wav")
	if engine_stream:
		engine_p.stream = engine_stream
	engine_p.unit_size = 15.0
	engine_p.max_distance = 60.0
	engine_p.bus = "SFX"
	car.add_child(engine_p)
	engine_p.owner = car

	var impact_p = AudioStreamPlayer3D.new()
	impact_p.name = "ImpactAudio"
	var impact_stream = load("res://audio/vehicles/impact_1.wav")
	if impact_stream:
		impact_p.stream = impact_stream
	impact_p.unit_size = 20.0
	impact_p.bus = "SFX"
	car.add_child(impact_p)
	impact_p.owner = car

	var horn_p = AudioStreamPlayer3D.new()
	horn_p.name = "HornAudio"
	var horn_stream = load("res://audio/vehicles/honk_1.wav")
	if horn_stream:
		horn_p.stream = horn_stream
	horn_p.unit_size = 25.0
	horn_p.bus = "SFX"
	car.add_child(horn_p)
	horn_p.owner = car

	# Headlights
	var hl_l = SpotLight3D.new()
	hl_l.name = "HeadlightL"
	hl_l.position = Vector3(-0.6, 0.65, -1.9)
	hl_l.rotation_degrees = Vector3(0, 180, 0)
	hl_l.spot_range = 45.0
	hl_l.spot_angle = 35.0
	hl_l.light_energy = 3.5
	hl_l.light_color = Color(1.0, 0.96, 0.88)
	car.add_child(hl_l)
	hl_l.owner = car

	var hl_r = SpotLight3D.new()
	hl_r.name = "HeadlightR"
	hl_r.position = Vector3(0.6, 0.65, -1.9)
	hl_r.rotation_degrees = Vector3(0, 180, 0)
	hl_r.spot_range = 45.0
	hl_r.spot_angle = 35.0
	hl_r.light_energy = 3.5
	hl_r.light_color = Color(1.0, 0.96, 0.88)
	car.add_child(hl_r)
	hl_r.owner = car

	# GTA 3rd-Person ChaseCamera
	var chase_cam = Camera3D.new()
	chase_cam.name = "ChaseCamera"
	chase_cam.current = false
	chase_cam.fov = 76.0
	chase_cam.position = Vector3(0.0, 2.4, 5.8)
	chase_cam.rotation_degrees = Vector3(-12.0, 0.0, 0.0)
	car.add_child(chase_cam)
	chase_cam.owner = car

	# Door Interaction Zone (Driver Left Side)
	var door_zone = Area3D.new()
	door_zone.name = "DoorZone"
	door_zone.position = Vector3(-1.6, 0.6, 0)
	door_zone.collision_layer = 0
	door_zone.collision_mask = 1
	car.add_child(door_zone)
	door_zone.owner = car
	var door_col = CollisionShape3D.new()
	var door_box = BoxShape3D.new()
	door_box.size = Vector3(3.2, 2.5, 3.5)
	door_col.shape = door_box
	door_zone.add_child(door_col)
	door_col.owner = car

	# Front Bumper Smash Zone (Roadkill physics)
	var smash_zone = Area3D.new()
	smash_zone.name = "SmashZone"
	smash_zone.position = Vector3(0, 0.55, -1.9)
	smash_zone.collision_layer = 0
	smash_zone.collision_mask = 3
	car.add_child(smash_zone)
	smash_zone.owner = car
	var smash_col = CollisionShape3D.new()
	var smash_box = BoxShape3D.new()
	smash_box.size = Vector3(2.2, 1.3, 1.4)
	smash_col.shape = smash_box
	smash_zone.add_child(smash_col)
	smash_col.owner = car

	# UI: Enter Prompt UI
	var prompt_ui = CanvasLayer.new()
	prompt_ui.name = "EnterPromptUI"
	prompt_ui.visible = false
	car.add_child(prompt_ui)
	prompt_ui.owner = car
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.anchors_preset = Control.PRESET_FULL_RECT
	prompt_ui.add_child(center)
	center.owner = car
	var lbl = Label.new()
	lbl.name = "PromptLabel"
	lbl.text = "PRESS [F] TO DRIVE POLICE CRUISER"
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	center.add_child(lbl)
	lbl.owner = car

	# UI: Drive HUD (Speedometer & Exit Button)
	var hud_layer = CanvasLayer.new()
	hud_layer.name = "DriveHUD"
	hud_layer.visible = false
	car.add_child(hud_layer)
	hud_layer.owner = car

	var speed_lbl = Label.new()
	speed_lbl.name = "SpeedLabel"
	speed_lbl.text = "0 KM/H"
	speed_lbl.position = Vector2(50, 480)
	speed_lbl.add_theme_font_size_override("font_size", 32)
	speed_lbl.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	speed_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hud_layer.add_child(speed_lbl)
	speed_lbl.owner = car

	var btn = Button.new()
	btn.name = "ExitButton"
	btn.text = "EXIT VEHICLE [F]"
	btn.position = Vector2(50, 540)
	btn.size = Vector2(180, 45)
	hud_layer.add_child(btn)
	btn.owner = car

	# Save PackedScene
	var packed = PackedScene.new()
	var err = packed.pack(car)
	if err == OK:
		DirAccess.make_dir_absolute("res://scenes/vehicles")
		var save_err = ResourceSaver.save(packed, "res://scenes/vehicles/DrivableCar.tscn")
		if save_err == OK:
			print("[SUCCESS] Fast & Optimized DrivableCar.tscn created successfully!")
		else:
			print("[ERROR] Failed to save scene: ", save_err)
	else:
		print("[ERROR] Failed to pack scene: ", err)
	quit(0)

func _set_owner_recursive(node: Node, new_owner: Node):
	for c in node.get_children():
		c.owner = new_owner
		_set_owner_recursive(c, new_owner)
