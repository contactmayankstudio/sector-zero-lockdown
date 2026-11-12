extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var anim: AnimationPlayer = inst.find_child("AnimationPlayer", true, false)
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	
	var left_arm = skel.find_bone("mixamorig_LeftArm")
	var right_arm = skel.find_bone("mixamorig_RightArm")
	print("Initial LeftArm rot: ", skel.get_bone_pose_rotation(left_arm))
	
	anim.play("BikeRiding")
	print("Played BikeRiding. Current animation: ", anim.current_animation)
	
	# Seek animation with update=true
	anim.seek(0.1, true)
	
	print("After seek(0.1, true):")
	print("LeftArm rot: ", skel.get_bone_pose_rotation(left_arm))
	print("RightArm rot: ", skel.get_bone_pose_rotation(right_arm))
	print("Hips rot: ", skel.get_bone_pose_rotation(skel.find_bone("mixamorig_Hips")))
	
	# Check track paths
	var lib = anim.get_animation_library("")
	var a = lib.get_animation("BikeRiding")
	for t in range(a.get_track_count()):
		var path = a.track_get_path(t)
		var np_node = NodePath(str(path).split(":")[0])
		var resolved = anim.get_node_or_null(np_node)
		var root_resolved = inst.get_node_or_null(np_node)
		var subname = str(path).split(":")[1]
		print("Track %d path: %s | from anim: %s | from inst: %s | bone: %s" % [t, str(path), resolved, root_resolved, subname])
	
	quit(0)
