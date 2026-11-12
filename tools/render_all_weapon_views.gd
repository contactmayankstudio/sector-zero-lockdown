extends SceneTree

func _init():
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("screenshots/weapons"):
		dir.make_dir_recursive("screenshots/weapons")
		
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
		
	print("Player has ", player.weapons.size(), " weapons.")
	var viewport = get_root()
	
	for w_idx in range(player.weapons.size()):
		player.current_weapon_index = w_idx
		player._apply_active_weapon()
		
		# Wait 3 frames for model instantiation and layout
		for f in range(4):
			await process_frame
			
		var w_node = player.weapons[w_idx]
		var w_id = player.weapon_configs[w_idx].id
		var img = viewport.get_texture().get_image()
		var out_path = "screenshots/weapons/" + str(w_idx) + "_" + w_id + ".png"
		img.save_png(out_path)
		print("Saved screenshot [", w_idx, "]: ", out_path)
		
	print("ALL WEAPONS SCREENSHOTS CAPTURED!")
	quit(0)
