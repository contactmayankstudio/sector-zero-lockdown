extends SceneTree

func _init():
	print("--- COMPARING BONES ---")
	var doc1 = GLTFDocument.new()
	var state1 = GLTFState.new()
	doc1.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state1)
	var scene1 = doc1.generate_scene(state1)
	var skel1: Skeleton3D = scene1.find_children("*", "Skeleton3D", true, false)[0]
	
	var doc2 = GLTFDocument.new()
	var state2 = GLTFState.new()
	doc2.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state2)
	var scene2 = doc2.generate_scene(state2)
	var skel2: Skeleton3D = scene2.find_children("*", "Skeleton3D", true, false)[0]
	
	print("Scary zombie bone count: ", skel1.get_bone_count())
	print("Vitruvian bone count: ", skel2.get_bone_count())
	
	var match_count = 0
	for i in range(skel1.get_bone_count()):
		var bname = skel1.get_bone_name(i)
		# Check if Vitruvian has this bone or clean mixamorig:
		var clean_name = bname.replace("mixamorig_", "mixamorig:").split("_")[0] # e.g. mixamorig_Hips_01 -> mixamorig:Hips
		var found = false
		for j in range(skel2.get_bone_count()):
			var vname = skel2.get_bone_name(j)
			if bname in vname or vname in bname or clean_name in vname:
				found = true
				break
		if found:
			match_count += 1
			
	print("Matching bones: ", match_count, " / ", skel1.get_bone_count())
	print("Sample Scary bones: ")
	for i in range(min(10, skel1.get_bone_count())):
		print("  ", skel1.get_bone_name(i))
	print("Sample Vitruvian bones: ")
	for i in range(min(10, skel2.get_bone_count())):
		print("  ", skel2.get_bone_name(i))
		
	scene1.free()
	scene2.free()
	quit(0)
