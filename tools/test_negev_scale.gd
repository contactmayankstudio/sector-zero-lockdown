extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = s.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	print("Negev meshes count: ", meshes.size())
	for m in meshes:
		print(" - ", m.name, " mesh: ", m.mesh, " aabb: ", m.get_aabb(), " pos: ", m.position, " scale: ", m.scale)
	inst.free()
	quit(0)
