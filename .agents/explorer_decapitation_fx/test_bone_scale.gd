extends SceneTree

func _init():
	var res = load("res://scenes/zombies/models/RealDoomZombie.scn")
	var inst = res.instantiate()
	var skels = inst.find_children("*", "Skeleton3D", true, false)
	var sk: Skeleton3D = skels[0]
	var head_idx = sk.find_bone("ValveBiped.Bip01_Head1_51")
	print("Initial head pose scale: ", sk.get_bone_pose_scale(head_idx))
	sk.set_bone_pose_scale(head_idx, Vector3.ZERO)
	print("After zero scale: ", sk.get_bone_pose_scale(head_idx))
	print("Global pose of head: ", sk.get_bone_global_pose(head_idx).basis.get_scale())
	
	# Also test child bone
	var jaw_idx = sk.find_bone("jaw_part01_md_27")
	print("Jaw global pose scale: ", sk.get_bone_global_pose(jaw_idx).basis.get_scale())
	inst.free()
	quit()
