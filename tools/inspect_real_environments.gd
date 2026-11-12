extends SceneTree

func _init():
	_inspect_glb("real/appartement_extracted/source/appartement.glb", "Apartment Complex")
	_inspect_glb("real/low_poly_street_gameready_6.glb", "Low Poly Street 6")
	_inspect_glb("real/street_city_7_for_games_free.glb", "City Street 7")
	_inspect_glb("real/street_city_buildings_8.glb", "City Buildings 8")
	quit(0)

func _inspect_glb(rel_path: String, label: String):
	print("\n==========================================")
	print("INSPECTING: ", label, " (", rel_path, ")")
	print("==========================================")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(rel_path, state)
	if err != OK:
		print("Failed to append from file: ", err)
		return
	var root_node = doc.generate_scene(state)
	if not root_node:
		print("Failed to generate scene")
		return
	
	var total_meshes = 0
	for c in root_node.find_children("*", "VisualInstance3D", true, false):
		total_meshes += 1
		if total_meshes <= 8:
			print("  Mesh: ", c.name, " aabb: ", c.get_aabb())
	print("Total visual meshes: ", total_meshes)
	root_node.free()
