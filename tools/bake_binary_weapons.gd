extends SceneTree

const WEAPONS_TO_BAKE = [
	{"id": "p90", "glb": "res://assets/3d/weapons/p90.glb", "target_size": 0.55},
	{"id": "ak74_bayonet", "glb": "res://assets/3d/weapons/ak74_bayonet.glb", "target_size": 0.95},
	{"id": "akx_scifi", "glb": "res://assets/3d/weapons/akx_scifi.glb", "target_size": 0.85},
	{"id": "n7_rifle", "glb": "res://assets/3d/weapons/n7_rifle.glb", "target_size": 0.82},
	{"id": "car_smg", "glb": "res://assets/3d/weapons/car_smg.glb", "target_size": 0.65},
	{"id": "grenade_mk2", "glb": "res://assets/3d/weapons/grenade_mk2.glb", "target_size": 0.18},
	{"id": "negev_ng7", "glb": "res://assets/3d/weapons/negev_ng7/scene.gltf", "target_size": 0.95}
]

func _init():
	for w in WEAPONS_TO_BAKE:
		var gltf = GLTFDocument.new()
		var state = GLTFState.new()
		var err = gltf.append_from_file(w.glb, state)
		if err == OK:
			var node = gltf.generate_scene(state)
			var aabb = AABB()
			var first = true
			var meshes = node.find_children("*", "MeshInstance3D", true, false)
			if node is MeshInstance3D: meshes.append(node)
			for mi in meshes:
				if mi.mesh:
					var m_aabb = mi.transform * mi.mesh.get_aabb()
					if first:
						aabb = m_aabb
						first = false
					else:
						aabb = aabb.merge(m_aabb)
			var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
			if max_dim > 0.001:
				var s = w.target_size / max_dim
				node.scale = Vector3(s, s, s)
				var center = aabb.get_center()
				node.position = -(node.transform.basis * center)
			var root = Node3D.new()
			root.name = w.id
			root.add_child(node)
			node.owner = root
			_set_owner(node, root)
			var ps = PackedScene.new()
			ps.pack(root)
			var out_path = "res://scenes/weapons/models/" + w.id + ".scn"
			var serr = ResourceSaver.save(ps, out_path, ResourceSaver.FLAG_COMPRESS)
			print("Saved binary .scn: ", out_path, " Result: ", serr)
		else:
			printerr("Failed to load: ", w.glb)
	quit(0)

func _set_owner(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner(c, root)
