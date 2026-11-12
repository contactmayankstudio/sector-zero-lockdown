@tool
extends SceneTree

func _init():
	print("=== INSPECTING DOWNLOADED ENVIRONMENTS ===")
	var envs = {
		"supermarket": "/home/am/Downloads/envarment/super_market_for_free.glb",
		"metro": "/home/am/Downloads/envarment/old_metro_tunnel_free.glb",
		"highway": "/home/am/Downloads/envarment/fixed_new_york_highway_interstate_95.glb",
		"horror_corridor": "/home/am/Downloads/envarment/horror_corridor_vr_room_baked.glb",
		"old_bar": "/home/am/Downloads/envarment/old_bar.glb",
		"city_pack": "/home/am/Downloads/envarment/city_pack_3.glb",
		"castle": "/home/am/Downloads/envarment/castle_of_loarre.glb"
	}
	
	for name in envs:
		var path = envs[name]
		var file = FileAccess.open(path, FileAccess.READ)
		if not file:
			print("Could not open: ", path)
			continue
		var size_mb = file.get_length() / (1024.0 * 1024.0)
		file.close()
		
		print("\n--------------------------------------------------")
		print("Environment: ", name, " (", size_mb, " MB)")
		var gltf = GLTFDocument.new()
		var state = GLTFState.new()
		var err = gltf.append_from_file(path, state)
		if err != OK:
			print("  GLTF append error: ", err)
			continue
		var root_node = gltf.generate_scene(state)
		if not root_node:
			print("  Could not generate scene!")
			continue
			
		var meshes = root_node.find_children("*", "MeshInstance3D", true, false)
		print("  Total MeshInstances: ", meshes.size())
		
		# Compute total AABB
		var total_aabb = AABB()
		var first = true
		for m in meshes:
			if m.mesh:
				var m_aabb = m.get_aabb()
				# transform aabb to root space
				var xform = root_node.transform.affine_inverse() * m.global_transform
				var transformed_aabb = xform * m_aabb
				if first:
					total_aabb = transformed_aabb
					first = false
				else:
					total_aabb = total_aabb.merge(transformed_aabb)
					
		print("  Total Bounds: Pos=", total_aabb.position, " Size=", total_aabb.size)
		print("  X range: [", total_aabb.position.x, " to ", total_aabb.position.x + total_aabb.size.x, "]")
		print("  Y range: [", total_aabb.position.y, " to ", total_aabb.position.y + total_aabb.size.y, "]")
		print("  Z range: [", total_aabb.position.z, " to ", total_aabb.position.z + total_aabb.size.z, "]")
		
		root_node.free()
		
	quit(0)
