extends SceneTree

func _init():
	var steps = [0, 90, 180, 270, -90, -180, -270]
	var found = []
	for rx in steps:
		for ry in steps:
			for rz in steps:
				var b = Basis.from_euler(Vector3(deg_to_rad(rx), deg_to_rad(ry), deg_to_rad(rz)))
				var fwd = b * Vector3(0, -1, 0)
				var up = b * Vector3(0, 0, 1)
				if fwd.is_equal_approx(Vector3(0, 0, -1)) and up.is_equal_approx(Vector3(0, 1, 0)):
					found.append(Vector3(rx, ry, rz))
	print("Exact solutions for AKX: ", found)
	quit(0)
