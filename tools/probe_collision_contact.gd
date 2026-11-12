extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn").instantiate()
	get_root().add_child(scn)
	for i in range(10): await process_frame

	var ss = scn.get_world_3d().direct_space_state
	print("--- Probing contacts from (-14, 0.5, -130) to (-20, 0.5, -130) ---")

	for x_f in range(140, 220, 5):
		var x = -float(x_f) / 10.0
		var q = PhysicsRayQueryParameters3D.create(Vector3(x, 15, -130), Vector3(x, -5, -130))
		var hit = ss.intersect_ray(q)
		if hit:
			print("X=", x, " Hit pos=", hit.position, " Normal=", hit.normal, " Collider=", hit.collider.name, " (Class: ", hit.collider.get_class(), ")")
		else:
			print("X=", x, " NO HIT!")

	# Check horizontal sweep
	var sweep_q = PhysicsRayQueryParameters3D.create(Vector3(-14, 0.5, -130), Vector3(-20, 0.5, -130))
	var sweep_hit = ss.intersect_ray(sweep_q)
	if sweep_hit:
		print("HORIZONTAL BLOCKED AT: ", sweep_hit.position, " by ", sweep_hit.collider.name)
	else:
		print("HORIZONTAL PATH CLEAR!")

	# Now check bike test directly
	var bike = scn.get_node_or_null("DrivableBike")
	if bike:
		bike.global_position = Vector3(-14, 0.8, -130)
		bike.rotation_degrees = Vector3(0, 90, 0)
		for i in range(5): await physics_frame
		print("Bike after 5 frames: pos=", bike.global_position, " on_floor=", bike.is_on_floor(), " on_wall=", bike.is_on_wall())
		for frame in range(30):
			bike.velocity = Vector3(-10, 0, 0)
			bike.move_and_slide()
			await physics_frame
			if bike.is_on_wall():
				print("Bike HIT WALL at frame ", frame, " pos=", bike.global_position, " wall_normal=", bike.get_wall_normal())
				for col_idx in range(bike.get_slide_collision_count()):
					var col = bike.get_slide_collision(col_idx)
					print("  Collider: ", col.get_collider().name, " at ", col.get_position(), " normal=", col.get_normal())
				break
		print("Bike final pos: ", bike.global_position)

	scn.queue_free()
	quit(0)
