@tool
extends SceneTree

func _init():
	var targets = [
		{"id": "negev_ng7", "path": "res://scenes/weapons/models/negev_ng7.scn", "scale": 0.048},
		{"id": "car_smg", "path": "res://scenes/weapons/models/car_smg.scn", "scale": 0.024},
	]

	var dirs = [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]

	for t in targets:
		var scn = load(t.path)
		var inst = scn.instantiate()
		root.add_child(inst)
		await process_frame
		
		var pts = []
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
						var step = max(1, int(v_arr.size() / 100))
						for i in range(0, v_arr.size(), step):
							pts.append(rel_t * v_arr[i])
			for c in curr.get_children():
				stack.append(c)
				
		print("\n--- Model: %s ---" % t.id)
		for r in dirs:
			for u in dirs:
				if abs(r.dot(u)) < 0.1:
					var f = r.cross(u)
					var b = Basis(r, u, f)
					if b.determinant() > 0.9:
						var min_v = Vector3(1e9, 1e9, 1e9)
						var max_v = Vector3(-1e9, -1e9, -1e9)
						for p in pts:
							var rp = (b * p) * t.scale
							min_v.x = min(min_v.x, rp.x)
							min_v.y = min(min_v.y, rp.y)
							min_v.z = min(min_v.z, rp.z)
							max_v.x = max(max_v.x, rp.x)
							max_v.y = max(max_v.y, rp.y)
							max_v.z = max(max_v.z, rp.z)
						var span = max_v - min_v
						if span.z > span.x:
							print("  Basis(Vector3(%.0f,%.0f,%.0f), Vector3(%.0f,%.0f,%.0f), Vector3(%.0f,%.0f,%.0f)) -> Span:(X:%.3fm, Y:%.3fm, Z:%.3fm)" % [
								b.x.x, b.x.y, b.x.z,
								b.y.x, b.y.y, b.y.z,
								b.z.x, b.z.y, b.z.z,
								span.x, span.y, span.z
							])
		inst.queue_free()
	quit(0)
