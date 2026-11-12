@tool
extends SceneTree

func _init():
	var models = [
		"res://scenes/zombies/models/RealSoldierZombie.scn",
		"res://scenes/zombies/models/RealZombie6ft.scn",
		"res://scenes/zombies/models/RealZombieBiker.scn",
		"res://scenes/zombies/models/RealZombieOffice.scn",
		"res://scenes/zombies/models/RealTitanBrute.scn",
		"res://scenes/zombies/models/RealButcherBoss.scn",
		"res://scenes/zombies/models/zombie_normal.tscn",
		"res://scenes/zombies/models/zombie_boss.tscn"
	]
	for p in models:
		if not ResourceLoader.exists(p):
			print("Missing: ", p)
			continue
		var s = load(p)
		if not s:
			print("Could not load: ", p)
			continue
		var inst = s.instantiate()
		var anims = inst.find_children("*", "AnimationPlayer", true, false)
		var anim_names = []
		if not anims.is_empty():
			anim_names = anims[0].get_animation_list()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		var tris = 0
		for m in meshes:
			if m.mesh:
				for i in range(m.mesh.get_surface_count()):
					tris += m.mesh.surface_get_array_len(i) / 3
		print(p.get_file(), " -> tris: ", tris, " | meshes: ", meshes.size(), " | anims: ", anim_names.slice(0, 5))
		inst.free()
	quit()
