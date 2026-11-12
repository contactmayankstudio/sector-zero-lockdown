@tool
extends SceneTree

func _init():
	var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
	var inst = scn.instantiate()
	print("--- Hayabusa Detailed Tree ---")
	_print_tree(inst, 0)
	quit(0)

func _print_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	var t_str = ""
	if node is Node3D:
		t_str = " pos=%s rot=%s scale=%s" % [node.position, node.rotation_degrees, node.scale]
	print("%s%s (%s)%s" % [indent, node.name, node.get_class(), t_str])
	for c in node.get_children():
		_print_tree(c, depth + 1)
