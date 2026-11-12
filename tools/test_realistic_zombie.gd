extends SceneTree

func _init():
	print("--- TESTING REALISTIC ZOMBIE SPAWN ---")
	var scn = load("res://assets/zombies/RealisticZombie.tscn")
	var inst = scn.instantiate()
	get_root().add_child(inst)
	print("Instantiated RealisticZombie successfully.")
	var sm = inst.get_node_or_null("SkeletalModel")
	print("SkeletalModel found: ", sm != null, " name: ", sm.name if sm else "")
	if sm:
		var meshes = sm.find_children("*", "MeshInstance3D", true, false)
		print("Meshes in SkeletalModel: ", meshes.size())
		for m in meshes:
			print("  Mesh node: ", m.name)
	inst.free()
	print("--- TEST COMPLETED ---")
	quit(0)
