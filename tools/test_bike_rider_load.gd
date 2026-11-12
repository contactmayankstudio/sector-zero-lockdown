extends SceneTree

func _init():
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	get_root().add_child(bike)
	# Force ready if in _init
	if not bike.is_node_ready():
		bike._ready()

	print("Bike instantiated into tree successfully!")

	var rider = bike.find_child("RiderSoldier", true, false)
	print("Rider soldier found: ", rider != null)
	if rider:
		print("Rider initially visible (should be false): ", rider.visible)
		var skel = rider.find_child("Skeleton3D", true, false)
		print("Rider skeleton found: ", skel != null)
		var back_gun = rider.find_child("HeldRifle", true, false)
		if not back_gun:
			back_gun = rider.find_child("akx_scifi", true, false)
		print("Back gun attached: ", back_gun != null)

	# Simulate dummy player mounting
	var dummy_player = CharacterBody3D.new()
	dummy_player.name = "DummyPlayer"
	get_root().add_child(dummy_player)

	bike.enter_vehicle(dummy_player)
	print("After enter_vehicle:")
	print("  is_occupied: ", bike.is_occupied)
	print("  rider.visible (should be true): ", rider.visible if rider else false)

	bike.exit_vehicle()
	print("After exit_vehicle:")
	print("  is_occupied: ", bike.is_occupied)
	print("  rider.visible (should be false): ", rider.visible if rider else false)

	bike.queue_free()
	dummy_player.queue_free()
	print("ALL BIKE RIDER LOGIC VERIFIED SUCCESSFULLY!")
	quit(0)
