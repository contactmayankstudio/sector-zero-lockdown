extends SceneTree

func _init():
	for name in ["n7_rifle", "car_smg", "negev_ng7", "akx_scifi"]:
		var p = "res://scenes/weapons/models/" + name + ".scn"
		var s = load(p)
		var inst = s.instantiate()
		print("=== ", name, " ===")
		print("Root class: ", inst.get_class(), " scale: ", inst.scale, " rot: ", inst.rotation_degrees)
		for c in inst.get_children():
			print(" - Child: ", c.name, " class: ", c.get_class(), " scale: ", c.scale, " rot: ", c.rotation_degrees, " pos: ", c.position)
		inst.free()
	quit(0)
