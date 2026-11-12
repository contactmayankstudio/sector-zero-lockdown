extends SceneTree

const REALISTIC_ZOMBIE_SCN = preload("res://assets/zombies/RealisticZombie.tscn")

var passed_count: int = 0
var total_count: int = 0

func _init():
	call_deferred("_run_tests")

func _run_tests():
	await process_frame
	await process_frame
	
	print("======================================================================")
	print("VISCERAL COMBAT JUICINESS VERIFICATION SUITE")
	print("Requirements: Headshot Decapitation, Blood Fountain, Slow-Mo Cam")
	print("======================================================================")
	
	await _test_headshot_decapitation()
	await _test_bodyshot_preserves_head()
	await _test_slowmo_finish_mission()
	
	print("\n======================================================================")
	print("VISCERAL COMBAT TEST RESULTS: %d / %d PASSED" % [passed_count, total_count])
	print("======================================================================")
	if passed_count == total_count:
		print("ALL VISCERAL COMBAT TESTS PASSED! (100% PASS RATE)")
		quit(0)
	else:
		printerr("SOME VISCERAL COMBAT TESTS FAILED!")
		quit(1)

func assert_test(condition: bool, msg: String):
	total_count += 1
	if condition:
		passed_count += 1
		print("  [PASS] %s" % msg)
	else:
		printerr("  [FAIL] %s" % msg)

func _test_headshot_decapitation():
	print("\n--- TEST GROUP 1: LETHAL HEADSHOT DECAPITATION & BLOOD FOUNTAIN ---")
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var zombie = REALISTIC_ZOMBIE_SCN.instantiate()
	zombie.archetype = "normal"
	root_node.add_child(zombie)
	await process_frame
	await process_frame
	
	# Verify skeleton exists
	assert_test(zombie.skeleton != null, "RealisticZombie has Skeleton3D initialized")
	
	# Perform lethal headshot
	zombie.take_damage(500.0, true, Vector3(0, 0, -1))
	await process_frame
	
	assert_test(zombie.is_dead == true, "Zombie is dead after lethal headshot")
	assert_test(zombie.last_hit_was_headshot == true, "last_hit_was_headshot flag is true")
	
	# Verify head bone scale is ZERO
	if zombie.skeleton:
		var head_scaled_down = false
		for b in range(zombie.skeleton.get_bone_count()):
			var bname = zombie.skeleton.get_bone_name(b).to_lower()
			if "head" in bname:
				var scale = zombie.skeleton.get_bone_pose_scale(b)
				if scale == Vector3.ZERO:
					head_scaled_down = true
					break
		assert_test(head_scaled_down, "Head bone pose scale reduced to Vector3.ZERO (Decapitated!)")
	else:
		assert_test(false, "Skeleton was null, cannot verify decapitation bone scale")
		
	# Verify arterial blood spray spawned in parent
	var blood_spray = root_node.get_node_or_null("HeadshotBloodSpray")
	assert_test(blood_spray != null, "HeadshotBloodSpray CPUParticles3D spawned in parent")
	if blood_spray:
		assert_test(blood_spray.emitting == true, "HeadshotBloodSpray is actively emitting")
		assert_test(blood_spray.one_shot == true, "HeadshotBloodSpray is one_shot")
		assert_test(blood_spray.amount >= 20, "HeadshotBloodSpray amount >= 20 droplets")
	
	root_node.queue_free()
	await process_frame

func _test_bodyshot_preserves_head():
	print("\n--- TEST GROUP 2: BODYSHOT DEATH PRESERVES HEAD ---")
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var zombie = REALISTIC_ZOMBIE_SCN.instantiate()
	zombie.archetype = "soldier"
	root_node.add_child(zombie)
	await process_frame
	await process_frame
	
	# Perform lethal bodyshot (is_headshot = false)
	zombie.take_damage(500.0, false, Vector3(0, 0, -1))
	await process_frame
	
	assert_test(zombie.is_dead == true, "Zombie is dead after bodyshot")
	assert_test(zombie.last_hit_was_headshot == false, "last_hit_was_headshot flag is false")
	
	if zombie.skeleton:
		var head_intact = true
		for b in range(zombie.skeleton.get_bone_count()):
			var bname = zombie.skeleton.get_bone_name(b).to_lower()
			if "head" in bname:
				var scale = zombie.skeleton.get_bone_pose_scale(b)
				if scale == Vector3.ZERO:
					head_intact = false
		assert_test(head_intact, "Head bone scale is intact on bodyshot death (NOT decapitated)")
	
	var blood_spray = root_node.get_node_or_null("HeadshotBloodSpray")
	assert_test(blood_spray == null, "No arterial headshot blood spray spawned on bodyshot death")
	
	root_node.queue_free()
	await process_frame

func _test_slowmo_finish_mission():
	print("\n--- TEST GROUP 3: SLOW-MO FINISH MISSION SAFEGUARD ---")
	var mission_mgr = root.get_node_or_null("MissionManager")
	if not mission_mgr:
		mission_mgr = load("res://scripts/MissionManager.gd").new()
		root.add_child(mission_mgr)
		await process_frame
		
	assert_test(mission_mgr != null, "MissionManager exists")
	assert_test("_is_finishing" in mission_mgr, "MissionManager has _is_finishing re-entry guard")
	assert_test(Engine.time_scale == 1.0, "Engine time scale is nominal (1.0)")
