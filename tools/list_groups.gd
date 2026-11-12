extends SceneTree

func _init():
	var scn = load("res://scenes/environments/models/road_pack.scn")
	var inst = scn.instantiate()
	# The root has Sketchfab_model -> root -> GLTF_SceneRootNode -> 49ffd578610c4c3f9a2207ac8f939fe4_fbx_81 -> RootNode_80
	var root_node = inst.find_child("RootNode_80", true, false)
	if not root_node:
		root_node = inst
	print("RootNode children count: ", root_node.get_child_count())
	for c in root_node.get_children():
		var meshes = c.find_children("*", "MeshInstance3D", true, false)
		print("Group: ", c.name, " (", c.get_class(), ") has ", meshes.size(), " meshes. Transform: ", c.transform)
	inst.free()
	quit(0)
