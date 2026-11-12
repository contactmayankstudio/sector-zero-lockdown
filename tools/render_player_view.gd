extends SceneTree

func _init():
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	
	for i in range(10):
		await process_frame
		
	var viewport = get_root()
	var img = viewport.get_texture().get_image()
	img.save_png("screenshots/headless_qa_view.png")
	print("Captured screenshot: screenshots/headless_qa_view.png")
	quit(0)
