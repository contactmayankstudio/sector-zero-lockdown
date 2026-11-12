extends SceneTree

func _init():
	var soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	get_root().add_child(soldier)
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var attach = BoneAttachment3D.new()
	attach.bone_name = "mixamorig_RightHand"
	skel.add_child(attach)
	var wep_scene = load("res://scenes/weapons/models/akx_scifi.scn")
	var wep = wep_scene.instantiate()
	wep.scale = Vector3(65.0, 65.0, 65.0)
	wep.position = Vector3(0.0, 4.0, 8.0)
	wep.rotation_degrees = Vector3(90.0, 0.0, -90.0)
	attach.add_child(wep)
	
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	if anim:
		anim.play("Idle")
		anim.advance(0.1)
		
	# Check global forward of weapon
	var wep_fwd = -wep.global_transform.basis.z.normalized()
	var soldier_fwd = -soldier.global_transform.basis.z.normalized()
	print("Soldier forward: ", soldier_fwd)
	print("Weapon forward: ", wep_fwd)
	print("Forward dot product: ", soldier_fwd.dot(wep_fwd))
	
	soldier.queue_free()
	quit(0)
