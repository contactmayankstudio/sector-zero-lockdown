extends SceneTree

var passed = 0
var total = 0

func _init():
	call_deferred("_run_tests")

func assert_test(condition: bool, pass_msg: String, fail_msg: String = ""):
	total += 1
	if condition:
		passed += 1
		print("  [PASS] %s" % pass_msg)
	else:
		printerr("  [FAIL] %s" % (fail_msg if fail_msg != "" else pass_msg))

func _run_tests():
	await process_frame
	await process_frame

	print("======================================================================")
	print("ADMOB, ECONOMY REBALANCE & 1-MATCH RENTAL VERIFICATION SUITE")
	print("======================================================================")

	# TEST 1: BannerAdManager Configuration & Game State Rules
	var banner = root.get_node_or_null("BannerAdManager")
	assert_test(banner != null and banner.banner_ad_unit_id == "ca-app-pub-7719493859621460/8812601577",
		"BannerAdManager has production Google AdMob banner unit ID")

	var gsm = root.get_node_or_null("GameStateManager")
	if gsm and banner:
		gsm.change_state(gsm.State.GAMEPLAY)
		assert_test(not banner.is_banner_visible, "Banner Ad is strictly HIDDEN during active GAMEPLAY")
		gsm.change_state(gsm.State.PAUSED)
		assert_test(not banner.is_banner_visible, "Banner Ad stays HIDDEN over the paused gameplay screen")
		gsm.resume_game()
		for screen_state in [gsm.State.MAIN_MENU, gsm.State.MISSION_SELECT, gsm.State.UPGRADES,
				gsm.State.SETTINGS, gsm.State.MISSION_COMPLETE, gsm.State.MISSION_FAILED]:
			gsm.change_state(screen_state)
			assert_test(banner.is_banner_visible, "Banner Ad is SHOWN for non-game screen %s" % gsm.state_to_string(screen_state))
		for in_game_state in [gsm.State.MISSION_INTRO, gsm.State.LOADING, gsm.State.GAMEPLAY, gsm.State.PAUSED]:
			if in_game_state == gsm.State.PAUSED and gsm.current_state != gsm.State.GAMEPLAY:
				gsm.change_state(gsm.State.GAMEPLAY)
			gsm.change_state(in_game_state)
			assert_test(not banner.is_banner_visible, "Banner Ad is HIDDEN for gameplay transition %s" % gsm.state_to_string(in_game_state))
			if in_game_state == gsm.State.PAUSED:
				gsm.resume_game()
		gsm.change_state(gsm.State.MAIN_MENU)
		assert_test(banner.is_banner_visible, "Banner Ad is SHOWN in MAIN_MENU")

	# TEST 2: AdManager Rewarded Video Configuration
	var ad_mgr = root.get_node_or_null("AdManager")
	assert_test(ad_mgr != null and ad_mgr.rewarded_ad_unit_id == "ca-app-pub-7719493859621460/2646648479",
		"AdManager has production Google AdMob rewarded unit ID")

	# TEST 3: Weapon Registry & Starter Lock Status
	var all_wids = WeaponManager.get_all_weapon_ids()
	var negev_entry = WeaponManager.get_weapon_entry("negev_ng7")
	assert_test(negev_entry.get("default_unlocked", false) == true and negev_entry.get("unlock_price", -1) == 0,
		"Starter LMG (negev_ng7) is default unlocked with price ₹0")

	var other_locked = true
	for wid in all_wids:
		if wid != "negev_ng7":
			var entry = WeaponManager.get_weapon_entry(wid)
			if entry.get("default_unlocked", true) != false:
				other_locked = false
				printerr("  [FAIL] Weapon %s was default unlocked!" % wid)
				break
	assert_test(other_locked, "All 13 other weapons are locked by default (requiring cash or rental)")

	# TEST 4: 1-Match Gun Rental Architecture
	var save_mgr = root.get_node_or_null("SaveManager")
	if save_mgr:
		# Test renting car_smg
		save_mgr.rent_weapon("car_smg", 1)
		var is_rented = save_mgr.is_weapon_rented("car_smg")
		var is_unlocked = save_mgr.is_weapon_unlocked("car_smg")
		var is_owned = save_mgr.is_weapon_owned("car_smg")
		assert_test(is_rented and is_unlocked and not is_owned,
			"Gun Rental: car_smg rented for 1 match (is_rented=true, is_unlocked=true, is_owned=false)")

		# Test consuming rental
		save_mgr.consume_rented_weapons()
		var is_still_rented = save_mgr.is_weapon_rented("car_smg")
		var eq_wep = save_mgr.get_equipped_weapon()
		assert_test(not is_still_rented and eq_wep == "negev_ng7",
			"Rental Expiration: car_smg expired after 1 match and equipped weapon returned to negev_ng7")

	# TEST 5: Rewarded Ad Unlock + 2X Cash Integration
	if ad_mgr and save_mgr:
		ad_mgr.is_showing_ad = true
		ad_mgr._current_reward_type = "unlock_gun"
		ad_mgr._current_extra_data = {"weapon_id": "car_smg"}
		ad_mgr._on_rewarded_video_rewarded()
		var permanent_unlock = save_mgr.is_weapon_owned("car_smg") and not save_mgr.is_weapon_rented("car_smg")
		var equipped_reward = save_mgr.get_equipped_weapon() == "car_smg"
		assert_test(permanent_unlock and equipped_reward,
			"Rewarded ad permanently unlocks and equips car_smg")

		var init_cash = save_mgr.data.cash
		ad_mgr._current_reward_type = "double_cash"
		ad_mgr._current_extra_data = {"amount": 250}
		ad_mgr.is_showing_ad = true
		ad_mgr._on_rewarded_video_rewarded()
		var new_cash = save_mgr.data.cash
		assert_test(new_cash == init_cash + 250,
			"2X Cash Reward: Successfully awarded +250 bonus cash on ad claim")

	# TEST 6: Mission Cash Progression Curve
	var m1_1 = load("res://resources/missions/campaign/mission_01_01.tres")
	var m1_7 = load("res://resources/missions/campaign/mission_01_07.tres")
	var m2_3 = load("res://resources/missions/campaign/mission_02_03.tres")
	if m1_1 and m1_7 and m2_3:
		assert_test(m1_1.reward_cash == 120 and m1_7.reward_cash == 260 and m2_3.reward_cash == 230,
			"Campaign Missions Economy: 1-1 (120), 1-7 Boss (260), 2-3 Level 10 (230) verified")
	else:
		printerr("  [FAIL] Could not load mission resources")

	# TEST 7: ArmoryUI Scene Inspection
	var armory_scene = load("res://scenes/UI/ArmoryUI.tscn")
	if armory_scene:
		var armory_inst = armory_scene.instantiate()
		var rent_btn = armory_inst.find_child("RentBtn", true, false)
		var unlock_btn = armory_inst.find_child("UnlockBtn", true, false)
		var equip_btn = armory_inst.find_child("EquipBtn", true, false)
		assert_test(rent_btn != null and unlock_btn != null and equip_btn != null,
			"ArmoryUI has RentBtn, UnlockBtn, and EquipBtn properly constructed")
		armory_inst.free()
	else:
		printerr("  [FAIL] Could not load ArmoryUI.tscn")

	# TEST 8: ResultUI Scene Inspection
	var result_scene = load("res://scenes/UI/ResultUI.tscn")
	if result_scene:
		var result_inst = result_scene.instantiate()
		var double_btn = result_inst.find_child("DoubleRewardButton", true, false)
		assert_test(double_btn != null,
			"ResultUI has DoubleRewardButton properly configured")
		result_inst.free()
	else:
		printerr("  [FAIL] Could not load ResultUI.tscn")

	print("======================================================================")
	print("TEST RESULTS: %d / %d PASSED" % [passed, total])
	print("======================================================================")
	if passed == total:
		print("ALL ADMOB & ECONOMY REBALANCE TESTS PASSED! (100%)")
	quit(0 if passed == total else 1)
