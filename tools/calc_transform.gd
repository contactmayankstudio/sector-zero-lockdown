extends SceneTree

func _init():
	print("--- COMPUTING EXACT WEAPON TRANSFORMS ---")
	
	# Let's inspect P90 carefully
	var p90_scn = load("res://scenes/weapons/models/p90.scn")
	var p90_inst = p90_scn.instantiate()
	var p90_mesh: MeshInstance3D = p90_inst.find_children("*", "MeshInstance3D", true, false)[0]
	var p90_arr = p90_mesh.mesh.surface_get_arrays(0)
	var p90_verts: PackedVector3Array = p90_arr[Mesh.ARRAY_VERTEX]
	
	# Find vertices near X = -0.49 (extreme left) and X = +0.49 (extreme right)
	var p90_neg_pts = []
	var p90_pos_pts = []
	for v in p90_verts:
		if v.x < -0.46: p90_neg_pts.append(v)
		if v.x > 0.46: p90_pos_pts.append(v)
	print("P90 neg X extreme count: ", p90_neg_pts.size(), " pos X extreme count: ", p90_pos_pts.size())
	if not p90_neg_pts.is_empty():
		var sum = Vector3.ZERO
		for v in p90_neg_pts: sum += v
		print("P90 neg extreme avg: ", sum / float(p90_neg_pts.size()))
	if not p90_pos_pts.is_empty():
		var sum = Vector3.ZERO
		for v in p90_pos_pts: sum += v
		print("P90 pos extreme avg: ", sum / float(p90_pos_pts.size()))

	# Also find P90 highest point (top rail / sight)
	var max_y = -999.0
	var top_v = Vector3.ZERO
	for v in p90_verts:
		if v.y > max_y:
			max_y = v.y
			top_v = v
	print("P90 highest vertex (Top Sight): ", top_v)

	p90_inst.free()
	
	# Inspect N7 rifle meshes: rifleN7_rifle-n7_0
	var n7_scn = load("res://scenes/weapons/models/n7_rifle.scn")
	var n7_inst = n7_scn.instantiate()
	var n7_mesh = n7_inst.find_children("*", "MeshInstance3D", true, false)[0]
	var n7_arr = n7_mesh.mesh.surface_get_arrays(0)
	var n7_verts: PackedVector3Array = n7_arr[Mesh.ARRAY_VERTEX]
	# Find extreme Z
	var n7_min_z = 9999.0; var n7_max_z = -9999.0
	var n7_min_pt = Vector3.ZERO; var n7_max_pt = Vector3.ZERO
	for v in n7_verts:
		if v.z < n7_min_z: n7_min_z = v.z; n7_min_pt = v
		if v.z > n7_max_z: n7_max_z = v.z; n7_max_pt = v
	print("N7 min Z vertex: ", n7_min_pt, " max Z vertex: ", n7_max_pt)
	n7_inst.free()

	# Inspect CAR SMG meshes
	var car_scn = load("res://scenes/weapons/models/car_smg.scn")
	var car_inst = car_scn.instantiate()
	var car_min_z = 9999.0; var car_max_z = -9999.0
	var car_min_pt = Vector3.ZERO; var car_max_pt = Vector3.ZERO
	for m in car_inst.find_children("*", "MeshInstance3D", true, false):
		if not m.mesh: continue
		var xf = m.transform
		for s in range(m.mesh.get_surface_count()):
			var arr = m.mesh.surface_get_arrays(s)
			if arr.is_empty(): continue
			for v in arr[Mesh.ARRAY_VERTEX]:
				var lv = xf * v
				if lv.z < car_min_z: car_min_z = lv.z; car_min_pt = lv
				if lv.z > car_max_z: car_max_z = lv.z; car_max_pt = lv
	print("CAR min Z vertex: ", car_min_pt, " max Z vertex: ", car_max_pt)
	car_inst.free()

	quit(0)
