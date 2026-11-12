extends SceneTree

func _init():
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)
	
	await process_frame
	await process_frame
	
	var check_pos = Vector3(72.0, 0.2, 58.0)
	print("Searching for mesh at pos: ", check_pos)
	
	var stack = [inst]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node is MeshInstance3D:
			var g_pos = node.global_position
			var aabb = node.get_aabb() if node.mesh else AABB()
			var g_aabb = Transform3D(node.global_transform.basis, g_pos) * aabb
			if g_aabb.has_point(check_pos) or g_pos.distance_to(check_pos) < 5.0:
				var mat_name = "null"
				if node.material_override:
					mat_name = node.material_override.resource_name + " color: " + str(node.material_override.albedo_color if "albedo_color" in node.material_override else "")
				elif node.mesh and node.mesh.get_surface_count() > 0:
					var m = node.mesh.surface_get_material(0)
					if m:
						mat_name = m.resource_name + " color: " + str(m.albedo_color if "albedo_color" in m else "")
				print("FOUND MESH: ", node.name, " parent: ", (node.get_parent().name if node.get_parent() else ""), " pos: ", g_pos, " mat: ", mat_name)
		for c in node.get_children():
			stack.append(c)
			
	quit(0)
