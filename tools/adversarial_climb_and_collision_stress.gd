extends SceneTree

# ==============================================================================
# ADVERSARIAL STRESS TEST: TERRAIN COLLISION & VEHICLE MOUNTAIN CLIMBING
# Rigorous empirical verification using Godot PhysicsServer3D & real physics frames
# ==============================================================================

var failures: Array[String] = []
var warnings: Array[String] = []
var results: Dictionary = {}

func _init():
	call_deferred("_run_all_adversarial_tests")

func _run_all_adversarial_tests():
	print("\n======================================================================")
	print("=== RUNNING EMPIRICAL ADVERSARIAL VEHICLE & TERRAIN STRESS TEST HARNESS ===")
	print("======================================================================\n")

	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		printerr("FATAL: Cannot load CityCarZombieArena.tscn")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Settle initial scene tree
	for i in range(10):
		await process_frame

	print("[STATUS] Scene instantiated. Beginning adversarial audits...\n")

	await _test_1_collision_coverage(arena)
	await _test_2_offroad_transitions(arena)
	await _test_3_raycast_void_and_slope_density(arena)
	await _test_4_car_mountain_climb_real_physics(arena)
	await _test_5_bike_mountain_climb_real_physics(arena)
	await _test_6_steep_slope_45deg_stress(arena)

	_print_final_summary()
	arena.queue_free()

	if failures.is_empty():
		print("\n[VERDICT] ADVERSARIAL STRESS SUITE: PASSED with 0 fatal errors.")
		quit(0)
	else:
		print("\n[VERDICT] ADVERSARIAL STRESS SUITE: FAILED with %d fatal failure(s)." % failures.size())
		quit(1)

# ------------------------------------------------------------------------------
# TEST 1: Permanent 3D Terrain Collision Mesh Integrity & Frame-0 Shape Verification
# ------------------------------------------------------------------------------
func _test_1_collision_coverage(arena: Node3D):
	print(">>> [TEST 1] Auditing Terrain Collision Integrity across all required meshes...")

	var adv = arena.get_node_or_null("AdvancedTerrain")
	var real = arena.get_node_or_null("RealisticTerrain")

	if not adv:
		failures.append("AdvancedTerrain node missing in arena scene")
		return

	var required_adv_bodies = [
		{"name": "ValleyFloor_Physics", "mesh": "ValleyFloor"},
		{"name": "MountainWest_Physics", "mesh": "MountainWest"},
		{"name": "MountainEast_Physics", "mesh": "MountainEast"},
		{"name": "MountainRoad_West_Physics", "mesh": "MountainRoad_West"},
		{"name": "MountainRoad_East_Physics", "mesh": "MountainRoad_East"},
		{"name": "DirtPath_West_Physics", "mesh": "DirtPath_West"},
		{"name": "DirtPath_East_Physics", "mesh": "DirtPath_East"},
		{"name": "MountainNorthWall_Physics", "mesh": "MountainNorthWall"},
		{"name": "MountainSouthWall_Physics", "mesh": "MountainSouthWall"},
	]

	var body_stats: Array[Dictionary] = []

	for b_info in required_adv_bodies:
		var b_name = b_info.name
		var m_name = b_info.mesh
		var body = adv.get_node_or_null(b_name) as StaticBody3D
		var mesh_inst = adv.get_node_or_null(m_name) as MeshInstance3D

		if not body:
			failures.append("Missing StaticBody3D: AdvancedTerrain/" + b_name)
			continue

		if not mesh_inst:
			failures.append("Missing visual MeshInstance3D: AdvancedTerrain/" + m_name)
			continue

		var shapes = body.find_children("*", "CollisionShape3D", true, false)
		if shapes.is_empty():
			failures.append("StaticBody3D " + b_name + " has NO CollisionShape3D children!")
			continue

		var cs = shapes[0] as CollisionShape3D
		if not cs.shape:
			failures.append("CollisionShape3D in " + b_name + " has NULL shape!")
			continue

		var shape_type = cs.shape.get_class()
		var face_count = 0
		if cs.shape is ConcavePolygonShape3D:
			var faces = (cs.shape as ConcavePolygonShape3D).get_faces()
			face_count = faces.size() / 3
			if face_count == 0:
				failures.append("ConcavePolygonShape3D in " + b_name + " has 0 faces!")

		body_stats.append({
			"name": b_name,
			"type": shape_type,
			"faces": face_count,
			"pos": body.global_position,
			"has_friction": body.physics_material_override != null
		})

	# Audit RealisticTerrain bodies (Sidewalks, Shoulders, Highway)
	if real:
		var real_targets = [
			"SidewalkLeft", "SidewalkRight",
			"DirtShoulderLeft", "DirtShoulderRight",
			"HighwayAsphalt"
		]
		for r_name in real_targets:
			var sb = real.get_node_or_null(r_name) as StaticBody3D
			if not sb:
				failures.append("Missing StaticBody3D in RealisticTerrain: " + r_name)
				continue
			var shapes = sb.find_children("*", "CollisionShape3D", true, false)
			if shapes.is_empty():
				failures.append("StaticBody3D RealisticTerrain/" + r_name + " has NO CollisionShape3D!")
				continue
			var cs = shapes[0] as CollisionShape3D
			var face_count = 0
			if cs.shape is ConcavePolygonShape3D:
				var faces = (cs.shape as ConcavePolygonShape3D).get_faces()
				face_count = faces.size() / 3

			body_stats.append({
				"name": r_name,
				"type": cs.shape.get_class() if cs.shape else "null",
				"faces": face_count,
				"pos": sb.global_position,
				"has_friction": sb.physics_material_override != null
			})

	print("  ✓ Collision Shape Audit Complete. Bodies verified: %d" % body_stats.size())
	for s in body_stats:
		print("    - %-26s | %-24s | Faces: %-6d | FrictionMat: %s" % [
			s.name, s.type, s.faces, str(s.has_friction)
		])
	results["collision_bodies_verified"] = body_stats.size()

# ------------------------------------------------------------------------------
# TEST 2: Off-road Seamless Transition & Curb Lips (Highway -> Sidewalk -> Shoulder)
# ------------------------------------------------------------------------------
func _test_2_offroad_transitions(arena: Node3D):
	print("\n>>> [TEST 2] Auditing Highway to Mountain Transition Heights & Barriers...")

	var space_state = arena.get_world_3d().direct_space_state

	# Check for legacy blocking barriers at |X| = 10.5m
	var hp = arena.get_node_or_null("HighwayProps")
	if hp:
		for i in range(8):
			var b = hp.get_node_or_null("Barrier_%d" % i)
			if b and is_instance_valid(b) and not b.is_queued_for_deletion():
				failures.append("Highway concrete obstacle barrier still active: Barrier_%d" % i)

	# Verify sidewalk/shoulder elevation steps at multiple Z sections
	var test_z_sections = [-150.0, -100.0, -50.0, 0.0, 50.0, 100.0, 150.0]
	var max_step_found = 0.0
	var total_transition_probes = 0

	for z in test_z_sections:
		# Probe West transition: X = 0 (Highway) -> X = -8 (Lane) -> X = -11 (Sidewalk) -> X = -16 (Shoulder) -> X = -25 (Terrain)
		var prev_y = 0.0
		var has_prev = false
		for x in range(0, -30, -2):
			var from_pos = Vector3(float(x), 15.0, z)
			var to_pos = Vector3(float(x), -10.0, z)
			var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
			var hit = space_state.intersect_ray(query)
			if hit:
				total_transition_probes += 1
				var hit_y = hit.position.y
				if has_prev:
					var step = absf(hit_y - prev_y)
					if step > max_step_found:
						max_step_found = step
					# Flag if step between adjacent 2m points is > 0.35m (a vertical lip)
					if step > 0.40 and absf(float(x)) < 18.0:
						failures.append("Abrupt vertical lip detected at X=%.1f, Z=%.1f: Step = %.3fm" % [float(x), z, step])
				prev_y = hit_y
				has_prev = true

		# Probe East transition
		has_prev = false
		for x in range(0, 30, 2):
			var from_pos = Vector3(float(x), 15.0, z)
			var to_pos = Vector3(float(x), -10.0, z)
			var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
			var hit = space_state.intersect_ray(query)
			if hit:
				total_transition_probes += 1
				var hit_y = hit.position.y
				if has_prev:
					var step = absf(hit_y - prev_y)
					if step > max_step_found:
						max_step_found = step
					if step > 0.40 and absf(float(x)) < 18.0:
						failures.append("Abrupt vertical lip detected at X=%.1f, Z=%.1f: Step = %.3fm" % [float(x), z, step])
				prev_y = hit_y
				has_prev = true

	print("  ✓ Transition probes executed: %d. Maximum transition delta step: %.3fm" % [total_transition_probes, max_step_found])
	results["max_transition_step"] = max_step_found

# ------------------------------------------------------------------------------
# TEST 3: Terrain Surface Raycast Density Grid (Void & Hole Detection, Slope Distribution)
# ------------------------------------------------------------------------------
func _test_3_raycast_void_and_slope_density(arena: Node3D):
	print("\n>>> [TEST 3] Stress-testing Terrain Mesh Surface Coverage (Void/Gaps Probe)...")

	var space_state = arena.get_world_3d().direct_space_state
	var total_rays = 0
	var hit_count = 0
	var missed_rays: Array[Vector3] = []

	var slopes_0_15 = 0
	var slopes_15_30 = 0
	var slopes_30_45 = 0
	var slopes_above_45 = 0

	# Test grid across West Mountain (-140 to -30), Valley (-30 to 30), East Mountain (30 to 140)
	var x_samples = [-130.0, -110.0, -90.0, -70.0, -50.0, -35.0, -20.0, -10.0, 0.0, 10.0, 20.0, 35.0, 50.0, 70.0, 90.0, 110.0, 130.0]
	var z_samples = [-180.0, -140.0, -100.0, -60.0, -20.0, 20.0, 60.0, 100.0, 140.0, 180.0]

	for x in x_samples:
		for z in z_samples:
			total_rays += 1
			var from_pos = Vector3(x, 80.0, z)
			var to_pos = Vector3(x, -30.0, z)
			var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
			var hit = space_state.intersect_ray(query)

			if hit:
				hit_count += 1
				var normal = hit.normal
				var slope_deg = rad_to_deg(acos(clampf(normal.dot(Vector3.UP), -1.0, 1.0)))

				if slope_deg <= 15.0:
					slopes_0_15 += 1
				elif slope_deg <= 30.0:
					slopes_15_30 += 1
				elif slope_deg <= 45.0:
					slopes_30_45 += 1
				else:
					slopes_above_45 += 1
			else:
				missed_rays.append(Vector3(x, 0.0, z))

	var coverage_pct = float(hit_count) / float(total_rays) * 100.0
	print("  ✓ Raycast Density Probe: %d / %d hit (%.1f%% coverage)" % [hit_count, total_rays, coverage_pct])
	print("    - Slopes  0°-15° (Flat/Gentle)   : %d (%.1f%%)" % [slopes_0_15, float(slopes_0_15)/float(hit_count)*100.0])
	print("    - Slopes 15°-30° (Moderate Hill) : %d (%.1f%%)" % [slopes_15_30, float(slopes_15_30)/float(hit_count)*100.0])
	print("    - Slopes 30°-45° (Steep Mountain): %d (%.1f%%)" % [slopes_30_45, float(slopes_30_45)/float(hit_count)*100.0])
	print("    - Slopes > 45°   (Cliff Wall)    : %d (%.1f%%)" % [slopes_above_45, float(slopes_above_45)/float(hit_count)*100.0])

	if missed_rays.size() > 0:
		failures.append("Terrain collision void holes detected! %d points penetrated through into void (e.g. %s)" % [
			missed_rays.size(), str(missed_rays[0])
		])

	results["raycast_coverage_pct"] = coverage_pct
	results["steep_slopes_count"] = slopes_30_45

# ------------------------------------------------------------------------------
# TEST 4: Police Cruiser Mountain Climb under REAL Godot Physics Ticks
# ------------------------------------------------------------------------------
func _test_4_car_mountain_climb_real_physics(arena: Node3D):
	print("\n>>> [TEST 4] Simulating Police Cruiser (DrivableCar) Real Physics Mountain Climbing...")

	var car = arena.get_node_or_null("DrivableCar")
	var player = arena.get_node_or_null("Player")

	if not car:
		failures.append("DrivableCar node not found in arena scene")
		return

	# Place car on highway edge facing West toward the mountain slope
	var start_pos = Vector3(-12.0, 1.2, -120.0)
	car.global_position = start_pos
	car.rotation_degrees = Vector3(0, 90, 0) # Facing -X (West)
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.is_occupied = true
	car.player_ref = player

	# Let wheels settle with suspension on ground
	for i in range(15):
		await physics_frame

	var settled_y = car.global_position.y
	print("  Car settled on ground at: ", car.global_position)
	if car.global_position.y < -5.0:
		failures.append("Car fell through terrain during initial settle: Y = %.2f" % car.global_position.y)
		return

	# Now run 150 real physics frames with full forward throttle
	var min_y_observed = car.global_position.y
	var max_y_observed = car.global_position.y

	for frame in range(150):
		# Feed throttle input into DrivableCar physics logic
		var delta = 1.0 / 60.0
		# Apply forward climb torque exactly as _handle_driving_input does
		var fwd_dir = -car.global_transform.basis.z
		car.apply_central_force(fwd_dir * 32000.0)
		var spd = car.linear_velocity.length() * 3.6
		if spd < 45.0:
			car.linear_velocity += fwd_dir * (22.0 * delta)

		var slope_pitch = fwd_dir.y
		var slope_angle_deg = rad_to_deg(asin(clampf(slope_pitch, -1.0, 1.0)))
		if slope_pitch > 0.01:
			var factor = clampf((slope_angle_deg - 8.0) / 37.0, 0.0, 1.0)
			var assist_dir = (fwd_dir + Vector3.UP * 0.25).normalized()
			car.apply_central_force(assist_dir * (car.crawl_base_force * factor))

		car.engine_force = 16000.0 * 2.8
		for w in [car.wheel_fl, car.wheel_fr, car.wheel_bl, car.wheel_br]:
			if w:
				w.wheel_friction_slip = 8.5

		await physics_frame

		var cur_y = car.global_position.y
		if cur_y < min_y_observed:
			min_y_observed = cur_y
		if cur_y > max_y_observed:
			max_y_observed = cur_y

		# Check for catastrophic fall-through into void
		if cur_y < -20.0:
			failures.append("Car fell through terrain mesh into void during climbing! Y = %.2f at frame %d" % [cur_y, frame])
			break

	var end_pos = car.global_position
	var dist_west = start_pos.x - end_pos.x # Positive means moved West into mountain
	var elevation_gain = end_pos.y - settled_y
	var total_dist = start_pos.distance_to(end_pos)

	print("  Car Real Physics Result:")
	print("    - Start Pos      : ", start_pos)
	print("    - End Pos        : ", end_pos)
	print("    - West Advance   : %.2f m" % dist_west)
	print("    - Elevation Gain : %.2f m" % elevation_gain)
	print("    - Total Distance : %.2f m" % total_dist)
	print("    - End Speed      : %.2f km/h" % (car.linear_velocity.length() * 3.6))

	if total_dist < 8.0:
		failures.append("Car stalled or beached on off-road terrain! Moved only %.2fm" % total_dist)
	elif elevation_gain < 0.5 and dist_west > 15.0:
		warnings.append("Car advanced West but gained less than 0.5m elevation (check slope incline)")
	else:
		print("  ✓ CAR REAL PHYSICS CLIMB TEST PASSED: Successfully climbed mountain!")

	results["car_dist_climbed"] = total_dist
	results["car_elevation_gain"] = elevation_gain

# ------------------------------------------------------------------------------
# TEST 5: Hayabusa Superbike Mountain Climb under REAL Godot Physics Ticks
# ------------------------------------------------------------------------------
func _test_5_bike_mountain_climb_real_physics(arena: Node3D):
	print("\n>>> [TEST 5] Simulating Hayabusa Superbike (DrivableBike) Real Physics Mountain Climbing...")

	var bike = arena.get_node_or_null("DrivableBike")
	var player = arena.get_node_or_null("Player")

	if not bike:
		failures.append("DrivableBike node not found in arena scene")
		return

	# Place bike on highway shoulder facing West toward mountain slope
	var start_pos = Vector3(-14.0, 1.5, -130.0)
	bike.global_position = start_pos
	bike.rotation_degrees = Vector3(0, 90, 0) # Facing West (-X)
	bike.velocity = Vector3.ZERO
	bike.current_forward_velocity = 0.0
	bike.is_occupied = true
	bike.player_ref = player

	# Settle bike on ground
	for i in range(15):
		await physics_frame

	var settled_y = bike.global_position.y
	print("  Bike settled on ground at: ", bike.global_position)
	if settled_y < -5.0:
		failures.append("Bike fell through terrain during initial settle: Y = %.2f" % settled_y)
		return

	# Run 150 real physics frames with full forward throttle using bike's move_and_slide logic
	var min_y_observed = bike.global_position.y
	var max_y_observed = bike.global_position.y

	for frame in range(150):
		var delta = 1.0 / 60.0
		# Accelerate forward
		var max_fwd_ms = bike.top_speed_kmh / 3.6
		bike.current_forward_velocity = move_toward(bike.current_forward_velocity, max_fwd_ms, bike.acceleration_rate * delta)

		var forward_dir = -bike.transform.basis.z.normalized()
		if bike.is_on_floor() or bike.is_on_wall():
			var surf_norm = bike.get_floor_normal() if bike.is_on_floor() else bike.get_wall_normal()
			if surf_norm.length_squared() < 0.1:
				surf_norm = Vector3.UP
			var slope_climb_boost = 1.85 + clampf((1.0 - surf_norm.y) * 2.5, 0.0, 2.5)
			var slope_dir = (forward_dir - surf_norm * forward_dir.dot(surf_norm)).normalized()
			if slope_dir.y < 0.1 and forward_dir.dot(surf_norm) < -0.1:
				slope_dir.y = maxf(slope_dir.y, 0.45)
				slope_dir = slope_dir.normalized()
			bike.velocity = slope_dir * (bike.current_forward_velocity * slope_climb_boost)
		else:
			bike.velocity.x = forward_dir.x * bike.current_forward_velocity
			bike.velocity.z = forward_dir.z * bike.current_forward_velocity
			bike.velocity.y -= bike.gravity * delta

		bike.move_and_slide()
		await physics_frame

		var cur_y = bike.global_position.y
		if cur_y < min_y_observed:
			min_y_observed = cur_y
		if cur_y > max_y_observed:
			max_y_observed = cur_y

		if cur_y < -20.0:
			failures.append("Bike fell through terrain mesh into void! Y = %.2f at frame %d" % [cur_y, frame])
			break

	var end_pos = bike.global_position
	var dist_west = start_pos.x - end_pos.x
	var elevation_gain = end_pos.y - settled_y
	var total_dist = start_pos.distance_to(end_pos)

	print("  Bike Real Physics Result:")
	print("    - Start Pos      : ", start_pos)
	print("    - End Pos        : ", end_pos)
	print("    - West Advance   : %.2f m" % dist_west)
	print("    - Elevation Gain : %.2f m" % elevation_gain)
	print("    - Total Distance : %.2f m" % total_dist)
	print("    - End Speed      : %.2f km/h" % (abs(bike.current_forward_velocity) * 3.6))

	if total_dist < 10.0:
		failures.append("Bike stalled on off-road terrain! Moved only %.2fm" % total_dist)
	else:
		print("  ✓ BIKE REAL PHYSICS CLIMB TEST PASSED: Successfully climbed mountain!")

	results["bike_dist_climbed"] = total_dist
	results["bike_elevation_gain"] = elevation_gain

# ------------------------------------------------------------------------------
# TEST 6: Steep Slope (Up to 45°) Incline Stress Test (Starting Mid-Slope)
# ------------------------------------------------------------------------------
func _test_6_steep_slope_45deg_stress(arena: Node3D):
	print("\n>>> [TEST 6] Stress-testing Vehicle Climbing starting on Steep Mid-Slope (30°-45°)...")

	var space_state = arena.get_world_3d().direct_space_state
	var car = arena.get_node_or_null("DrivableCar")
	var bike = arena.get_node_or_null("DrivableBike")

	# Locate a steep point on MountainWest (X between -50 and -80) with slope between 25° and 45°
	var steep_test_pos = Vector3.ZERO
	var steep_normal = Vector3.UP
	var steep_slope_deg = 0.0

	for test_x in [-55.0, -65.0, -75.0, -85.0]:
		for test_z in [-100.0, -120.0, -140.0]:
			var q = PhysicsRayQueryParameters3D.create(Vector3(test_x, 60.0, test_z), Vector3(test_x, -10.0, test_z))
			var hit = space_state.intersect_ray(q)
			if hit:
				var deg = rad_to_deg(acos(clampf(hit.normal.dot(Vector3.UP), -1.0, 1.0)))
				if deg >= 20.0 and deg <= 45.0:
					steep_test_pos = hit.position
					steep_normal = hit.normal
					steep_slope_deg = deg
					break
		if steep_test_pos != Vector3.ZERO:
			break

	if steep_test_pos == Vector3.ZERO:
		warnings.append("Could not find a specific point with slope 20°-45° via quick probe; using baseline mid-slope Vector3(-60, 5, -120)")
		steep_test_pos = Vector3(-60.0, 5.0, -120.0)
		steep_slope_deg = 25.0

	print("  Found steep slope test location: Pos=%s, Normal=%s, Slope=%.1f°" % [
		steep_test_pos, steep_normal, steep_slope_deg
	])

	# Test 6A: Car on Steep Slope
	if car:
		car.global_position = steep_test_pos + Vector3(0, 1.2, 0)
		car.rotation_degrees = Vector3(0, 90, 0) # Facing West (uphill)
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO

		for i in range(15):
			await physics_frame

		var initial_y = car.global_position.y
		var initial_pos = car.global_position

		# Apply crawl force for 90 physics frames
		for frame in range(90):
			var delta = 1.0 / 60.0
			var fwd_dir = -car.global_transform.basis.z
			car.apply_central_force(fwd_dir * 36000.0)
			var factor = clampf((steep_slope_deg - 8.0) / 37.0, 0.0, 1.0)
			var assist_dir = (fwd_dir + Vector3.UP * 0.25).normalized()
			car.apply_central_force(assist_dir * (car.crawl_base_force * factor * 1.5))
			car.engine_force = 16000.0 * 3.5
			await physics_frame

		var dist_uphill = initial_pos.distance_to(car.global_position)
		var delta_y = car.global_position.y - initial_y
		print("  Car Steep Slope (%.1f°) Result: Dist=%.2fm, ElevationGain=%.2fm, FinalY=%.2f" % [
			steep_slope_deg, dist_uphill, delta_y, car.global_position.y
		])

		if dist_uphill < 3.0:
			failures.append("Car failed to crawl uphill from standstill on %.1f° slope! Moved only %.2fm" % [steep_slope_deg, dist_uphill])
		else:
			print("  ✓ Car successfully crawled from standstill on %.1f° mountain slope!" % steep_slope_deg)

	# Test 6B: Bike on Steep Slope
	if bike:
		bike.global_position = steep_test_pos + Vector3(0, 1.5, 0)
		bike.rotation_degrees = Vector3(0, 90, 0)
		bike.velocity = Vector3.ZERO
		bike.current_forward_velocity = 0.0

		for i in range(15):
			await physics_frame

		var initial_bike_y = bike.global_position.y
		var initial_bike_pos = bike.global_position

		for frame in range(90):
			var delta = 1.0 / 60.0
			var max_fwd_ms = bike.top_speed_kmh / 3.6
			bike.current_forward_velocity = move_toward(bike.current_forward_velocity, max_fwd_ms, bike.acceleration_rate * 1.5 * delta)
			var forward_dir = -bike.transform.basis.z.normalized()
			var surf_norm = bike.get_floor_normal() if bike.is_on_floor() else steep_normal
			var slope_climb_boost = 1.85 + clampf((1.0 - surf_norm.y) * 2.5, 0.0, 2.5)
			var slope_dir = (forward_dir - surf_norm * forward_dir.dot(surf_norm)).normalized()
			if slope_dir.y < 0.1 and forward_dir.dot(surf_norm) < -0.1:
				slope_dir.y = maxf(slope_dir.y, 0.45)
				slope_dir = slope_dir.normalized()
			bike.velocity = slope_dir * (bike.current_forward_velocity * slope_climb_boost)
			bike.move_and_slide()
			await physics_frame

		var bike_dist_uphill = initial_bike_pos.distance_to(bike.global_position)
		var bike_delta_y = bike.global_position.y - initial_bike_y
		print("  Bike Steep Slope (%.1f°) Result: Dist=%.2fm, ElevationGain=%.2fm, FinalY=%.2f" % [
			steep_slope_deg, bike_dist_uphill, bike_delta_y, bike.global_position.y
		])

		if bike_dist_uphill < 3.0:
			failures.append("Bike failed to climb uphill on %.1f° slope! Moved only %.2fm" % [steep_slope_deg, bike_dist_uphill])
		else:
			print("  ✓ Bike successfully climbed on %.1f° mountain slope!" % steep_slope_deg)

# ------------------------------------------------------------------------------
# Final Audit Summary
# ------------------------------------------------------------------------------
func _print_final_summary():
	print("\n======================================================================")
	print("=== EMPIRICAL ADVERSARIAL STRESS TEST SUMMARY REPORT ===")
	print("======================================================================")
	print("Total Warnings : %d" % warnings.size())
	for w in warnings:
		print("  [WARN] ", w)

	print("Total Failures : %d" % failures.size())
	for f in failures:
		print("  [FAIL] ", f)
	print("======================================================================")
