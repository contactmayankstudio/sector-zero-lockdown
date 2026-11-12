@tool
extends SceneTree

func _init():
	print("=== CHECKING vitruvian FACING DIRECTION ===")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	doc.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state)
	var scene = doc.generate_scene(state)
	
	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var b_hips = skel.find_bone("mixamorig_Hips")
	var b_head = skel.find_bone("mixamorig_Head")
	var b_toe = skel.find_bone("mixamorig_LeftToeBase")
	
	print("Vitruvian rest bones:")
	print("  Hips pos: ", skel.get_bone_pose(b_hips).origin)
	print("  Head pos: ", skel.get_bone_pose(b_head).origin)
	print("  LeftToe pos: ", skel.get_bone_pose(b_toe).origin)
	
	var ap: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
	var anim = ap.get_animation("Walk")
	for t in range(anim.get_track_count()):
		var p = anim.track_get_path(t)
		if "Hips" in str(p) and anim.track_get_type(t) == Animation.TYPE_ROTATION_3D:
			print("Hips rotation key 0: ", anim.track_get_key_value(t, 0))
			var q: Quaternion = anim.track_get_key_value(t, 0)
			print("Hips rotation Euler: ", q.get_euler())
			
	scene.queue_free()
	quit(0)
