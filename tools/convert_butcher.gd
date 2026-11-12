
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/the_butcher__horror_stalker.glb", state)
	print("append err: ", err)
	if err == OK:
		var scene = doc.generate_scene(state)
		print("Butcher root: ", scene.name)
		for c in scene.find_children("*", "Node3D", true, false):
			print("  Node: ", c.name, " type: ", c.get_class())
		var packed = PackedScene.new()
		packed.pack(scene)
		var s_err = ResourceSaver.save(packed, "res://scenes/zombies/models/RealButcherBoss.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved RealButcherBoss.scn err: ", s_err)
		scene.free()
	quit(0)
