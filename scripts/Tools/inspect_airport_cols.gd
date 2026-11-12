@tool
extends SceneTree

func _init():
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	root.add_child(inst)
	
	var col_nodes = inst.find_children("*", "CollisionShape3D", true, false)
	print("Found CollisionShape3Ds: ", col_nodes.size())
	for c in col_nodes:
		print("Col: ", c.get_parent().name, " / ", c.name, " shape: ", c.shape, " pos: ", c.global_position)
	
	quit()
