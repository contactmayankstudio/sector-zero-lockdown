extends SceneTree
func _init():
    var scn = load("res://scenes/characters/RealSoldier.scn")
    var inst = scn.instantiate()
    var skel = inst.find_child("Skeleton3D", true, false)
    var l_arm = skel.find_bone("mixamorig_LeftArm")
    var r_arm = skel.find_bone("mixamorig_RightArm")
    print("LeftArm rest basis: ", skel.get_bone_rest(l_arm).basis)
    print("RightArm rest basis: ", skel.get_bone_rest(r_arm).basis)
    var l_sh = skel.find_bone("mixamorig_LeftShoulder")
    var r_sh = skel.find_bone("mixamorig_RightShoulder")
    print("LeftShoulder rest basis: ", skel.get_bone_rest(l_sh).basis)
    print("RightShoulder rest basis: ", skel.get_bone_rest(r_sh).basis)
    quit(0)
