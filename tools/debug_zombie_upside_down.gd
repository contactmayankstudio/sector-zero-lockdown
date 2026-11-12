
extends SceneTree

func _init():
	var s = load("res://scenes/environments/UrbanStreet.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	
	# Wait 2 frames for ready and spawns
	for i in range(10):
		process_frame.emit()
		
	var zombies = inst.find_children("*", "CharacterBody3D", true, false)
	print("Found CharacterBody3Ds: ", zombies.size())
	for z in zombies:
		if z.name != "Player":
			print("Zombie ", z.name, " pos: ", z.global_position, " rot_deg: ", z.rotation_degrees, " up: ", z.transform.basis.y)
			var sm = z.get_node_or_null("SkeletalModel")
			if sm:
				print("  SkeletalModel rot_deg: ", sm.rotation_degrees, " up: ", sm.transform.basis.y)
				for c in sm.get_children():
					if c is Node3D:
						print("    Child ", c.name, " rot: ", c.rotation_degrees, " up: ", c.transform.basis.y)
	quit(0)
