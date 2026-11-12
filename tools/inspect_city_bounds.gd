extends SceneTree

func _init():
    var res = load("res://assets/external/downloads/environments/street_city_7_for_games_free.glb")
    if res:
        var inst = res.instantiate()
        var aabb = AABB()
        var first = true
        for c in inst.find_children("*", "VisualInstance3D"):
            if c is VisualInstance3D:
                var baabb = c.get_aabb()
                if first:
                    aabb = baabb
                    first = false
                else:
                    aabb = aabb.merge(baabb)
        print("street_city_7 bounds:", aabb.position, " size:", aabb.size)
        inst.queue_free()
    quit(0)
