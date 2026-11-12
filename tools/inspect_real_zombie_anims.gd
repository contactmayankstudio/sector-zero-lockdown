@tool
extends SceneTree

func _init():
	var scns = [
		"res://scenes/zombies/models/RealZombieOffice.scn",
		"res://scenes/zombies/models/RealZombieBiker.scn",
		"res://scenes/zombies/models/RealTitanBrute.scn"
	]
	for p in scns:
		var scn = load(p) as PackedScene
		if scn:
			var inst = scn.instantiate()
			print("Inspecting: ", p)
			var aps = inst.find_children("*", "AnimationPlayer", true, false)
			print("  AnimationPlayers: ", aps.size())
			for ap in aps:
				print("    AP [", ap.name, "]: ", ap.get_animation_list())
			inst.free()
	quit(0)
