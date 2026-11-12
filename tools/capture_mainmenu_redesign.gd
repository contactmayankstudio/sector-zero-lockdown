extends SceneTree

func _init():
	var sc = load("res://scenes/UI/MainMenu.tscn")
	var node = sc.instantiate()
	root.add_child(node)
	for i in range(25):
		await process_frame
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/showcase_mainmenu_redesign.png")
		print("SAVED: screenshots/showcase_mainmenu_redesign.png")
	node.queue_free()
	quit(0)
