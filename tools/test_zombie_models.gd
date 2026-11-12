extends SceneTree

func _init():
	print("--- TESTING ZOMBIE GLB IMPORTS ---")
	var paths = [
		"/home/am/Downloads/scary_zombie_pack.glb",
		"/home/am/Downloads/muscled_mutated_male_zombie.glb"
	]
	for p in paths:
		var gltf = GLTFDocument.new()
		var state = GLTFState.new()
		var err = gltf.append_from_file(p, state)
		if err == OK:
			var node = gltf.generate_scene(state)
			print("Loaded ", p.get_file(), " node: ", node.name)
			var meshes = node.find_children("*", "MeshInstance3D", true, false)
			print("  Meshes: ", meshes.size())
			for m in meshes:
				print("    Mesh: ", m.name, " AABB: ", m.get_aabb())
			var anims = node.find_children("*", "AnimationPlayer", true, false)
			print("  AnimationPlayers: ", anims.size())
			if not anims.is_empty():
				for a in anims[0].get_animation_list():
					print("    Anim: ", a, " length: ", anims[0].get_animation(a).length)
			node.free()
		else:
			print("Error loading ", p, " err: ", err)
	quit(0)
