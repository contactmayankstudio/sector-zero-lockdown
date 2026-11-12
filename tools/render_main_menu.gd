extends SceneTree

func _init():
	var ps = load("res://scenes/UI/MainMenu.tscn")
	var inst = ps.instantiate()
	root.add_child(inst)
	call_deferred("_render", root)

func _render(win: Window):
	for f in range(6):
		await RenderingServer.frame_post_draw
	var img = win.get_texture().get_image()
	var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/main_menu_preview.png"
	img.save_png(fname)
	print("Saved Main Menu preview: ", fname)
	quit(0)
