@tool
extends SceneTree

func _init():
	print("--- Inspecting Animal Models ---")
	var paths = [
		"res://assets/external/downloads/animals/fox_-_realistic_3d_model_demo_free.glb",
		"res://assets/external/downloads/animals/mutant_insect.glb",
		"res://assets/3d/characters/infected_canine.glb",
		"res://assets/3d/zombies/infected_dog.glb"
	]
	
	for p in paths:
		if not ResourceLoader.exists(p):
			print("File does NOT exist: ", p)
			continue
		var scn = load(p)
		if not scn:
			print("Could not load: ", p)
			continue
		var inst = scn.instantiate()
		print("\nModel: ", p)
		print("  Root class: ", inst.get_class(), " name: ", inst.name)
		print("  Total children: ", inst.get_child_count())
		var anim_players = inst.find_children("*", "AnimationPlayer", true, false)
		for ap in anim_players:
			print("  AnimationPlayer: ", ap.name, " Animations: ", ap.get_animation_list())
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		print("  MeshInstance3D count: ", meshes.size())
		for m in meshes:
			if m.mesh:
				print("    Mesh: ", m.name, " faces/surfaces: ", m.mesh.get_surface_count())
		inst.free()
		
	quit(0)
