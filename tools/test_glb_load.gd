extends SceneTree

func _init():
	var glb_path = "res://assets/3d/weapons/p90.glb"
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var err = gltf.append_from_file(glb_path, state)
	if err == OK:
		var node = gltf.generate_scene(state)
		print("SUCCESS: GLTFDocument loaded p90.glb in memory! Node: ", node.name)
		var ps = PackedScene.new()
		ps.pack(node)
		# Save as BINARY .scn (NOT .tscn text!)
		var serr = ResourceSaver.save(ps, "res://scenes/weapons/models/p90.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved compressed binary .scn: ", serr)
	else:
		print("Failed: ", err)
	quit(0)
