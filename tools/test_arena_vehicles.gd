@tool
extends SceneTree

func _init():
	print("--- Testing CityCarZombieArena with DrivableCar and DrivableBike ---")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		printerr("Failed to load CityCarZombieArena.tscn")
		quit(1)
		return
	var inst = scn.instantiate()
	var car = inst.get_node_or_null("DrivableCar")
	var bike = inst.get_node_or_null("DrivableBike")
	print("Car found: ", car != null)
	print("Bike found: ", bike != null)
	if bike:
		print("Bike position: ", bike.position)
		print("Bike class: ", bike.get_class())
	assert(car != null, "Car must exist")
	assert(bike != null, "Bike must exist")
	inst.free()
	print("CityCarZombieArena verified with both vehicles!")
	quit(0)
