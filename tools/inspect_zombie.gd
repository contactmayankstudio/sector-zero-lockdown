@tool
extends SceneTree

func _init():
	print("=== INSPECTING zombie_scary.scn ===")
	var res = load("res://scenes/zombies/models/zombie_scary.scn")
	if not res:
		print("ERROR: Could not load zombie_scary.scn")
		quit(1)
		return
	var inst = res.instantiate()
	root.add_child(inst)
	
	print("Root name: ", inst.name)
	print("Root transform: pos=", inst.position, " rot=", inst.rotation, " scale=", inst.scale)
	
	_print_tree(inst, "  ")
	
	var skel: Skeleton3D = inst.find_child("*Skeleton3D*", true, false)
	if skel:
		print("\n--- SKELETON INFO ---")
		print("Bone count: ", skel.get_bone_count())
		for bname in ["mixamorig_Head_06", "mixamorig:Head", "Head", "mixamorig_LeftToeBase_060", "mixamorig_RightToeBase_065", "mixamorig_Hips_01", "mixamorig:Hips"]:
			var b = skel.find_bone(bname)
			if b != -1:
				var gpose = skel.global_transform * skel.get_bone_global_pose(b)
				print("Bone '", bname, "': global pos = ", gpose.origin)
	
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		print("\n--- MESH: ", m.name, " ---")
		print("Mesh visible: ", m.visible)
		print("Global transform: pos=", m.global_position, " rot=", m.global_rotation, " scale=", m.global_transform.basis.get_scale())
		if m.mesh:
			var aabb = m.get_aabb()
			print("Local AABB: ", aabb)
			var g_aabb = m.global_transform * aabb
			print("Global AABB: ", g_aabb)
			
	var aps = inst.find_children("*", "AnimationPlayer", true, false)
	for ap in aps:
		print("\n--- ANIMATION PLAYER: ", ap.name, " ---")
		for lib_name in ap.get_animation_library_list():
			var lib = ap.get_animation_library(lib_name)
			print("Lib '", lib_name, "': ", lib.get_animation_list())
			
	inst.queue_free()
	print("=== DONE INSPECTION ===")
	quit(0)

func _print_tree(node: Node, indent: String):
	for c in node.get_children():
		var extra = ""
		if c is Node3D:
			extra = " pos=" + str(c.position) + " rot=" + str(c.rotation) + " scale=" + str(c.scale)
		print(indent, c.name, " (", c.get_class(), ")", extra)
		_print_tree(c, indent + "  ")
