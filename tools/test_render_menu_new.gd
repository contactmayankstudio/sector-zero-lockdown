@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/UI/MainMenu.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(10):
		await process_frame
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		var p = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/main_menu_new_preview.png"
		img.save_png(p)
		print("Saved menu render to: ", p)
	inst.queue_free()
	quit(0)
