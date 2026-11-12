
extends SceneTree

func _init():
	var sc = load("res://scenes/environments/props/WreckedVehiclesPack.scn")
	var inst = sc.instantiate()
	for c in inst.find_children("*", "Node3D", true, false):
		if "car" in c.name.to_lower():
			print("Found car node: ", c.name)
	inst.free()
	quit(0)
