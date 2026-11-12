@tool
extends SceneTree

func _init():
	print("=== CHECKING ANIMATIONS AND ROOT BONE TRANSFORMS ===")
	var res = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = res.instantiate()
	root.add_child(inst)
	
	var ap: AnimationPlayer = inst.find_child("*AnimationPlayer*", true, false)
	var skel: Skeleton3D = inst.find_child("*Skeleton3D*", true, false)
	
	if ap and skel:
		var anim = ap.get_animation("walk")
		if anim:
			print("Walk anim length: ", anim.length, " track count: ", anim.get_track_count())
			for t in range(anim.get_track_count()):
				var path = anim.track_get_path(t)
				if "Hips" in str(path) or "root" in str(path).to_lower():
					print("Track ", t, ": ", path, " type: ", anim.track_get_type(t))
					if anim.track_get_key_count(t) > 0:
						print("   Key 0: time=", anim.track_get_key_time(t, 0), " val=", anim.track_get_key_value(t, 0))
						
			# Let's test playing the animation at t=0 and t=0.5 and check bone global transforms!
			ap.play("walk")
			ap.advance(0.0)
			
			var b_head = skel.find_bone("mixamorig_Head_06")
			var b_hips = skel.find_bone("mixamorig_Hips_01")
			var b_lfoot = skel.find_bone("mixamorig_LeftToeBase_060")
			
			print("\nAt t=0.0 in walk animation:")
			var h_pos = skel.global_transform * skel.get_bone_global_pose(b_head)
			var hips_pos = skel.global_transform * skel.get_bone_global_pose(b_hips)
			var f_pos = skel.global_transform * skel.get_bone_global_pose(b_lfoot)
			print("Head world pos: ", h_pos.origin)
			print("Hips world pos: ", hips_pos.origin)
			print("Foot world pos: ", f_pos.origin)
			print("Height: ", h_pos.origin.y - f_pos.origin.y)
			
			ap.advance(0.45)
			print("\nAt t=0.45 in walk animation:")
			h_pos = skel.global_transform * skel.get_bone_global_pose(b_head)
			hips_pos = skel.global_transform * skel.get_bone_global_pose(b_hips)
			f_pos = skel.global_transform * skel.get_bone_global_pose(b_lfoot)
			print("Head world pos: ", h_pos.origin)
			print("Hips world pos: ", hips_pos.origin)
			print("Foot world pos: ", f_pos.origin)
			print("Height: ", h_pos.origin.y - f_pos.origin.y)
			
	inst.queue_free()
	quit(0)
