extends SceneTree

func _init():
	await process_frame
	var manager = get_root().get_node_or_null("ChallengeManager")
	if not manager:
		printerr("[FAIL] ChallengeManager autoload missing")
		quit(1)
		return

	var challenge = manager.get_daily_challenge()
	var save_mgr = get_root().get_node_or_null("SaveManager")
	var valid = challenge.has("id") and challenge.has("target") and challenge.has("stat")
	valid = valid and int(challenge.target) > 0 and manager.get_progress() >= 0
	if not valid:
		printerr("[FAIL] Invalid daily challenge payload: %s" % challenge)
		quit(1)
		return

	var before = manager.get_progress()
	manager._increment_progress()
	var after = manager.get_progress()
	var progress_ok = after == min(before + 1, int(challenge.target))
	var bounded = after <= int(challenge.target)
	print("[PASS] Daily challenge: %s (%d/%d)" % [challenge.title, after, challenge.target])
	print("[PASS] Progress bounded: %s" % bounded)
	print("[PASS] Progress increment: %s" % progress_ok)
	if save_mgr:
		save_mgr.load_game()
	var persisted = save_mgr != null and save_mgr.data.has("daily_challenge")
	print("[PASS] Challenge persistence field: %s" % persisted)
	quit(0 if progress_ok and bounded and persisted else 1)
