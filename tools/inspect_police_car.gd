@tool
extends SceneTree

func _init():
	var p = load("res://scenes/environments/props/PoliceCarProp.scn")
	if p:
		var inst = p.instantiate()
		print("Loaded PoliceCarProp successfully!")
		print_node(inst, 0)
	else:
		print("Failed to load PoliceCarProp.scn")
	quit()

func print_node(node: Node, depth: int):
	var ind = ""
	for i in range(depth): ind += "  "
	var details = ""
	if node is Node3D:
		details = " pos=" + str(node.position) + " rot=" + str(node.rotation_degrees) + " scale=" + str(node.scale)
	if node is MeshInstance3D:
		details += " mesh=" + str(node.mesh.get_class() if node.mesh else "null")
		if node.mesh:
			details += " surfs=" + str(node.mesh.get_surface_count())
	print(ind + "- " + node.name + " (" + node.get_class() + ")" + details)
	for c in node.get_children():
		print_node(c, depth + 1)
