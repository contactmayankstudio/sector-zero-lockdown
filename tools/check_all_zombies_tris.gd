extends SceneTree

func _init():
	for path in [
		"res://scenes/zombies/models/zombie_normal.tscn",
		"res://scenes/zombies/models/zombie_fast.tscn",
		"res://scenes/zombies/models/zombie_heavy.tscn",
		"res://scenes/zombies/models/zombie_scary.scn",
		"res://scenes/zombies/models/zombie_mutant.tscn"
	]:
		if ResourceLoader.exists(path):
			var s = load(path).instantiate()
			var tris = 0
			for m in s.find_children("*", "MeshInstance3D", true, false):
				if m.mesh: tris += m.mesh.get_faces().size() / 3
			print(path.get_file(), " tris: ", tris)
	quit(0)
