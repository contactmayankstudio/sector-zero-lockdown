extends SceneTree

func _init():
	print("Starting conversion of real environments to compressed .scn...")
	_convert_glb("real/appartement_extracted/source/appartement.glb", "res://scenes/environments/models/RealApartment.scn")
	_convert_glb("real/street_city_7_for_games_free.glb", "res://scenes/environments/models/RealCityStreet7.scn")
	_convert_glb("real/street_city_buildings_8.glb", "res://scenes/environments/models/RealCityBuildings8.scn")
	_convert_glb("real/low_poly_street_gameready_6.glb", "res://scenes/environments/models/RealStreet6.scn")
	print("All environment conversions completed successfully!")
	quit(0)

func _convert_glb(src_path: String, dst_path: String):
	print("\nConverting: ", src_path, " -> ", dst_path)
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(src_path, state)
	if err != OK:
		print("  ERROR appending GLTF: ", err)
		return
	var scene = doc.generate_scene(state)
	if not scene:
		print("  ERROR generating scene")
		return
	
	_set_owner_recursive(scene, scene)
	
	var packed = PackedScene.new()
	var pack_err = packed.pack(scene)
	if pack_err != OK:
		print("  ERROR packing scene: ", pack_err)
		scene.free()
		return
		
	var save_err = ResourceSaver.save(packed, dst_path, ResourceSaver.FLAG_COMPRESS)
	print("  Saved: ", dst_path, " (err code: ", save_err, ")")
	scene.free()

func _set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.owner = root
		_set_owner_recursive(child, root)
