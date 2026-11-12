extends SceneTree

func _init():
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var err = gltf.append_from_file("res://assets/3d/weapons/negev_ng7/scene.gltf", state)
	if err != OK:
		print("Failed to parse GLTF")
		quit(1)
		return
		
	var node = gltf.generate_scene(state)
	
	# Create a proper Node3D wrapper
	var root = Node3D.new()
	root.name = "negev_ng7"
	root.add_child(node)
	node.owner = root
	
	# Scale it down, models from sketchfab are usually huge (100x bigger)
	# M4A1 in game is ~1 unit long. If this is 100 units, we need 0.01 scale. Let's do 0.01 for safety
	node.scale = Vector3(0.01, 0.01, 0.01)
	
	# Add Muzzle
	var muzzle = Node3D.new()
	muzzle.name = "MuzzleSocket"
	muzzle.position = Vector3(0, 0, -1.0)
	node.add_child(muzzle)
	muzzle.owner = root
	
	_set_owner_recursive(node, root)
	
	var out = PackedScene.new()
	out.pack(root)
	ResourceSaver.save(out, "res://scenes/weapons/models/negev_ng7.tscn", ResourceSaver.FLAG_COMPRESS)
	print("SUCCESSFULLY SAVED NEGEV.tscn")
	quit(0)

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
