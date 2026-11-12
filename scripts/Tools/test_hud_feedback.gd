extends SceneTree

static var suite_executed: bool = false

func _init():
	if suite_executed:
		return
	suite_executed = true
	_run_suite()

func _run_suite():
	print("======================================================================")
	print("HUD FEEDBACK VERIFICATION SUITE (SCREEN BLOOD SPLATTER & LOW-HP)")
	print("Requirement R1: Dynamic Blood Splatter, Cardiac Vignette, Heartbeat Audio")
	print("======================================================================")

	var hud_scene = load("res://scenes/UI/HUD.tscn")
	if not hud_scene:
		printerr("[FAIL] Failed to load res://scenes/UI/HUD.tscn")
		quit(1)
		return
	
	var hud = hud_scene.instantiate()
	root.add_child(hud)
	for _i in range(10):
		await process_frame

	var results = {"passed": 0, "total": 0}

	var test = func(test_name: String, condition: bool, err_msg: String = ""):
		results["total"] += 1
		if condition:
			results["passed"] += 1
			print("  [PASS] %s" % test_name)
		else:
			printerr("  [FAIL] %s: %s" % [test_name, err_msg])

	# -------------------------------------------------------------
	# TEST 1: Node Hierarchy & Mobile Touch Transparency
	# -------------------------------------------------------------
	print("\n--- TEST GROUP 1: HUD OVERLAYS & NODE HIERARCHY ---")
	test.call("BloodSplatterOverlay exists under Control", hud.has_node("Control/BloodSplatterOverlay"))
	var b_overlay = hud.get_node_or_null("Control/BloodSplatterOverlay")
	if b_overlay:
		test.call("BloodSplatterOverlay mouse_filter is MOUSE_FILTER_IGNORE (2)", b_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	
	test.call("LowHPVignette exists under Control", hud.has_node("Control/LowHPVignette"))
	var v_overlay = hud.get_node_or_null("Control/LowHPVignette")
	if v_overlay:
		test.call("LowHPVignette mouse_filter is MOUSE_FILTER_IGNORE (2)", v_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE)
		test.call("LowHPVignette has radial gradient texture assigned", v_overlay.texture != null)
	
	test.call("HeartbeatPlayer exists on HUD", hud.has_node("HeartbeatPlayer") or hud.heartbeat_player != null)
	if hud.heartbeat_player:
		test.call("HeartbeatPlayer audio bus is SFX", hud.heartbeat_player.bus == "SFX")
		test.call("HeartbeatPlayer stream is assigned", hud.heartbeat_player.stream != null)

	# -------------------------------------------------------------
	# TEST 2: Dynamic Blood Splatter Trigger & 2.5s Dissipation
	# -------------------------------------------------------------
	print("\n--- TEST GROUP 2: BLOOD SPLATTER LIFECYCLE & DISSIPATION (2.5s) ---")
	hud.update_health(100.0, 100.0)
	hud.active_blood_splatters.clear()
	
	# Sustaining damage from 100 to 70 (-30 damage)
	hud.update_health(70.0, 100.0)
	test.call("Damage sustained triggers active blood splatter", hud.active_blood_splatters.size() >= 1)
	
	if hud.active_blood_splatters.size() > 0:
		var splatter = hud.active_blood_splatters[0]
		test.call("Splatter max_life is exactly 2.5 seconds", abs(splatter["max_life"] - 2.5) < 0.001)
		test.call("Splatter initial life is 2.5 seconds", abs(splatter["life"] - 2.5) < 0.001)
		test.call("Splatter contains viscous droplet clusters", splatter["clusters"].size() >= 2)
		var has_drops = false
		var has_streaks = false
		for c in splatter["clusters"]:
			if c["droplets"].size() > 0:
				has_drops = true
			if c["streaks"].size() > 0:
				has_streaks = true
		test.call("Splatter clusters contain organic satellite droplets", has_drops)
		test.call("Splatter clusters support gravity drip streaks", has_streaks)

	# Simulate 1.0s passage -> Splatters must remain active and dripping
	hud._process(1.0)
	test.call("At t = 1.0s, splatter is still active", hud.active_blood_splatters.size() >= 1)
	if hud.active_blood_splatters.size() > 0:
		test.call("At t = 1.0s, remaining life is ~1.5s", abs(hud.active_blood_splatters[0]["life"] - 1.5) < 0.05)

	# Simulate further 1.6s passage (total 2.6s > 2.5s) -> Must completely dissipate
	hud._process(1.6)
	test.call("At t = 2.6s (> 2.5s), splatters are completely dissipated", hud.active_blood_splatters.is_empty())

	# Stacking test: multiple damage events
	hud.update_health(60.0, 100.0)
	hud.update_health(50.0, 100.0)
	test.call("Multiple damage hits stack active blood splatters", hud.active_blood_splatters.size() >= 2)
	hud._process(2.6)
	test.call("All stacked splatters cleanly dissipate after 2.5s", hud.active_blood_splatters.is_empty())

	# -------------------------------------------------------------
	# TEST 3: Low-HP Red Screen Vignette & Heartbeat Audio (< 30 HP)
	# -------------------------------------------------------------
	print("\n--- TEST GROUP 3: LOW-HP FEEDBACK ACTIVATION (< 30 HP) ---")
	# Above 30 HP (e.g. 50 HP) -> Low-HP must be inactive
	hud.update_health(50.0, 100.0)
	hud._process(0.1)
	test.call("Health at 50 HP: is_low_hp_active is false", hud.is_low_hp_active == false)
	test.call("Health at 50 HP: vignette alpha is 0.0", hud.low_hp_vignette.modulate.a < 0.01)

	# Exactly 30.0 HP boundary -> Not low-HP (< 30.0)
	hud.update_health(30.0, 100.0)
	hud._process(0.1)
	test.call("Boundary: Health at 30.0 HP is NOT low-HP", hud.is_low_hp_active == false)

	# Drop to 25.0 HP (< 30.0 HP) -> Must activate
	hud.update_health(25.0, 100.0)
	hud._process(0.1)
	test.call("Health at 25.0 HP (< 30 HP): is_low_hp_active is true", hud.is_low_hp_active == true)
	test.call("Health at 25.0 HP: vignette is visible (alpha > 0.05)", hud.low_hp_vignette.modulate.a > 0.05)
	if hud.heartbeat_player:
		test.call("Health at 25.0 HP: Heartbeat audio is playing", hud.heartbeat_player.playing == true)

	# -------------------------------------------------------------
	# TEST 4: Cardiac Double-Pulse Rhythm Verification (~75 BPM)
	# -------------------------------------------------------------
	print("\n--- TEST GROUP 4: CARDIAC DOUBLE-PULSE RHYTHM (~75 BPM) ---")
	# 75 BPM = 0.8s cycle.
	# At t = 0.10s (systolic peak): alpha should be high.
	hud.low_hp_pulse_timer = 0.09
	hud._process(0.01)
	var systolic_alpha = hud.low_hp_vignette.modulate.a
	
	# At t = 0.32s (diastolic rebound): secondary peak
	hud.low_hp_pulse_timer = 0.31
	hud._process(0.01)
	var diastolic_alpha = hud.low_hp_vignette.modulate.a

	# At t = 0.60s (diastole rest): resting baseline
	hud.low_hp_pulse_timer = 0.59
	hud._process(0.01)
	var rest_alpha = hud.low_hp_vignette.modulate.a

	test.call("Systolic contraction produces strong alpha pulse", systolic_alpha > 0.20)
	test.call("Diastolic rebound produces secondary pulse", diastolic_alpha > 0.15)
	test.call("Resting phase relaxes below systolic peak", rest_alpha < systolic_alpha)

	# -------------------------------------------------------------
	# TEST 5: Health Recovery & Subsidence (>= 30 HP)
	# -------------------------------------------------------------
	print("\n--- TEST GROUP 5: HEALTH RECOVERY SUBSIDENCE (>= 30 HP) ---")
	# Player health regenerates from 25 HP to 35 HP (exceeds 30 HP threshold)
	hud.update_health(35.0, 100.0)
	test.call("Health recovers to 35.0 HP: previous_health updated", hud.previous_health == 35.0)

	# Advance frames for subsidence
	hud._process(0.05)
	test.call("Low-HP state immediately deactivates upon reaching 35 HP", hud.is_low_hp_active == false)
	
	# Simulate frames for smooth fade out
	for _f in range(30):
		hud._process(0.033)
	
	test.call("Vignette smoothly subsides towards 0.0 alpha", hud.low_hp_vignette.modulate.a < 0.05)
	if hud.heartbeat_player:
		test.call("Heartbeat audio stops after recovery fade", not hud.heartbeat_player.playing)

	# -------------------------------------------------------------
	# TEST 6: Game Over & Death Safeguards
	# -------------------------------------------------------------
	print("\n--- TEST GROUP 6: GAME OVER & DEATH SAFEGUARDS ---")
	# Re-enter low HP
	hud.update_health(15.0, 100.0)
	hud._process(0.1)
	test.call("Re-entered low HP before death", hud.is_low_hp_active == true)
	
	# Trigger game over
	hud._on_game_over()
	test.call("Game over sets is_game_over true", hud.is_game_over == true)
	test.call("Game over stops heartbeat audio immediately", not hud.heartbeat_player.playing)
	test.call("Game over clears vignette alpha to 0.0", hud.low_hp_vignette.modulate.a == 0.0)

	# Cleanup
	hud.queue_free()
	await process_frame

	print("\n======================================================================")
	print("HUD FEEDBACK TEST RESULTS: %d / %d PASSED" % [results["passed"], results["total"]])
	print("======================================================================")
	
	if results["passed"] == results["total"] and results["total"] > 0:
		print("ALL HUD FEEDBACK TESTS PASSED SUCCESSFULLY! (100% PASS RATE)")
		quit(0)
	else:
		printerr("TEST FAILURES ENCOUNTERED: %d failed out of %d" % [results["total"] - results["passed"], results["total"]])
		quit(1)
