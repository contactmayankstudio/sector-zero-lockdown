
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/ak74u__free_animation..glb", state)
	print("AK74u append err: ", err)
	if err == OK:
		var scene = doc.generate_scene(state)
		print("AK74u root: ", scene.name)
		var anims = scene.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			var ap = anims[0]
			print("AnimationPlayer found! Animations: ", ap.get_animation_list())
		var packed = PackedScene.new()
		packed.pack(scene)
		var s_err = ResourceSaver.save(packed, "res://scenes/weapons/models/AK74uAnimated.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved AK74uAnimated.scn err: ", s_err)
		scene.free()
	quit(0)
