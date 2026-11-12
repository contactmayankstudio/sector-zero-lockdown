extends SceneTree

func _init():
	var res = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = res.instantiate()
	_print_tree(inst, "")
	inst.free()
	quit(0)

func _print_tree(n: Node, indent: String):
	var pos = n.position if n is Node3D else ""
	var rot = n.rotation_degrees if n is Node3D else ""
	print(indent, n.name, " (", n.get_class(), ") pos=", pos, " rot=", rot)
	for c in n.get_children():
		_print_tree(c, indent + "  ")
