@tool
extends SceneTree

func _init():
	print("=== CHECKING FACING DIRECTION OF zombie_scary.scn ===")
	var res = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = res.instantiate()
	root.add_child(inst)
	
	var skel: Skeleton3D = inst.find_child("*Skeleton3D*", true, false)
	var ap: AnimationPlayer = inst.find_child("*AnimationPlayer*", true, false)
	
	var b_head = skel.find_bone("mixamorig_Head_06")
	var b_hips = skel.find_bone("mixamorig_Hips_01")
	var b_toe_l = skel.find_bone("mixamorig_LeftToeBase_060")
	var b_toe_r = skel.find_bone("mixamorig_RightToeBase_065")
	
	print("\n--- REST POSE ---")
	var h_pos = (skel.global_transform * skel.get_bone_global_pose(b_head)).origin
	var hips_pos = (skel.global_transform * skel.get_bone_global_pose(b_hips)).origin
	var tl_pos = (skel.global_transform * skel.get_bone_global_pose(b_toe_l)).origin
	print("Hips global Z: ", hips_pos.z)
	print("Head global Z: ", h_pos.z)
	print("Toe Left global Z: ", tl_pos.z)
	if tl_pos.z < hips_pos.z:
		print(">> REST POSE: Toes are at -Z relative to hips -> FACING -Z (GODOT FORWARD)")
	else:
		print(">> REST POSE: Toes are at +Z relative to hips -> FACING +Z (GODOT BACKWARD)")
		
	print("\n--- IN WALK ANIMATION ---")
	ap.play("walk")
	ap.advance(0.1)
	h_pos = (skel.global_transform * skel.get_bone_global_pose(b_head)).origin
	hips_pos = (skel.global_transform * skel.get_bone_global_pose(b_hips)).origin
	tl_pos = (skel.global_transform * skel.get_bone_global_pose(b_toe_l)).origin
	print("Hips global Z: ", hips_pos.z)
	print("Head global Z: ", h_pos.z)
	print("Toe Left global Z: ", tl_pos.z)
	if tl_pos.z < hips_pos.z:
		print(">> WALK ANIM: Toes are at -Z relative to hips -> FACING -Z (GODOT FORWARD)")
	else:
		print(">> WALK ANIM: Toes are at +Z relative to hips -> FACING +Z (GODOT BACKWARD)")
		
	inst.queue_free()
	quit(0)
