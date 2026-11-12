extends SceneTree

func _init():
	var p_sc = load("res://scenes/player/Player.tscn")
	var p = p_sc.instantiate()
	root.add_child(p)
	
	for idx in range(p.weapons.size()):
		if p.weapons[idx].weapon_data and p.weapons[idx].weapon_data.weapon_id == "ak74u":
			p.switch_to_weapon(idx)
			break
			
	var ak = p.weapon_manager.get_child(0)
	print("AK node: ", ak.name)
	for c in ak.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", c.name, " visible: ", c.visible, " global_pos: ", c.global_position)
	
	p.free()
	quit(0)
