extends SceneTree
func _init():
    var s = load("res://scenes/environments/RailwayStation.tscn")
    var inst = s.instantiate()
    root.add_child(inst)
    for c in inst.find_children("*", "Camera3D", true, false):
        print("Camera: ", c.get_path(), " pos: ", c.global_position, " current: ", c.current)
    quit(0)
