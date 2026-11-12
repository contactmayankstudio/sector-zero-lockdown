extends SceneTree

func _init():
	var scenes_to_test = [
		"res://scenes/environments/UrbanStreet.tscn",
		"res://scenes/environments/ApartmentComplex.tscn",
		"res://scenes/environments/NightCityStreet.tscn",
		"res://scenes/environments/AirportServiceRoad.tscn",
		"res://scenes/environments/RailwayStation.tscn",
		"res://scenes/environments/AbandonedTrain.tscn",
		"res://scenes/environments/DarkIndustrial.tscn",
		"res://scenes/environments/AirportTerminal.tscn",
		"res://scenes/environments/FinalLockdown.tscn"
	]
	
	for s_path in scenes_to_test:
		print("Testing scene: ", s_path)
		var sc = load(s_path)
		if not sc:
			print("  FAILED to load: ", s_path)
			quit(1)
		var inst = sc.instantiate()
		if not inst:
			print("  FAILED to instantiate: ", s_path)
			quit(1)
		print("  OK! Nodes: ", inst.get_child_count())
		inst.free()
	print("\n>>> ALL 9 ENVIRONMENT SCENES LOADED AND INSTANTIATED CLEANLY! <<<")
	quit(0)
