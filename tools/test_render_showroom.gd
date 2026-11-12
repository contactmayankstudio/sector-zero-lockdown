extends SceneTree

func _init():
	var root_node = Control.new()
	root_node.custom_minimum_size = Vector2(1280, 720)
	root_node.size = Vector2(1280, 720)
	root.add_child(root_node)
	
	var vp_container = SubViewportContainer.new()
	vp_container.size = Vector2(1280, 720)
	vp_container.stretch = true
	root_node.add_child(vp_container)
	
	var vp = SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.own_world_3d = true
	vp.transparent_bg = false
	vp_container.add_child(vp)
	
	# WorldEnvironment
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.05, 0.07, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.15, 0.2, 0.28, 1.0)
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.15
	var we = WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	
	# Camera
	var cam = Camera3D.new()
	cam.position = Vector3(0, 0.05, 1.1)
	cam.fov = 42.0
	cam.current = true
	vp.add_child(cam)
	
	# Lights
	var key_light = DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-30, 40, 0)
	key_light.light_color = Color(1.0, 0.96, 0.92)
	key_light.light_energy = 2.0
	vp.add_child(key_light)
	
	var fill_light = DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(20, -50, 0)
	fill_light.light_color = Color(0.25, 0.65, 0.95)
	fill_light.light_energy = 1.2
	vp.add_child(fill_light)
	
	var rim_light = DirectionalLight3D.new()
	rim_light.rotation_degrees = Vector3(45, 140, 0)
	rim_light.light_color = Color(0.4, 0.85, 1.0)
	rim_light.light_energy = 2.5
	vp.add_child(rim_light)
	
	var floor_accent = OmniLight3D.new()
	floor_accent.position = Vector3(0, -0.4, 0)
	floor_accent.light_color = Color(0.0, 0.8, 1.0)
	floor_accent.light_energy = 1.5
	floor_accent.omni_range = 2.5
	vp.add_child(floor_accent)
	
	# Floor Pedestal
	var disc_mesh = CylinderMesh.new()
	disc_mesh.top_radius = 0.75
	disc_mesh.bottom_radius = 0.8
	disc_mesh.height = 0.04
	var disc_mat = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.07, 0.09, 0.12)
	disc_mat.metallic = 0.85
	disc_mat.roughness = 0.35
	var disc_inst = MeshInstance3D.new()
	disc_inst.mesh = disc_mesh
	disc_inst.material_override = disc_mat
	disc_inst.position = Vector3(0, -0.32, 0)
	vp.add_child(disc_inst)
	
	# Pivot
	var pivot = Node3D.new()
	vp.add_child(pivot)
	
	# Test with M4A1
	var m4_scn = load("res://scenes/weapons/models/m4a1.tscn")
	var m4_inst = m4_scn.instantiate()
	pivot.add_child(m4_inst)
	
	# Orientation & framing
	# If Y is longest axis, rotate Z by -90 to lay horizontal
	m4_inst.rotation_degrees = Vector3(0, 0, -90)
	# Slight perspective tilt
	pivot.rotation_degrees = Vector3(10, -25, 0)
	
	# Compute transformed AABB to center
	var aabb = AABB()
	var first = true
	var meshes = m4_inst.find_children("*", "MeshInstance3D", true, false)
	if m4_inst is MeshInstance3D: meshes.append(m4_inst)
	for mi in meshes:
		if mi.mesh:
			var m_aabb = mi.transform * mi.mesh.get_aabb()
			if first:
				aabb = m_aabb
				first = false
			else:
				aabb = aabb.merge(m_aabb)
				
	var center = aabb.get_center()
	m4_inst.position = -center
	var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
	var s = 0.68 / max_dim
	m4_inst.scale = Vector3(s, s, s)
	
	await process_frame
	await process_frame
	await process_frame
	
	var img = vp.get_texture().get_image()
	DirAccess.make_dir_absolute("res://screenshots")
	img.save_png("res://screenshots/test_showroom_m4a1.png")
	print("Saved screenshots/test_showroom_m4a1.png")
	quit()
