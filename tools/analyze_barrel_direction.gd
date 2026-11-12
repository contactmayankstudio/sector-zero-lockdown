extends SceneTree

func _init():
	var models = [
		{"id": "negev_ng7", "path": "res://scenes/weapons/models/negev_ng7.scn"},
		{"id": "akx_scifi", "path": "res://scenes/weapons/models/akx_scifi.scn"},
		{"id": "car_smg", "path": "res://scenes/weapons/models/car_smg.scn"},
		{"id": "primordium_vandal", "path": "res://scenes/weapons/models/primordium_vandal.scn"},
		{"id": "prowler_smg", "path": "res://scenes/weapons/models/prowler_smg.scn"}
	]
	
	for entry in models:
		var ps = load(entry.path)
		var inst = ps.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		if inst is MeshInstance3D:
			meshes.append(inst)
			
		# Sample vertices along the extreme ends of X, Y, Z
		var all_verts = []
		for m in meshes:
			if not m.mesh: continue
			for s in range(m.mesh.get_surface_count()):
				var arrs = m.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_VERTEX:
					for v in arrs[Mesh.ARRAY_VERTEX]:
						all_verts.append(m.transform * v)
						
		print("\n--- WEAPON: ", entry.id, " --- (total verts: ", all_verts.size(), ")")
		# Check extremities:
		# For each axis (X, Y, Z), check the bounding box of vertices within 10% of the positive end vs negative end
		for axis_idx in range(3):
			var axis_name = ["X", "Y", "Z"][axis_idx]
			var min_val = 1e9
			var max_val = -1e9
			for v in all_verts:
				var val = v[axis_idx]
				if val < min_val: min_val = val
				if val > max_val: max_val = val
			var span = max_val - min_val
			if span < 0.2: continue # skip short axes
			
			var pos_verts = []
			var neg_verts = []
			for v in all_verts:
				if v[axis_idx] > max_val - span * 0.1:
					pos_verts.append(v)
				elif v[axis_idx] < min_val + span * 0.1:
					neg_verts.append(v)
					
			# Compute cross-sectional spread at pos end vs neg end
			var pos_spread = _calc_spread(pos_verts, axis_idx)
			var neg_spread = _calc_spread(neg_verts, axis_idx)
			print("Axis ", axis_name, ": [", min_val, " to ", max_val, "]")
			print("  Positive end spread: ", pos_spread, " (verts: ", pos_verts.size(), ")")
			print("  Negative end spread: ", neg_spread, " (verts: ", neg_verts.size(), ")")
			if pos_spread < neg_spread:
				print("  --> Positive end (+", axis_name, ") has SMALLER spread (likely MUZZLE/BARREL)")
				print("  --> Negative end (-", axis_name, ") has LARGER spread (likely BUTTSTOCK)")
			else:
				print("  --> Negative end (-", axis_name, ") has SMALLER spread (likely MUZZLE/BARREL)")
				print("  --> Positive end (+", axis_name, ") has LARGER spread (likely BUTTSTOCK)")
		inst.free()
	quit(0)

func _calc_spread(verts: Array, exclude_axis: int) -> float:
	if verts.is_empty(): return 0.0
	var min_other = Vector2(1e9, 1e9)
	var max_other = Vector2(-1e9, -1e9)
	for v in verts:
		var coords = []
		for i in range(3):
			if i != exclude_axis:
				coords.append(v[i])
		min_other.x = min(min_other.x, coords[0])
		min_other.y = min(min_other.y, coords[1])
		max_other.x = max(max_other.x, coords[0])
		max_other.y = max(max_other.y, coords[1])
	var d = max_other - min_other
	return d.x * d.y
