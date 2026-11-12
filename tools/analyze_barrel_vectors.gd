extends SceneTree

func _init():
	print("=== PRECISE BARREL AND SIGHT ORIENTATION DETECTOR ===")
	
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	
	for cfg in cfgs:
		var wid = cfg.id
		var res = load(cfg.model)
		if not (res is PackedScene):
			continue
			
		var inst = res.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		
		# Collect all vertices
		var all_verts: Array[Vector3] = []
		for m in meshes:
			if m.mesh:
				var faces = m.mesh.get_faces()
				var xf = m.transform
				for v in faces:
					all_verts.append(xf * v)
					
		if all_verts.is_empty():
			print(wid, " -> NO VERTICES")
			inst.free()
			continue
			
		# Calculate centroid
		var center = Vector3.ZERO
		var min_v = Vector3(9999, 9999, 9999)
		var max_v = Vector3(-9999, -9999, -9999)
		for v in all_verts:
			center += v
			min_v.x = min(min_v.x, v.x)
			min_v.y = min(min_v.y, v.y)
			min_v.z = min(min_v.z, v.z)
			max_v.x = max(max_v.x, v.x)
			max_v.y = max(max_v.y, v.y)
			max_v.z = max(max_v.z, v.z)
		center /= float(all_verts.size())
		var size = max_v - min_v
		
		# Find primary elongation axis
		var primary_axis = "X"
		var barrel_length = size.x
		if size.y > barrel_length:
			primary_axis = "Y"
			barrel_length = size.y
		if size.z > barrel_length:
			primary_axis = "Z"
			barrel_length = size.z
			
		# Determine which end is the muzzle vs stock:
		# Measure cross-sectional radius and vertex count in extreme 15% slices
		var slice_pos = []
		var slice_neg = []
		
		if primary_axis == "X":
			var thresh_pos = max_v.x - size.x * 0.15
			var thresh_neg = min_v.x + size.x * 0.15
			for v in all_verts:
				if v.x > thresh_pos:
					slice_pos.append(Vector2(v.y, v.z))
				elif v.x < thresh_neg:
					slice_neg.append(Vector2(v.y, v.z))
		elif primary_axis == "Y":
			var thresh_pos = max_v.y - size.y * 0.15
			var thresh_neg = min_v.y + size.y * 0.15
			for v in all_verts:
				if v.y > thresh_pos:
					slice_pos.append(Vector2(v.x, v.z))
				elif v.y < thresh_neg:
					slice_neg.append(Vector2(v.x, v.z))
		else: # Z
			var thresh_pos = max_v.z - size.z * 0.15
			var thresh_neg = min_v.z + size.z * 0.15
			for v in all_verts:
				if v.z > thresh_pos:
					slice_pos.append(Vector2(v.x, v.y))
				elif v.z < thresh_neg:
					slice_neg.append(Vector2(v.x, v.y))
					
		# Calculate bounding cross-section area in pos vs neg
		var area_pos = _calc_area(slice_pos)
		var area_neg = _calc_area(slice_neg)
		
		var muzzle_dir_raw = ""
		# Muzzle is typically narrower than stock/receiver
		if area_pos < area_neg:
			muzzle_dir_raw = "+" + primary_axis
		else:
			muzzle_dir_raw = "-" + primary_axis
			
		print("\nWeapon: ", wid)
		print("  Primary axis: ", primary_axis, " (Size: ", size, ")")
		print("  Slice counts: pos=", slice_pos.size(), " neg=", slice_neg.size())
		print("  Slice areas: pos=", area_pos, " neg=", area_neg)
		print("  Estimated Muzzle: ", muzzle_dir_raw)
		print("  Current Config: rot=", cfg.get("rot", "N/A"), " basis=", cfg.get("basis", "N/A"))
		
		inst.free()
		
	p.free()
	quit(0)

func _calc_area(pts: Array) -> float:
	if pts.is_empty():
		return 0.0
	var min_p = Vector2(9999, 9999)
	var max_p = Vector2(-9999, -9999)
	for p in pts:
		min_p.x = min(min_p.x, p.x)
		min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x)
		max_p.y = max(max_p.y, p.y)
	var s = max_p - min_p
	return s.x * s.y
