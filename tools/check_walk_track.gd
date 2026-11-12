extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    var ap = inst.find_children("*", "AnimationPlayer", true, false)[0]
    var walk = ap.get_animation("walk")
    for t in range(walk.get_track_count()):
        if walk.track_get_type(t) == Animation.TYPE_POSITION_3D:
            print("Walk pos track: ", walk.track_get_path(t), " val 0: ", walk.track_get_key_value(t, 0))
    quit(0)
