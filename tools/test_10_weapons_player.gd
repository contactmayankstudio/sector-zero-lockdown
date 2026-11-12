extends SceneTree

func _init():
	for i in range(10):
		await process_frame
		
	print("\n==================================================")
	print("TEST SUITE: 10 WEAPONS & COMBAT ARMS INTEGRATION")
	print("==================================================\n")
	
	var save_mgr = root.get_node_or_null("SaveManager")
	if not save_mgr:
		var sm_script = load("res://scripts/SaveManager.gd")
		save_mgr = sm_script.new()
		save_mgr.name = "SaveManager"
		root.add_child(save_mgr)
		
	# Unlock all 10 canonical weapons
	save_mgr.data.unlocked_weapons = [
		"usp45", "m4a1", "remington870", "ak47", "desert_eagle",
		"mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"
	]
	
	var player_scene = load("res://scenes/player/Player.tscn")
	if not player_scene:
		printerr("[FAIL] Failed to load Player.tscn")
		quit(1)
		return
		
	var player = player_scene.instantiate()
	root.add_child(player)
	
	for i in range(5):
		await process_frame
		
	print("--- 1. PLAYER WEAPON ROSTER CHECK ---")
	print("Loaded weapons count: %d" % player.weapons.size())
	for idx in range(player.weapons.size()):
		var w = player.weapons[idx]
		var w_id = w.weapon_data.weapon_id if w.weapon_data else "UNKNOWN"
		var w_name = w.weapon_data.display_name if w.weapon_data else "UNKNOWN"
		var has_model = w.has_node("WeaponModel") or (w.has_node("MeshInstance3D") and w.get_node("MeshInstance3D").mesh != null)
		print("  [%d] ID: %s | Name: %s | Model: %s | Ammo: %d/%d" % [idx, w_id, w_name, has_model, w.current_ammo, w.max_ammo])
	
	print("\n--- 2. FPS ARMS VIEWMODEL CHECK ---")
	var fps_arms = player.get_node_or_null("Camera3D/FPSArms")
	print("FPSArms node present: %s" % (fps_arms != null))
	if fps_arms:
		print("FPSArms global transform: pos=%s" % str(fps_arms.global_position))
		var arms_model = fps_arms.get_node_or_null("CombatArmsModel")
		print("CombatArmsModel present: %s" % (arms_model != null))
		if arms_model:
			print("CombatArmsModel visible: %s" % arms_model.visible)
			print("CombatArmsModel local pos: %s" % str(arms_model.position))
	
	print("\n--- 3. WEAPON SWITCHING & MODEL VERIFICATION ---")
	var all_weapons_valid = true
	for step in range(player.weapons.size()):
		var cur_w = player.get_current_weapon()
		var cur_id = cur_w.weapon_data.weapon_id if cur_w and cur_w.weapon_data else "N/A"
		var cur_name = cur_w.weapon_data.display_name if cur_w and cur_w.weapon_data else "N/A"
		var is_vis = cur_w.visible if cur_w else false
		print("Active [%d]: %s (%s) visible=%s" % [step, cur_name, cur_id, is_vis])
		if not is_vis:
			all_weapons_valid = false
		player.switch_weapon()
		await process_frame
		
	print("All weapons switched cleanly: %s" % all_weapons_valid)
	
	print("\n--- 4. EMPTY MAGAZINE & AUTO-RELOAD TEST ---")
	player.switch_to_weapon(0) # USP-45
	var usp = player.get_current_weapon()
	print("Initial USP-45 ammo: %d/%d, can_shoot=%s, is_reloading=%s" % [usp.current_ammo, usp.max_ammo, usp.can_shoot, usp.is_reloading])
	
	# Fire until empty waiting for fire_timer
	var shots = 0
	while usp.current_ammo > 0 and shots < 50:
		if usp.can_shoot and not usp.is_reloading:
			usp.shoot()
			shots += 1
		await process_frame
	print("After %d shots: ammo=%d, can_shoot=%s, is_reloading=%s" % [shots, usp.current_ammo, usp.can_shoot, usp.is_reloading])

	
	# Fire again when 0 ammo: should trigger reload or empty sound
	usp.shoot()
	print("After empty fire: is_reloading=%s, can_shoot=%s" % [usp.is_reloading, usp.can_shoot])
	
	print("\n--- 5. WEAPON STATE FREEZE TEST (SWITCH DURING 0 AMMO) ---")
	# Cancel reload by switching away
	player.switch_weapon()
	print("Switched away to: %s" % player.get_current_weapon().weapon_data.display_name)
	print("USP-45 state while inactive: ammo=%d, is_reloading=%s, can_shoot=%s" % [usp.current_ammo, usp.is_reloading, usp.can_shoot])
	
	# Switch back to USP-45
	player.switch_to_weapon(0)
	print("Switched back to USP-45: ammo=%d, is_reloading=%s, can_shoot=%s" % [usp.current_ammo, usp.is_reloading, usp.can_shoot])
	
	# Try shooting: does _trigger_shoot work or is it frozen?
	var can_trigger_shoot_before = (usp.can_shoot and not usp.is_reloading)
	print("Can player._trigger_shoot() fire? %s" % can_trigger_shoot_before)
	if not can_trigger_shoot_before:
		printerr("[BUG DETECTED] USP-45 is FROZEN! Player cannot shoot or reload via fire button!")
	else:
		print("[OK] Weapon is responsive after switching with 0 ammo")
		
	player.free()
	print("\n==================================================")
	print("TEST COMPLETE")
	print("==================================================")
	quit(0)
