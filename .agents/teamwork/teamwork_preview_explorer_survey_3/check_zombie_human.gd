extends SceneTree
func _init():
	print("Checking zombie_realistic_human.scn...")
	var scn = load("res://scenes/zombies/models/zombie_realistic_human.scn")
	var inst = scn.instantiate()
	for child in inst.find_children("*", "", true, false):
		if child is CollisionShape3D or child is CollisionObject3D:
			print("Found collision: ", child.name, " class: ", child.get_class())
	inst.free()
	quit(0)
