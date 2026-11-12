extends SceneTree

func _init():
	print("==================================================")
	print("STARTING COMPREHENSIVE AUDIO VERIFICATION")
	print("==================================================")
	var all_ok = true
	
	# 1. Test Weapon shoot & reload sounds
	var weapon_tests = [
		{"id": "minigun", "expected_shoot": "sfx_minigun_shoot", "expected_reload": "sfx_reload_mag"},
		{"id": "flatline", "expected_shoot": "sfx_flatline_shoot", "expected_reload": "sfx_reload_mag"},
		{"id": "car_smg", "expected_shoot": "sfx_car_shoot", "expected_reload": "sfx_reload_mag"},
		{"id": "hawk_shotgun", "expected_shoot": "sfx_hawk_shoot", "expected_reload": "sfx_reload_shotgun"},
		{"id": "sniper", "expected_shoot": "sfx_sniper_shoot", "expected_reload": "sfx_reload_bolt"},
		{"id": "pistol", "expected_shoot": "sfx_pistol_shoot", "expected_reload": "sfx_reload_slide"},
		{"id": "rifle", "expected_shoot": "sfx_rifle_shoot", "expected_reload": "sfx_reload_mag"}
	]
	
	var weapon_scene = load("res://scenes/weapons/Weapon.tscn") as PackedScene
	if not weapon_scene:
		printerr("[FAIL] Could not load Weapon.tscn")
		quit(1)
		return
		
	for wt in weapon_tests:
		var w_inst = weapon_scene.instantiate()
		var w_data = WeaponData.new()
		w_data.weapon_id = wt.id
		w_data.sound_set = wt.id
		w_inst.weapon_data = w_data
		root.add_child(w_inst)
		w_inst._load_sound_set()
		
		var shoot_s = w_inst.sfx_shoot.stream
		var reload_s = w_inst.sfx_reload.stream
		
		var shoot_ok = shoot_s != null and wt.expected_shoot in shoot_s.resource_path
		var reload_ok = reload_s != null and wt.expected_reload in reload_s.resource_path
		
		if shoot_ok and reload_ok:
			print("[PASS] Weapon %s | Shoot: %s | Reload: %s" % [wt.id, shoot_s.resource_path, reload_s.resource_path])
		else:
			all_ok = false
			printerr("[FAIL] Weapon %s | Shoot: %s (exp: %s) | Reload: %s (exp: %s)" % [
				wt.id,
				shoot_s.resource_path if shoot_s else "null", wt.expected_shoot,
				reload_s.resource_path if reload_s else "null", wt.expected_reload
			])
		w_inst.queue_free()
	
	# 2. Test EnemyBase Headshot sound
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn") as PackedScene
	if zombie_scene:
		var z_inst = zombie_scene.instantiate()
		root.add_child(z_inst)
		z_inst._ready()
		var sfx_hs = z_inst.get_node_or_null("SfxHeadshot")
		var has_hs_node = sfx_hs != null and sfx_hs.stream != null
		if has_hs_node:
			print("[PASS] EnemyBase SfxHeadshot node verified: stream=%s" % sfx_hs.stream.resource_path)
		else:
			all_ok = false
			printerr("[FAIL] EnemyBase SfxHeadshot node missing or stream null")
		
		# Test headshot damage playback
		z_inst.take_damage(20.0, true, Vector3.FORWARD)
		if sfx_hs.playing:
			print("[PASS] SfxHeadshot playing upon is_headshot=true damage")
		else:
			all_ok = false
			printerr("[FAIL] SfxHeadshot not playing after headshot damage")
		z_inst.queue_free()
	else:
		all_ok = false
		printerr("[FAIL] Could not load Zombie.tscn")
	
	# 3. Test AudioManager Horror Drone
	var audio_mgr = root.get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_horror_drone(-12.0)
		var dp = audio_mgr.horror_drone_player
		var drone_ok = dp != null and dp.stream != null and dp.volume_db == -12.0 and dp.playing
		if drone_ok:
			print("[PASS] AudioManager Horror Drone verified: playing=%s, volume_db=%.1f, stream=%s" % [dp.playing, dp.volume_db, dp.stream.resource_path])
		else:
			all_ok = false
			printerr("[FAIL] AudioManager Horror Drone failed check")
	else:
		printerr("[WARN] AudioManager autoload not available in standalone script mode")

	# 4. Test Level Scenes HorrorDronePlayer nodes
	var level_scenes = [
		"res://scenes/environments/UrbanStreet.tscn",
		"res://scenes/environments/AirportServiceRoad.tscn"
	]
	for l_path in level_scenes:
		var sc = load(l_path) as PackedScene
		if sc:
			var inst = sc.instantiate()
			var dp = inst.find_child("HorrorDronePlayer", true, false) as AudioStreamPlayer
			var ok = dp != null and dp.stream != null and dp.volume_db == -12.0 and dp.autoplay
			if ok:
				print("[PASS] Level %s HorrorDronePlayer verified: vol=%.1f, autoplay=%s, stream=%s" % [l_path, dp.volume_db, dp.autoplay, dp.stream.resource_path])
			else:
				all_ok = false
				printerr("[FAIL] Level %s HorrorDronePlayer invalid or missing" % l_path)
			inst.queue_free()

	print("==================================================")
	if all_ok:
		print("AUDIO VERIFICATION RESULT: ALL PASS")
		quit(0)
	else:
		printerr("AUDIO VERIFICATION RESULT: FAILURES DETECTED")
		quit(1)
