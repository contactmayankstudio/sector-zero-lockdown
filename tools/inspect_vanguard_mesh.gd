extends SceneTree
func _init():
    var scn = load("res://scenes/characters/RealSoldier.scn")
    var inst = scn.instantiate()
    var mesh_inst = inst.find_child("vanguard_Mesh", true, false)
    if mesh_inst:
        print("vanguard_Mesh skeleton path: ", mesh_inst.skeleton)
        var skel = mesh_inst.get_node_or_null(mesh_inst.skeleton)
        print("Resolved skeleton node: ", skel)
        print("Skin: ", mesh_inst.skin)
        if mesh_inst.skin:
            print("Skin bind count: ", mesh_inst.skin.get_bind_count())
            for i in range(min(5, mesh_inst.skin.get_bind_count())):
                print("  bind ", i, ": name=", mesh_inst.skin.get_bind_name(i), " bone=", mesh_inst.skin.get_bind_bone(i))
    quit(0)
