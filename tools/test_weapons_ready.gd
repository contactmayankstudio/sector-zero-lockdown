extends SceneTree

func _init():
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	get_root().add_child(level)
	
	var player = level.get_node_or_null("Player")
	if player:
		print("Player found! Total weapons initialized: ", player.weapons.size())
		for i in range(player.weapons.size()):
			var w = player.weapons[i]
			var w_name = w.weapon_data.display_name if w.weapon_data else "Unknown"
			print(" - Weapon [", i+1, "]: ", w_name, " (Ammo: ", w.current_ammo, "/", w.max_ammo, ")")
		print("Is Third Person default: ", player.is_third_person)
	else:
		printerr("Player NOT found!")
		
	quit(0)
