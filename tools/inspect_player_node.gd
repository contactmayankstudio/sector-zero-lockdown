extends SceneTree

func _init():
	var p_scene = load("res://scenes/player/Player.tscn")
	if not p_scene:
		print("Player.tscn not found")
		quit(1)
		return
	var p = p_scene.instantiate()
	print("Player root: ", p.name, " Class: ", p.get_class())
	for c in p.get_children():
		print("  Child: ", c.name, " Class: ", c.get_class(), " Visible: ", c.visible if "visible" in c else "N/A")
		for cc in c.get_children():
			print("    Grandchild: ", cc.name, " Class: ", cc.get_class(), " Visible: ", cc.visible if "visible" in cc else "N/A")
	quit(0)
