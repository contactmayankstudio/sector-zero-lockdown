extends SceneTree

var frame_count = 0
var scene_inst = null

func _process(delta):
    frame_count += 1
    if frame_count == 1:
        var s = load("res://scenes/environments/UrbanStreet.tscn")
        scene_inst = s.instantiate()
        root.add_child(scene_inst)
    elif frame_count == 5:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        img.save_png("preview_gameplay_grove.png")
        print("Saved preview_gameplay_grove.png")
        quit(0)
