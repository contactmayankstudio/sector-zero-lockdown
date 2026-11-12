extends SceneTree

func _init():
	print("--- BAKING REALISTIC ZOMBIE MODELS ---")
	
	# 1. Scary Zombie
	var gltf1 = GLTFDocument.new()
	var state1 = GLTFState.new()
	var err1 = gltf1.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state1)
	if err1 == OK:
		var raw_node = gltf1.generate_scene(state1)
		var wrapper = Node3D.new()
		wrapper.name = "ZombieScaryModel"
		
		# Scale down from cm to meters (0.01) and rotate to face forward (-Z)
		raw_node.scale = Vector3(0.01, 0.01, 0.01)
		raw_node.rotation.y = PI
		wrapper.add_child(raw_node)
		raw_node.owner = wrapper
		_set_owner_recursive(raw_node, wrapper)
		
		var packed = PackedScene.new()
		packed.pack(wrapper)
		var save_err = ResourceSaver.save(packed, "res://scenes/zombies/models/zombie_scary.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved zombie_scary.scn: ", save_err)
		wrapper.free()
	else:
		print("Failed loading scary_zombie_pack.glb: ", err1)
		
	# 2. Mutant Zombie
	var gltf2 = GLTFDocument.new()
	var state2 = GLTFState.new()
	var err2 = gltf2.append_from_file("/home/am/Downloads/muscled_mutated_male_zombie.glb", state2)
	if err2 == OK:
		var raw_node2 = gltf2.generate_scene(state2)
		var wrapper2 = Node3D.new()
		wrapper2.name = "ZombieMutantModel"
		
		# Position to stand on floor
		raw_node2.position.y = 1.0 # Centered around ground
		raw_node2.rotation.y = PI
		wrapper2.add_child(raw_node2)
		raw_node2.owner = wrapper2
		_set_owner_recursive(raw_node2, wrapper2)
		
		var packed2 = PackedScene.new()
		packed2.pack(wrapper2)
		var save_err2 = ResourceSaver.save(packed2, "res://scenes/zombies/models/zombie_mutant.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved zombie_mutant.scn: ", save_err2)
		wrapper2.free()
	else:
		print("Failed loading muscled_mutated_male_zombie.glb: ", err2)
		
	quit(0)

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
