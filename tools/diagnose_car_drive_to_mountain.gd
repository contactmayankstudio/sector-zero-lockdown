extends SceneTree

func _init():
	print("=== DIAGNOSING CAR DRIVE TO MOUNTAIN ===")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = scn.instantiate()
	get_root().add_child(arena)

	for i in range(10):
		await RenderingServer.frame_post_draw

	var car = arena.get_node_or_null("DrivableCar")
	var player = arena.get_node_or_null("Player")
	if not car or not player:
		print("ERROR: car or player not found")
		quit(1)
		return

	print("Car initial pos: ", car.global_position)
	car.enter_vehicle(player)

	# Aim car directly towards the West Mountain (angle towards -X)
	# Turn car to face (-1, 0, 0)
	car.global_position = Vector3(0.0, 0.8, -80.0)
	car.rotation_degrees = Vector3(0, 90, 0) # facing West (-X)
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO

	print("Testing driving car West towards mountain...")
	# Simulate pressing W (forward throttle) for 300 physics ticks (5 seconds)
	var blocked_at = Vector3.ZERO
	var last_x = car.global_position.x
	var stuck_counter = 0

	for tick in range(300):
		# Force throttle
		car.engine_force = 9500.0
		car.brake = 0.0
		# Apply hill climb traction
		var slope_pitch = -car.transform.basis.z.y
		if slope_pitch > 0.02:
			car.apply_central_force(-car.transform.basis.z * 4800.0)
		
		# Step physics
		await RenderingServer.frame_post_draw
		
		if tick % 30 == 0:
			var speed = car.linear_velocity.length() * 3.6
			print("Tick %3d: pos=(%.2f, %.2f, %.2f) speed=%.1f km/h" % [
				tick, car.global_position.x, car.global_position.y, car.global_position.z, speed
			])
			
			if absf(car.global_position.x - last_x) < 0.2:
				stuck_counter += 1
				if stuck_counter >= 3:
					print("--> CAR IS STUCK AT pos: ", car.global_position)
					# Check what is under/in front of the car
					var space = car.get_world_3d().direct_space_state
					var ray = PhysicsRayQueryParameters3D.create(
						car.global_position + Vector3(0, 0.5, 0),
						car.global_position + Vector3(-2.0, -0.5, 0)
					)
					var hit = space.intersect_ray(ray)
					if hit:
						print("Hit collider: ", hit.collider.name, " class: ", hit.collider.get_class(), " at: ", hit.position)
					break
			else:
				stuck_counter = 0
			last_x = car.global_position.x

	arena.queue_free()
	quit(0)
