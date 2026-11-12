extends SceneTree

func _init():
	var res = load("res://scenes/zombies/models/zombie_normal.tscn")
	if not res:
		res = load("res://assets/zombies/RealisticZombie.tscn")
	var inst = res.instantiate()
	root.add_child(inst)
	
	var anims = inst.find_children("*", "AnimationPlayer", true, false)
	var skels = inst.find_children("*", "Skeleton3D", true, false)
	print("Anims: ", anims.size(), " Skels: ", skels.size())
	if not anims.is_empty() and not skels.is_empty():
		var ap: AnimationPlayer = anims[0]
		var sk: Skeleton3D = skels[0]
		var h_idx = sk.find_bone("Head")
		if h_idx < 0:
			h_idx = sk.find_bone("ValveBiped.Bip01_Head1_51")
		if h_idx < 0:
			h_idx = sk.find_bone("mixamorig_Head_06")
		print("Head index: ", h_idx, " name: ", sk.get_bone_name(h_idx) if h_idx >= 0 else "N/A")
		
		# Check if animations have scale tracks
		for anim_name in ap.get_animation_list():
			var anim = ap.get_animation(anim_name)
			var has_scale = false
			for t in range(anim.get_track_count()):
				if anim.track_get_type(t) == Animation.TYPE_SCALE_3D:
					has_scale = true
			print("Anim '", anim_name, "' has scale tracks: ", has_scale)
			
		# Test playing anim and setting bone scale
		sk.set_bone_pose_scale(h_idx, Vector3.ZERO)
		if ap.get_animation_list().size() > 0:
			ap.play(ap.get_animation_list()[0])
			ap.advance(0.1)
			print("After ap.advance(0.1), bone scale is: ", sk.get_bone_pose_scale(h_idx))
	
	inst.free()
	quit()
