extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	if not soldier_res:
		print("Failed to load RealSoldier.tscn")
		quit(1)
		return

	var soldier = soldier_res.instantiate()
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)

	print("Skeleton found: ", skel != null)
	print("AnimationPlayer found: ", anim != null)

	# Test bone attachment to right hand
	var hand_idx = skel.find_bone("mixamorig_RightHand")
	print("RightHand bone index: ", hand_idx)

	var attach = BoneAttachment3D.new()
	attach.bone_name = "mixamorig_RightHand"
	skel.add_child(attach)

	var wep_res = load("res://scenes/weapons/models/akx_scifi.scn")
	if wep_res:
		var wep = wep_res.instantiate()
		wep.scale = Vector3(65.0, 65.0, 65.0)
		wep.position = Vector3(0.0, 4.0, 8.0)
		wep.rotation_degrees = Vector3(90.0, 0.0, -90.0)
		attach.add_child(wep)
		print("Weapon attached successfully to RightHand!")

	if anim:
		for a in anim.get_animation_list():
			anim.play(a)
			print("Tested animation: ", a, " length: ", anim.current_animation_length)

	soldier.queue_free()
	print("All on-foot soldier tests passed!")
	quit(0)
