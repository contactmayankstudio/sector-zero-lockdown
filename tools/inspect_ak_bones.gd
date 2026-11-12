extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/ak74u.tscn") as PackedScene
	var inst = s.instantiate()
	var root_node = Node3D.new()
	root.add_child(root_node)
	root_node.add_child(inst)
	
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	if skel:
		print("Skeleton found! Bone count: ", skel.get_bone_count())
		for i in range(min(15, skel.get_bone_count())):
			print("  Bone ", i, ": ", skel.get_bone_name(i), " pose pos: ", skel.get_bone_pose_position(i), " global_rest pos: ", skel.get_bone_global_rest(i).origin)
	var ap: AnimationPlayer = inst.find_child("AnimationPlayer", true, false)
	if ap:
		print("Animation list: ", ap.get_animation_list())
	
	var m61: MeshInstance3D = inst.find_child("Object_61", true, false)
	if m61:
		print("Object_61 global_position: ", m61.global_position)
		print("Object_61 skin: ", m61.skin != null)
	
	inst.free()
	root_node.free()
	quit(0)
