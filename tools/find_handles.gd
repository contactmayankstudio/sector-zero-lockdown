extends SceneTree

func _init():
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root.add_child(bike)
	
	_search_nodes(bike, "")
	quit(0)

func _search_nodes(node: Node, path: String):
	var p = path + "/" + node.name if path != "" else node.name
	if node is Node3D:
		var n3d = node as Node3D
		var nm = node.name.to_lower()
		if "fork" in nm or "steer" in nm or "handle" in nm or "element_b" in nm or "glasses" in nm or "headlight" in nm:
			print(p, " pos: ", n3d.position, " global_pos: ", n3d.global_position)
	for c in node.get_children():
		_search_nodes(c, p)
