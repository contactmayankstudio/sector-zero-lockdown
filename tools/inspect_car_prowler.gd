extends SceneTree

func _init():
	# Test car_smg internal structure
	var res = load("res://scenes/weapons/models/car_smg.scn")
	var inst = res.instantiate()
	print("--- CAR SMG NODES ---")
	_print_tree(inst, "")
	inst.free()
	
	# Test prowler_smg internal structure
	var res2 = load("res://scenes/weapons/models/prowler_smg.scn")
	var inst2 = res2.instantiate()
	print("\n--- PROWLER SMG NODES ---")
	_print_tree(inst2, "")
	inst2.free()
	
	quit(0)

func _print_tree(n: Node, indent: String):
	var info = ""
	if n is Node3D:
		info = " pos=" + str(n.position) + " rot=" + str(n.rotation_degrees) + " scale=" + str(n.scale)
	print(indent + n.name + " (" + n.get_class() + ")" + info)
	for c in n.get_children():
		_print_tree(c, indent + "  ")
