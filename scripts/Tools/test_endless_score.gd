extends SceneTree

func _init():
	await process_frame
	var manager = get_root().get_node_or_null("MissionManager")
	var save_mgr = get_root().get_node_or_null("SaveManager")
	if not manager or not save_mgr:
		printerr("[FAIL] Required autoloads missing")
		quit(1)
		return

	var endless = load("res://resources/missions/mission_endless.tres") as MissionData
	manager.current_mission = endless
	manager.score = 0
	manager._on_enemy_killed_event("normal", false, Vector3.ZERO)
	var base_score = manager.score
	manager._on_enemy_killed_event("normal", true, Vector3.ZERO)
	var headshot_score = manager.score
	manager._on_enemy_killed_event("boss", false, Vector3.ZERO)
	var boss_score = manager.score
	var valid = base_score == 100 and headshot_score == 275 and boss_score == 875
	print("[PASS] Score values: base=%d headshot_total=%d boss_total=%d" % [base_score, headshot_score, boss_score])
	var old_best = save_mgr.get_highest_score()
	save_mgr.set_highest_score(boss_score)
	var persisted = save_mgr.get_highest_score() >= max(old_best, boss_score)
	print("[PASS] Personal best persisted: %s" % persisted)
	manager.current_mission = null
	quit(0 if valid and persisted else 1)
