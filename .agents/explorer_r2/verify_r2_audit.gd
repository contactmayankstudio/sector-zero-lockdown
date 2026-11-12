extends SceneTree

var passed := 0
var failed := 0

func _init():
	print("\n==================================================")
	print("EXPLORER R2 AUDIT TEST SUITE")
	print("==================================================")
	
	_test_12_missions_strict_waves()
	_test_enemy_archetypes()
	_test_gamemanager_boss_wave_advance_logic()
	_test_idempotency_and_double_finish()
	
	print("\n==================================================")
	print("AUDIT SUMMARY: %d PASSED, %d FAILED" % [passed, failed])
	print("==================================================")
	quit(0)

func _check(label: String, condition: bool):
	if condition:
		passed += 1
		print("[PASS] %s" % label)
	else:
		failed += 1
		printerr("[FAIL] %s" % label)

func _test_12_missions_strict_waves():
	print("\n--- Test Group 1: Strict 3-Wave Enforcement (waves.size() == 3) ---")
	for i in range(1, 13):
		var path = "res://resources/missions/mission_%02d.tres" % i
		var m = load(path) as MissionData
		if not m:
			_check("Load mission_%02d" % i, false)
			continue
		_check("mission_%02d wave_count is 3" % i, m.wave_count == 3)
		# This will fail on 03-12, proving the residual 4th wave issue!
		_check("mission_%02d waves.size() == 3 (strict check)" % i, m.waves.size() == 3)

func _test_enemy_archetypes():
	print("\n--- Test Group 2: Enemy Archetype Validity in Wave Definitions ---")
	var valid_archetypes = ["normal", "fast", "heavy", "special", "spitter", "dog", "boss", "rat", "rats", "bat"]
	for i in range(1, 13):
		var path = "res://resources/missions/mission_%02d.tres" % i
		var m = load(path) as MissionData
		if not m: continue
		for w_idx in range(m.waves.size()):
			var w = m.waves[w_idx]
			for g in w.get("groups", []):
				var et = g.get("enemy_type", "")
				var is_valid = et in valid_archetypes
				if not is_valid:
					_check("mission_%02d wave %d has valid archetype '%s'" % [i, w_idx + 1, et], false)

func _test_gamemanager_boss_wave_advance_logic():
	print("\n--- Test Group 3: GameManager Wave Advance Logic for BOSS_KILL ---")
	var m12 = load("res://resources/missions/mission_12.tres") as MissionData
	if not m12:
		_check("Load mission_12", false)
		return
	# In Mission 12: objective_type is BOSS_KILL (2), target_count is 1
	# After wave 1, 8 minions are killed -> kill_count = 8
	var wave_1_kills = 8
	var current_wave = 1
	var total_waves = m12.wave_count # 3
	
	# Simulating GameManager.gd line 330-342 logic:
	var can_advance_original = false
	if current_wave < total_waves:
		if m12.objective_type == MissionData.ObjectiveType.SURVIVE_WAVES:
			can_advance_original = true
		else:
			if wave_1_kills < m12.target_count:
				can_advance_original = true
				
	_check("Simulate CURRENT GameManager.gd: Does Wave 1 advance to Wave 2 in Mission 12?", can_advance_original)

func _test_idempotency_and_double_finish():
	print("\n--- Test Group 4: SaveManager & MissionManager Idempotency ---")
	var save_mgr = root.get_node_or_null("SaveManager")
	if not save_mgr:
		save_mgr = load("res://scripts/SaveManager.gd").new()
		root.add_child(save_mgr)
		
	save_mgr.data.cash = 1000
	save_mgr.data.completed_missions = []
	
	# First claim
	var claim1 = save_mgr.claim_mission_reward("mission_01", 500)
	_check("First claim succeeds", claim1 == true)
	_check("Cash is 1500", save_mgr.data.cash == 1500)
	_check("mission_01 marked completed", save_mgr.is_mission_completed("mission_01"))
	
	# Second claim (duplicate)
	var claim2 = save_mgr.claim_mission_reward("mission_01", 500)
	_check("Second claim blocked (returns false)", claim2 == false)
	_check("Cash remains 1500 (no duplicate payout)", save_mgr.data.cash == 1500)
