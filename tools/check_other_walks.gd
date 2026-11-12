extends SceneTree
func _init():
    for p in ["res://scenes/zombies/models/RealZombieBiker.scn", "res://scenes/zombies/models/RealZombie6ft.scn", "res://scenes/zombies/models/RealTitanBrute.scn"]:
        var res = load(p)
        var inst = res.instantiate()
        var ap: AnimationPlayer = inst.find_children("*", "AnimationPlayer", true, false)[0]
        var anim = ap.get_animation("walk")
        for t in range(anim.get_track_count()):
            if anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
                print(p.get_file(), " track ", anim.track_get_path(t), " val0=", anim.track_get_key_value(t, 0))
        inst.free()
    quit()
