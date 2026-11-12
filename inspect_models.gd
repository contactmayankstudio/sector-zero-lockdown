
extends SceneTree
func _init():
    var s = load("res://scenes/characters/RealSoldier.tscn")
    if s:
        var inst = s.instantiate()
        print("RealSoldier position:", inst.position, "scale:", inst.scale)
        var aabb = AABB()
        var first = true
        for mi in inst.find_children("*", "VisualInstance3D", true, false):
            var c_aabb = mi.get_aabb()
            if first:
                aabb = c_aabb
                first = false
            else:
                aabb = aabb.merge(c_aabb)
        print("RealSoldier AABB:", aabb, "size:", aabb.size)
    quit(0)
