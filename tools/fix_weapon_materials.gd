extends SceneTree

func _init():
	print("Fixing weapons...")
	var mat = load("res://resources/materials/mat_weapon.tres")
	var weapons = ["usp45", "m4a1", "remington870", "ak47", "desert_eagle", "mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"]
	
	for w in weapons:
		var glb_path = "res://assets/3d/weapons/" + w + ".glb"
		var scn_path = "res://assets/3d/weapons/" + w + ".scn"
		var scene = load(glb_path) as PackedScene
		if not scene: continue
		var node = scene.instantiate()
		
		# apply materials
		var meshes = node.find_children("*", "MeshInstance3D", true, false)
		if node is MeshInstance3D: meshes.append(node)
		for mi in meshes:
			if mi.mesh:
				for i in range(mi.mesh.get_surface_count()):
					mi.set_surface_override_material(i, mat)
					
		_set_owner_recursive(node, node)
		var p = PackedScene.new()
		p.pack(node)
		ResourceSaver.save(p, scn_path, ResourceSaver.FLAG_COMPRESS)
		print("Saved ", scn_path)
	quit()

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
