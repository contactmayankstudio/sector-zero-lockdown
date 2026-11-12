extends SceneTree

func _init():
	var sc = load("res://scenes/zombies/models/RealAlienMutant.scn")
	var inst = sc.instantiate()
	var meshes = inst.find_children("*", "VisualInstance3D", true, false)
	var box = AABB()
	for m in meshes:
		box = box.merge(m.get_aabb())
	print("Alien combined visual AABB: ", box)
	inst.free()
	quit(0)
