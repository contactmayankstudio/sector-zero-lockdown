extends SceneTree
func _init():
    var s = load("res://scenes/environments/RailwayStation.tscn")
    var inst = s.instantiate()
    root.add_child(inst)
    for i in range(10):
        await process_frame
    var img = root.get_texture().get_image()
    img.save_png("tools/preview_railway_render.png")
    print("Rendered tools/preview_railway_render.png")
    quit(0)
