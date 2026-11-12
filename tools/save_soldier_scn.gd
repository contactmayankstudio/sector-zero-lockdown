
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/big_fat_stupid_soldier_zombie.glb", state)
	if err == OK:
		var scene = doc.generate_scene(state)
		var packed = PackedScene.new()
		packed.pack(scene)
		var err_save = ResourceSaver.save(packed, "res://scenes/zombies/models/RealSoldierZombie.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved RealSoldierZombie.scn err: ", err_save)
		scene.free()
	quit(0)
