@tool
extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	p.free()

	print("=== MATHEMATICAL WEAPON ORIENTATION SOLVER ===")

	# Specific manual confirmation of barrel and up vectors for each weapon:
	# (based on vertex analysis of where muzzle and sights are located)
	var alignments = {
		"negev_ng7": {
			"forward": Vector3(0, 0, -1), # Barrel along -Z (wait, earlier test said X or -Z?)
			"up": Vector3(0, 1, 0)
		}
	}

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

		# Find bounds
		var min_pt = Vector3(9999, 9999, 9999)
		var max_pt = Vector3(-9999, -9999, -9999)
		for m in meshes:
			if not m.mesh: continue
			var xf = m.transform
			for s in range(m.mesh.get_surface_count()):
				var arrs = m.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_VERTEX and arrs[Mesh.ARRAY_VERTEX] != null:
					var verts: PackedVector3Array = arrs[Mesh.ARRAY_VERTEX]
					for v in verts:
						var wv = xf * v
						min_pt.x = minf(min_pt.x, wv.x); max_pt.x = maxf(max_pt.x, wv.x)
						min_pt.y = minf(min_pt.y, wv.y); max_pt.y = maxf(max_pt.y, wv.y)
						min_pt.z = minf(min_pt.z, wv.z); max_pt.z = maxf(max_pt.z, wv.z)

		var extents = max_pt - min_pt
		var center = (min_pt + max_pt) * 0.5

		# Barrel axis
		var b_axis = "Z"
		var max_dim = extents.z
		if extents.x > max_dim:
			b_axis = "X"
			max_dim = extents.x
		if extents.y > max_dim:
			b_axis = "Y"
			max_dim = extents.y

		print("[%s]" % wid)
		print("  Extents: X=%.2f, Y=%.2f, Z=%.2f -> Longest Axis: %s" % [extents.x, extents.y, extents.z, b_axis])

		inst.free()

	quit(0)
