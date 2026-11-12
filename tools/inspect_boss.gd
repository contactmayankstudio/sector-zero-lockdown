extends SceneTree

func _init():
	var s = load("res://scenes/zombies/models/zombie_boss.tscn").instantiate()
	var total_tris = 0
	var meshes = s.find_children("*", "MeshInstance3D", true, false)
	print("Meshes in zombie_boss: ", meshes.size())
	for m in meshes:
		if m.mesh:
			var tris = m.mesh.get_faces().size() / 3
			total_tris += tris
			print(" - Mesh: ", m.name, " tris: ", tris, " mat: ", m.material_override)
	print("TOTAL TRIS IN BOSS: ", total_tris)
	quit(0)
