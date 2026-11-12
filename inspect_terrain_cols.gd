extends SceneTree

func _init():
	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	var inst = scene.instantiate()
	root.add_child(inst)
	
	print("--- INSPECTING TERRAIN COLLIDERS ---")
	for parent_name in ["RealisticTerrain", "AdvancedTerrain"]:
		var p = inst.get_node_or_null(parent_name)
		if not p:
			print("Missing parent: ", parent_name)
			continue
		print("\nChecking: ", parent_name)
		for child in p.get_children():
			var has_col = false
			if child is StaticBody3D:
				var cols = child.find_children("*", "CollisionShape3D", true, false)
				print("  StaticBody3D '", child.name, "' has ", cols.size(), " CollisionShape3D")
			elif child is MeshInstance3D:
				var cols = child.find_children("*", "CollisionShape3D", true, false)
				print("  MeshInstance3D '", child.name, "' has ", cols.size(), " CollisionShape3D")
	quit()
