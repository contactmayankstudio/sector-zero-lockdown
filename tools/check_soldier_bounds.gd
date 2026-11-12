extends SceneTree
func _init():
	var s = load("res://scenes/characters/CombineSoldier.tscn").instantiate()
	var meshes = s.find_children("*", "MeshInstance3D")
	for m in meshes:
		if m.mesh:
			print("Combine ", m.name, " aabb: ", m.mesh.get_aabb())
	quit(0)
