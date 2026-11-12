extends SceneTree

func _init():
	var sc = load("res://scenes/weapons/models/AK74uAnimated.scn")
	var inst = sc.instantiate()
	for c in inst.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", c.name, " parent: ", c.get_parent().name, " aabb: ", c.get_aabb())
	inst.free()
	quit(0)
