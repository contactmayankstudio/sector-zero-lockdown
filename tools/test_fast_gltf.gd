
extends SceneTree

func _init():
	var t0 = Time.get_ticks_msec()
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/zombie_doom_default.glb", state)
	var t1 = Time.get_ticks_msec()
	print("GLTF append_from_file err: ", err, " in ", (t1 - t0), " ms")
	if err == OK:
		var scene = doc.generate_scene(state)
		var t2 = Time.get_ticks_msec()
		print("generate_scene in ", (t2 - t1), " ms")
		var packed = PackedScene.new()
		packed.pack(scene)
		var err_save = ResourceSaver.save(packed, "res://scenes/zombies/models/RealDoomZombie.scn", ResourceSaver.FLAG_COMPRESS)
		var t3 = Time.get_ticks_msec()
		print("Saved binary .scn in ", (t3 - t2), " ms, err: ", err_save)
		scene.free()
	quit(0)
