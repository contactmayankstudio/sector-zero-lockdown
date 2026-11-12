@tool
extends SceneTree

func _init():
	print("--- Building Realistic GTA DrivableBike.tscn ---")
	
	var bike = CharacterBody3D.new()
	bike.name = "DrivableBike"
	bike.set_script(load("res://scripts/Vehicles/DrivableBike.gd"))
	bike.add_to_group("vehicles")
	bike.add_to_group("bikes")
	bike.collision_layer = 1
	bike.collision_mask = 1
	bike.floor_snap_length = 0.3
	bike.floor_max_angle = deg_to_rad(45.0)

	# 1. Main Chassis / Rider Collision Shape
	var col = CollisionShape3D.new()
	col.name = "BodyCollision"
	var box = BoxShape3D.new()
	box.size = Vector3(0.65, 1.15, 2.10)
	col.shape = box
	col.position = Vector3(0.0, 0.58, 0.0)
	bike.add_child(col)
	col.owner = bike

	# 2. Visual Wrapper (Node that rolls / leans on Z)
	var visual_wrapper = Node3D.new()
	visual_wrapper.name = "VisualWrapper"
	bike.add_child(visual_wrapper)
	visual_wrapper.owner = bike

	# 3. Instantiate Hayabusa 3D Model
	var hayabusa_glb = load("res://assets/downloaded_bikes/hayabusa.glb")
	if hayabusa_glb:
		var model_inst = hayabusa_glb.instantiate()
		model_inst.name = "HayabusaMesh"
		# Model faces +Z in GLB, so rotate 180 deg Y to face standard Godot forward (-Z)
		model_inst.rotation_degrees = Vector3(0.0, 180.0, 0.0)
		model_inst.position = Vector3(0.0, 0.0, 0.0)
		
		# Tune materials for photorealistic superbike graphics
		_tune_hayabusa_materials(model_inst)
		
		visual_wrapper.add_child(model_inst)
		model_inst.owner = bike
		_set_owner_recursive(model_inst, bike)
		print("[BIKE] Attached hayabusa.glb with GTA metallic paint, chrome exhaust, and smoked visor!")
	else:
		printerr("[BIKE] ERROR: Failed to load res://assets/downloaded_bikes/hayabusa.glb")

	# 4. SpringArm3D & ChaseCamera
	var spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.position = Vector3(0.0, 1.35, 0.0)
	spring_arm.rotation_degrees = Vector3(-10.0, 0.0, 0.0)
	spring_arm.spring_length = 3.8
	spring_arm.margin = 0.25
	bike.add_child(spring_arm)
	spring_arm.owner = bike

	var chase_cam = Camera3D.new()
	chase_cam.name = "ChaseCamera"
	chase_cam.fov = 76.0
	chase_cam.near = 0.1
	chase_cam.current = false
	spring_arm.add_child(chase_cam)
	chase_cam.owner = bike

	# 5. Front Headlight & Glow
	var headlight = SpotLight3D.new()
	headlight.name = "Headlight"
	headlight.position = Vector3(0.0, 0.72, -1.02)
	headlight.rotation_degrees = Vector3(-4.0, 180.0, 0.0) # Aim forward (-Z), slight dip
	headlight.light_color = Color(1.0, 0.96, 0.90)
	headlight.light_energy = 3.5
	headlight.spot_range = 45.0
	headlight.spot_angle = 35.0
	headlight.shadow_enabled = true
	bike.add_child(headlight)
	headlight.owner = bike

	var hl_glow = OmniLight3D.new()
	hl_glow.name = "HeadlightGlow"
	hl_glow.position = Vector3(0.0, 0.72, -1.05)
	hl_glow.light_color = Color(1.0, 0.95, 0.85)
	hl_glow.light_energy = 1.2
	hl_glow.omni_range = 1.5
	bike.add_child(hl_glow)
	hl_glow.owner = bike

	# Rear Taillight
	var taillight = OmniLight3D.new()
	taillight.name = "Taillight"
	taillight.position = Vector3(0.0, 0.75, 1.05)
	taillight.light_color = Color(1.0, 0.10, 0.05)
	taillight.light_energy = 1.8
	taillight.omni_range = 2.5
	bike.add_child(taillight)
	taillight.owner = bike

	# 6. Audio Systems
	var engine_s = load("res://audio/vehicles/engine.wav")
	var engine_a = AudioStreamPlayer3D.new()
	engine_a.name = "EngineAudio"
	engine_a.stream = engine_s
	engine_a.unit_size = 12.0
	engine_a.max_distance = 55.0
	engine_a.bus = &"SFX"
	bike.add_child(engine_a)
	engine_a.owner = bike

	var impact_s = load("res://audio/vehicles/impact_1.wav")
	var impact_a = AudioStreamPlayer3D.new()
	impact_a.name = "ImpactAudio"
	impact_a.stream = impact_s
	impact_a.unit_size = 18.0
	impact_a.bus = &"SFX"
	bike.add_child(impact_a)
	impact_a.owner = bike

	var horn_s = load("res://audio/vehicles/honk_1.wav")
	var horn_a = AudioStreamPlayer3D.new()
	horn_a.name = "HornAudio"
	horn_a.stream = horn_s
	horn_a.unit_size = 20.0
	horn_a.bus = &"SFX"
	bike.add_child(horn_a)
	horn_a.owner = bike

	# 7. Interaction Zones (Mount & Smash)
	var mount_z = Area3D.new()
	mount_z.name = "MountZone"
	mount_z.position = Vector3(0.0, 0.5, 0.0)
	mount_z.collision_layer = 0
	mount_z.collision_mask = 1 # Player layer
	bike.add_child(mount_z)
	mount_z.owner = bike

	var mount_col = CollisionShape3D.new()
	mount_col.name = "MountShape"
	var mount_sphere = SphereShape3D.new()
	mount_sphere.radius = 3.5
	mount_col.shape = mount_sphere
	mount_z.add_child(mount_col)
	mount_col.owner = bike

	var smash_z = Area3D.new()
	smash_z.name = "SmashZone"
	smash_z.position = Vector3(0.0, 0.55, -1.05)
	smash_z.collision_layer = 0
	smash_z.collision_mask = 3 # Enemies & HitZones
	bike.add_child(smash_z)
	smash_z.owner = bike

	var smash_col = CollisionShape3D.new()
	smash_col.name = "SmashShape"
	var smash_box = BoxShape3D.new()
	smash_box.size = Vector3(1.2, 0.95, 0.9)
	smash_col.shape = smash_box
	smash_z.add_child(smash_col)
	smash_col.owner = bike

	# 8. Enter Prompt UI
	var prompt_ui = CanvasLayer.new()
	prompt_ui.name = "EnterPromptUI"
	prompt_ui.visible = false
	bike.add_child(prompt_ui)
	prompt_ui.owner = bike

	var center_c = CenterContainer.new()
	center_c.name = "CenterContainer"
	center_c.set_anchors_preset(Control.PRESET_FULL_RECT)
	prompt_ui.add_child(center_c)
	center_c.owner = bike

	var prompt_lbl = Label.new()
	prompt_lbl.name = "PromptLabel"
	prompt_lbl.text = "PRESS [F] TO RIDE HAYABUSA SUPERBIKE"
	prompt_lbl.add_theme_font_size_override("font_size", 22)
	prompt_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	prompt_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	center_c.add_child(prompt_lbl)
	prompt_lbl.owner = bike

	# 9. Drive HUD (Speedometer & Controls)
	var hud = CanvasLayer.new()
	hud.name = "DriveHUD"
	hud.visible = false
	bike.add_child(hud)
	hud.owner = bike

	var spd_lbl = Label.new()
	spd_lbl.name = "SpeedLabel"
	spd_lbl.position = Vector2(50, 465)
	spd_lbl.text = "0 KM/H"
	spd_lbl.add_theme_font_size_override("font_size", 36)
	spd_lbl.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
	spd_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hud.add_child(spd_lbl)
	spd_lbl.owner = bike

	var gear_lbl = Label.new()
	gear_lbl.name = "GearLabel"
	gear_lbl.position = Vector2(50, 515)
	gear_lbl.text = "GEAR: 1 | TACHO: 2000 RPM"
	gear_lbl.add_theme_font_size_override("font_size", 16)
	gear_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.2))
	hud.add_child(gear_lbl)
	gear_lbl.owner = bike

	var beam_lbl = Label.new()
	beam_lbl.name = "BeamLabel"
	beam_lbl.position = Vector2(50, 540)
	beam_lbl.text = "LOW BEAM [L]"
	beam_lbl.add_theme_font_size_override("font_size", 15)
	beam_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	hud.add_child(beam_lbl)
	beam_lbl.owner = bike

	var ctrl_lbl = Label.new()
	ctrl_lbl.name = "ControlsLabel"
	ctrl_lbl.position = Vector2(50, 565)
	ctrl_lbl.text = "[W/S] Throttle/Brake  [A/D] Steer & Lean  [SPACE] Drift Skid  [L] Lights  [H] Horn"
	ctrl_lbl.add_theme_font_size_override("font_size", 13)
	ctrl_lbl.add_theme_color_override("font_color", Color(0.72, 0.75, 0.78))
	hud.add_child(ctrl_lbl)
	ctrl_lbl.owner = bike

	var exit_b = Button.new()
	exit_b.name = "ExitButton"
	exit_b.position = Vector2(50, 595)
	exit_b.size = Vector2(170, 42)
	exit_b.text = "EXIT BIKE [F]"
	hud.add_child(exit_b)
	exit_b.owner = bike

	# 10. Save Packed Scene
	var packed = PackedScene.new()
	var err = packed.pack(bike)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/vehicles/DrivableBike.tscn")
		if save_err == OK:
			print("[SUCCESS] DrivableBike.tscn generated and saved successfully!")
		else:
			printerr("[ERROR] Failed to save DrivableBike.tscn: ", save_err)
	else:
		printerr("[ERROR] Failed to pack DrivableBike: ", err)

	bike.queue_free()
	quit(0)

func _tune_hayabusa_materials(root_node: Node3D):
	var chrome_mat = StandardMaterial3D.new()
	chrome_mat.resource_name = "ChromeExhaust"
	chrome_mat.albedo_color = Color(0.92, 0.94, 0.96)
	chrome_mat.metallic = 0.98
	chrome_mat.roughness = 0.10

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
					var m_name = mat.resource_name
					var node_name = curr.name.to_lower()
					
					if node_name.contains("crome") or node_name.contains("exhaust"):
						curr.set_surface_override_material(i, chrome_mat)
					elif m_name == "Material.001":
						# Metallic superbike paint & fairings
						m_dup.metallic = 0.88
						m_dup.roughness = 0.22
						m_dup.clearcoat_enabled = true
						m_dup.clearcoat = 1.0
						m_dup.clearcoat_roughness = 0.1
						curr.set_surface_override_material(i, m_dup)
					elif m_name == "Material.003":
						# Mechanical details & alloy rims
						m_dup.metallic = 0.72
						m_dup.roughness = 0.28
						curr.set_surface_override_material(i, m_dup)
					elif m_name == "Material.004" or node_name.contains("glass"):
						# Smoked aerodynamic visor
						m_dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
						m_dup.albedo_color = Color(0.08, 0.12, 0.18, 0.42)
						m_dup.metallic = 0.3
						m_dup.roughness = 0.05
						m_dup.cull_mode = BaseMaterial3D.CULL_DISABLED
						curr.set_surface_override_material(i, m_dup)
					elif m_name == "Material.005" or node_name.contains("tyre") or node_name.contains("tire"):
						# Matte rubber tires
						m_dup.albedo_color = Color(0.09, 0.09, 0.09, 1.0)
						m_dup.metallic = 0.0
						m_dup.roughness = 0.92
						curr.set_surface_override_material(i, m_dup)
					else:
						curr.set_surface_override_material(i, m_dup)
		for c in curr.get_children():
			stack.push_back(c)

func _set_owner_recursive(node: Node, new_owner: Node):
	for child in node.get_children():
		child.owner = new_owner
		_set_owner_recursive(child, new_owner)
