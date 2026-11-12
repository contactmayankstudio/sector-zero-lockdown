extends SceneTree

func _init():
	print("--- TEST PLAYER ON FLAT FLOOR ---")
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	# Floor
	var sb = StaticBody3D.new()
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(100.0, 1.0, 100.0)
	col.shape = box
	col.position = Vector3(0.0, -0.5, 0.0) # Top of floor is at y = 0.0!
	sb.add_child(col)
	root_node.add_child(sb)
	
	# Player
	var p_scene = load("res://scenes/player/Player.tscn")
	var pl = p_scene.instantiate()
	pl.position = Vector3(0.0, 1.0, 0.0)
	root_node.add_child(pl)
	
	for i in range(20):
		await process_frame
		print("Step %d | pos: %s | on_floor: %s" % [i, str(pl.position), str(pl.is_on_floor())])
		
	quit(0)
