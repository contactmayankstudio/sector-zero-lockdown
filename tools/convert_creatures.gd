extends SceneTree

func _init():
	print("Converting real creatures to compressed .scn...")
	_convert_glb("real/fox_-_realistic_3d_model_demo_free.glb", "res://scenes/zombies/models/RealInfectedHound.scn")
	_convert_glb("real/land_of_the_lost_2009_alice.glb", "res://scenes/zombies/models/RealReptileMutant.scn")
	_convert_glb("real/character_alien_3d_model_by_oscar_creativo.glb", "res://scenes/zombies/models/RealAlienMutant.scn")
	print("All creature conversions finished!")
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
