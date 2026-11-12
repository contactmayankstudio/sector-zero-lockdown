extends SceneTree

func _init():
	print("--- INSPECTING HOUND AND OTHER MODELS ---")
	var hound_res = load("res://scenes/zombies/models/RealInfectedHound.scn")
	if hound_res:
		var hound = hound_res.instantiate()
		print("Hound name: ", hound.name)
		var anims = hound.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			print("Hound anims: ", anims[0].get_animation_list())
		var meshes = hound.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			print("Hound mesh: ", m.name, " resource: ", m.mesh.resource_name if m.mesh else "none")
		hound.free()

	var raptor_res = load("res://scenes/zombies/models/RealVelociraptor.scn")
	if raptor_res:
		var raptor = raptor_res.instantiate()
		print("Raptor name: ", raptor.name)
		var anims = raptor.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			print("Raptor anims: ", anims[0].get_animation_list())
		raptor.free()
		
	var titan_res = load("res://scenes/zombies/models/RealTitanBrute.scn")
	if titan_res:
		var titan = titan_res.instantiate()
		print("Titan name: ", titan.name)
		var anims = titan.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			print("Titan anims: ", anims[0].get_animation_list())
		titan.free()
		
	quit()
