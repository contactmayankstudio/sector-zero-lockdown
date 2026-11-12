extends SceneTree

func _init():
	print("--- TESTING GUN SHOOTING CYCLE ---")
	var player_scene = load("res://scenes/player/Player.tscn")
	if not player_scene:
		print("FAILED to load Player.tscn")
		quit(1)
		return
	var player = player_scene.instantiate()
	root.add_child(player)
	
	# Wait 2 frames for ready
	await process_frame
	await process_frame
	
	var weapon = player.get_current_weapon()
	if not weapon:
		print("ERROR: No current weapon!")
		quit(1)
		return
		
	print("Initial weapon: %s, ammo: %d/%d, can_shoot: %s, is_reloading: %s, is_automatic: %s" % [
		weapon.weapon_data.weapon_id if weapon.weapon_data else "none",
		weapon.current_ammo,
		weapon.max_ammo,
		weapon.can_shoot,
		weapon.is_reloading,
		weapon.weapon_data.is_automatic if weapon.weapon_data else false
	])
	
	print("\nShot 1:")
	player.start_fire()
	print("After shot 1: ammo=%d, can_shoot=%s, is_firing=%s" % [weapon.current_ammo, weapon.can_shoot, player.is_firing])
	player.stop_fire()
	print("After stop_fire: is_firing=%s, can_shoot=%s" % [player.is_firing, weapon.can_shoot])
	
	print("\nWaiting 0.3s for fire_rate cooldown...")
	var t = create_timer(0.3)
	await t.timeout
	print("After 0.3s: can_shoot=%s" % weapon.can_shoot)
	
	print("\nShot 2:")
	player.start_fire()
	print("After shot 2: ammo=%d, can_shoot=%s" % [weapon.current_ammo, weapon.can_shoot])
	player.stop_fire()
	
	print("\nWaiting 0.3s...")
	t = create_timer(0.3)
	await t.timeout
	
	print("\nEmptying magazine to test auto-reload...")
	while weapon.current_ammo > 0:
		player.start_fire()
		player.stop_fire()
		t = create_timer(0.25)
		await t.timeout
		print("Ammo: %d, can_shoot=%s, is_reloading=%s" % [weapon.current_ammo, weapon.can_shoot, weapon.is_reloading])
		
	print("\nAfter magazine empty: is_reloading=%s" % weapon.is_reloading)
	print("Waiting for reload duration (2.0s)...")
	t = create_timer(2.0)
	await t.timeout
	print("After reload: ammo=%d/%d, can_shoot=%s, is_reloading=%s" % [weapon.current_ammo, weapon.max_ammo, weapon.can_shoot, weapon.is_reloading])
	
	print("\nShot after reload:")
	player.start_fire()
	player.stop_fire()
	print("After shot post-reload: ammo=%d, can_shoot=%s" % [weapon.current_ammo, weapon.can_shoot])
	
	print("SUCCESS: Gun shooting test finished")
	quit(0)
