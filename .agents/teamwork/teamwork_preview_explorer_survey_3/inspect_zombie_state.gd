extends SceneTree
func _init():
	var scn = load("res://scenes/zombies/Zombie.tscn")
	var state = scn.get_state()
	print("Nodes in Zombie.tscn: ", state.get_node_count())
	for i in range(state.get_node_count()):
		print("Node ", i, ": ", state.get_node_name(i), " type: ", state.get_node_type(i))
	quit(0)
