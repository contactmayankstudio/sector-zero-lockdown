extends SceneTree

func _init():
	print("--- SOLVING AKX SCIFI ROTATION ---")
	# In akx_scifi:
	# v_barrel points along (0, -1, 0) (from stock at +Y to muzzle at -Y)
	# v_up (from grip at -Z to sights at +Z) points along (0, 0, 1)
	var v_barrel = Vector3(0, -1, 0)
	var v_up = Vector3(0, 0, 1)
	
	# We want:
	# v_barrel -> Vector3(0, 0, -1) (Forward)
	# v_up -> Vector3(0, 1, 0) (Up)
	
	var found = []
	for rx in range(-180, 181, 45):
		for ry in range(-180, 181, 45):
			for rz in range(-180, 181, 45):
				var rot = Vector3(rx, ry, rz)
				var node = Node3D.new()
				node.rotation_degrees = rot
				var b = node.transform.basis
				var transformed_barrel = b * v_barrel
				var transformed_up = b * v_up
				node.free()
				
				if transformed_barrel.distance_to(Vector3(0, 0, -1)) < 0.05 and transformed_up.distance_to(Vector3(0, 1, 0)) < 0.05:
					found.append(rot)
					print("MATCH FOR AKX: rot = ", rot)
					
	print("\n--- SOLVING NEGEV NG7 ROTATION ---")
	# In negev:
	# Muzzle at (-0.334, 0.166, 0.001), Stock at (0.311, 0.114, 0.018)
	# So v_barrel is normalized((-0.334 - 0.311, 0.166 - 0.114, 0.001 - 0.018))
	var neg_barrel = (Vector3(-0.334, 0.166, 0.001) - Vector3(0.311, 0.114, 0.018)).normalized()
	# Up is top sights (+Y)
	var neg_up = Vector3(0, 1, 0)
	print("Negev raw barrel vector: ", neg_barrel)
	
	var neg_found = []
	for rx in range(-180, 181, 45):
		for ry in range(-180, 181, 45):
			for rz in range(-180, 181, 45):
				var rot = Vector3(rx, ry, rz)
				var node = Node3D.new()
				node.rotation_degrees = rot
				var b = node.transform.basis
				var transformed_barrel = b * neg_barrel
				var transformed_up = b * neg_up
				node.free()
				
				if transformed_barrel.distance_to(Vector3(0, 0, -1)) < 0.2 and transformed_up.distance_to(Vector3(0, 1, 0)) < 0.2:
					neg_found.append({"rot": rot, "b_err": transformed_barrel.distance_to(Vector3(0, 0, -1)), "u_err": transformed_up.distance_to(Vector3(0, 1, 0))})
					
	neg_found.sort_custom(func(a, b): return (a.b_err + a.u_err) < (b.b_err + b.u_err))
	for m in neg_found.slice(0, 5):
		print("Negev Candidate: rot = ", m.rot, " barrel_err = ", m.b_err, " up_err = ", m.u_err)
		
	print("\n--- SOLVING CAR SMG ROTATION ---")
	# Muzzle at -Z, Stock at +Z, Up at +Y
	var car_barrel = Vector3(0, 0, -1)
	var car_up = Vector3(0, 1, 0)
	for rx in range(-180, 181, 45):
		for ry in range(-180, 181, 45):
			for rz in range(-180, 181, 45):
				var rot = Vector3(rx, ry, rz)
				var node = Node3D.new()
				node.rotation_degrees = rot
				var b = node.transform.basis
				var transformed_barrel = b * car_barrel
				var transformed_up = b * car_up
				node.free()
				if transformed_barrel.distance_to(Vector3(0, 0, -1)) < 0.05 and transformed_up.distance_to(Vector3(0, 1, 0)) < 0.05:
					print("MATCH FOR CAR SMG: rot = ", rot)
					
	quit(0)
