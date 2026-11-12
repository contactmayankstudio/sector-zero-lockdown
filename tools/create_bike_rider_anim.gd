extends SceneTree

func _init():
	var soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	get_root().add_child(soldier)
	var anim_player: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	
	print("Checking existing animations:")
	for anim_name in anim_player.get_animation_list():
		print("  Anim: ", anim_name)
		
	# Let's inspect Mixamo arm bone transforms in rest
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var r_arm = skel.find_bone("mixamorig_RightArm")
	print("LeftArm rest: ", skel.get_bone_rest(l_arm).basis.get_euler())
	print("RightArm rest: ", skel.get_bone_rest(r_arm).basis.get_euler())
	
	quit(0)
