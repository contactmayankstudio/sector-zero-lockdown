extends SceneTree

func _init():
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	
	for i in range(10):
		await process_frame
		
	var player = inst.find_child("Player", true, false)
	var viewport = get_root()
	
	# Test CAR SMG
	player.current_weapon_index = 2
	player.weapon_configs[2].rot = Vector3(94.0, 0.0, 0.0)
	player.weapon_configs[2].scale = Vector3(1.0, 1.0, 1.0)
	player.weapon_configs[2].offset = Vector3(-0.03, -0.15, 0.05)
	var w2 = player.weapons[2]
	if w2.has_node("WeaponModel"):
		w2.get_node("WeaponModel").queue_free()
	w2.set_meta("weapon_config", player.weapon_configs[2])
	player._apply_active_weapon()
	
	for f in range(5):
		await process_frame
	var img = viewport.get_texture().get_image()
	img.save_png("screenshots/weapons/test_car_upright.png")
	print("Saved test_car_upright.png")
	
	# Test Ray Gun COD
	player.current_weapon_index = 6
	player.weapon_configs[6].rot = Vector3(1.0, 1.5, 0.0)
	player.weapon_configs[6].scale = Vector3(0.08, 0.08, 0.08)
	player.weapon_configs[6].offset = Vector3(-0.02, -0.05, -0.12)
	var w6 = player.weapons[6]
	if w6.has_node("WeaponModel"):
		w6.get_node("WeaponModel").queue_free()
	w6.set_meta("weapon_config", player.weapon_configs[6])
	player._apply_active_weapon()
	
	for f in range(5):
		await process_frame
	var img2 = viewport.get_texture().get_image()
	img2.save_png("screenshots/weapons/test_raygun_upright.png")
	print("Saved test_raygun_upright.png")
	
	quit(0)
