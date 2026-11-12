extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = s.instantiate()
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		var aabb = m.get_aabb()
		print("Mesh: ", m.name, " size: ", aabb.size, " pos: ", m.position, " xf*aabb.size: ", (m.transform * aabb).size)
	inst.free()
	quit(0)
