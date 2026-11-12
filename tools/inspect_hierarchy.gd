extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	print("Root name:", s.name)
	print("Transform:", s.transform)
	for c in s.get_children():
		print("  child:", c.name, "transform:", c.transform)
		if c is Node3D:
			for gc in c.get_children():
				print("    grandchild:", gc.name, "transform:", gc.transform)
	quit(0)
