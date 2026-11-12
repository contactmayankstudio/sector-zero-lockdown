extends SceneTree

func _init():
	var models = [
		"res://scenes/weapons/models/negev_ng7.scn",
		"res://scenes/weapons/models/akx_scifi.scn",
		"res://scenes/weapons/models/car_smg.scn",
		"res://scenes/weapons/models/pestilence_handgun.scn",
		"res://scenes/weapons/models/primordium_vandal.scn",
		"res://scenes/weapons/models/prowler_smg.scn"
	]
	
	for path in models:
		if not ResourceLoader.exists(path):
			print("Missing: ", path)
			continue
		var ps = load(path)
		var inst = ps.instantiate()
		print("\n================== ", path, " ==================")
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		if inst is MeshInstance3D:
			meshes.append(inst)
			
		var min_v = Vector3(1e9, 1e9, 1e9)
		var max_v = Vector3(-1e9, -1e9, -1e9)
		var count = 0
		var center = Vector3.ZERO
		
		for m in meshes:
			if not m.mesh: continue
			for s in range(m.mesh.get_surface_count()):
				var arrs = m.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_VERTEX:
					var verts = arrs[Mesh.ARRAY_VERTEX]
					for v in verts:
						var gv = m.transform * v
						min_v.x = min(min_v.x, gv.x)
						min_v.y = min(min_v.y, gv.y)
						min_v.z = min(min_v.z, gv.z)
						max_v.x = max(max_v.x, gv.x)
						max_v.y = max(max_v.y, gv.y)
						max_v.z = max(max_v.z, gv.z)
						center += gv
						count += 1
		if count > 0:
			center /= float(count)
		var size = max_v - min_v
		print("Vertex count: ", count)
		print("Min: ", min_v)
		print("Max: ", max_v)
		print("Size: ", size)
		print("Dims order (longest to shortest):")
		var dims = [
			{"axis": "X", "len": size.x},
			{"axis": "Y", "len": size.y},
			{"axis": "Z", "len": size.z}
		]
		dims.sort_custom(func(a, b): return a.len > b.len)
		for d in dims:
			print("  Axis ", d.axis, " = ", d.len)
			
		inst.free()
	quit(0)
