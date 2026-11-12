extends SceneTree

func _init():
	# Modify negev_ng7 rot in Player.gd temporarily or instantiate Player directly
	var p_scene = load("res://scenes/player/Player.tscn")
	var p = p_scene.instantiate()
	p.weapon_configs[0].rot = Vector3(0.0, -90.0, 0.0)
	# Position weapon nicely in first person view
	p.weapon_configs[0].offset = Vector3(0.12, -0.15, -0.25)
	
	var world = World3D.new()
	var env_scene = load("res://scenes/environments/AirportTerminal.tscn")
	var env = env_scene.instantiate()
	
	# Replace Player in AirportTerminal with our configured player
	var existing_p = env.find_child("Player", true, false)
	if existing_p:
		var parent = existing_p.get_parent()
		var xform = existing_p.transform
		existing_p.queue_free()
		p.transform = xform
		parent.add_child(p)
	else:
		env.add_child(p)
		
	get_root().add_child(env)
	
	for i in range(15):
		await process_frame
		
	var viewport = get_root()
	var img = viewport.get_texture().get_image()
	img.save_png("screenshots/test_negev_forward.png")
	print("Captured test_negev_forward.png!")
	quit(0)
