extends SceneTree

func _init():
	var mesh = load("res://models/player/fps_arms.obj")
	if not mesh:
		print("Failed to load mesh")
		quit(1)
		return
	print("Mesh surface count:", mesh.get_surface_count())
	for i in range(mesh.get_surface_count()):
		var mat = mesh.surface_get_material(i)
		print("Surface ", i, ": material = ", (mat.resource_name if (mat and mat.resource_name != "") else (mat.to_string() if mat else "null")))
	quit(0)
