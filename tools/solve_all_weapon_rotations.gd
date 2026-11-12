@tool
extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	p.free()

	print("=== SOLVING EXACT ROTATION TO ALIGN EVERY WEAPON FORWARD (-Z) ===")

	for cfg in cfgs:
		var wid = cfg.id
		var model_path = cfg.model
		if not ResourceLoader.exists(model_path):
			continue
		var res = load(model_path)
		if not (res is PackedScene):
			continue

		var inst = res.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)

		var all_verts = PackedVector3Array()
		for m in meshes:
			if not m.mesh: continue
			var xf = m.transform
			for s in range(m.mesh.get_surface_count()):
				var arrs = m.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_VERTEX and arrs[Mesh.ARRAY_VERTEX] != null:
					var verts: PackedVector3Array = arrs[Mesh.ARRAY_VERTEX]
					for v in verts:
						all_verts.append(xf * v)

		if all_verts.is_empty():
			inst.free()
			continue

		# Compute bounding box
		var min_pt = Vector3(9999, 9999, 9999)
		var max_pt = Vector3(-9999, -9999, -9999)
		for v in all_verts:
			min_pt.x = minf(min_pt.x, v.x); max_pt.x = maxf(max_pt.x, v.x)
			min_pt.y = minf(min_pt.y, v.y); max_pt.y = maxf(max_pt.y, v.y)
			min_pt.z = minf(min_pt.z, v.z); max_pt.z = maxf(max_pt.z, v.z)
		var extents = max_pt - min_pt
		var center = (min_pt + max_pt) * 0.5

		# Longest axis is barrel
		var barrel_axis = 0 # 0=X, 1=Y, 2=Z
		if extents.y > extents.x and extents.y > extents.z:
			barrel_axis = 1
		elif extents.z > extents.x and extents.z > extents.y:
			barrel_axis = 2

		# Let's check which end (positive or negative of barrel axis) is the muzzle!
		# Count vertices and cross-section volume in the 15% slice at min vs 15% slice at max
		var min_slice_count = 0
		var max_slice_count = 0
		var min_slice_bb = AABB()
		var max_slice_bb = AABB()

		var threshold_min = 0.0
		var threshold_max = 0.0
		if barrel_axis == 0:
			threshold_min = min_pt.x + extents.x * 0.15
			threshold_max = max_pt.x - extents.x * 0.15
		elif barrel_axis == 1:
			threshold_min = min_pt.y + extents.y * 0.15
			threshold_max = max_pt.y - extents.y * 0.15
		else:
			threshold_min = min_pt.z + extents.z * 0.15
			threshold_max = max_pt.z - extents.z * 0.15

		for v in all_verts:
			var val = v.x if barrel_axis == 0 else (v.y if barrel_axis == 1 else v.z)
			if val <= threshold_min:
				min_slice_count += 1
			elif val >= threshold_max:
				max_slice_count += 1

		# The muzzle (barrel end) is almost always thinner/simpler (fewer vertices / smaller cross-section) than the stock/receiver
		# Or if there's a muzzle socket, that overrides
		var muzzle_dir_positive = (max_slice_count < min_slice_count)
		
		# Now let's determine height (up/down) axis among the remaining two axes
		var height_axis = 1
		if barrel_axis == 1:
			height_axis = 2 if extents.z > extents.x else 0
		else:
			height_axis = 1 # Y is usually height

		# Check if magazine/grip extends towards negative or positive of height axis
		# Grip/mag usually extends furthest from center
		var min_h_dist = abs(min_pt[height_axis] - center[height_axis])
		var max_h_dist = abs(max_pt[height_axis] - center[height_axis])
		var grip_is_negative = (min_h_dist > max_h_dist)

		print("[%s]" % wid)
		var axis_names = ["X", "Y", "Z"]
		print("  Barrel Axis: %s (%s end is muzzle)" % [axis_names[barrel_axis], "+" if muzzle_dir_positive else "-"])
		print("  Height Axis: %s (%s is top/sights)" % [axis_names[height_axis], "+" if grip_is_negative else "-"])
		print("  Current in Player.gd: rot=%s, scale=%s, offset=%s" % [str(cfg.get("rot", Vector3.ZERO)), str(cfg.get("scale", Vector3.ONE)), str(cfg.get("offset", Vector3.ZERO))])

		inst.free()

	quit(0)
