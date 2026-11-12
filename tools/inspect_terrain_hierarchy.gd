extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = scn.instantiate()
	get_root().add_child(arena)
	await process_frame

	var adv = arena.get_node_or_null("AdvancedTerrain")
	print("--- INSPECTING ADVANCED TERRAIN CHILDREN ---")
	for child in adv.get_children():
		print("Node: ", child.name, " (", child.get_class(), ")")
		for sub in child.get_children():
			print("   Sub: ", sub.name, " (", sub.get_class(), ")")
			if sub is CollisionShape3D:
				print("     Shape: ", sub.shape)
			for sub2 in sub.get_children():
				print("     Sub2: ", sub2.name, " (", sub2.get_class(), ")")
				if sub2 is CollisionShape3D:
					print("       Shape: ", sub2.shape)

	arena.queue_free()
	quit(0)
