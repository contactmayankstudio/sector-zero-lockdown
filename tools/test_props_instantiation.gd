extends SceneTree

func _init():
	print("--- TESTING PROPS INSTANTIATION ---")
	var props = [
		"res://scenes/environments/props/ConcreteBarrierA.scn",
		"res://scenes/environments/props/ConcreteBarrierB.scn",
		"res://scenes/environments/props/RoadSignClosed.scn",
		"res://scenes/environments/props/RoadSignWorks.scn",
		"res://scenes/environments/props/TrafficCone.scn",
		"res://scenes/environments/props/StraightRoadSection.scn"
	]
	for p in props:
		var scn = load(p)
		if scn:
			var inst = scn.instantiate()
			print("OK: ", p, " -> root: ", inst.name)
			inst.free()
		else:
			print("FAIL: ", p)
	quit(0)
