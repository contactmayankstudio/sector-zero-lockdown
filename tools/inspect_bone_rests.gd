extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	for b_name in ["mixamorig_LeftShoulder", "mixamorig_RightShoulder", "mixamorig_LeftArm", "mixamorig_RightArm", "mixamorig_LeftFoot", "mixamorig_RightFoot"]:
		var idx = skel.find_bone(b_name)
		if idx != -1:
			var rest = skel.get_bone_rest(idx)
			print("[%d] %s parent: %s rest pos: %s, rest rot euler: %s" % [
				idx, b_name, skel.get_bone_name(skel.get_bone_parent(idx)), rest.origin,
				Vector3(rad_to_deg(rest.basis.get_euler().x), rad_to_deg(rest.basis.get_euler().y), rad_to_deg(rest.basis.get_euler().z))
			])
	quit(0)
