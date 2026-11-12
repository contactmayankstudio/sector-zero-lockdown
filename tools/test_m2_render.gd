extends SceneTree

var frame_count = 0
var scene_inst = null

func _process(delta):
    frame_count += 1
    if frame_count == 1:
        var t0 = Time.get_ticks_msec()
        var s = load("res://scenes/environments/AirportServiceRoad.tscn")
        print("Loaded AirportServiceRoad in ", Time.get_ticks_msec() - t0, " ms")
        scene_inst = s.instantiate()
        root.add_child(scene_inst)
    elif frame_count == 5:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        img.save_png("preview_m2_city.png")
        print("Saved preview_m2_city.png")
        quit(0)
