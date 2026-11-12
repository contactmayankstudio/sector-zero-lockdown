extends SceneTree

func _init():
	var scn = load("res://scenes/weapons/models/usp45.tscn")
	var inst = scn.instantiate()
	var mi = inst.find_child("*USP45*", true, false)
	if not mi and inst is MeshInstance3D: mi = inst
	print("USP45 inst name: ", inst.name)
	for child in inst.get_children():
		print("  child: ", child.name, " class: ", child.get_class())
		if child is MeshInstance3D:
			mi = child
	if mi and mi.mesh:
		var aabb = mi.mesh.get_aabb()
		print("aabb: ", aabb)
		print("aabb center: ", aabb.get_center())
		print("aabb size: ", aabb.size)
		# Let's inspect some vertices
		var arrs = mi.mesh.surface_get_arrays(0)
		var verts = arrs[Mesh.ARRAY_VERTEX]
		var min_v = Vector3.INF
		var max_v = -Vector3.INF
		for v in verts:
			min_v = min_v.min(v)
			max_v = max_v.max(v)
		print("verts count: ", verts.size())
		print("vertex bounds: min=", min_v, " max=", max_v)
		
		# Find highest point (sight) and lowest point (grip) and furthest forward (muzzle)
		var highest_y = -999.0
		var lowest_y = 999.0
		var highest_z = -999.0
		var lowest_z = 999.0
		for v in verts:
			if v.y > highest_y: highest_y = v.y
			if v.y < lowest_y: lowest_y = v.y
			if v.z > highest_z: highest_z = v.z
			if v.z < lowest_z: lowest_z = v.z
		print("y: [", lowest_y, ", ", highest_y, "]")
		print("z: [", lowest_z, ", ", highest_z, "]")
	quit()
