extends SceneTree

func _init():
	print("Applying high-quality PBR materials to all weapons...")
	var dir = DirAccess.open("res://assets/3d/weapons/")
	var mat_metal = load("res://resources/materials/mat_weapon.tres") as Material
	var mat_dark = load("res://resources/materials/mat_player.tres") as Material # swat camo is dark
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".glb"):
				var path = "res://assets/3d/weapons/" + file_name
				_apply_mat_to_scene(path, mat_metal, mat_dark)
			file_name = dir.get_next()
	quit(0)

func _apply_mat_to_scene(glb_path: String, mat1: Material, mat2: Material):
	# load glb, create a scene, apply materials, save as .scn
	var packed = load(glb_path) as PackedScene
	if not packed: return
	var node = packed.instantiate()
	_set_mats(node, mat1, mat2)
	
	var new_packed = PackedScene.new()
	_set_owner_recursive(node, node)
	new_packed.pack(node)
	
	var out_path = glb_path.replace(".glb", "_mat.scn")
	ResourceSaver.save(new_packed, out_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved material-applied weapon: ", out_path)

func _set_mats(node: Node, m1: Material, m2: Material):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				node.set_surface_override_material(i, m1)
	for c in node.get_children():
		_set_mats(c, m1, m2)

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
