extends SceneTree

func _init():
	_inspect_glb("real/fox_-_realistic_3d_model_demo_free.glb", "Fox / Beast (Realistic Dog)")
	_inspect_glb("real/land_of_the_lost_2009_alice.glb", "Alice / Reptilian Beast")
	_inspect_glb("real/character_alien_3d_model_by_oscar_creativo.glb", "Alien / Xenomorph Mutant")
	quit(0)

func _inspect_glb(rel_path: String, label: String):
	print("\n==========================================")
	print("INSPECTING: ", label, " (", rel_path, ")")
	print("==========================================")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(rel_path, state)
	if err != OK:
		print("Failed to append: ", err)
		return
	var scene = doc.generate_scene(state)
	if not scene:
		print("Failed to generate scene")
		return
	
	print("Root name: ", scene.name)
	for c in scene.find_children("*", "AnimationPlayer", true, false):
		print("  AnimationPlayer: ", c.name, " anims: ", c.get_animation_list())
	for c in scene.find_children("*", "Skeleton3D", true, false):
		print("  Skeleton3D: ", c.name, " bones: ", c.get_bone_count())
	for c in scene.find_children("*", "VisualInstance3D", true, false):
		print("  Mesh: ", c.name, " aabb: ", c.get_aabb())
	scene.free()
