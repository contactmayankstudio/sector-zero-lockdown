extends SceneTree

func _init():
	print("--- Rendering RailwayStation frame ---")
	var s = load("res://scenes/environments/RailwayStation.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	for i in range(25):
		await process_frame
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/am/targetkill/test_railway_render.png")
	print("Saved test_railway_render.png!")
	quit(0)
