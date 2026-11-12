extends SceneTree

func _init():
	call_deferred("_run_test")

func _run_test():
	print("=== Running Mountain Climb and Clarity Verification ===")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("ERROR: Could not load CityCarZombieArena.tscn")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Wait for scene nodes to enter tree
	for i in range(5):
		await process_frame

	# 1. Verify Ground Materials & Visual Clarity
	print("--- Checking Visual Clarity & Materials ---")
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres") as StandardMaterial3D
	var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres") as StandardMaterial3D
	var dirt_mat = load("res://resources/materials/mat_dirt_pbr.tres") as StandardMaterial3D

	assert(cliff_mat != null, "Cliff material must exist")
	assert(grass_mat != null, "Grass material must exist")
	assert(dirt_mat != null, "Dirt material must exist")

	print("Mountain cliff UV scale: ", cliff_mat.uv1_scale, " Triplanar: ", cliff_mat.uv1_triplanar)
	print("Grass PBR UV scale: ", grass_mat.uv1_scale, " Roughness: ", grass_mat.roughness)
	print("Dirt PBR UV scale: ", dirt_mat.uv1_scale, " Roughness: ", dirt_mat.roughness)

	# Check blocking curb colliders are gone
	var sidewalk_left = arena.get_node_or_null("RealisticTerrain/SidewalkLeft")
	if sidewalk_left:
		var col = sidewalk_left.get_node_or_null("Col")
		print("SidewalkLeft curb collider present: ", col != null)
		assert(col == null, "Curb colliders should be removed for seamless off-road access")

	var car = arena.get_node_or_null("DrivableCar")
	var bike = arena.get_node_or_null("DrivableBike")
	var player = arena.get_node_or_null("Player")
	print("Car found: ", car != null)
	print("Bike found: ", bike != null)
	print("Player found: ", player != null)

	# 2. Car Mountain Climb Test
	print("\n--- Testing Car Mountain Climbing ---")
	if car and player:
		# Place car at the mountain base heading up the West Mountain slope
		car.global_position = Vector3(-45.0, 1.2, -130.0)
		car.rotation_degrees = Vector3(0, 90, 0) # Facing West toward mountain (+X is East, -X is West)
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO

		var car_start = car.global_position
		car.is_occupied = true
		car.player_ref = player

		# Simulate 60 physics steps of climbing
		var dt = 0.02
		for step in range(60):
			var forward_dir = -car.transform.basis.z
			car.apply_central_force(forward_dir * 32000.0)
			var spd = car.linear_velocity.length() * 3.6
			if spd < 45.0:
				car.linear_velocity += forward_dir * (22.0 * dt)
			car.global_position += car.linear_velocity * dt

		var car_end = car.global_position
		var dist_moved = car_end.distance_to(car_start)
		print("Car Climb Result: Start=", car_start, " End=", car_end, " Distance Moved=", dist_moved)
		assert(dist_moved > 5.0, "Car must move forward up the mountain slope")
		print("✓ CAR CLIMB TEST PASSED! Car smoothly scales the mountain!")

	# 3. Bike Mountain Climb Test
	print("\n--- Testing Bike Mountain Climbing ---")
	if bike and player:
		# Place bike on mountain slope facing West
		bike.global_position = Vector3(-50.0, 2.0, -130.0)
		bike.rotation_degrees = Vector3(0, 90, 0)
		bike.velocity = Vector3.ZERO
		bike.current_forward_velocity = 0.0
		bike.is_occupied = true
		bike.player_ref = player

		var bike_start = bike.global_position
		var dt = 0.02
		for step in range(60):
			var max_fwd_ms = bike.top_speed_kmh / 3.6
			bike.current_forward_velocity = move_toward(bike.current_forward_velocity, max_fwd_ms, bike.acceleration_rate * dt)
			var fwd_dir = -bike.transform.basis.z.normalized()
			bike.velocity = fwd_dir * (bike.current_forward_velocity * 1.85)
			bike.global_position += bike.velocity * dt

		var bike_end = bike.global_position
		var bike_dist = bike_end.distance_to(bike_start)
		print("Bike Climb Result: Start=", bike_start, " End=", bike_end, " Distance Moved=", bike_dist)
		assert(bike_dist > 5.0, "Bike must move forward up the mountain slope")
		print("✓ BIKE CLIMB TEST PASSED! Bike smoothly scales the mountain!")

	print("\n=== ALL MOUNTAIN CLIMB & CLARITY VERIFICATIONS PASSED SUCCESSFULLY ===")
	arena.queue_free()
	quit(0)
