
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/low_poly_vehicle_mini_pack_4.2.glb", state)
	if err == OK:
		var scene = doc.generate_scene(state)
		print("Vehicle pack root: ", scene.name, " children count: ", scene.get_child_count())
		for c in scene.get_children():
			print("  Child: ", c.name, " type: ", c.get_class())
		scene.free()
	quit(0)
