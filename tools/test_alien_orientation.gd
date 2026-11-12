extends SceneTree

func _init():
	var s = load("res://assets/zombies/RealisticZombie.tscn")
	var z = s.instantiate()
	z.archetype = "mutant"
	root.add_child(z)
	
	var model = z.get_node_or_null("RealAlienMutantModel")
	print("Model found: ", model != null)
	if model:
		print("Model scale: ", model.scale, " rot_deg: ", model.rotation_degrees)
		for c in model.get_children():
			print("  Child: ", c.name, " rot_deg: ", c.rotation_degrees)
	for m in z.find_children("*", "VisualInstance3D", true, false):
		print("Mesh: ", m.name, " global_pos: ", m.global_position)
	quit(0)
