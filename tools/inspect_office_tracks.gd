extends SceneTree

func _init():
	print("--- INSPECTING TRACKS FOR OFFICE, BIKER, REALISTIC ---")
	for path in [
		"res://scenes/zombies/models/RealZombieOffice.scn",
		"res://scenes/zombies/models/RealZombieBiker.scn",
		"res://scenes/zombies/models/zombie_realistic_human.scn",
		"res://scenes/zombies/models/RealSoldierZombie.scn"
	]:
		var res = load(path)
		if res and res is PackedScene:
			var inst = res.instantiate()
			var ap = inst.find_child("AnimationPlayer", true, false)
			print("\nPath: ", path)
			if ap:
				print("  AP root_node: ", ap.root_node)
				for a in ["walk", "Walk", "idle", "Idle", "attack"]:
					if ap.has_animation(a):
						var anim = ap.get_animation(a)
						print("  Anim ", a, " length: ", anim.length, " tracks: ", anim.get_track_count())
						for i in range(min(5, anim.get_track_count())):
							print("    track ", i, " type: ", anim.track_get_type(i), " path: ", anim.track_get_path(i))
			inst.free()
	quit()
