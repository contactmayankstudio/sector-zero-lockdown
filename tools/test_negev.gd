@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = scn.instantiate()
	root.add_child(inst)
	await process_frame
	
	for y_rot in [0.0, 90.0, -90.0, 180.0]:
		inst.rotation_degrees = Vector3(0.0, y_rot, 0.0)
		inst.scale = Vector3(0.048, 0.048, 0.048)
		inst.position = Vector3(0.04, -0.07, 0.06)
		
		var min_b = Vector3(1e9, 1e9, 1e9)
		var max_b = Vector3(-1e9, -1e9, -1e9)
		var stack = [inst]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				var m = curr.mesh
				for s in range(m.get_surface_count()):
					var arr = m.surface_get_arrays(s)
					if arr.size() > Mesh.ARRAY_VERTEX:
						for v in arr[Mesh.ARRAY_VERTEX]:
							var gv = curr.global_transform * v
							min_b.x = min(min_b.x, gv.x)
							min_b.y = min(min_b.y, gv.y)
							min_b.z = min(min_b.z, gv.z)
							max_b.x = max(max_b.x, gv.x)
							max_b.y = max(max_b.y, gv.y)
							max_b.z = max(max_b.z, gv.z)
			for c in curr.get_children():
				stack.append(c)
		var span = max_b - min_b
		print("Negev Y_Rot=%.1f -> Span:(X:%.3fm, Y:%.3fm, Z:%.3fm) Bounds: X[%.2f..%.2f], Y[%.2f..%.2f], Z[%.2f..%.2f]" % [
			y_rot, span.x, span.y, span.z, min_b.x, max_b.x, min_b.y, max_b.y, min_b.z, max_b.z
		])
	inst.queue_free()
	quit(0)
