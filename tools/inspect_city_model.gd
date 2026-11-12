@tool
extends SceneTree

func _init():
	var s = load("res://scenes/environments/models/RealCityBuildings8.scn")
	if s:
		var inst = s.instantiate()
		print("Loaded RealCityBuildings8! Children count: ", inst.get_child_count())
		for i in range(mini(inst.get_child_count(), 10)):
			var c = inst.get_child(i)
			print(" Child ", i, ": ", c.name, " (", c.get_class(), ") pos=", c.position if "position" in c else "")
	var s2 = load("res://scenes/environments/models/RealCityStreet7.scn")
	if s2:
		var inst2 = s2.instantiate()
		print("Loaded RealCityStreet7! Children count: ", inst2.get_child_count())
	quit(0)
