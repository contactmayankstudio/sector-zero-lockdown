extends SceneTree

func _init():
	var soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	get_root().add_child(soldier)
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	print("Anim active before: ", anim.is_active() if anim else "none")
	if anim:
		anim.active = false
	for bname in ["mixamorig_LeftShoulder", "mixamorig_RightShoulder", "mixamorig_LeftArm", "mixamorig_RightArm", "mixamorig_LeftForeArm", "mixamorig_RightForeArm", "mixamorig_LeftHand", "mixamorig_RightHand"]:
		var idx = skel.find_bone(bname)
		if idx != -1:
			var p_idx = skel.get_bone_parent(idx)
			var p_name = skel.get_bone_name(p_idx) if p_idx != -1 else "None"
			print(bname, " (", idx, ") parent=", p_name, " rest_quat=", skel.get_bone_rest(idx).basis.get_rotation_quaternion(), " euler_deg=", skel.get_bone_rest(idx).basis.get_euler() * 180.0 / PI)
	quit(0)
