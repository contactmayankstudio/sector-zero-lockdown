@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/InfectedDog.tscn")
	var inst = scn.instantiate()
	get_root().add_child(inst)
	print("--- INFECTED DOG NODES ---")
	for c in inst.get_children():
		print("Child: ", c.name, " (", c.get_class(), ")")
		if c.name == "ModelWrapper":
			print("  ModelWrapper rot.y: ", c.rotation.y)
			for wc in c.get_children():
				print("    Wrapper Child: ", wc.name)
		elif c.name == "SkeletalModel":
			print("  Direct SkeletalModel rot.y: ", c.rotation.y)
	inst.free()
	quit(0)
