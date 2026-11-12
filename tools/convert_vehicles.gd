
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/low_poly_vehicle_mini_pack_4.2.glb", state)
	if err == OK:
		var scene = doc.generate_scene(state)
		var packed = PackedScene.new()
		packed.pack(scene)
		var s_err = ResourceSaver.save(packed, "res://scenes/environments/props/WreckedVehiclesPack.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved WreckedVehiclesPack.scn err: ", s_err)
		scene.free()
	quit(0)
