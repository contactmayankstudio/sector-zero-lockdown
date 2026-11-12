extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/RealZombieOffice.scn")
    var inst = res.instantiate()
    var ap: AnimationPlayer = inst.find_children("*", "AnimationPlayer", true, false)[0]
    var anim = ap.get_animation("walk")
    print("RealZombieOffice walk length: ", anim.length, " tracks: ", anim.get_track_count())
    for t in range(anim.get_track_count()):
        var p = anim.track_get_path(t)
        var typ = anim.track_get_type(t)
        if typ == Animation.TYPE_POSITION_3D:
            print("Track ", p, " keys: ", anim.track_get_key_count(t))
            for k in range(min(5, anim.track_get_key_count(t))):
                print("   time=", anim.track_get_key_time(t, k), " val=", anim.track_get_key_value(t, k))
    inst.free()
    quit()
