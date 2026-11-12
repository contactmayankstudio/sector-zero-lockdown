extends SceneTree

func _init():
	var res = load("res://scenes/weapons/models/car_smg.scn")
	var inst = res.instantiate()
	
	# Test rotations near (90, 0, 0) or multiples of 90
	print("--- TESTING CAR_SMG ROTATIONS ---")
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	
	for rx in [0, 90, -90]:
		for ry in [0, 90, -90, 180]:
			for rz in [0, 90, -90, 180]:
				inst.rotation_degrees = Vector3(rx, ry, rz)
				var min_v = Vector3(999, 999, 999)
				var max_v = Vector3(-999, -999, -999)
				for m in meshes:
					if m.mesh:
						var aabb = (inst.transform * m.transform) * m.mesh.get_aabb()
						min_v.x = min(min_v.x, aabb.position.x)
						min_v.y = min(min_v.y, aabb.position.y)
						min_v.z = min(min_v.z, aabb.position.z)
						max_v.x = max(max_v.x, aabb.end.x)
						max_v.y = max(max_v.y, aabb.end.y)
						max_v.z = max(max_v.z, aabb.end.z)
				var sz = max_v - min_v
				# Z should be length (~0.7), Y should be height (~0.2-0.3), X should be thickness (~0.05-0.1)
				if sz.z > sz.y and sz.y > sz.x:
					print("Valid Rot: Vector3(", rx, ", ", ry, ", ", rz, ") -> Size: ", sz)
	inst.free()
	quit(0)
