extends SceneTree

func _init():
	var b_sc = load("res://scenes/zombies/BossZombie.tscn")
	var b = b_sc.instantiate()
	root.add_child(b)
	await process_frame
	await process_frame
	
	for c in b.find_children("*", "VisualInstance3D", true, false):
		print("Boss mesh: ", c.name, " global_pos: ", c.global_position, " aabb: ", c.get_aabb())
		
	b.free()
	quit(0)
