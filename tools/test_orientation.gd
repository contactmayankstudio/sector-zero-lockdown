@tool
extends SceneTree

func _init():
	print("=== CHECKING SCARY ZOMBIE ORIENTATION & SCALE ===")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state)
	if err != OK:
		print("Error loading: ", err)
		quit(1)
		return
	var scene = doc.generate_scene(state)
	root.add_child(scene)
	
	print("Raw scene name: ", scene.name)
	print("Raw scene scale: ", scene.scale, " rot: ", scene.rotation)
	
	var skel: Skeleton3D = scene.find_child("*Skeleton3D*", true, false)
	if skel:
		for bname in ["mixamorig_Head_06", "mixamorig_Hips_01", "mixamorig_LeftToeBase_060", "mixamorig_LeftFoot_059"]:
			var b = skel.find_bone(bname)
			if b != -1:
				var lpose = skel.get_bone_pose(b)
				var gpose = skel.global_transform * skel.get_bone_global_pose(b)
				print("Raw bone '", bname, "':")
				print("   pose pos: ", lpose.origin)
				print("   global pos: ", gpose.origin)
				
		var b_head = skel.find_bone("mixamorig_Head_06")
		var b_hips = skel.find_bone("mixamorig_Hips_01")
		var b_lfoot = skel.find_bone("mixamorig_LeftToeBase_060")
		var b_rfoot = skel.find_bone("mixamorig_RightToeBase_065")
		
		var gh = (skel.global_transform * skel.get_bone_global_pose(b_head)).origin
		var gf = (skel.global_transform * skel.get_bone_global_pose(b_lfoot)).origin
		print("\nRAW GLOBAL STATS (with scale=", scene.scale, "):")
		print("Head global pos: ", gh)
		print("Foot global pos: ", gf)
		print("Total height (head.y - foot.y): ", gh.y - gf.y)
		print("Head Z vs Hips Z: head.z = ", gh.z, " hips.z = ", (skel.global_transform * skel.get_bone_global_pose(b_hips)).origin.z)
		print("Foot Z vs Hips Z: foot.z = ", gf.z)
	
	scene.queue_free()
	quit(0)
