@tool
extends SceneTree

func _init():
	print("=== VERIFYING ZOMBIE WALK CYCLE FACING ===")
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var z_inst = z_scene.instantiate()
	root.add_child(z_inst)
	
	for i in range(3):
		await process_frame
		
	var skel: Skeleton3D = z_inst.find_child("*Skeleton3D*", true, false)
	var ap: AnimationPlayer = z_inst.find_child("*AnimationPlayer*", true, false)
	
	var b_head = skel.find_bone("mixamorig_Head_06")
	var b_spine = skel.find_bone("mixamorig_Spine2_04")
	var b_hips = skel.find_bone("mixamorig_Hips_01")
	var b_toe_l = skel.find_bone("mixamorig_LeftToeBase_060")
	var b_toe_r = skel.find_bone("mixamorig_RightToeBase_065")
	
	var dummy_player = Node3D.new()
	dummy_player.position = Vector3(0, 0, -10)
	root.add_child(dummy_player)
	z_inst.player = dummy_player
	
	ap.play("walk")
	
	print("Frame by frame check (0.0s to 1.0s):")
	for step in range(11):
		var anim_time = step * 0.1
		ap.seek(anim_time, true)
		for i in range(2):
			await process_frame
			
		var gh = (skel.global_transform * skel.get_bone_global_pose(b_head)).origin
		var gsp = (skel.global_transform * skel.get_bone_global_pose(b_spine)).origin
		var ghip = (skel.global_transform * skel.get_bone_global_pose(b_hips)).origin
		var gtl = (skel.global_transform * skel.get_bone_global_pose(b_toe_l)).origin
		var gtr = (skel.global_transform * skel.get_bone_global_pose(b_toe_r)).origin
		
		var avg_feet_z = (gtl.z + gtr.z) * 0.5
		var forward_foot_z = min(gtl.z, gtr.z)
		var back_foot_z = max(gtl.z, gtr.z)
		
		print("t=%.1f | Head Z: %.3f | Spine Z: %.3f | Hips Z: %.3f | FwdFoot Z: %.3f | BackFoot Z: %.3f" % [
			anim_time, gh.z, gsp.z, ghip.z, forward_foot_z, back_foot_z
		])
		
	dummy_player.queue_free()
	z_inst.queue_free()
	quit(0)
