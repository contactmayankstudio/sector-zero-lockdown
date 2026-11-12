extends SceneTree

func _init():
	print("--- TESTING ROAD PACK IMPORT ---")
	var t0 = Time.get_ticks_msec()
	var scene = load("res://assets/3d/environments/road_pack.glb")
	var t1 = Time.get_ticks_msec()
	print("road_pack.glb loaded in: ", t1 - t0, " ms")
	if scene:
		var inst = scene.instantiate()
		print("Instantiated root node: ", inst.name, " children: ", inst.get_child_count())
		
		# Set owner on all descendants so packed scene saves properly
		_set_owner_recursive(inst, inst)

		var packed = PackedScene.new()
		var res = packed.pack(inst)
		if res == OK:
			var save_path = "res://scenes/environments/models/road_pack.scn"
			var err = ResourceSaver.save(packed, save_path, ResourceSaver.FLAG_COMPRESS)
			print("Saved to ", save_path, " err: ", err, " in ", Time.get_ticks_msec() - t1, " ms")
		else:
			print("Pack failed: ", res)
		inst.free()
	else:
		print("Failed to load road_pack.glb")
	quit(0)

func _set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.owner = root
		_set_owner_recursive(child, root)
