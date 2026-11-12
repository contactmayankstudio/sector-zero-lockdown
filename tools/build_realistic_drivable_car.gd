@tool
extends SceneTree

func _init():
	print("--- Building Realistic GTA DrivableCar.tscn ---")
	
	var car = VehicleBody3D.new()
	car.name = "DrivableCar"
	car.set_script(load("res://scripts/Vehicles/DrivableCar.gd"))
	car.mass = 1500.0
	car.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	car.center_of_mass = Vector3(0.0, -0.25, 0.0)
	
	# 1. Main Chassis Collision Shape
	var col = CollisionShape3D.new()
	col.name = "BodyCollision"
	var box = BoxShape3D.new()
	box.size = Vector3(2.1, 1.35, 4.3)
	col.shape = box
	col.position = Vector3(0.0, 0.70, 0.0)
	car.add_child(col)
	col.owner = car
	
	# 2. Realistic Sedan 3D Model Instance
	var sedan_glb = load("res://assets/downloaded_cars/sedan_real.glb")
	if sedan_glb:
		var visual_inst = sedan_glb.instantiate()
		visual_inst.name = "CarMeshWrapper"
		visual_inst.rotation_degrees = Vector3(0.0, 180.0, 0.0)
		visual_inst.position = Vector3(0.0, 0.0, 0.0)
		
		# Apply GTA high-end metallic paint shader & chrome tuning
		_tune_sedan_materials(visual_inst)
		
		car.add_child(visual_inst)
		visual_inst.owner = car
		_set_owner_recursive(visual_inst, car)
		print("[CAR] Attached sedan_real.glb with GTA metallic paint & chrome!")
	else:
		printerr("[CAR] ERROR: could not load sedan_real.glb")
		
	# 3. Four VehicleWheel3D Physics Nodes
	var wheel_configs = [
		{"name": "WheelFL", "pos": Vector3(-0.817, 0.33, -1.575), "steer": true},
		{"name": "WheelFR", "pos": Vector3(0.814, 0.33, -1.575), "steer": true},
		{"name": "WheelBL", "pos": Vector3(-0.817, 0.33, 1.341), "steer": false},
		{"name": "WheelBR", "pos": Vector3(0.814, 0.33, 1.341), "steer": false}
	]
	
	for w_cfg in wheel_configs:
		var vw = VehicleWheel3D.new()
		vw.name = w_cfg.name
		vw.position = w_cfg.pos
		vw.use_as_traction = true
		vw.use_as_steering = w_cfg.steer
		vw.wheel_radius = 0.34
		vw.wheel_friction_slip = 3.2
		vw.suspension_stiffness = 38.0
		vw.suspension_max_force = 9500.0
		vw.damping_compression = 1.4
		vw.damping_relaxation = 2.0
		car.add_child(vw)
		vw.owner = car
		
	# 4. Audio Components
	var engine_s = load("res://audio/vehicles/engine.wav")
	var engine_a = AudioStreamPlayer3D.new()
	engine_a.name = "EngineAudio"
	engine_a.stream = engine_s
	engine_a.unit_size = 15.0
	engine_a.max_distance = 60.0
	engine_a.bus = &"SFX"
	car.add_child(engine_a)
	engine_a.owner = car
	
	var impact_s = load("res://audio/vehicles/impact_1.wav")
	var impact_a = AudioStreamPlayer3D.new()
	impact_a.name = "ImpactAudio"
	impact_a.stream = impact_s
	impact_a.unit_size = 20.0
	impact_a.bus = &"SFX"
	car.add_child(impact_a)
	impact_a.owner = car

	var horn_s = load("res://audio/vehicles/honk_1.wav")
	var horn_a = AudioStreamPlayer3D.new()
	horn_a.name = "HornAudio"
	horn_a.stream = horn_s
	horn_a.unit_size = 25.0
	horn_a.bus = &"SFX"
	car.add_child(horn_a)
	horn_a.owner = car

	# 5. Dual Front Headlights
	var hl_l = SpotLight3D.new()
	hl_l.name = "HeadlightL"
	hl_l.position = Vector3(-0.75, 0.65, -2.15)
	hl_l.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	hl_l.light_color = Color(1.0, 0.96, 0.88)
	hl_l.light_energy = 3.5
	hl_l.spot_range = 50.0
	hl_l.spot_angle = 35.0
	car.add_child(hl_l)
	hl_l.owner = car

	var hl_r = SpotLight3D.new()
	hl_r.name = "HeadlightR"
	hl_r.position = Vector3(0.75, 0.65, -2.15)
	hl_r.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	hl_r.light_color = Color(1.0, 0.96, 0.88)
	hl_r.light_energy = 3.5
	hl_r.spot_range = 50.0
	hl_r.spot_angle = 35.0
	car.add_child(hl_r)
	hl_r.owner = car

	# 6. Smooth Third-Person Chase Camera
	var cam = Camera3D.new()
	cam.name = "ChaseCamera"
	cam.position = Vector3(0.0, 2.3, 5.8)
	cam.rotation_degrees = Vector3(-12.0, 0.0, 0.0)
	cam.fov = 76.0
	car.add_child(cam)
	cam.owner = car

	# 7. Interaction Zones
	var door_zone = Area3D.new()
	door_zone.name = "DoorZone"
	door_zone.position = Vector3(-1.6, 0.6, 0.0)
	door_zone.collision_layer = 0
	door_zone.collision_mask = 1
	car.add_child(door_zone)
	door_zone.owner = car
	
	var door_col = CollisionShape3D.new()
	door_col.name = "Col"
	var door_box = BoxShape3D.new()
	door_box.size = Vector3(2.0, 2.0, 3.5)
	door_col.shape = door_box
	door_zone.add_child(door_col)
	door_col.owner = car

	var smash_zone = Area3D.new()
	smash_zone.name = "SmashZone"
	smash_zone.position = Vector3(0.0, 0.55, -2.2)
	smash_zone.collision_layer = 0
	smash_zone.collision_mask = 3
	car.add_child(smash_zone)
	smash_zone.owner = car
	
	var smash_col = CollisionShape3D.new()
	smash_col.name = "Col"
	var smash_box = BoxShape3D.new()
	smash_box.size = Vector3(2.2, 1.2, 1.2)
	smash_col.shape = smash_box
	smash_zone.add_child(smash_col)
	smash_col.owner = car

	# 8. Enter Prompt UI & Drive HUD
	var prompt_ui = CanvasLayer.new()
	prompt_ui.name = "EnterPromptUI"
	prompt_ui.visible = false
	car.add_child(prompt_ui)
	prompt_ui.owner = car
	
	var center_c = CenterContainer.new()
	center_c.name = "CenterContainer"
	center_c.set_anchors_preset(Control.PRESET_FULL_RECT)
	prompt_ui.add_child(center_c)
	center_c.owner = car
	
	var prompt_lbl = Label.new()
	prompt_lbl.name = "PromptLabel"
	prompt_lbl.text = "PRESS [F] TO DRIVE GTA SEDAN"
	prompt_lbl.add_theme_font_size_override("font_size", 22)
	prompt_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	prompt_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	center_c.add_child(prompt_lbl)
	prompt_lbl.owner = car

	var hud = CanvasLayer.new()
	hud.name = "DriveHUD"
	hud.visible = false
	car.add_child(hud)
	hud.owner = car
	
	var spd_lbl = Label.new()
	spd_lbl.name = "SpeedLabel"
	spd_lbl.position = Vector2(50, 480)
	spd_lbl.text = "0 KM/H"
	spd_lbl.add_theme_font_size_override("font_size", 32)
	spd_lbl.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	hud.add_child(spd_lbl)
	spd_lbl.owner = car
	
	var exit_b = Button.new()
	exit_b.name = "ExitButton"
	exit_b.position = Vector2(50, 540)
	exit_b.size = Vector2(180, 45)
	exit_b.text = "EXIT VEHICLE [F]"
	hud.add_child(exit_b)
	exit_b.owner = car

	# 9. Save PackedScene
	var packed = PackedScene.new()
	var err = packed.pack(car)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/vehicles/DrivableCar.tscn")
		if save_err == OK:
			print("[SUCCESS] DrivableCar.tscn updated with realistic GTA sedan without warnings!")
		else:
			print("[ERROR] Failed to save DrivableCar.tscn: ", save_err)
	else:
		print("[ERROR] Failed to pack DrivableCar: ", err)
		
	car.queue_free()
	quit(0)

func _tune_sedan_materials(root_node: Node3D):
	var stack = [root_node]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D and curr.mesh:
			for i in range(curr.mesh.get_surface_count()):
				var mat = curr.get_surface_override_material(i)
				if not mat:
					mat = curr.mesh.surface_get_material(i)
				if mat is StandardMaterial3D:
					var m_dup = mat.duplicate()
					if mat.resource_name.contains("Car_Paint"):
						m_dup.metallic = 0.95
						m_dup.roughness = 0.18
						m_dup.clearcoat_enabled = true
						m_dup.clearcoat = 1.0
						m_dup.clearcoat_roughness = 0.1
					elif mat.resource_name.contains("Chrome"):
						m_dup.metallic = 1.0
						m_dup.roughness = 0.10
					elif mat.resource_name.contains("Glass"):
						m_dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
						m_dup.roughness = 0.05
					curr.set_surface_override_material(i, m_dup)
		for c in curr.get_children():
			stack.push_back(c)

func _set_owner_recursive(node: Node, new_owner: Node):
	for child in node.get_children():
		child.owner = new_owner
		_set_owner_recursive(child, new_owner)
