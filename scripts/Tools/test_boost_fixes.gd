extends SceneTree

var passed_count: int = 0
var total_count: int = 0

func _init():
	call_deferred("_run_tests")

func assert_test(condition: bool, msg: String):
	total_count += 1
	if condition:
		passed_count += 1
		print("  [PASS] %s" % msg)
	else:
		printerr("  [FAIL] %s" % msg)

func _run_tests():
	await process_frame
	await process_frame
	
	print("======================================================================")
	print("DEEP INVESTIGATOR BOOST FIXES VERIFICATION SUITE")
	print("Audio Architecture, Group Mismatch, Ducking & Performance Recovery")
	print("======================================================================")
	
	await _test_audio_bus_layout()
	await _test_audio_manager_ducking()
	await _test_hud_audio_and_hitmarker()
	await _test_zombie_group_mismatch_and_grenade()
	await _test_player_auto_aim()
	await _test_weapon_tree_guard()
	await _test_performance_recovery_and_quality()
	
	print("\n======================================================================")
	print("BOOST FIXES TEST RESULTS: %d / %d PASSED" % [passed_count, total_count])
	print("======================================================================")
	if passed_count == total_count:
		print("ALL BOOST FIX TESTS PASSED! (100% PASS RATE)")
		quit(0)
	else:
		printerr("SOME BOOST FIX TESTS FAILED!")
		quit(1)

func _test_audio_bus_layout():
	print("\n--- TEST GROUP 1: AUDIO BUS LAYOUT & LOW-PASS FILTERS ---")
	assert_test(ResourceLoader.exists("res://default_bus_layout.tres"), "default_bus_layout.tres exists")
	var layout = load("res://default_bus_layout.tres") as AudioBusLayout
	assert_test(layout != null, "default_bus_layout.tres loads as AudioBusLayout")
	
	if layout:
		AudioServer.set_bus_layout(layout)
	
	var bus_count = AudioServer.bus_count
	assert_test(bus_count >= 4, "AudioServer has at least 4 buses (Found: %d)" % bus_count)
	
	var master_idx = AudioServer.get_bus_index("Master")
	var music_idx = AudioServer.get_bus_index("Music")
	var sfx_idx = AudioServer.get_bus_index("SFX")
	var amb_idx = AudioServer.get_bus_index("Ambience")
	
	assert_test(master_idx == 0, "Master bus is at index 0")
	assert_test(music_idx != -1, "Music bus exists")
	assert_test(sfx_idx != -1, "SFX bus exists")
	assert_test(amb_idx != -1, "Ambience bus exists")
	
	if music_idx != -1:
		assert_test(AudioServer.get_bus_send(music_idx) == &"Master", "Music bus routes to Master")
		assert_test(AudioServer.get_bus_effect_count(music_idx) >= 1, "Music bus has an audio effect")
		var eff = AudioServer.get_bus_effect(music_idx, 0)
		assert_test(eff is AudioEffectLowPassFilter, "Music bus effect is AudioEffectLowPassFilter")
		
	if sfx_idx != -1:
		assert_test(AudioServer.get_bus_send(sfx_idx) == &"Master", "SFX bus routes to Master")
		
	if amb_idx != -1:
		assert_test(AudioServer.get_bus_send(amb_idx) == &"Master", "Ambience bus routes to Master")
		assert_test(AudioServer.get_bus_effect_count(amb_idx) >= 1, "Ambience bus has an audio effect")
		var eff = AudioServer.get_bus_effect(amb_idx, 0)
		assert_test(eff is AudioEffectLowPassFilter, "Ambience bus effect is AudioEffectLowPassFilter")

func _test_audio_manager_ducking():
	print("\n--- TEST GROUP 2: AUDIOMANAGER ROUTING, SIGNALS & DUCKING ---")
	var am = root.get_node_or_null("AudioManager")
	if not am:
		var am_script = load("res://scripts/AudioManager.gd")
		am = am_script.new()
		am.name = "AudioManager"
		root.add_child(am)
		await process_frame
		
	assert_test(am != null, "AudioManager exists")
	assert_test(am.bg_player != null and am.bg_player.bus == "Ambience", "Background player bus is Ambience")
	assert_test(am.horror_drone_player != null and am.horror_drone_player.bus == "Ambience", "Horror drone player bus is Ambience")
	assert_test(am.bg_player.volume_db == 0.0, "Background player volume_db is nominal (no double attenuation)")
	
	# Verify audio streams load properly without returning null
	var hit_body_stream = am._load_audio(am.sounds["hit_body"])
	assert_test(hit_body_stream != null, "Hit body audio stream loaded successfully")
	var hit_head_stream = am._load_audio(am.sounds["hit_headshot"])
	assert_test(hit_head_stream != null, "Hit headshot audio stream loaded successfully")
	
	# Test ducking via EventBus briefing signals
	var event_bus = root.get_node_or_null("EventBus")
	if not event_bus:
		var eb_script = load("res://scripts/Core/EventBus.gd")
		event_bus = eb_script.new()
		event_bus.name = "EventBus"
		root.add_child(event_bus)
		await process_frame
		am._connect_signals()
	
	event_bus.briefing_opened.emit()
	assert_test(am.is_ducked == true, "AudioManager ducking active on EventBus.briefing_opened signal")
	var music_idx = AudioServer.get_bus_index("Music")
	var amb_idx = AudioServer.get_bus_index("Ambience")
	if music_idx != -1:
		assert_test(AudioServer.is_bus_effect_enabled(music_idx, 0), "Music LowPassFilter enabled when ducked")
	if amb_idx != -1:
		assert_test(AudioServer.is_bus_effect_enabled(amb_idx, 0), "Ambience LowPassFilter enabled when ducked")
		
	event_bus.briefing_closed.emit()
	assert_test(am.is_ducked == false, "AudioManager ducking deactivated on EventBus.briefing_closed signal")
	if music_idx != -1:
		assert_test(not AudioServer.is_bus_effect_enabled(music_idx, 0), "Music LowPassFilter disabled when unducked")
		
	# Test ducking via GameStateManager.pause_toggled signal
	var gsm = root.get_node_or_null("GameStateManager")
	if not gsm:
		var gsm_script = load("res://scripts/Core/GameStateManager.gd")
		gsm = gsm_script.new()
		gsm.name = "GameStateManager"
		root.add_child(gsm)
		await process_frame
		am._connect_signals()
		
	gsm.pause_toggled.emit(true)
	assert_test(am.is_ducked == true, "AudioManager ducking active on GameStateManager.pause_toggled(true)")
	gsm.pause_toggled.emit(false)
	assert_test(am.is_ducked == false, "AudioManager ducking deactivated on GameStateManager.pause_toggled(false)")
	
	# Test hit confirmation playback spawns audio player on SFX bus
	var child_count_before = am.get_child_count()
	am.play_hit_confirm(false)
	var found_sfx = false
	for child in am.get_children():
		if child is AudioStreamPlayer and child.bus == "SFX":
			found_sfx = true
			break
	assert_test(found_sfx, "Bodyshot hit confirm creates AudioStreamPlayer on SFX bus")
	
	am.play_hit_confirm(true)
	var found_headshot_sfx = false
	for child in am.get_children():
		if child is AudioStreamPlayer and child.bus == "SFX" and child.stream != null:
			found_headshot_sfx = true
			break
	assert_test(found_headshot_sfx, "Headshot hit confirm creates AudioStreamPlayer with non-null stream on SFX bus")

func _test_hud_audio_and_hitmarker():
	print("\n--- TEST GROUP 3: HUD AUDIO BUS & HIT CONFIRMATION ---")
	var hud_scn = load("res://scenes/UI/HUD.tscn")
	assert_test(hud_scn != null, "HUD scene loads successfully")
	var hud = hud_scn.instantiate()
	root.add_child(hud)
	await process_frame
	
	assert_test(hud.heartbeat_player != null, "HUD has heartbeat_player")
	if hud.heartbeat_player:
		assert_test(hud.heartbeat_player.bus == "SFX", "HUD heartbeat_player bus is SFX")
		
	# Test show_hitmarker bodyshot and headshot
	hud.show_hitmarker(false)
	assert_test(hud.hitmarker.visible == true, "Bodyshot hitmarker displays")
	
	hud.show_hitmarker(true)
	assert_test(hud.hitmarker.visible == true, "Headshot hitmarker displays")
	
	hud.queue_free()
	await process_frame

func _test_zombie_group_mismatch_and_grenade():
	print("\n--- TEST GROUP 4: ZOMBIE GROUP MISMATCH & GRENADE SPLASH ---")
	var zombie_scn = load("res://assets/zombies/RealisticZombie.tscn")
	assert_test(zombie_scn != null, "RealisticZombie.tscn loads successfully")
	var zombie = zombie_scn.instantiate()
	root.add_child(zombie)
	await process_frame
	
	assert_test(zombie.is_in_group("zombies"), "RealisticZombie belongs to 'zombies' group (plural)")
	assert_test(zombie.is_in_group("zombie"), "RealisticZombie belongs to 'zombie' group (singular)")
	
	# Verify BossZombie and InfectedDog scenes also declare both groups
	var boss_scn = load("res://scenes/zombies/BossZombie.tscn")
	if boss_scn:
		var boss = boss_scn.instantiate()
		assert_test(boss.is_in_group("zombies") and boss.is_in_group("zombie"), "BossZombie belongs to both 'zombies' and 'zombie' groups")
		boss.free()
		
	var dog_scn = load("res://scenes/zombies/InfectedDog.tscn")
	if dog_scn:
		var dog = dog_scn.instantiate()
		assert_test(dog.is_in_group("zombies") and dog.is_in_group("zombie"), "InfectedDog belongs to both 'zombies' and 'zombie' groups")
		dog.free()
	
	# Verify group removal on death
	zombie._on_died()
	assert_test(not zombie.is_in_group("zombies"), "Zombie removed from 'zombies' group on death")
	assert_test(not zombie.is_in_group("zombie"), "Zombie removed from 'zombie' group on death")
	
	# Create dummy targets with HealthComponents: one in 'zombie' only and one in 'zombies' only
	var dummy_singular = CharacterBody3D.new()
	dummy_singular.set_script(load("res://scripts/Zombies/EnemyBase.gd"))
	root.add_child(dummy_singular)
	dummy_singular.add_to_group("zombie")
	if dummy_singular.is_in_group("zombies"):
		dummy_singular.remove_from_group("zombies")
	var hc_sing = HealthComponent.new()
	hc_sing.name = "HealthComponent"
	hc_sing.max_health = 100.0
	dummy_singular.add_child(hc_sing)
	dummy_singular.health_component = hc_sing
	dummy_singular.global_position = Vector3(2, 0, 0)
	dummy_singular.is_dead = false
	
	var dummy_plural = CharacterBody3D.new()
	dummy_plural.set_script(load("res://scripts/Zombies/EnemyBase.gd"))
	root.add_child(dummy_plural)
	dummy_plural.add_to_group("zombies")
	if dummy_plural.is_in_group("zombie"):
		dummy_plural.remove_from_group("zombie")
	var hc_plur = HealthComponent.new()
	hc_plur.name = "HealthComponent"
	hc_plur.max_health = 100.0
	dummy_plural.add_child(hc_plur)
	dummy_plural.health_component = hc_plur
	dummy_plural.global_position = Vector3(-2, 0, 0)
	dummy_plural.is_dead = false
	await process_frame
	
	var grenade_script = load("res://scenes/weapons/Grenade.gd")
	var grenade = RigidBody3D.new()
	grenade.set_script(grenade_script)
	root.add_child(grenade)
	grenade.global_position = Vector3(0, 0, 0)
	await process_frame
	
	# Trigger grenade explosion
	grenade.explode()
	await process_frame
	
	# Both dummies must have received real blast damage
	assert_test(dummy_singular.health_component.current_health < 100.0, "Singular zombie target damaged by grenade splash (HP: %.1f < 100)" % dummy_singular.health_component.current_health)
	assert_test(dummy_plural.health_component.current_health < 100.0, "Plural zombie target damaged by grenade splash (HP: %.1f < 100)" % dummy_plural.health_component.current_health)
	
	zombie.queue_free()
	dummy_singular.queue_free()
	dummy_plural.queue_free()
	await process_frame

func _test_player_auto_aim():
	print("\n--- TEST GROUP 5: PLAYER AUTO-AIM TRACKING ---")
	var player_scn = load("res://scenes/player/Player.tscn")
	assert_test(player_scn != null, "Player.tscn loads successfully")
	var player = player_scn.instantiate()
	root.add_child(player)
	await process_frame
	
	# Test 1: Place living target in 'zombies' group in front-right of player
	var target_plural = CharacterBody3D.new()
	target_plural.set_script(load("res://scripts/Zombies/EnemyBase.gd"))
	target_plural.add_to_group("zombies")
	root.add_child(target_plural)
	target_plural.is_dead = false
	target_plural.global_position = player.global_position + (-player.camera.global_transform.basis.z * 5.0) + Vector3(0.5, 0, 0)
	await process_frame
	
	var rot_y_before = player.rotation.y
	player.auto_aim(0.1)
	assert_test(player.rotation.y != rot_y_before, "Player auto-aim rotates horizontally toward 'zombies' target (Delta: %.4f rad)" % (player.rotation.y - rot_y_before))
	target_plural.queue_free()
	await process_frame
	
	# Test 2: Target in 'zombie' group (singular)
	player.rotation.y = 0.0
	player.camera.rotation.x = 0.0
	var target_singular = CharacterBody3D.new()
	target_singular.set_script(load("res://scripts/Zombies/EnemyBase.gd"))
	target_singular.add_to_group("zombie")
	root.add_child(target_singular)
	target_singular.is_dead = false
	target_singular.global_position = player.global_position + (-player.camera.global_transform.basis.z * 5.0) + Vector3(-0.5, 0, 0)
	await process_frame
	
	player.auto_aim(0.1)
	assert_test(player.rotation.y != 0.0, "Player auto-aim rotates toward 'zombie' target (Delta: %.4f rad)" % player.rotation.y)
	target_singular.queue_free()
	await process_frame
	
	# Test 3: Dead target must NOT be tracked
	player.rotation.y = 0.0
	var dead_target = CharacterBody3D.new()
	dead_target.set_script(load("res://scripts/Zombies/EnemyBase.gd"))
	dead_target.add_to_group("zombies")
	root.add_child(dead_target)
	dead_target.is_dead = true
	dead_target.global_position = player.global_position + (-player.camera.global_transform.basis.z * 5.0) + Vector3(0.5, 0, 0)
	await process_frame
	
	player.auto_aim(0.1)
	assert_test(player.rotation.y == 0.0, "Player auto-aim ignores dead target (rotation remains unchanged)")
	dead_target.queue_free()
	
	# Test 4: Pitch stays within min/max bounds
	assert_test(player.camera.rotation.x >= deg_to_rad(player.min_pitch) and player.camera.rotation.x <= deg_to_rad(player.max_pitch), "Player camera pitch is clamped within allowable range")
	
	player.queue_free()
	await process_frame

func _test_weapon_tree_guard():
	print("\n--- TEST GROUP 6: WEAPON C++ ENGINE TREE GUARD ---")
	var weapon_scn = load("res://scenes/weapons/Weapon.tscn")
	assert_test(weapon_scn != null, "Weapon.tscn loads")
	var weapon = weapon_scn.instantiate()
	# Verify that before adding to tree, impact_pool is safely null and no engine error is thrown
	assert_test(weapon.impact_pool == null, "Weapon impact_pool safely guarded when outside tree")
	weapon.free()

func _test_performance_recovery_and_quality():
	print("\n--- TEST GROUP 7: PERFORMANCE RECOVERY & QUALITY SETTINGS ---")
	var pm_script = load("res://scripts/Performance/PerformanceManager.gd")
	var pm = pm_script.new()
	root.add_child(pm)
	await process_frame
	
	# Simulate throttle lockout
	pm.is_adaptive_throttling = true
	pm.current_profile = pm.Profile.LOW
	pm.pre_throttle_profile = pm.Profile.HIGH
	pm.simulated_fps = 30.0
	pm.recovery_fps_timer = 0.0
	
	# Step 4.5 seconds of sustained 30 FPS (> 29.0)
	pm._process(4.5)
	assert_test(pm.is_adaptive_throttling == false, "Adaptive throttling recovers after 4+ seconds of FPS > 29.0")
	assert_test(pm.current_profile == pm.Profile.HIGH, "Pre-throttle HIGH profile restored upon recovery (Got: %d)" % pm.current_profile)
	pm.queue_free()
	
	# Test QualityManager respecting save_mgr.data.selected_quality
	var save_mgr = root.get_node_or_null("SaveManager")
	if save_mgr:
		save_mgr.data.selected_quality = 2 # HIGH
	var qm_script = load("res://scripts/QualityManager.gd")
	var qm = qm_script.new()
	root.add_child(qm)
	await process_frame
	
	assert_test(qm.current_quality == 2, "QualityManager respects saved selected_quality (Expected: 2, Got: %d)" % qm.current_quality)
	qm.queue_free()
	
	# Also test Performance/QualityManager.gd
	var pqm_script = load("res://scripts/Performance/QualityManager.gd")
	var pqm = pqm_script.new()
	root.add_child(pqm)
	await process_frame
	assert_test(pqm.current_quality == 2, "Performance/QualityManager respects saved selected_quality (Expected: 2, Got: %d)" % pqm.current_quality)
	pqm.queue_free()
	await process_frame
