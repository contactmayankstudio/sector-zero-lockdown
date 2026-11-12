extends SceneTree

func _get_relative_transform(node: Node3D, root_node: Node3D) -> Transform3D:
	var xf = node.transform
	var cur = node.get_parent()
	while cur and cur != root_node:
		if cur is Node3D:
			xf = cur.transform * xf
		cur = cur.get_parent()
	return xf

func _init():
	var s = load("res://scenes/weapons/models/ak74_bayonet.scn")
	var inst = s.instantiate()
	
	var comp: MeshInstance3D = inst.find_child("compensator_low_main_0", true, false)
	var stock: MeshInstance3D = inst.find_child("stock_low_main_0", true, false)
	var grip: MeshInstance3D = inst.find_child("grip_low_main_0", true, false)
	var fs: MeshInstance3D = inst.find_child("front_sights_low_main_0", true, false)
	
	print("Compensator: ", _get_relative_transform(comp, inst).origin)
	print("Stock: ", _get_relative_transform(stock, inst).origin)
	print("Grip: ", _get_relative_transform(grip, inst).origin)
	print("Front sight: ", _get_relative_transform(fs, inst).origin)
	
	inst.free()
	quit(0)
