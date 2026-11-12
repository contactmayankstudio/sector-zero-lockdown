extends SceneTree

func _init():
	var s = load("res://scenes/characters/RealSoldier.scn")
	if s:
		var inst = s.instantiate()
		print("--- RealSoldier.scn Structure ---")
		_print_tree(inst, "")
	quit(0)

func _print_tree(n: Node, indent: String):
	print(indent, n.name, " (", n.get_class(), ")")
	for c in n.get_children():
		_print_tree(c, indent + "  ")
