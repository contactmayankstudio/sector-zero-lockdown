extends SceneTree

func _init():
	var files = [
		"/home/am/Downloads/scary_zombie_pack.glb",
		"/home/am/Downloads/muscled_mutated_male_zombie.glb",
		"res://real/zombie_doom_default.glb",
		"res://real/big_fat_stupid_soldier_zombie.glb",
		"res://real/the_butcher__horror_stalker.glb",
		"res://assets/3d/characters/infected_canine.glb",
		"res://assets/external/animations/vitruvian_full_rigged.glb"
	]
	
	for path in files:
		print("\n--- CHECKING: ", path, " ---")
		var doc = GLTFDocument.new()
		var state = GLTFState.new()
		var err = doc.append_from_file(ProjectSettings.globalize_path(path) if path.begins_with("res://") else path, state)
		if err != OK:
			print("Error: ", err)
			continue
		var scene = doc.generate_scene(state)
		if not scene:
			print("Scene is null")
			continue
		var anim_players = scene.find_children("*", "AnimationPlayer", true, false)
		print("AnimPlayers: ", anim_players.size())
		for ap in anim_players:
			print("  AP: ", ap.name, " anims: ", ap.get_animation_list())
		var skels = scene.find_children("*", "Skeleton3D", true, false)
		print("Skeletons: ", skels.size())
		for sk in skels:
			print("  Skeleton: ", sk.name, " bones: ", sk.get_bone_count())
		var meshes = scene.find_children("*", "MeshInstance3D", true, false)
		print("Meshes: ", meshes.size())
		for m in meshes:
			print("  Mesh: ", m.name, " AABB: ", m.get_aabb())
		scene.free()
	quit(0)
