extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_res.instantiate()
	var char_node = soldier.find_child("Character", true, false)
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	print("Character transform: ", char_node.transform)
	print("Skeleton transform: ", skel.transform)
	quit(0)
