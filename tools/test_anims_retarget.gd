extends SceneTree

func _init():
	print("--- TEST ANIMATION TRACK RETARGETING ---")
	var doc1 = GLTFDocument.new()
	var state1 = GLTFState.new()
	doc1.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state1)
	var vit = doc1.generate_scene(state1)
	var ap: AnimationPlayer = vit.find_children("*", "AnimationPlayer", true, false)[0]
	
	var doc2 = GLTFDocument.new()
	var state2 = GLTFState.new()
	doc2.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state2)
	var scary = doc2.generate_scene(state2)
	var skel: Skeleton3D = scary.find_children("*", "Skeleton3D", true, false)[0]
	
	# Build bone map: vitruvian bone name -> scary bone name
	var bone_map = {}
	for bi in range(skel.get_bone_count()):
		var s_name = skel.get_bone_name(bi)
		# e.g. mixamorig_Hips_01 -> base is mixamorig_Hips
		var parts = s_name.split("_")
		var base_name = s_name
		if parts.size() >= 2:
			# If last part is numeric (e.g. 01, 02)
			if parts[-1].is_valid_int():
				base_name = s_name.substr(0, s_name.rfind("_"))
		bone_map[base_name] = s_name
	
	print("Bone map entries: ", bone_map.size())
	for k in ["mixamorig_Hips", "mixamorig_Spine", "mixamorig_Head", "mixamorig_LeftArm", "mixamorig_RightHand"]:
		print("  ", k, " -> ", bone_map.get(k, "NOT FOUND"))
		
	# Check tracks in "Walk"
	var walk_anim: Animation = ap.get_animation("Walk")
	print("Walk track count: ", walk_anim.get_track_count())
	var mapped_tracks = 0
	for t in range(walk_anim.get_track_count()):
		var path_str = String(walk_anim.track_get_path(t))
		# Usually "Skeleton3D:mixamorig_Hips" or "%GeneralSkeleton:mixamorig_Hips" or similar
		var subname = walk_anim.track_get_path(t).get_subname(0)
		if subname in bone_map:
			mapped_tracks += 1
	print("Mapped tracks in Walk: ", mapped_tracks, " / ", walk_anim.get_track_count())
	
	vit.free()
	scary.free()
	quit(0)
