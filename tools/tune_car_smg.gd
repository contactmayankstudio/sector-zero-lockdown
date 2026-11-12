extends SceneTree

func _init():
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	
	for i in range(10):
		await process_frame
		
	var player = inst.find_child("Player", true, false)
	player.current_weapon_index = 2 # car_smg
	
	# Test rotations for car_smg
	# Previous: rot=(94.0, 27.0, 12.0), scale=(1, 1, 1), offset=(-0.02, -0.08, 0.05)
	# Let's test:
	var test_rots = [
		Vector3(90.0, 0.0, 0.0),
		Vector3(94.0, 0.0, 0.0),
		Vector3(94.0, 15.0, 0.0),
		Vector3(90.0, 180.0, 0.0)
	]
	
	var viewport = get_root()
	for i in range(test_rots.size()):
		var rot = test_rots[i]
		player.weapon_configs[2].rot = rot
		player.weapon_configs[2].scale = Vector3(1.0, 1.0, 1.0)
		player.weapon_configs[2].offset = Vector3(-0.03, -0.15, 0.05)
		
		# Re-apply
		if player.weapons.size() > 2:
			var w = player.weapons[2]
			if w.has_node("WeaponModel"):
				w.get_node("WeaponModel").queue_free()
			player._ensure_weapon_model(w)
			
		for f in range(3):
			await process_frame
			
		var img = viewport.get_texture().get_image()
		img.save_png("screenshots/weapons/car_rot_test_" + str(i) + ".png")
		print("Saved car_rot_test_", i, " with rot: ", rot)
		
	quit(0)
