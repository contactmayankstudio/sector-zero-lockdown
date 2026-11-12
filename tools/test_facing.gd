extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_res.instantiate()
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	# Check nose/face position relative to head
	var head_idx = skel.find_bone("mixamorig_Head")
	var nose_idx = skel.find_bone("mixamorig_HeadTop_End")
	print("Head rest pos: ", skel.get_bone_rest(head_idx).origin)
	print("HeadTop_End rest pos: ", skel.get_bone_rest(nose_idx).origin)
	# Check foot direction (toe vs foot)
	var foot_idx = skel.find_bone("mixamorig_LeftFoot")
	var toe_idx = skel.find_bone("mixamorig_LeftToeBase")
	print("LeftFoot rest: ", skel.get_bone_rest(foot_idx).origin)
	print("LeftToeBase rest: ", skel.get_bone_rest(toe_idx).origin)
	soldier.queue_free()
	quit(0)
