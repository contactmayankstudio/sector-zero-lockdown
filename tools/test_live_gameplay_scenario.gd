extends SceneTree

func _init():
	print("--- Starting Full Live Gameplay Scenario Test ---")
	var arena_scn = load("res://scenes/environments/CityCarZombieArena.scn")
	if not arena_scn:
		print("ERROR: Could not load CityCarZombieArena.scn")
		quit(1)
		return
	
	var arena = arena_scn.instantiate()
	get_root().add_child(arena)
	
	run_simulation(arena)

func run_simulation(arena: Node):
	var tree = self
	
	# Wait for initial load and frames
	for i in range(25):
		await process_frame
		await RenderingServer.frame_post_draw

	var bike = arena.find_child("DrivableBike", true, false)
	var car = arena.find_child("DrivableCar", true, false)
	var player = arena.find_child("Player", true, false)

	print("Found bike: ", bike != null, " car: ", car != null, " player: ", player != null)
	if not bike or not player:
		print("ERROR: Bike or player not found!")
		quit(1)
		return

	# Step 1: Mount the Superbike!
	print("[TEST] Mounting Hayabusa Superbike...")
	bike.enter_vehicle(player)

	for i in range(15):
		await process_frame
		await RenderingServer.frame_post_draw

	# Capture Screenshot 1: Mounted Superbike
	var vp = get_root().get_viewport()
	if vp:
		var img1 = vp.get_texture().get_image()
		var out1 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_rider_mounted_in_game.png"
		img1.save_png(out1)
		print("SUCCESS: Saved live mounted rider screenshot to: ", out1)

	# Step 2: Drive Superbike off-road towards West Mountain slope!
	print("[TEST] Driving Hayabusa toward West Mountain (Left off-road)...")
	# Rotate bike toward West (positive X to negative X)
	bike.rotation.y = deg_to_rad(75.0)
	bike.current_forward_velocity = 22.0 # 80 KM/H initial sprint

	# Simulate driving up the mountain for 60 frames
	for i in range(60):
		# Emulate holding W
		Input.action_press("move_forward")
		await process_frame
		await RenderingServer.frame_post_draw

	Input.action_release("move_forward")

	# Capture Screenshot 2: Bike Climbing Mountain
	if vp:
		var img2 = vp.get_texture().get_image()
		var out2 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_bike_climbing_mountain.png"
		img2.save_png(out2)
		print("SUCCESS: Saved live bike climbing screenshot to: ", out2)

	print("Bike Position on mountain: ", bike.global_position, " Y height: ", bike.global_position.y)

	# Step 3: Test Car Mountain Climbing!
	if car:
		print("[TEST] Testing Car Mountain Climbing...")
		bike.exit_vehicle()
		# Place car at mountain foothill
		car.global_position = Vector3(-65.0, 1.2, -10.0)
		car.rotation.y = deg_to_rad(80.0)
		car.enter_vehicle(player)
		car.linear_velocity = -car.transform.basis.z * 15.0

		for i in range(60):
			Input.action_press("move_forward")
			await process_frame
			await RenderingServer.frame_post_draw

		Input.action_release("move_forward")

		if vp:
			var img3 = vp.get_texture().get_image()
			var out3 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_car_climbing_mountain.png"
			img3.save_png(out3)
			print("SUCCESS: Saved live car climbing screenshot to: ", out3)

		print("Car Position on mountain: ", car.global_position, " Y height: ", car.global_position.y)

	print("--- Live Gameplay Scenario Test Completed Successfully! ---")
	quit(0)
