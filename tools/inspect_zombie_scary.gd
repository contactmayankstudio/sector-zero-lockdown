extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    print("zombie_scary children:")
    for c in inst.get_children():
        print("  ", c.name, " (", c.get_class(), ") pos: ", c.position)
        if c is Skeleton3D:
            print("    Skeleton bones: ", c.get_bone_count())
            for b in range(min(5, c.get_bone_count())):
                print("      bone ", b, ": ", c.get_bone_name(b), " pose pos: ", c.get_bone_pose_position(b))
        elif c is MeshInstance3D and c.mesh:
            print("    mesh aabb: ", c.mesh.get_aabb())
    var ap = inst.find_children("*", "AnimationPlayer", true, false)
    if not ap.is_empty():
        print("Anims: ", ap[0].get_animation_list())
        for a_name in ["walk", "idle", "attack"]:
            if ap[0].has_animation(a_name):
                var a = ap[0].get_animation(a_name)
                print("Anim ", a_name, " tracks: ", a.get_track_count())
                for t in range(a.get_track_count()):
                    print("  track ", t, ": ", a.track_get_path(t), " type: ", a.track_get_type(t))
                    if a.track_get_key_count(t) > 0:
                        print("    key 0: ", a.track_get_key_value(t, 0))
    quit(0)
