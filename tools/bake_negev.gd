extends SceneTree

func _init():
	var glb_path = "res://assets/3d/weapons/negev_ng7/scene.gltf"
	var p = load(glb_path) as PackedScene
	if not p:
		print("FAILED to load scene.gltf")
		quit(1)
		return
		
	var n = p.instantiate()
	
	# Fix scaling or rotations if necessary. Usually just saving it as a root Node3D is good enough.
	# We'll just wrap it in a Node3D named negev_ng7
	var root = Node3D.new()
	root.name = "negev_ng7"
	
	# Add the model to root
	root.add_child(n)
	n.owner = root
	
	# MuzzleSocket
	var muzzle = Node3D.new()
	muzzle.name = "MuzzleSocket"
	# approx position
	muzzle.position = Vector3(0, 0, -1.0)
	n.add_child(muzzle)
	muzzle.owner = root
	
	_set_owner_recursive(n, root)
	
	var out = PackedScene.new()
	out.pack(root)
	ResourceSaver.save(out, "res://scenes/weapons/models/negev_ng7.tscn", ResourceSaver.FLAG_COMPRESS)
	print("Saved negev_ng7.tscn")
	quit(0)

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
