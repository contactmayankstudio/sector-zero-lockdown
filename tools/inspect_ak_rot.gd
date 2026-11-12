
extends SceneTree

func _init():
	var sc = load("res://scenes/weapons/models/AK74uAnimated.scn")
	var inst = sc.instantiate()
	print("AK74u rot_deg: ", inst.rotation_degrees)
	for c in inst.get_children():
		print("  Child: ", c.name, " rot_deg: ", c.rotation_degrees, " scale: ", c.scale)
	inst.free()
	quit(0)
