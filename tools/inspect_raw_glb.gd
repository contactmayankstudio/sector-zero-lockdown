@tool
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	doc.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state)
	var scene = doc.generate_scene(state)
	_print(scene, "")
	quit()

func _print(n: Node, indent: String):
	var s = ""
	if n is Node3D:
		s = " pos=" + str(n.position) + " rot=" + str(n.rotation_degrees) + " scale=" + str(n.scale)
	print(indent, n.name, " (", n.get_class(), ")", s)
	for c in n.get_children():
		_print(c, indent + "  ")
