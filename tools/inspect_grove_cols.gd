
extends SceneTree

func _init():
	var sc = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = sc.instantiate()
	var cols = inst.find_children("*", "CollisionShape3D", true, false)
	print("GTAGroveStreet CollisionShape3D count: ", cols.size())
	inst.free()
	quit(0)
