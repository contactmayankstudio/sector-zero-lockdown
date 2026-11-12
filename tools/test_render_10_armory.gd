extends SceneTree

func _init():
	print("--- TESTING 10 ARMORY WEAPONS ORIENTATION & CENTERING ---")
	
	var weapons = [
		"usp45", "m4a1", "remington870", "ak47", "desert_eagle",
		"mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"
	]
	
	var orientations = {
		"usp45": Vector3(-90, 0, 90),
		"m4a1": Vector3(-90, 0, 90),
		"remington870": Vector3(-90, 0, 90),
		"ak47": Vector3(-90, 0, 90),
		"desert_eagle": Vector3(-90, 0, 90),
		"mp5": Vector3(0, 90, 0),
		"awp": Vector3(-90, 0, 90),
		"combat_knife": Vector3(-90, 0, 90),
		"crossbow": Vector3(-90, 0, 90),
		"grenade_launcher": Vector3(0, 90, 0)
	}
	
	# Setup render viewport
	var root_node = Control.new()
	root_node.size = Vector2(1280, 720)
	root.add_child(root_node)
	
	var vpc = SubViewportContainer.new()
	vpc.size = Vector2(1280, 720)
	vpc.stretch = true
	root_node.add_child(vpc)
	
	var vp = SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.own_world_3d = true
	vpc.add_child(vp)
	
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.05, 0.07, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.25, 0.35, 1.0)
	env.ambient_light_energy = 0.8
	var we = WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0, 0.08, 1.25)
	cam.fov = 42.0
	cam.current = true
	vp.add_child(cam)
	
	var key_light = DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-30, 35, 0)
	key_light.light_energy = 2.0
	vp.add_child(key_light)
	
	var fill_light = DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(20, -45, 0)
	fill_light.light_color = Color(0.2, 0.65, 0.95)
	fill_light.light_energy = 1.2
	vp.add_child(fill_light)
	
	var rim_light = DirectionalLight3D.new()
	rim_light.rotation_degrees = Vector3(45, 140, 0)
	rim_light.light_color = Color(0.4, 0.85, 1.0)
	rim_light.light_energy = 2.5
	vp.add_child(rim_light)
	
	# Pedestal
	var disc = CylinderMesh.new()
	disc.top_radius = 0.8
	disc.bottom_radius = 0.85
	disc.height = 0.04
	var disc_mat = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.08, 0.1, 0.14)
	disc_mat.metallic = 0.85
	disc_mat.roughness = 0.3
	var ped = MeshInstance3D.new()
	ped.mesh = disc
	ped.material_override = disc_mat
	ped.position = Vector3(0, -0.34, 0)
	vp.add_child(ped)
	
	var pivot = Node3D.new()
	pivot.rotation_degrees = Vector3(-5, 20, 0) # 3/4 showcase angle
	vp.add_child(pivot)
	
	for wid in ["m4a1", "usp45", "remington870", "ak47", "awp", "mp5"]:
		var scn_path = "res://scenes/weapons/models/%s.tscn" % wid
		var scn = load(scn_path)
		var inst = scn.instantiate()
		pivot.add_child(inst)
		
		var rot = orientations.get(wid, Vector3.ZERO)
		inst.rotation_degrees = rot
		
		# Compute local AABB
		var aabb = AABB()
		var first = true
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		if inst is MeshInstance3D: meshes.append(inst)
		for mi in meshes:
			if mi.mesh:
				var m_aabb = mi.transform * mi.mesh.get_aabb()
				if first:
					aabb = m_aabb
					first = false
				else:
					aabb = aabb.merge(m_aabb)
					
		var center = aabb.get_center()
		var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
		var target_size = 0.72
		var s = target_size / max_dim
		inst.scale = Vector3(s, s, s)
		
		# Rotate center by inst.transform.basis to match pivot coordinate system
		var rot_center = inst.transform.basis * center
		inst.position = -rot_center * s + Vector3(0, 0.04, 0)
		
		for f in range(12):
			await process_frame
			
		var img = vp.get_texture().get_image()
		img.save_png("screenshots/test_armory_profile_%s.png" % wid)
		print("  [SAVED] screenshots/test_armory_profile_%s.png" % wid)
		inst.queue_free()
		await process_frame
		
	print("DONE!")
	quit(0)
