extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    var meshes = inst.find_children("*", "MeshInstance3D", true, false)
    for m in meshes:
        print("m.name=", m.name, " scale=", m.scale, " basis.scale=", m.transform.basis.get_scale())
    inst.free()
    quit()
