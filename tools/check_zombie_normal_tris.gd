extends SceneTree

func _init():
	var s = load("res://scenes/zombies/models/zombie_normal.tscn").instantiate()
	var total_tris = 0
	var meshes = s.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		if m.mesh:
			total_tris += m.mesh.get_faces().size() / 3
	print(">>> zombie_normal.tscn TOTAL TRIS: ", total_tris)
	quit(0)
