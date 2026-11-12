@tool
extends SceneTree

func _init():
	print("=== TESTING PLAYER WASD MOVEMENT ===")
	var scene_res = load("res://scenes/environments/AirportTerminal.tscn")
	var game_scene = scene_res.instantiate()
	root.add_child(game_scene)
	
	for i in range(5):
		await process_frame
		
	var player = game_scene.find_child("Player", true, false)
	if player:
		var init_pos = player.global_position
		print("Player initial pos: ", init_pos)
		
		# Simulate pressing 'W' (move forward / -Z)
		var ev_w_down = InputEventKey.new()
		ev_w_down.physical_keycode = KEY_W
		ev_w_down.pressed = true
		Input.parse_input_event(ev_w_down)
		
		for f in range(30):
			await process_frame
			
		var pos_after_w = player.global_position
		print("Player pos after pressing W for 30 frames: ", pos_after_w)
		print("Delta Z: ", pos_after_w.z - init_pos.z)
		if pos_after_w.z < init_pos.z:
			print(">> PLAYER IS MOVING FORWARD WITH 'W' (SUCCESS!)")
			
		var ev_w_up = InputEventKey.new()
		ev_w_up.physical_keycode = KEY_W
		ev_w_up.pressed = false
		Input.parse_input_event(ev_w_up)
		
		# Simulate pressing 'D' (move right / +X)
		var ev_d_down = InputEventKey.new()
		ev_d_down.physical_keycode = KEY_D
		ev_d_down.pressed = true
		Input.parse_input_event(ev_d_down)
		
		for f in range(30):
			await process_frame
			
		var pos_after_d = player.global_position
		print("Player pos after pressing D: ", pos_after_d)
		print("Delta X: ", pos_after_d.x - pos_after_w.x)
		if pos_after_d.x > pos_after_w.x:
			print(">> PLAYER IS STRAFING RIGHT WITH 'D' (SUCCESS!)")
			
		var ev_d_up = InputEventKey.new()
		ev_d_up.physical_keycode = KEY_D
		ev_d_up.pressed = false
		Input.parse_input_event(ev_d_up)
		
	game_scene.queue_free()
	print("=== DONE TESTING PLAYER WASD MOVEMENT ===")
	quit(0)
