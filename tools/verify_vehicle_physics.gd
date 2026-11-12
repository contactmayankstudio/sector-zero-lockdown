extends SceneTree

func _init():
	print("==================================================================")
	print("🧪 VERIFYING VEHICLE PHYSICS & DYNAMICS SUITE")
	print("==================================================================")
	
	var pass_count = 0
	var total_tests = 5
	
	# TEST 1: Speed Conversion (m/s to KM/H exact calibration)
	print("\n[TEST 1] Verifying Speed Conversion Formula (m/s -> KM/H)...")
	var car_scene = load("res://scenes/vehicles/DrivableCar.tscn")
	var car: DrivableCar = car_scene.instantiate()
	root.add_child(car)
	if not car.is_node_ready():
		car._ready()
	
	# Set linear velocity to exactly 50 m/s: 50 * 3.6 = 180 km/h
	car.linear_velocity = Vector3(30.0, 0.0, 40.0) # length = 50.0 m/s
	car._physics_process(0.016)
	var expected_kmh = 50.0 * 3.6
	print("  Car speed_kmh: %.2f (expected: %.2f)" % [car.speed_kmh, expected_kmh])
	assert(abs(car.speed_kmh - expected_kmh) < 0.01, "Car speed conversion mismatch!")
	
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike: DrivableBike = bike_scene.instantiate()
	root.add_child(bike)
	if not bike.is_node_ready():
		bike._ready()
	
	# Set bike linear_velocity to 25 m/s: 25 * 3.6 = 90 km/h
	bike.linear_velocity = Vector3(0.0, 0.0, -25.0)
	bike._physics_process(0.016)
	var expected_bike_kmh = 25.0 * 3.6
	print("  Bike speed_kmh: %.2f (expected: %.2f)" % [bike.speed_kmh, expected_bike_kmh])
	assert(abs(bike.speed_kmh - expected_bike_kmh) < 0.01, "Bike speed conversion mismatch!")
	print("✅ TEST 1 PASSED: Speed conversion formula exact and calibrated.")
	pass_count += 1
	
	# TEST 2: Strict Maximum Speed Caps (Cruise <= 190 KM/H, Nitro <= 230 KM/H)
	print("\n[TEST 2] Verifying Strict Speed Caps (Cruise 190 km/h, Nitro 230 km/h)...")
	# Test extreme runaway velocity injection (e.g. 918 KM/H = 255 m/s)
	car.is_boosting = false
	car.linear_velocity = Vector3(0.0, -50.0, 250.0) # > 918 KM/H
	car._physics_process(0.016)
	print("  Car cruise clamped speed: %.2f KM/H (cap: %.2f)" % [car.speed_kmh, car.max_top_speed_kmh])
	assert(car.speed_kmh <= car.max_top_speed_kmh + 0.01, "Car cruise speed cap breached!")
	assert(car.linear_velocity.length() * 3.6 <= car.max_top_speed_kmh + 0.01, "Car 3D velocity breached cruise cap!")
	
	# Test Nitro boost cap
	car.is_boosting = true
	car.linear_velocity = Vector3(0.0, 0.0, 100.0) # 360 KM/H
	car._physics_process(0.016)
	print("  Car nitro clamped speed: %.2f KM/H (cap: %.2f)" % [car.speed_kmh, car.nitro_top_speed_kmh])
	assert(car.speed_kmh <= car.nitro_top_speed_kmh + 0.01, "Car nitro speed cap breached!")
	
	# Test Bike speed caps under runaway acceleration
	bike.is_boosting = false
	bike.linear_velocity = Vector3(0.0, 0.0, -255.0) # 918 KM/H
	bike._physics_process(0.016)
	print("  Bike cruise clamped speed: %.2f KM/H (cap: %.2f)" % [bike.speed_kmh, bike.max_top_speed_kmh])
	assert(bike.speed_kmh <= bike.max_top_speed_kmh + 0.01, "Bike cruise speed cap breached!")
	
	bike.is_boosting = true
	bike.linear_velocity = Vector3(0.0, 0.0, -100.0) # 360 KM/H
	bike._physics_process(0.016)
	print("  Bike nitro clamped speed: %.2f KM/H (cap: %.2f)" % [bike.speed_kmh, bike.nitro_top_speed_kmh])
	assert(bike.speed_kmh <= bike.nitro_top_speed_kmh + 0.01, "Bike nitro speed cap breached!")
	print("✅ TEST 2 PASSED: Strict speed caps enforced. 918 km/h runaway velocity eradicated!")
	pass_count += 1
	
	# TEST 3: Ground contact via wheel checks & Downforce
	print("\n[TEST 3] Verifying Ground Contact via Wheel Checks & Aerodynamic Downforce...")
	# Verify wheel check helper methods exist and function
	assert(car.has_method("get_contact_wheel_count"), "Car missing get_contact_wheel_count method!")
	assert(car.has_method("_can_apply_drive_force"), "Car missing _can_apply_drive_force method!")
	assert(bike.has_method("_is_bike_grounded"), "Bike missing _is_bike_grounded method!")
	assert(bike.has_method("_has_solid_traction"), "Bike missing _has_solid_traction method!")
	
	# Check that airborne car has 0 engine_force when airborne
	car.is_occupied = true
	# When airborne, wheel contact is 0
	assert(car.get_contact_wheel_count() == 0, "Airborne car should have 0 wheels in contact in empty test space")
	assert(not car._can_apply_drive_force(), "Airborne car should not be allowed to apply forward drive force!")
	car._handle_driving_input(0.016, 100.0, false)
	assert(car.engine_force == 0.0, "Airborne car applied non-zero engine_force!")
	assert(not car.is_boosting, "Airborne car should not be allowed to activate nitro boost!")
	car.is_occupied = false
	print("  Airborne car engine_force: %.1f, is_boosting: %s" % [car.engine_force, car.is_boosting])
	print("✅ TEST 3 PASSED: Ground contact verified via wheel checks before applying forward driving forces.")
	pass_count += 1
	
	# TEST 4: Nitro Particle Density Optimization
	print("\n[TEST 4] Verifying Nitro Particle Optimization in DrivableCar...")
	assert(car.nitro_exhaust_l != null, "Nitro left emitter not found!")
	assert(car.nitro_exhaust_r != null, "Nitro right emitter not found!")
	var l_amount = car.nitro_exhaust_l.amount
	var r_amount = car.nitro_exhaust_r.amount
	var lifetime = car.nitro_exhaust_l.lifetime
	print("  Nitro particle amount per side: %d (lifetime: %.2fs)" % [l_amount, lifetime])
	assert(l_amount <= 10 and r_amount <= 10, "Nitro particle amount too high! GPU fill-rate throttling risk!")
	assert(lifetime <= 0.20, "Nitro particle lifetime too long!")
	var mat: StandardMaterial3D = car.nitro_exhaust_l.mesh.material
	assert(mat.depth_draw_mode == BaseMaterial3D.DEPTH_DRAW_DISABLED, "Material should use DEPTH_DRAW_DISABLED for low fill overhead!")
	print("✅ TEST 4 PASSED: Nitro particle emission optimized for mobile/low-end GPU fill-rate.")
	pass_count += 1
	
	# TEST 5: Vehicle Chase Camera & Horizon Stabilization (top_level = true)
	print("\n[TEST 5] Verifying Chase Camera Smooth Following & Horizon Stabilization...")
	var dummy_player = Node3D.new()
	dummy_player.add_to_group("player")
	root.add_child(dummy_player)
	
	# Mount car
	car.enter_vehicle(dummy_player)
	car._update_smooth_camera(0.016, 50.0)
	assert(car.chase_camera != null, "Car chase camera null!")
	assert(car.chase_camera.top_level == true, "Car chase camera top_level must be TRUE for horizon stabilization!")
	print("  Car chase camera top_level: %s, transform up: %s" % [car.chase_camera.top_level, car.chase_camera.global_transform.basis.y])
	# Check upright horizon: up vector should point mostly towards Vector3.UP
	assert(car.chase_camera.global_transform.basis.y.dot(Vector3.UP) > 0.8, "Camera horizon not upright!")
	
	car.exit_vehicle()
	assert(car.chase_camera.top_level == false, "Car chase camera top_level should be reset to false when exited!")
	
	# Mount bike
	bike.enter_vehicle(dummy_player)
	bike._update_smooth_camera(0.016, 50.0)
	assert(bike.chase_camera != null, "Bike chase camera null!")
	assert(bike.chase_camera.top_level == true, "Bike chase camera top_level must be TRUE for horizon stabilization!")
	print("  Bike chase camera top_level: %s, transform up: %s" % [bike.chase_camera.top_level, bike.chase_camera.global_transform.basis.y])
	assert(bike.chase_camera.global_transform.basis.y.dot(Vector3.UP) > 0.8, "Bike camera horizon not upright!")
	
	bike.exit_vehicle()
	assert(bike.chase_camera.top_level == false, "Bike chase camera top_level should be reset to false when exited!")
	print("✅ TEST 5 PASSED: Chase camera follows smoothly with upright horizon stabilization.")
	pass_count += 1
	
	print("\n==================================================================")
	print("🎉 ALL %d/%d VEHICLE PHYSICS TESTS PASSED PERFECTLY!" % [pass_count, total_tests])
	print("==================================================================")
	quit(0)
