@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/models/RealVelociraptor.scn")
	var inst = scn.instantiate()
	get_root().add_child(inst)
	inst.global_position = Vector3.ZERO
	inst.global_rotation = Vector3.ZERO
	
	print("=== VELOCIRAPTOR GLOBAL BONE & MESH POSITIONS ===")
	var skel: Skeleton3D = inst.find_children("*", "Skeleton3D", true, false)[0]
	
	# Compute global transforms of all bones
	for b_name in ["jaw_17", "neck_18", "head_16", "tail_11", "tail.003_8", "toe1a.l_20", "foot.l_25", "thigh.l_27"]:
		var b_idx = skel.find_bone(b_name)
		if b_idx >= 0:
			var global_pose = skel.global_transform * skel.get_bone_global_pose(b_idx)
			print("Bone '", b_name, "' GLOBAL origin: ", global_pose.origin)
			
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		var aabb = m.get_aabb()
		var g_center = m.global_transform * aabb.get_center()
		var g_min = m.global_transform * aabb.position
		var g_max = m.global_transform * (aabb.position + aabb.size)
		if "raptorLPBody" in m.get_parent().name:
			print("Main Body Mesh '", m.name, "' GLOBAL min: ", g_min, " max: ", g_max, " center: ", g_center)
			
	inst.free()
	quit(0)
