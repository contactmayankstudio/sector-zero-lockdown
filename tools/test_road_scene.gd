extends SceneTree

func _init():
	print("--- Testing AirportServiceRoad.tscn ---")
	var s = load("res://scenes/environments/AirportServiceRoad.tscn")
	print("Loaded AirportServiceRoad.tscn: ", s)
	if s:
		var inst = s.instantiate()
		print("Instantiated AirportServiceRoad successfully: ", inst.name)
		inst.queue_free()
	print("--- Passed AirportServiceRoad Test ---")
	quit(0)
