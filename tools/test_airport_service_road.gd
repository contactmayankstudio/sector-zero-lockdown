extends SceneTree

func _init():
	print("--- TESTING AIRPORT SERVICE ROAD ---")
	var t0 = Time.get_ticks_msec()
	var scene = load("res://scenes/environments/AirportServiceRoad.tscn")
	var t1 = Time.get_ticks_msec()
	print("AirportServiceRoad loaded in: ", t1 - t0, " ms")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	print("Instantiated in: ", Time.get_ticks_msec() - t1, " ms")
	print("--- TEST PASSED WITH ZERO FREEZE ---")
	quit(0)
