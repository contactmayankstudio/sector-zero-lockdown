extends SceneTree

func _init():
	var glb_path = "res://assets/3d/characters/combine_ordinal_soldier.glb"
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var err = gltf_doc.append_from_file(glb_path, gltf_state)
	if err != OK:
		print("Failed to append from file: ", err)
		quit(1)
		return

	var root_node: Node3D = gltf_doc.generate_scene(gltf_state)
	if not root_node:
		print("Failed to generate scene!")
		quit(1)
		return

	root_node.name = "CombineSoldier"
	
	# Pack and save scene
	var packed = PackedScene.new()
	for child in root_node.find_children("*"):
		child.owner = root_node
	packed.pack(root_node)
	var save_err = ResourceSaver.save(packed, "res://scenes/characters/CombineSoldier.tscn")
	print("Saved CombineSoldier.tscn status: ", save_err)

	# Print mesh details
	var meshes = root_node.find_children("*", "MeshInstance3D", true, false)
	print("Found MeshInstances: ", meshes.size())
	for m in meshes:
		print("  Mesh: ", m.name, " mesh: ", m.mesh != null)
		if m.mesh:
			print("    Surfaces: ", m.mesh.get_surface_count())
			for s in range(m.mesh.get_surface_count()):
				var mat = m.mesh.surface_get_material(s)
				print("      Mat ", s, ": ", mat != null)

	quit(0)
