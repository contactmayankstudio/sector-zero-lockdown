extends SceneTree

func _init():
	print("--- Starting Armory & Cash UI Showcase Capture ---")
	
	# Set up showcase save state: cash, unlocked weapons, equipped weapon
	var save_mgr = root.get_node_or_null("SaveManager")
	if save_mgr and "data" in save_mgr:
		save_mgr.data.cash = 14580
		save_mgr.data.completed_missions = ["mission_01", "1-1", "mission_02", "2-1"]
		if save_mgr.has_method("set_equipped_weapon"):
			save_mgr.set_equipped_weapon("m4a1")
		elif "equipped_weapon" in save_mgr.data:
			save_mgr.data.equipped_weapon = "m4a1"
		# Unlock the first 3 weapons for showcase variety
		if "unlocked_weapons" in save_mgr.data:
			save_mgr.data.unlocked_weapons = ["usp45", "pistol", "m4a1", "rifle", "remington870", "shotgun"]
		print("Set showcase: cash=14,580, equipped=m4a1, 3 weapons unlocked.")

	# STAGE 0: Main Menu with Cash Display
	print("\n[STAGE 0] Loading MainMenu.tscn...")
	var sc_menu = load("res://scenes/UI/MainMenu.tscn")
	var menu_node = sc_menu.instantiate()
	root.add_child(menu_node)
	for i in range(45):
		await process_frame
	
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_mainmenu_cash.png")
		print("  [SAVED] screenshots/showcase_mainmenu_cash.png")
	menu_node.queue_free()
	await process_frame

	# STAGE 1: ArmoryUI with M4A1 Sentinel (Equipped)
	print("\n[STAGE 1] Loading ArmoryUI.tscn (M4A1 Sentinel)...")
	var sc_armory = load("res://scenes/UI/ArmoryUI.tscn")
	var armory_node = sc_armory.instantiate()
	root.add_child(armory_node)
	# Force select M4A1 after ready
	for i in range(10):
		await process_frame
	if armory_node.has_method("_select_weapon"):
		armory_node._select_weapon("m4a1")
	for i in range(40):
		await process_frame

	img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_armory_m4a1.png")
		print("  [SAVED] screenshots/showcase_armory_m4a1.png")

	# STAGE 2: ArmoryUI with USP-45 selected
	print("\n[STAGE 2] Selecting USP-45...")
	if armory_node.has_method("_select_weapon"):
		armory_node._select_weapon("usp45")
	for i in range(35):
		await process_frame

	img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_armory_usp45.png")
		print("  [SAVED] screenshots/showcase_armory_usp45.png")

	# STAGE 3: ArmoryUI with AWP Arctic Warfare (Locked)
	print("\n[STAGE 3] Selecting AWP Arctic Warfare (Locked)...")
	if armory_node.has_method("_select_weapon"):
		armory_node._select_weapon("awp")
	for i in range(35):
		await process_frame

	img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_armory_awp_locked.png")
		print("  [SAVED] screenshots/showcase_armory_awp_locked.png")

	# STAGE 4: ArmoryUI with AK-47 Vanguard
	print("\n[STAGE 4] Selecting AK-47 Vanguard...")
	if armory_node.has_method("_select_weapon"):
		armory_node._select_weapon("ak47")
	for i in range(35):
		await process_frame

	img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_armory_ak47.png")
		print("  [SAVED] screenshots/showcase_armory_ak47.png")

	# STAGE 5: Desert Eagle
	print("\n[STAGE 5] Selecting Desert Eagle .50 AE...")
	if armory_node.has_method("_select_weapon"):
		armory_node._select_weapon("desert_eagle")
	for i in range(35):
		await process_frame

	img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_armory_deagle.png")
		print("  [SAVED] screenshots/showcase_armory_deagle.png")

	armory_node.queue_free()
	await process_frame

	# STAGE 6: ArmoryUI at 960x540 resolution
	print("\n[STAGE 6] Loading ArmoryUI at 960x540 resolution...")
	DisplayServer.window_set_size(Vector2i(960, 540))
	armory_node = sc_armory.instantiate()
	root.add_child(armory_node)
	for i in range(10):
		await process_frame
	if armory_node.has_method("_select_weapon"):
		armory_node._select_weapon("m4a1")
	for i in range(40):
		await process_frame

	img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_armory_960x540.png")
		print("  [SAVED] screenshots/showcase_armory_960x540.png")

	armory_node.queue_free()
	await process_frame

	print("\n🎉 ALL SHOWCASE SCREENSHOTS CAPTURED SUCCESSFULLY!")
	quit(0)
