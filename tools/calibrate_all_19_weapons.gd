@tool
extends SceneTree

# Calibrate orientation, scale, and offset for all 19 weapons
func _init():
	var test_data = {
		"scifi_battle_rifle": {
			"model": "res://scenes/weapons/models/scifi_battle_rifle.scn",
			# Long axis is Y (23.2m). Height is X (11.3m). Width is Z (5.3m).
			# We want Y -> -Z (forward), X -> +Y (up), Z -> +X (right)
		},
		"vaccinator_energy": {
			"model": "res://scenes/weapons/models/vaccinator_energy.scn",
			# Long axis is Y (66.5m). Height is Z (25.5m) or X (15.6m).
		},
		"axon_cannon": {
			"model": "res://scenes/weapons/models/axon_cannon.scn",
			# X: 17.0m, Y: 14.8m, Z: 6.1m
		},
		"car_smg": {
			"model": "res://scenes/weapons/models/car_smg.scn",
			# Long axis is Z (27.7m). Height is Y (8.6m). Width is X (3.3m).
		},
		"prowl_blaster": {
			"model": "res://scenes/weapons/models/prowl_blaster.scn",
			# Long axis is Y (0.86m).
		},
		"arcade_gun": {
			"model": "res://scenes/weapons/models/arcade_gun.scn",
			# Long axis is X (4.44m).
		},
		"retro_ray_gun": {
			"model": "res://scenes/weapons/models/retro_ray_gun.scn",
			# Long axis is Z (8.52m).
		},
	}

	for id in test_data:
		var info = test_data[id]
		var scn = load(info.model)
		var inst = scn.instantiate()
		root.add_child(inst)
		await process_frame
		
		# Test different rotations:
		# We test 24 standard 90-degree rotations to find the one where:
		# - The longest dimension is along -Z (Z min is most negative, Z span is largest)
		# - The vertical dimension (Y) is positive-up
		# - Bounding box in front of camera
		print("\nTesting orientations for: ", id)
		var best_rot = Vector3.ZERO
		var max_z_span = -1.0
		
		var angles = [0.0, 90.0, 180.0, 270.0, -90.0]
		for rx in angles:
			for ry in angles:
				for rz in angles:
					var basis = Basis.from_euler(Vector3(deg_to_rad(rx), deg_to_rad(ry), deg_to_rad(rz)))
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
										var rv = basis * v
										min_b.x = min(min_b.x, rv.x)
										min_b.y = min(min_b.y, rv.y)
										min_b.z = min(min_b.z, rv.z)
										max_b.x = max(max_b.x, rv.x)
										max_b.y = max(max_b.y, rv.y)
										max_b.z = max(max_b.z, rv.z)
						for c in curr.get_children():
							stack.append(c)
					var span = max_b - min_b
					# Longest dimension should be along Z (the barrel pointing forward/backward)
					# AND Y span should be greater than X span (guns are taller than they are wide)
					if span.z > span.x and span.z > span.y and span.y > span.x:
						if span.z > max_z_span:
							max_z_span = span.z
							best_rot = Vector3(rx, ry, rz)
							print("  Candidate rot: %s -> Span: (X:%.2f, Y:%.2f, Z:%.2f) Bounds: Z[%.2f to %.2f]" % [str(best_rot), span.x, span.y, span.z, min_b.z, max_b.z])
							
		inst.queue_free()
	quit(0)
