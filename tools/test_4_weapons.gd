@tool
extends SceneTree

func _init():
	var test_weapons = [
		{
			"id": "negev_ng7",
			"model": "res://scenes/weapons/models/negev_ng7.scn",
			"scale": Vector3(0.048, 0.048, 0.048),
			"offset": Vector3(-0.02, -0.05, 0.0)
		},
		{
			"id": "scifi_battle_rifle",
			"model": "res://scenes/weapons/models/scifi_battle_rifle.scn",
			"scale": Vector3(0.024, 0.024, 0.024),
			"offset": Vector3(-0.02, -0.05, 0.0)
		},
		{
			"id": "vaccinator_energy",
			"model": "res://scenes/weapons/models/vaccinator_energy.scn",
			"scale": Vector3(0.0093, 0.0093, 0.0093),
			"offset": Vector3(-0.02, -0.05, 0.0)
		},
		{
			"id": "axon_cannon",
			"model": "res://scenes/weapons/models/axon_cannon.scn",
			"scale": Vector3(2.8, 2.8, 2.8),
			"offset": Vector3(-0.02, -0.40, 0.0)
		}
	]

	print("\n================ TESTING 4 TARGET WEAPONS ================")
	for w in test_weapons:
		var scn = load(w.model)
		var inst = scn.instantiate()
		root.add_child(inst)
		await process_frame
		
		print("\n--- Weapon: %s ---" % w.id)
		# Test a set of rotations around X, Y, Z
		var rots = [
			Vector3(0, 0, 0),
			Vector3(0, 90, 0),
			Vector3(0, -90, 0),
			Vector3(0, 180, 0),
			Vector3(90, 0, 0),
			Vector3(-90, 0, 0),
			Vector3(90, 90, 0),
			Vector3(-90, 90, 0),
			Vector3(0, 90, 90),
			Vector3(0, 90, -90),
			Vector3(90, 0, 90),
			Vector3(90, 0, -90),
			Vector3(-90, 0, 90),
			Vector3(-90, 0, -90),
		]
		
		for r in rots:
			inst.rotation_degrees = r
			inst.scale = w.scale
			inst.position = w.offset
			
			var min_b = Vector3(1e9, 1e9, 1e9)
			var max_b = Vector3(-1e9, -1e9, -1e9)
			var stack = [inst]
			while stack.size() > 0:
				var curr = stack.pop_back()
				if curr is MeshInstance3D and curr.mesh:
					var m = curr.mesh
					var rel_t = inst.transform.affine_inverse() * curr.transform
					for s in range(m.get_surface_count()):
						var arr = m.surface_get_arrays(s)
						if arr.size() > Mesh.ARRAY_VERTEX:
							var v_arr = arr[Mesh.ARRAY_VERTEX]
							for v in v_arr:
								var gv = inst.transform * (rel_t * v)
								min_b.x = min(min_b.x, gv.x)
								min_b.y = min(min_b.y, gv.y)
								min_b.z = min(min_b.z, gv.z)
								max_b.x = max(max_b.x, gv.x)
								max_b.y = max(max_b.y, gv.y)
								max_b.z = max(max_b.z, gv.z)
				for c in curr.get_children():
					stack.append(c)
			var span = max_b - min_b
			# We want Z to be the longest (length), Y to be height (0.15 - 0.35m), X to be width (0.05 - 0.25m)
			if span.z > span.x and span.z > span.y and span.y > span.x:
				print("  MATCH rot=%s -> Span: (X:%.3fm, Y:%.3fm, Z:%.3fm) Bounds: Y[%.2f..%.2f], Z[%.2f..%.2f]" % [
					str(r), span.x, span.y, span.z, min_b.y, max_b.y, min_b.z, max_b.z
				])
		inst.queue_free()
	quit(0)
