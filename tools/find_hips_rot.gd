extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var skel = s.find_child("Skeleton3D", true, false) as Skeleton3D
	var hips = skel.find_bone("mixamorig_Hips")
	var spine = skel.find_bone("mixamorig_Spine")
	var head = skel.find_bone("mixamorig_Head")

	print("With current Hips pose rot:")
	var head_trans = skel.get_bone_global_pose(head)
	var hips_trans = skel.get_bone_global_pose(hips)
	print("  Hips global pose:", hips_trans.origin)
	print("  Head global pose:", head_trans.origin)
	print("  Head - Hips diff:", head_trans.origin - hips_trans.origin)

	# Try different rotations for Hips
	var candidates = [
		Quaternion.IDENTITY,
		Quaternion(0, 0.707107, 0.707107, 0),
		Quaternion(Vector3.RIGHT, deg_to_rad(90.0)),
		Quaternion(Vector3.RIGHT, deg_to_rad(-90.0)),
		Quaternion(Vector3.RIGHT, deg_to_rad(180.0)),
		Quaternion(Vector3.UP, deg_to_rad(180.0)) * Quaternion(Vector3.RIGHT, deg_to_rad(90.0)),
	]
	for idx in range(candidates.size()):
		var q = candidates[idx]
		skel.set_bone_pose_rotation(hips, q)
		var h_pos = skel.get_bone_global_pose(head).origin
		var hip_pos = skel.get_bone_global_pose(hips).origin
		var diff = h_pos - hip_pos
		print("Candidate", idx, "q:", q, "diff (Head - Hips):", diff)

	quit(0)
