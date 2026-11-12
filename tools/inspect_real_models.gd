extends SceneTree

func _init():
	print("--- DETAILED REAL MODELS AUDIT ---")
	var candidates = [
		"res://scenes/zombies/models/zombie_realistic_human.scn",
		"res://scenes/zombies/models/RealSoldierZombie.scn",
		"res://scenes/zombies/models/RealSoldierZombie.tscn",
		"res://scenes/zombies/models/RealDoomZombie.scn",
		"res://scenes/zombies/models/RealDoomZombie.tscn",
		"res://scenes/zombies/models/RealZombieOffice.scn",
		"res://scenes/zombies/models/RealZombieBiker.scn",
		"res://scenes/zombies/models/RealTitanBrute.scn",
		"res://scenes/zombies/models/RealVelociraptor.scn",
		"res://scenes/zombies/models/RealAlienMutant.scn",
		"res://assets/3d/zombies/zombie_scary.glb"
	]
	
	for path in candidates:
		if not ResourceLoader.exists(path):
			continue
		print("\n>> Inspecting: ", path)
		var res = load(path)
		if not (res is PackedScene):
			print("   NOT PackedScene: ", res)
			continue
		var inst = res.instantiate()
		print("   Root: ", inst.name, " (", inst.get_class(), ")")
		_dump_tree(inst, "   ")
		inst.free()
	quit()

func _dump_tree(node: Node, prefix: String):
	var info = prefix + "- " + node.name + " (" + node.get_class() + ")"
	if node is MeshInstance3D:
		info += " Mesh: " + (str(node.mesh.get_class()) if node.mesh else "none")
		if node.skeleton:
			info += " SkeletonPath: " + str(node.skeleton)
	elif node is Skeleton3D:
		info += " Bones: " + str(node.get_bone_count())
	elif node is AnimationPlayer:
		info += " Anims: " + str(node.get_animation_list()) + " RootNode: " + str(node.root_node)
	print(info)
	for c in node.get_children():
		_dump_tree(c, prefix + "  ")
