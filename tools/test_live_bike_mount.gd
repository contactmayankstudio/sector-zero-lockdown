extends SceneTree

func _init():
	print("--- Starting Live Bike Mount Test ---")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("ERROR: Could not load CityCarZombieArena.tscn")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Find player and bike
	var player = arena.get_node_or_null("Player")
	var bike = arena.get_node_or_null("DrivableBike")

	if not player or not bike:
		print("ERROR: Player or bike not found. Player: ", player, " Bike: ", bike)
		quit(1)
		return

	print("Found player at: ", player.global_position, " and bike at: ", bike.global_position)

	# Mount the bike
	bike.enter_vehicle(player)
	print("Entered vehicle! Bike is_occupied: ", bike.is_occupied)

	# Verify rider soldier visibility and transform
	var rider = bike.get_node_or_null("VisualWrapper/RiderSoldier")
	if not rider:
		rider = bike.find_child("RiderSoldier", true, false)
	print("Rider soldier node: ", rider, " Visible: ", (rider.visible if rider else false))

	# Create a dedicated camera to take an over-the-shoulder / 3/4 beauty shot of the rider
	var test_cam = Camera3D.new()
	test_cam.name = "TestPhotoCam"
	# Position camera behind and to the side of the bike to clearly see soldier, handlebars, and mountains
	test_cam.position = bike.global_position + Vector3(1.6, 1.4, 2.4)
	test_cam.look_at(bike.global_position + Vector3(0.0, 0.75, 0.0), Vector3.UP)
	test_cam.current = true
	arena.add_child(test_cam)

	# Let frames simulate
	for i in range(15):
		await RenderingServer.frame_post_draw

	# Capture viewport
	var vp = get_root().get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var save_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_bike_handlebar_mounted_proof.png"
				var err = img.save_png(save_path)
				print("Saved bike mount proof image to: ", save_path, " Status: ", err)

	print("--- Live Bike Mount Test Complete ---")
	quit(0)
