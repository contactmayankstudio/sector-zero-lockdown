extends SceneTree

func _init():
	print("Converting clean AK-74u to compressed .scn...")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("assets/3d/weapons/downloaded/ak74u_perfect.glb", state)
	if err != OK:
		printerr("ERROR appending GLTF: ", err)
		quit(1)
		return
	var scene = doc.generate_scene(state)
	if not scene:
		printerr("ERROR generating scene")
		quit(1)
		return
		
	_set_owner_recursive(scene, scene)
	
	var packed = PackedScene.new()
	packed.pack(scene)
	var dst = "res://scenes/weapons/models/AK74uClean.scn"
	var save_err = ResourceSaver.save(packed, dst, ResourceSaver.FLAG_COMPRESS)
	print("Saved clean AK-74u: ", dst, " err code: ", save_err)
	scene.free()
	quit(0)

func _set_owner_recursive(node: Node, root_node: Node):
	for child in node.get_children():
		child.owner = root_node
		_set_owner_recursive(child, root_node)
