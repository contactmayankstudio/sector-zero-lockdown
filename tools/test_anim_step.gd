extends SceneTree

func _init():
	var soldier_scene = load("res://scenes/characters/RealSoldier.scn")
	var soldier = soldier_scene.instantiate()
	root.add_child(soldier)
	
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	
	var arm_idx = skel.find_bone("mixamorig_LeftArm")
	print("Initial LeftArm pose rotation: ", skel.get_bone_pose_rotation(arm_idx))
	
	if anim:
		anim.play("BikeRiding")
		print("Started BikeRiding anim. Current anim: ", anim.current_animation)
	
	# Step a frame
	anim.advance(0.1)
	print("LeftArm pose rotation after anim advance(0.1): ", skel.get_bone_pose_rotation(arm_idx))
	var euler = skel.get_bone_pose_rotation(arm_idx).get_euler()
	print("LeftArm Euler degrees: (", rad_to_deg(euler.x), ", ", rad_to_deg(euler.y), ", ", rad_to_deg(euler.z), ")")
	
	quit(0)
