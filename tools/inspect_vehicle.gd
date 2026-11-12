@tool
extends SceneTree

func _init():
	print("=== Inspecting PoliceCarProp.scn ===")
	_inspect("res://scenes/environments/props/PoliceCarProp.scn")
	print("\n=== Inspecting WreckedVehiclesPack.scn ===")
	_inspect("res://scenes/environments/props/WreckedVehiclesPack.scn")
	quit(0)

func _inspect(path: String):
	if not ResourceLoader.exists(path):
		print("File does not exist: ", path)
		return
	var scene = load(path)
	if not scene:
		print("Could not load scene: ", path)
		return
	var inst = scene.instantiate()
	_print_tree(inst, "")
	inst.free()

func _print_tree(node: Node, indent: String):
	var mesh_info = ""
	if node is MeshInstance3D and node.mesh:
		mesh_info = " [Mesh: " + str(node.mesh.get_class()) + "]"
	print(indent + node.name + " (" + node.get_class() + ")" + mesh_info)
	if indent.length() < 8:
		for c in node.get_children():
			_print_tree(c, indent + "  ")
