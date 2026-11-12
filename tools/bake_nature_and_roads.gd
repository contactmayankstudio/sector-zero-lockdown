extends SceneTree

func _init():
	print("=== Baking Nature and Road GLB to Godot SCN ===")
	DirAccess.make_dir_absolute("res://assets/nature_kit/scn")
	DirAccess.make_dir_absolute("res://assets/roads_kit/scn")
	
	var nature_files = [
		["res://assets/nature_kit/glb/tree_pineTallA_detailed.glb", "res://assets/nature_kit/scn/tree_pine_tall.scn"],
		["res://assets/nature_kit/glb/tree_pineRoundA.glb", "res://assets/nature_kit/scn/tree_pine_round.scn"],
		["res://assets/nature_kit/glb/rock_largeA.glb", "res://assets/nature_kit/scn/rock_large.scn"],
		["res://assets/nature_kit/glb/rock_tallA.glb", "res://assets/nature_kit/scn/rock_tall.scn"],
		["res://assets/nature_kit/glb/grass.glb", "res://assets/nature_kit/scn/grass_tuft.scn"],
		["res://assets/nature_kit/glb/plant_bushDetailed.glb", "res://assets/nature_kit/scn/bush_detailed.scn"]
	]
	
	for pair in nature_files:
		_bake_glb(pair[0], pair[1])
		
	var road_files = [
		["res://assets/roads_kit/glb/road-bend.glb", "res://assets/roads_kit/scn/road_bend.scn"],
		["res://assets/roads_kit/glb/light-curved.glb", "res://assets/roads_kit/scn/light_curved.scn"],
		["res://assets/roads_kit/glb/electricity-pole.glb", "res://assets/roads_kit/scn/electricity_pole.scn"]
	]
	
	for pair in road_files:
		_bake_glb(pair[0], pair[1])
		
	print("=== Baking Complete ===")
	quit(0)

func _bake_glb(glb_path: String, scn_path: String):
	if not FileAccess.file_exists(glb_path):
		print("File not found: ", glb_path)
		return
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(glb_path, state)
	if err != OK:
		print("Failed to append GLTF: ", glb_path, " err: ", err)
		return
	var root = doc.generate_scene(state)
	if not root:
		print("Failed to generate scene: ", glb_path)
		return
	_set_owner_recursive(root, root)
	var pack = PackedScene.new()
	pack.pack(root)
	var save_err = ResourceSaver.save(pack, scn_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved ", scn_path, " [Status: ", save_err, "]")
	root.free()

func _set_owner_recursive(node: Node, owner_node: Node):
	for child in node.get_children():
		child.owner = owner_node
		_set_owner_recursive(child, owner_node)
