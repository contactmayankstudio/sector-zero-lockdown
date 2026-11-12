
extends SceneTree

func _init():
	var s = load("res://assets/zombies/RealisticZombie.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	inst.global_position = Vector3(0, 0, -4)
	print("Zombie global_transform: ", inst.global_transform)
	print("Zombie rotation_degrees: ", inst.rotation_degrees)
	var sm = inst.get_node_or_null("SkeletalModel")
	if sm:
		print("SkeletalModel transform: ", sm.transform)
		print("SkeletalModel rot: ", sm.rotation_degrees)
		for c in sm.get_children():
			print("  child: ", c.name, " type: ", c.get_class(), " rot: ", c.rotation_degrees if c is Node3D else "-")
	inst.free()
	quit(0)
