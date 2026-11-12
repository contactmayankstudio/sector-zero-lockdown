extends SceneTree

func _init():
	print("--- FINDING EXACT ROTATIONS & CONVERGENCE ---")
	
	# Helper to find which Euler angles map (src_fwd -> (0,0,-1)) and (src_up -> (0,1,0))
	var solve_rot = func(src_fwd: Vector3, src_up: Vector3) -> Vector3:
		var target_fwd = Vector3(0, 0, -1)
		var target_up = Vector3(0, 1, 0)
		var target_right = target_fwd.cross(target_up).normalized() # (1, 0, 0)
		var target_basis = Basis(target_right, target_up, -target_fwd)
		
		var src_right = src_fwd.cross(src_up).normalized()
		var src_basis = Basis(src_right, src_up, -src_fwd)
		
		# We want R * src_basis = target_basis => R = target_basis * src_basis.inverse()
		var r = target_basis * src_basis.inverse()
		return r.get_euler() * (180.0 / PI)

	# 1. Negev NG7: fwd = (-1, 0, 0), up = (0, 1, 0)
	print("Negev NG7 rot: ", solve_rot.call(Vector3(-1, 0, 0), Vector3(0, 1, 0)))

	# 2. P90: fwd = (-1, 0, 0), up = (0, 1, 0)
	print("P90 rot: ", solve_rot.call(Vector3(-1, 0, 0), Vector3(0, 1, 0)))

	# 3. AKX SciFi: fwd = (0, -1, 0), up = (0, 0, 1)
	print("AKX SciFi rot: ", solve_rot.call(Vector3(0, -1, 0), Vector3(0, 0, 1)))

	# Let's inspect N7 rifle muzzle vs stock
	var n7_scn = load("res://scenes/weapons/models/n7_rifle.scn")
	var n7 = n7_scn.instantiate()
	var n7_fwd = Vector3(0, 0, -1)
	# Check diameter at Z = -12 vs Z = +3
	var n7_meshes = n7.find_children("*", "MeshInstance3D", true, false)
	var z_neg_pts = []; var z_pos_pts = []
	for m in n7_meshes:
		if not m.mesh: continue
		for s in range(m.mesh.get_surface_count()):
			var arr = m.mesh.surface_get_arrays(s)
			if arr.is_empty(): continue
			for v in arr[Mesh.ARRAY_VERTEX]:
				if v.z < -10.0: z_neg_pts.append(v)
				if v.z > 2.0: z_pos_pts.append(v)
	print("N7 neg Z pts count: ", z_neg_pts.size(), " pos Z pts count: ", z_pos_pts.size())
	# Barrel has fewer vertices and smaller radius than buttstock
	if z_neg_pts.size() < z_pos_pts.size():
		print("N7 muzzle is at -Z (forward)")
		n7_fwd = Vector3(0, 0, -1)
	else:
		print("N7 muzzle is at +Z (need 180)")
		n7_fwd = Vector3(0, 0, 1)
	print("N7 rot: ", solve_rot.call(n7_fwd, Vector3(0, 1, 0)))
	n7.free()

	# Inspect CAR SMG muzzle vs stock
	var car_scn = load("res://scenes/weapons/models/car_smg.scn")
	var car = car_scn.instantiate()
	var car_fwd = Vector3(0, 0, -1)
	var car_neg = []; var car_pos = []
	for m in car.find_children("*", "MeshInstance3D", true, false):
		if not m.mesh: continue
		var xf = m.transform
		for s in range(m.mesh.get_surface_count()):
			var arr = m.mesh.surface_get_arrays(s)
			if arr.is_empty(): continue
			for v in arr[Mesh.ARRAY_VERTEX]:
				var lv = xf * v
				if lv.z < -10.0: car_neg.append(lv)
				if lv.z > 8.0: car_pos.append(lv)
	print("CAR neg Z pts count: ", car_neg.size(), " pos Z pts count: ", car_pos.size())
	if car_neg.size() < car_pos.size():
		print("CAR muzzle is at -Z (forward)")
		car_fwd = Vector3(0, 0, -1)
	else:
		print("CAR muzzle is at +Z (need 180)")
		car_fwd = Vector3(0, 0, 1)
	print("CAR rot: ", solve_rot.call(car_fwd, Vector3(0, 1, 0)))
	car.free()

	# Inspect AK-74 with Bayonet: check compensator vs stock position
	var ak_scn = load("res://scenes/weapons/models/ak74_bayonet.scn")
	var ak = ak_scn.instantiate()
	var comp: MeshInstance3D = ak.find_child("compensator_low_main_0", true, false)
	var stock: MeshInstance3D = ak.find_child("stock_low_main_0", true, false)
	var ak_fwd = Vector3(0, 0, -1)
	if comp and stock:
		var comp_pos = comp.global_position if comp.is_inside_tree() else comp.position
		var stock_pos = stock.global_position if stock.is_inside_tree() else stock.position
		var dir = (comp_pos - stock_pos).normalized()
		print("AK-74 Compensator pos: ", comp_pos, " Stock pos: ", stock_pos)
		print("AK-74 Stock-to-Muzzle vector: ", dir)
		# Up vector: front_sights - compensator
		var fs: MeshInstance3D = ak.find_child("front_sights_low_main_0", true, false)
		var ak_up = Vector3(0, 1, 0)
		if fs:
			ak_up = (fs.position - comp_pos).normalized()
			print("AK-74 Up vector: ", ak_up)
		print("AK-74 rot: ", solve_rot.call(dir, ak_up))
	ak.free()

	quit(0)
