extends SceneTree

func _init():
	print("--- COMPUTING EXACT BASIS & EULER ANGLES ---")
	
	# Negev NG7
	# Let's inspect raw negev vertices to find exact muzzle point and buttstock point and top sight point!
	var ps = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = ps.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	
	# Find extreme points
	var min_x_pt = Vector3(1e9, 1e9, 1e9)
	var max_x_pt = Vector3(-1e9, -1e9, -1e9)
	var min_y_pt = Vector3(1e9, 1e9, 1e9)
	var max_y_pt = Vector3(-1e9, -1e9, -1e9)
	var min_z_pt = Vector3(1e9, 1e9, 1e9)
	var max_z_pt = Vector3(-1e9, -1e9, -1e9)
	
	for m in meshes:
		if not m.mesh: continue
		for s in range(m.mesh.get_surface_count()):
			var arrs = m.mesh.surface_get_arrays(s)
			if arrs.size() > Mesh.ARRAY_VERTEX:
				for v in arrs[Mesh.ARRAY_VERTEX]:
					var gv = m.transform * v
					if gv.x < min_x_pt.x: min_x_pt = gv
					if gv.x > max_x_pt.x: max_x_pt = gv
					if gv.y < min_y_pt.y: min_y_pt = gv
					if gv.y > max_y_pt.y: max_y_pt = gv
					if gv.z < min_z_pt.z: min_z_pt = gv
					if gv.z > max_z_pt.z: max_z_pt = gv
					
	print("Negev min_x: ", min_x_pt, " max_x: ", max_x_pt)
	print("Negev min_y: ", min_y_pt, " max_y: ", max_y_pt)
	print("Negev min_z: ", min_z_pt, " max_z: ", max_z_pt)
	
	# For AKX:
	var ps_ak = load("res://scenes/weapons/models/akx_scifi.scn")
	var inst_ak = ps_ak.instantiate()
	var meshes_ak = inst_ak.find_children("*", "MeshInstance3D", true, false)
	var ak_min_y = Vector3(1e9, 1e9, 1e9)
	var ak_max_y = Vector3(-1e9, -1e9, -1e9)
	var ak_min_z = Vector3(1e9, 1e9, 1e9)
	var ak_max_z = Vector3(-1e9, -1e9, -1e9)
	for m in meshes_ak:
		if not m.mesh: continue
		for s in range(m.mesh.get_surface_count()):
			var arrs = m.mesh.surface_get_arrays(s)
			if arrs.size() > Mesh.ARRAY_VERTEX:
				for v in arrs[Mesh.ARRAY_VERTEX]:
					var gv = m.transform * v
					if gv.y < ak_min_y.y: ak_min_y = gv
					if gv.y > ak_max_y.y: ak_max_y = gv
					if gv.z < ak_min_z.z: ak_min_z = gv
					if gv.z > ak_max_z.z: ak_max_z = gv
	print("AKX min_y: ", ak_min_y, " max_y: ", ak_max_y)
	print("AKX min_z: ", ak_min_z, " max_z: ", ak_max_z)
	
	quit(0)
