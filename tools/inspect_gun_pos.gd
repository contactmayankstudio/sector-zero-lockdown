extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/ak74u.tscn") as PackedScene
	var inst = s.instantiate()
	root.add_child(inst)
	
	var ap: AnimationPlayer = inst.find_child("AnimationPlayer", true, false)
	if ap:
		ap.play("IDLE")
		ap.advance(0.1)
		
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	if skel:
		for i in range(skel.get_bone_count()):
			var bname = skel.get_bone_name(i)
			if "gun" in bname.to_lower() or "krinkov" in bname.to_lower() or "43" in bname or "weapon" in bname.to_lower() or "hand" in bname.to_lower():
				var global_bone_trans = skel.global_transform * skel.get_bone_global_pose(i)
				print("Bone ", i, " (", bname, ") global pos: ", global_bone_trans.origin)
	
	inst.free()
	quit(0)
