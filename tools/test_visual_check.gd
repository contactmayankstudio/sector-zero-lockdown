extends SceneTree

func _init():
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	var w = scn.instantiate()
	root.add_child(w)
	_test()

func _test():
	for i in range(40):
		await process_frame
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	img.save_png("/home/am/test_visual_check.png")
	print("Saved /home/am/test_visual_check.png")
	quit(0)
