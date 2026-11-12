extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.tscn")
	if not scene:
		print("Failed to load RealSoldier.tscn")
		quit(1)
		return
	var inst = scene.instantiate()
	print("Instantiated RealSoldier successfully!")
	_print_tree(inst, "")
	var anim_player = inst.find_child("AnimationPlayer", true, false)
	if anim_player:
		print("Animations: ", anim_player.get_animation_list())
	quit(0)

func _print_tree(node: Node, indent: String):
	print(indent + node.name + " (" + node.get_class() + ")")
	for c in node.get_children():
		_print_tree(c, indent + "  ")
