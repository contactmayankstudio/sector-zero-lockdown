extends SceneTree

var passed: int = 0
var failed: int = 0

func _init():
	print("\n==================================================")
	print("AUDITING SAVE MIGRATION (V1/V2 -> V3) IN SAVEMANAGER")
	print("==================================================")
	
	var save_mgr = root.get_node_or_null("SaveManager")
	if not save_mgr:
		# If autoload not present in minimal tree, load script directly
		var SaveManagerClass = load("res://scripts/SaveManager.gd")
		save_mgr = SaveManagerClass.new()
		root.add_child(save_mgr)
		
	# 1. Test clean state
	save_mgr.data.cash = 0
	save_mgr.data.completed_missions = []
	save_mgr.data.mission_stars = {}
	
	# 2. Simulate legacy v2 save
	var legacy_save = {
		"version": 2,
		"cash": 18500,
		"completed_missions": ["mission_01", "mission_02", "mission_06", "mission_12"],
		"unlocked_weapons": ["pistol", "m4a1", "awp"],
		"weapon_upgrades": {
			"m4a1": {"damage": 3, "mag": 2, "reload": 1, "accuracy": 2}
		},
		"mission_stars": {
			"mission_01": 3,
			"mission_02": 2,
			"mission_12": 3
		}
	}
	
	# Merge legacy data
	save_mgr._merge_data(legacy_save)
	
	# Assertions
	_check("Cash fully preserved (18,500)", save_mgr.data.cash == 18500)
	_check("Legacy mission_01 maps to 1-1", save_mgr.is_mission_completed("1-1"))
	_check("Legacy mission_02 maps to 2-1", save_mgr.is_mission_completed("2-1"))
	_check("Legacy mission_06 maps to 6-1", save_mgr.is_mission_completed("6-1"))
	_check("Legacy mission_12 maps to 12-7 (Final Boss)", save_mgr.is_mission_completed("12-7"))
	
	_check("Reverse lookup: mission_01 still reported completed", save_mgr.is_mission_completed("mission_01"))
	_check("Reverse lookup: mission_12 still reported completed", save_mgr.is_mission_completed("mission_12"))
	
	_check("Endless mode unlocked by 12-7", save_mgr.is_endless_unlocked())
	_check("Campaign marked completed by 12-7", save_mgr.is_campaign_completed())
	
	_check("Uncompleted mission 3-2 correctly reports false", not save_mgr.is_mission_completed("3-2"))
	_check("Uncompleted mission 11-4 correctly reports false", not save_mgr.is_mission_completed("11-4"))
	
	_check("Weapon unlock preserved (AWP)", save_mgr.is_weapon_unlocked("awp"))
	_check("Weapon upgrade preserved (M4A1 Damage L3)", save_mgr.get_weapon_upgrade("m4a1", "damage") == 3)
	_check("Stars mapped: 1-1 has 3 stars", save_mgr.get_mission_stars("1-1") == 3)
	_check("Stars mapped: 12-7 has 3 stars", save_mgr.get_mission_stars("12-7") == 3)
	
	# 3. Test New Sub-Mission Completion
	save_mgr.complete_mission("3-4")
	_check("Newly completed 3-4 is marked complete", save_mgr.is_mission_completed("3-4"))
	
	# 4. Test Single-Claim Transaction Protection
	var reward_claimed = save_mgr.claim_mission_reward("4-1", 1200)
	_check("First claim on 4-1 succeeds", reward_claimed == true)
	_check("Cash increased by 1200", save_mgr.data.cash == 19700)
	_check("Mission 4-1 is now completed", save_mgr.is_mission_completed("4-1"))
	
	var duplicate_claim = save_mgr.claim_mission_reward("4-1", 1200)
	_check("Duplicate claim on 4-1 is rejected (false)", duplicate_claim == false)
	_check("Cash remains 19700 after rejected claim", save_mgr.data.cash == 19700)
	
	print("\n==================================================")
	print("SAVE MIGRATION AUDIT: %d PASSED, %d FAILED" % [passed, failed])
	print("==================================================")
	
	if failed > 0:
		quit(1)
	else:
		quit(0)

func _check(label: String, cond: bool):
	if cond:
		passed += 1
		print("[PASS] %s" % label)
	else:
		failed += 1
		printerr("[FAIL] %s" % label)
