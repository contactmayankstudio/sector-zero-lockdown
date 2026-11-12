
extends SceneTree

func _init():
	var sc = load("res://scenes/zombies/models/RealDoomZombie.scn")
	var inst = sc.instantiate()
	var sk = inst.find_child("*Skeleton3D*", true, false) as Skeleton3D
	for bname in ["ValveBiped.Bip01_L_Thigh_8", "ValveBiped.Bip01_R_Thigh_17", "ValveBiped.Bip01_L_UpperArm_78", "ValveBiped.Bip01_R_UpperArm_105"]:
		var b = sk.find_bone(bname)
		if b >= 0:
			print(bname, " rest rot_deg: ", sk.get_bone_rest(b).basis.get_euler() * 180.0 / PI)
	inst.free()
	quit(0)
