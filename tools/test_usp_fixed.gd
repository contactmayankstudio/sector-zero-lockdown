extends SceneTree

func _init():
	var wid = "usp45"
	var scn = load("res://scenes/weapons/models/%s.tscn" % wid)
	var inst = scn.instantiate()
	var base_rot = Vector3(90, -90, 0)
	inst.rotation_degrees = base_rot
	
	var aabb = AABB()
	var first = true
	var meshes_found = inst.find_children("*", "MeshInstance3D", true, false)
	if inst is MeshInstance3D: meshes_found.append(inst)
	for mi in meshes_found:
		if mi.mesh:
			var m_aabb = mi.transform * mi.mesh.get_aabb()
			if first:
				aabb = m_aabb
				first = false
			else:
				aabb = aabb.merge(m_aabb)
				
	var center = aabb.get_center()
	var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
	var target_size = 0.42
	var s = target_size / max_dim
	inst.scale = Vector3(s, s, s)
	# NOTE: inst.transform.basis already has scale s!
	# So inst.transform.basis * center is already scaled by s!
	var rot_center = inst.transform.basis * center
	inst.position = -rot_center + Vector3(0, 0.04, 0)
	
	print("USP45 max_dim: ", max_dim, " scale: ", s)
	print("aabb: ", aabb)
	print("center: ", center)
	print("rot_center: ", rot_center)
	print("inst.position: ", inst.position)
	
	var min_w = Vector3.INF
	var max_w = -Vector3.INF
	for mi in meshes_found:
		if mi.mesh:
			var arrs = mi.mesh.surface_get_arrays(0)
			var verts = arrs[Mesh.ARRAY_VERTEX]
			for v in verts:
				var local_v = mi.transform * v
				var world_v = inst.transform * local_v
				min_w = min_w.min(world_v)
				max_w = max_w.max(world_v)
	print("World bounds of USP45: min=", min_w, " max=", max_w)
	print("World size: ", max_w - min_w)
	print("World center: ", (min_w + max_w) * 0.5)
	inst.free()
	quit()
