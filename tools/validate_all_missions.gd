extends SceneTree

func _init():
	print("==================================================")
	print("STARTING COMPREHENSIVE VALIDATION FOR ALL MISSIONS")
	print("==================================================")
	
	var mission_ids = [
		"mission_01", "mission_02", "mission_03", "mission_04",
		"mission_05", "mission_06", "mission_07", "mission_08",
		"mission_09", "mission_10", "mission_11", "mission_12",
		"mission_endless"
	]
	
	var all_passed = true
	
	for m_id in mission_ids:
		var res_path = "res://resources/missions/" + m_id + ".tres"
		var mission = load(res_path)
		if not mission:
			print("❌ FAILED to load mission resource: ", res_path)
			all_passed = false
			continue
			
		print("\n--- Validating ", m_id, " (", mission.display_name, ") ---")
		print("  Location: ", mission.location_name)
		print("  Scene: ", mission.scene_path)
		
		var sc = load(mission.scene_path)
		if not sc:
			print("  ❌ Scene load failed: ", mission.scene_path)
			all_passed = false
			continue
			
		var inst = sc.instantiate()
		if not inst:
			print("  ❌ Scene instantiate failed")
			all_passed = false
			continue
			
		# Check Player
		var player = inst.find_child("Player", true, false)
		if not player:
			print("  ❌ Player node missing!")
			all_passed = false
		else:
			print("  ✅ Player found at pos: ", player.position)
			
		# Check ZombieSpawner
		var spawner = inst.find_child("ZombieSpawner", true, false)
		if not spawner:
			print("  ❌ ZombieSpawner node missing!")
			all_passed = false
		else:
			var pts = spawner.get("spawn_points")
			if not pts or pts.size() < 4:
				print("  ❌ Spawn points too few: ", pts.size() if pts else 0)
				all_passed = false
			else:
				print("  ✅ ZombieSpawner points count: ", pts.size())
				
			var z_scene = spawner.get("zombie_scene")
			if not z_scene:
				print("  ❌ zombie_scene missing in spawner!")
				all_passed = false
			else:
				print("  ✅ zombie_scene configured")
				
		# Check Ground Collision
		var ground_col = inst.find_children("*", "CollisionShape3D", true, false)
		if ground_col.is_empty():
			print("  ❌ Ground collision missing!")
			all_passed = false
		else:
			print("  ✅ CollisionShape3D found (count: ", ground_col.size(), ")")
			
		# Check ResultUI and ImpactPool
		var r_ui = inst.find_child("ResultUI", true, false)
		var imp_pool = inst.find_child("ImpactPool", true, false)
		if not r_ui or not imp_pool:
			print("  ❌ ResultUI or ImpactPool missing!")
			all_passed = false
		else:
			print("  ✅ ResultUI & ImpactPool present")
			
		# Check Audio (Ambience + Horror Drone)
		var amb = inst.find_child("AmbiencePlayer", true, false)
		var drone = inst.find_child("HorrorDronePlayer", true, false)
		if not amb or not drone:
			print("  ❌ Ambience or Horror Drone audio missing!")
			all_passed = false
		else:
			print("  ✅ AmbiencePlayer & HorrorDronePlayer present")
			
		# Check Police Car / Barricades
		var police_cars = inst.find_children("*PoliceCar*", "Node3D", true, false)
		if police_cars.is_empty():
			print("  ⚠️ No PoliceCarProp found in this scene")
		else:
			print("  ✅ PoliceCarProp found (count: ", police_cars.size(), ")")
			
		inst.free()
		print("  ✅ Mission ", m_id, " PASS")
		
	print("\n==================================================")
	if all_passed:
		print("🎉 ALL 12 MISSIONS + ENDLESS PASSED 100% VALIDATION!")
		print("==================================================")
		quit(0)
	else:
		print("❌ SOME MISSIONS FAILED VALIDATION!")
		print("==================================================")
		quit(1)
