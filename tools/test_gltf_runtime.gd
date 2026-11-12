extends SceneTree

func _init():
	var t0 = Time.get_ticks_msec()
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://quarantine_suspect_assets/gta_grove_street.glb", state)
	print("GLTF append result: ", err, " in ", Time.get_ticks_msec() - t0, " ms")
	if err == OK:
		var scene_root = doc.generate_scene(state)
		print("Generated scene root: ", scene_root.name, " children: ", scene_root.get_child_count(), " total time: ", Time.get_ticks_msec() - t0, " ms")
		var packed = PackedScene.new()
		packed.pack(scene_root)
		ResourceSaver.save(packed, "res://scenes/environments/GTAGroveStreetDirect.tscn")
		print("Successfully saved res://scenes/environments/GTAGroveStreetDirect.tscn!")
		scene_root.free()
	quit(0)
