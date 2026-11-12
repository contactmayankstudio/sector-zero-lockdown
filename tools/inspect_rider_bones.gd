extends SceneTree

func _init():
	print("--- Inspecting RealSoldier ---")
	var soldier_scene = load("res://scenes/characters/RealSoldier.scn")
	if not soldier_scene:
		soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	if not soldier_scene:
		print("FAILED to load RealSoldier")
		quit(1)
		return
	
	var soldier = soldier_scene.instantiate()
	print("Soldier root node: ", soldier.name, " Class: ", soldier.get_class())
	
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	if skel:
		print("Skeleton3D FOUND! Bone count: ", skel.get_bone_count())
		var test_bones = ["mixamorig_Hips", "Hips", "mixamorig_Spine", "Spine", "mixamorig_LeftArm", "LeftArm", "mixamorig_RightArm", "RightArm"]
		for b in test_bones:
			var idx = skel.find_bone(b)
			print("  Bone '", b, "' -> index: ", idx)
	else:
		print("Skeleton3D NOT FOUND! Dumping children:")
		_dump_children(soldier, 1)

	var anim = soldier.find_child("AnimationPlayer", true, false)
	if anim:
		print("AnimationPlayer FOUND: ", anim.name, " active: ", anim.active, " anims: ", anim.get_animation_list())
	var b = load("res://scenes/environments/models/RealCityBuildings8.scn")
	if b:
		var inst = b.instantiate()
		print("RealCityBuildings8 root: ", inst.name)
		for mi in inst.find_children("*", "MeshInstance3D", true, false):
			print("  Mesh: ", mi.name)
			if mi.mesh:
				for s in range(mi.mesh.get_surface_count()):
					var mat = mi.get_active_material(s)
					print("    surf ", s, " mat: ", mat.resource_name if mat else "null", " tex: ", mat.albedo_texture.resource_path if (mat and mat is StandardMaterial3D and mat.albedo_texture) else "none")
	quit(0)

func _dump_children(n: Node, depth: int):
	for c in n.get_children():
		var indent = ""
		for d in range(depth): indent += "  "
		print(indent, c.name, " (", c.get_class(), ")")
		_dump_children(c, depth + 1)
