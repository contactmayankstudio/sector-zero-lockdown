extends SceneTree

func _init():
	var s = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = s.instantiate()
	var ap: AnimationPlayer = inst.find_children("*", "AnimationPlayer", true, false)[0]
	var skel: Skeleton3D = inst.find_children("*", "Skeleton3D", true, false)[0]
	print("AP path: ", ap.get_path())
	print("AP root_node: ", ap.root_node)
	print("Skeleton path: ", skel.get_path())
	print("Relative path from AP root_node to Skeleton: ", ap.get_node(ap.root_node).get_path_to(skel))
	inst.free()
	quit(0)
