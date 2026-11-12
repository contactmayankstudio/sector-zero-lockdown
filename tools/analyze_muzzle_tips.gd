@tool
extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	p.free()

	print("=== EXACT MUZZLE / BARREL TIP ANALYSIS ===")

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
		
		var max_dist = 0.0
		var tip_vec = Vector3.ZERO
		var vertex_count = 0
		var center = Vector3.ZERO

		# First compute center
		var aabb = AABB()
		var first = true
		for m in meshes:
			if m.mesh:
				var m_aabb = m.transform * m.mesh.get_aabb()
				if first:
					aabb = m_aabb
					first = false
				else:
					aabb = aabb.merge(m_aabb)
		center = aabb.get_center()

		# Find the tip furthest from center along each axis
		var min_x = 9999.0; var max_x = -9999.0
		var min_y = 9999.0; var max_y = -9999.0
		var min_z = 9999.0; var max_z = -9999.0

		for m in meshes:
			if not m.mesh: continue
			var xform = m.transform
			for s in range(m.mesh.get_surface_count()):
				var arrs = m.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_VERTEX and arrs[Mesh.ARRAY_VERTEX] != null:
					var verts: PackedVector3Array = arrs[Mesh.ARRAY_VERTEX]
					for v in verts:
						var wv = xform * v
						if wv.x < min_x: min_x = wv.x
						if wv.x > max_x: max_x = wv.x
						if wv.y < min_y: min_y = wv.y
						if wv.y > max_y: max_y = wv.y
						if wv.z < min_z: min_z = wv.z
						if wv.z > max_z: max_z = wv.z

		var span_x = max_x - min_x
		var span_y = max_y - min_y
		var span_z = max_z - min_z

		print("\n[%s]" % wid)
		print("  Span X: %.3f (min: %.3f, max: %.3f)" % [span_x, min_x, max_x])
		print("  Span Y: %.3f (min: %.3f, max: %.3f)" % [span_y, min_y, max_y])
		print("  Span Z: %.3f (min: %.3f, max: %.3f)" % [span_z, min_z, max_z])
		print("  Current Config: rot=%s, scale=%s, offset=%s" % [str(cfg.get("rot", Vector3.ZERO)), str(cfg.get("scale", Vector3.ONE)), str(cfg.get("offset", Vector3.ZERO))])

		inst.free()

	quit(0)
