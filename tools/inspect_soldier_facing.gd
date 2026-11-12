extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_res.instantiate()
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var head_idx = skel.find_bone("mixamorig_Head")
	var hips_idx = skel.find_bone("mixamorig_Hips")
	print("Hips rest transform: ", skel.get_bone_rest(hips_idx))
	print("Head rest transform: ", skel.get_bone_rest(head_idx))
	soldier.queue_free()
	quit(0)
