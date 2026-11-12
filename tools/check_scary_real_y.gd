extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    root.add_child(inst)
    var m = inst.find_children("*", "MeshInstance3D", true, false)[0]
    var aabb = m.global_transform * m.mesh.get_aabb()
    print("zombie_scary rendered AABB: ", aabb, " min_y=", aabb.position.y, " max_y=", aabb.position.y + aabb.size.y)
    inst.free()
    quit()
