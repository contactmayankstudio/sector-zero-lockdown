extends SceneTree

func _init():
	var soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	root.add_child(soldier)
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	
	print("--- SKELETON BONE TREE & REST POSES ---")
	for i in range(skel.get_bone_count()):
		var b_name = skel.get_bone_name(i)
		var p_idx = skel.get_bone_parent(i)
		var p_name = skel.get_bone_name(p_idx) if p_idx != -1 else "ROOT"
		var rest = skel.get_bone_rest(i)
		if "Arm" in b_name or "Hand" in b_name or "Leg" in b_name or "Foot" in b_name or "Spine" in b_name or "Hips" in b_name:
			print("Bone [%2d] %-24s parent=[%2d] %-20s pos=%s rot_euler=%s" % [
				i, b_name, p_idx, p_name, rest.origin, rest.basis.get_euler()
			])
	soldier.queue_free()
	quit(0)
