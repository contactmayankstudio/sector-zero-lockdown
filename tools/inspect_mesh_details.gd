extends SceneTree

func _init():
	var ps = load("res://scenes/weapons/models/akx_scifi.scn")
	var inst = ps.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	
	# Let's find vertices at Y < -0.5 (near minimum Y)
	# and vertices at Y > 0.15 (near maximum Y)
	var low_y_verts = []
	var high_y_verts = []
	for m in meshes:
		if not m.mesh: continue
		for s in range(m.mesh.get_surface_count()):
			var arrs = m.mesh.surface_get_arrays(s)
			if arrs.size() > Mesh.ARRAY_VERTEX:
				for v in arrs[Mesh.ARRAY_VERTEX]:
					var gv = m.transform * v
					if gv.y < -0.5:
						low_y_verts.append(gv)
					elif gv.y > 0.15:
						high_y_verts.append(gv)
						
	print("AKX Low Y verts count: ", low_y_verts.size())
	if not low_y_verts.is_empty():
		print("  Sample low Y (muzzle?): ", low_y_verts[0], " to ", low_y_verts[min(5, low_y_verts.size()-1)])
	print("AKX High Y verts count: ", high_y_verts.size())
	if not high_y_verts.is_empty():
		print("  Sample high Y (stock?): ", high_y_verts[0], " to ", high_y_verts[min(5, high_y_verts.size()-1)])
		
	# Same for negev
	var ps_neg = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst_neg = ps_neg.instantiate()
	var meshes_neg = inst_neg.find_children("*", "MeshInstance3D", true, false)
	var low_x_verts = []
	var high_x_verts = []
	var low_z_verts = []
	var high_z_verts = []
	for m in meshes_neg:
		if not m.mesh: continue
		for s in range(m.mesh.get_surface_count()):
			var arrs = m.mesh.surface_get_arrays(s)
			if arrs.size() > Mesh.ARRAY_VERTEX:
				for v in arrs[Mesh.ARRAY_VERTEX]:
					var gv = m.transform * v
					if gv.x < -0.3:
						low_x_verts.append(gv)
					elif gv.x > 0.3:
						high_x_verts.append(gv)
					if gv.z < -0.1:
						low_z_verts.append(gv)
					elif gv.z > 0.1:
						high_z_verts.append(gv)
	print("Negev Low X (muzzle?): ", low_x_verts[0] if low_x_verts.size() > 0 else "none")
	print("Negev High X (stock?): ", high_x_verts[0] if high_x_verts.size() > 0 else "none")
	print("Negev Low Z: ", low_z_verts[0] if low_z_verts.size() > 0 else "none")
	print("Negev High Z: ", high_z_verts[0] if high_z_verts.size() > 0 else "none")
	
	quit(0)
