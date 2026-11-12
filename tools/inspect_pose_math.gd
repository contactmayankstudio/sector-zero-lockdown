extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var anim: AnimationPlayer = inst.find_child("AnimationPlayer", true, false)
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	
	anim.play("BikeRiding")
	anim.seek(0.1, true)
	
	for b_name in ["mixamorig_Hips", "mixamorig_Spine", "mixamorig_Spine1", "mixamorig_Spine2", "mixamorig_LeftArm", "mixamorig_LeftForeArm", "mixamorig_LeftHand", "mixamorig_RightArm", "mixamorig_RightForeArm", "mixamorig_RightHand", "mixamorig_LeftUpLeg", "mixamorig_LeftLeg"]:
		var b_idx = skel.find_bone(b_name)
		if b_idx != -1:
			var rot = skel.get_bone_pose_rotation(b_idx)
			var euler_deg = Vector3(rad_to_deg(rot.get_euler().x), rad_to_deg(rot.get_euler().y), rad_to_deg(rot.get_euler().z))
			print("%s (bone %d): rot quat = %s, euler deg = %s" % [b_name, b_idx, rot, euler_deg])
	quit(0)
