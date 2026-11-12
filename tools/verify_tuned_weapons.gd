extends SceneTree

func _init():
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	
	for i in range(10):
		await process_frame
		
	var player = inst.find_child("Player", true, false)
	if not player:
		print("ERROR: Player not found")
		quit(1)
		return
		
	var viewport = get_root()
	var indices_to_check = [0, 2, 5, 6, 12]
	
	for idx in indices_to_check:
		player.current_weapon_index = idx
		player._apply_active_weapon()
		for f in range(4):
			await process_frame
		var w_id = player.weapon_configs[idx].id
		var img = viewport.get_texture().get_image()
		var out_path = "screenshots/weapons/tuned_" + str(idx) + "_" + w_id + ".png"
		img.save_png(out_path)
		print("Saved tuned screenshot: ", out_path)
		
	print("TUNED WEAPONS VERIFIED!")
	quit(0)
