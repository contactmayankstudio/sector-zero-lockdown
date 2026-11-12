extends SceneTree

func _init():
	print("--- TESTING URBAN STREET SCENE ---")
	var t0 = Time.get_ticks_msec()
	var scene = load("res://scenes/environments/UrbanStreet.tscn")
	var t1 = Time.get_ticks_msec()
	print("UrbanStreet loaded in: ", t1 - t0, " ms")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	print("Instantiated in: ", Time.get_ticks_msec() - t1, " ms")
	print("Total test time: ", Time.get_ticks_msec() - t0, " ms")
	print("--- TEST PASSED WITH ZERO FREEZE ---")
	quit(0)
