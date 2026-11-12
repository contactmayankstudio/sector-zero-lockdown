extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/ak74_bayonet.scn")
	var inst = s.instantiate()
	for c in inst.get_children():
		print("Child: ", c.name, " (", c.get_class(), ") pos=", c.position, " rot=", c.rotation_degrees)
		for gc in c.get_children():
			print("   * ", gc.name, " (", gc.get_class(), ") pos=", gc.position, " rot=", gc.rotation_degrees)
	inst.free()
	quit(0)
