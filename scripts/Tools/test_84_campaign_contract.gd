extends SceneTree

var passed: int = 0
var failed: int = 0

func _init():
	print("\n==================================================")
	print("AUDITING 84-MISSION CAMPAIGN CONTRACT (CH 1-12)")
	print("==================================================")
	
	for c in range(1, 13):
		for s in range(1, 8):
			var file_path = "res://resources/missions/campaign/mission_%02d_%02d.tres" % [c, s]
			var mission_id = "%d-%d" % [c, s]
			_audit_mission(file_path, mission_id, c, s)
			
	# Audit Endless Survival
	var endless_res = load("res://resources/missions/mission_endless.tres") as MissionData
	_check("Endless mode resource loads", endless_res != null)
	if endless_res:
		_check("Endless mode unlocks after 12-7", endless_res.unlock_requirement_id == "12-7")
		_check("Endless mode is marked is_endless", endless_res.is_endless == true)
	
	print("\n==================================================")
	print("84-MISSION CONTRACT AUDIT: %d PASSED, %d FAILED" % [passed, failed])
	print("==================================================")
	
	if failed > 0:
		quit(1)
	else:
		quit(0)

func _audit_mission(path: String, expected_id: String, chap: int, sub: int):
	var mission = load(path) as MissionData
	_check("Mission resource loads: %s" % path, mission != null)
	if not mission:
		return
		
	_check("[%s] Correct mission_id" % expected_id, mission.mission_id == expected_id)
	_check("[%s] Has 3 waves" % expected_id, mission.wave_count == 3 and mission.waves.size() == 3)
	
	# Unlock check
	if chap == 1 and sub == 1:
		_check("[%s] 1-1 has empty unlock requirement" % expected_id, mission.unlock_requirement_id == "")
	elif sub > 1:
		var prev_sub = "%d-%d" % [chap, sub - 1]
		_check("[%s] Unlocks after %s" % [expected_id, prev_sub], mission.unlock_requirement_id == prev_sub)
	else:
		var prev_chap_end = "%d-7" % [chap - 1]
		_check("[%s] Unlocks after prev chapter %s" % [expected_id, prev_chap_end], mission.unlock_requirement_id == prev_chap_end)
		
	# Scene check
	_check("[%s] Scene file exists: %s" % [expected_id, mission.scene_path], FileAccess.file_exists(mission.scene_path))
	
	# Boss check for sub 7
	if sub == 7:
		_check("[%s] Capstone sub-mission 7 is BOSS_KILL" % expected_id, mission.objective_type == MissionData.ObjectiveType.BOSS_KILL)
	
	# Cash reward check
	_check("[%s] Cash reward is positive (%d)" % [expected_id, mission.reward_cash], mission.reward_cash > 0)

func _check(label: String, cond: bool):
	if cond:
		passed += 1
		# Only print every 14th test or errors to avoid flood
		if passed % 20 == 0:
			print("[PASS] %s" % label)
	else:
		failed += 1
		printerr("[FAIL] %s" % label)
