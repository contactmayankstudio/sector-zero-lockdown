extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/zombie_doom_default.glb", state)
	print("zombie_doom_default GLTF load: ", err)
	if err == OK:
		var scene = doc.generate_scene(state)
		var packed = PackedScene.new()
		packed.pack(scene)
		ResourceSaver.save(packed, "res://scenes/zombies/models/RealDoomZombie.tscn")
		print("Saved res://scenes/zombies/models/RealDoomZombie.tscn")
		scene.free()
		
	var doc2 = GLTFDocument.new()
	var state2 = GLTFState.new()
	var err2 = doc2.append_from_file("res://real/big_fat_stupid_soldier_zombie.glb", state2)
	print("big_fat_stupid_soldier_zombie GLTF load: ", err2)
	if err2 == OK:
		var scene2 = doc2.generate_scene(state2)
		var packed2 = PackedScene.new()
		packed2.pack(scene2)
		ResourceSaver.save(packed2, "res://scenes/zombies/models/RealSoldierZombie.tscn")
		print("Saved res://scenes/zombies/models/RealSoldierZombie.tscn")
		scene2.free()
	quit(0)
