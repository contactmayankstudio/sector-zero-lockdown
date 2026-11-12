
extends SceneTree

func _init():
	var sc = load("res://scenes/zombies/models/RealDoomZombie.scn")
	var inst = sc.instantiate()
	print("RealDoomZombie root: ", inst.name, " class: ", inst.get_class(), " rot: ", inst.rotation_degrees)
	for c in inst.find_children("*", "Node3D", true, false):
		print("  Node: ", c.name, " type: ", c.get_class(), " pos: ", c.position, " rot: ", c.rotation_degrees, " scale: ", c.scale)
	inst.free()
	quit(0)
