extends SceneTree

func _init():
	print("--- TRACING GTA OPEN WORLD READY ---")
	var scene = load("res://scenes/world/GTAOpenWorld.tscn")
	var inst = scene.instantiate()
	
	# Add child to root
	root.add_child(inst)
	var pl = inst.get_node_or_null("Player")
	if pl:
		print("Right after add_child: Player pos: ", pl.global_position)
	
	for i in range(5):
		await process_frame
		if pl:
			print("Frame %d: Player pos: %s on_floor: %s" % [i, str(pl.global_position), str(pl.is_on_floor())])
			
	quit(0)
