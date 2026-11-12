extends SceneTree

func _init():
	print("--- Diagnosing RailwayStation.tscn ---")
	var s = load("res://scenes/environments/RailwayStation.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	for i in range(5):
		await process_frame
	print("Inst child count: ", inst.get_child_count())
	var cam = inst.find_children("*", "Camera3D", true, false)
	print("Camera3D found: ", cam)
	for c in cam:
		print("  Cam current: ", c.current, " pos: ", c.global_position)
	var player = inst.find_child("Player", true, false)
	print("Player found: ", player)
	if player:
		print("  Player hud: ", player.get_node_or_null("HUD"))
		print("  Player camera: ", player.get_node_or_null("Camera3D"))
		print("  Player weapons count: ", player.weapons.size())
		if not player.weapons.is_empty():
			print("  Current weapon: ", player.weapons[player.current_weapon_index].weapon_data.weapon_id)
	quit(0)
