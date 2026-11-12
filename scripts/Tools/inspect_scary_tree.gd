@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = scn.instantiate()
	_print_tree(inst, "")
	quit()

func _print_tree(n: Node, indent: String):
	var s = ""
	if n is Node3D:
		s = " pos: " + str(n.position) + " rot: " + str(n.rotation_degrees) + " scale: " + str(n.scale)
	print(indent, n.name, " (", n.get_class(), ")", s)
	for c in n.get_children():
		_print_tree(c, indent + "  ")
