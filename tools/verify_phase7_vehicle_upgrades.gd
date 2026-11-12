extends SceneTree

func _init():
	print("==================================================================")
	print("🧪 VERIFYING PHASE 7 VEHICLE UPGRADES & NIGHT HEADLIGHTS")
	print("==================================================================")
	
	var pass_count = 0
	var total_tests = 4
	
	# TEST 1: Headlight Orientations & Fill-Rate Settings
	print("\n[PHASE 7 - TEST 1] Verifying Car & Bike Headlights...")
	var car_scene = load("res://scenes/vehicles/DrivableCar.tscn")
	var car: DrivableCar = car_scene.instantiate()
	root.add_child(car)
	if not car.is_node_ready():
		car._ready()
		
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike: DrivableBike = bike_scene.instantiate()
	root.add_child(bike)
	if not bike.is_node_ready():
		bike._ready()
		
	var hl_l = car.get_node("HeadlightL") as SpotLight3D
	var hl_r = car.get_node("HeadlightR") as SpotLight3D
	var b_hl = bike.get_node("Headlight") as SpotLight3D
	
	assert(hl_l != null and hl_r != null, "Car headlights not found!")
	assert(b_hl != null, "Bike headlight not found!")
	
	# Verify forward-down direction: local forward is -basis.z
	var l_dir = -hl_l.transform.basis.z
	var r_dir = -hl_r.transform.basis.z
	var b_dir = -b_hl.transform.basis.z
	
	print("  Car Left Headlight forward vector: %s" % l_dir)
	print("  Car Right Headlight forward vector: %s" % r_dir)
	print("  Bike Headlight forward vector: %s" % b_dir)
	
	# -Z is forward in vehicle space. The headlights must point forward (Z < -0.9) and down (Y < 0.0)
	assert(l_dir.z < -0.9 and l_dir.y < 0.0, "Car Left Headlight not pointing forward and down at road!")
	assert(r_dir.z < -0.9 and r_dir.y < 0.0, "Car Right Headlight not pointing forward and down at road!")
	assert(b_dir.z < -0.9 and b_dir.y < 0.0, "Bike Headlight not pointing forward and down at road!")
	
	# Verify shadow_enabled is FALSE to eliminate GPU fill rate & shadow map overhead
	assert(hl_l.shadow_enabled == false, "Car Left Headlight shadow_enabled should be false!")
	assert(hl_r.shadow_enabled == false, "Car Right Headlight shadow_enabled should be false!")
	assert(b_hl.shadow_enabled == false, "Bike Headlight shadow_enabled should be false!")
	
	print("✅ TEST 1 PASSED: Headlights illuminated forward-down onto road with 0 shadow fill overhead.")
	pass_count += 1
	
	# TEST 2: Night Headlight Toggling & State Transitions
	print("\n[PHASE 7 - TEST 2] Verifying Headlight Controls & On/Off Toggles...")
	assert(car.has_method("_toggle_headlight"), "Car missing _toggle_headlight method!")
	assert(bike.has_method("_toggle_headlight"), "Bike missing _toggle_headlight method!")
	
	# Simulate entering car: headlights should turn on
	var dummy_p = Node3D.new()
	root.add_child(dummy_p)
	car.enter_vehicle(dummy_p)
	assert(hl_l.visible == true and hl_r.visible == true, "Car headlights should turn on upon entry!")
	
	# Toggle headlights off with L key simulation
	car._toggle_headlight()
	assert(hl_l.visible == false and hl_r.visible == false, "Car headlights should toggle off with [L]!")
	car._toggle_headlight()
	assert(hl_l.visible == true and hl_r.visible == true, "Car headlights should toggle back on with [L]!")
	
	car.exit_vehicle()
	assert(hl_l.visible == false and hl_r.visible == false, "Car headlights should turn off upon exit!")
	
	# Simulate entering bike
	bike.enter_vehicle(dummy_p)
	assert(b_hl.visible == true, "Bike headlight should be visible on mount!")
	# Toggle to high beam
	bike._toggle_headlight()
	assert(bike.headlight_state == 2, "Bike headlight should be in High Beam state!")
	assert(b_hl.shadow_enabled == false, "Bike High Beam must keep shadow_enabled = false!")
	# Toggle off
	bike._toggle_headlight()
	assert(bike.headlight_state == 0 and b_hl.visible == false, "Bike headlight should toggle off!")
	bike.exit_vehicle()
	
	print("✅ TEST 2 PASSED: Headlight states & toggles function seamlessly.")
	pass_count += 1
	
	# TEST 3: Curb & Barrier Collision Tuning
	print("\n[PHASE 7 - TEST 3] Verifying Curb & Barrier Collision Tuning...")
	assert(bike.floor_constant_speed == true, "Bike floor_constant_speed must be true for curb rolling!")
	assert(bike.floor_snap_length <= 0.4, "Bike floor_snap_length must be <= 0.4m to prevent snagging!")
	assert(bike.floor_block_on_wall == false, "Bike floor_block_on_wall must be false to slide on highway barriers!")
	
	var bike_col: CollisionShape3D = bike.get_node("BodyCollision")
	var box_shape: BoxShape3D = bike_col.shape as BoxShape3D
	var bottom_y = bike_col.position.y - (box_shape.size.y * 0.5)
	print("  Bike chassis collision bottom clearance: %.3fm" % bottom_y)
	assert(bottom_y >= 0.15, "Bike chassis collision clearance must be >= 0.15m to clear curbs!")
	
	# Car grounded roll damping verification
	car.is_occupied = true
	car.angular_velocity = Vector3(2.5, 0.0, 2.5) # simulate curb roll/pitch impulse
	car._physics_process(0.016)
	print("  Car damped angular velocity: %s" % car.angular_velocity)
	assert(abs(car.angular_velocity.z) < 2.5, "Car angular roll not damped when grounded!")
	assert(abs(car.angular_velocity.x) < 2.5, "Car angular pitch not damped when grounded!")
	car.is_occupied = false
	
	print("✅ TEST 3 PASSED: Curb & barrier collision dynamics tuned for smooth traversal.")
	pass_count += 1
	
	# TEST 4: Speed Caps & Downforce Preservation
	print("\n[PHASE 7 - TEST 4] Verifying Speed Caps (190 km/h cruise, 230 km/h nitro)...")
	car.linear_velocity = Vector3(0, 0, 200.0) # > 700 km/h
	car.is_boosting = false
	car._physics_process(0.016)
	assert(car.speed_kmh <= 190.01, "Cruise speed cap breached!")
	
	car.linear_velocity = Vector3(0, 0, 200.0)
	car.is_boosting = true
	car._physics_process(0.016)
	assert(car.speed_kmh <= 230.01, "Nitro speed cap breached!")
	
	print("✅ TEST 4 PASSED: Speed caps strictly preserved.")
	pass_count += 1
	
	print("\n==================================================================")
	print("🎉 ALL %d/%d PHASE 7 VEHICLE TESTS PASSED!" % [pass_count, total_tests])
	print("==================================================================")
	quit(0)
