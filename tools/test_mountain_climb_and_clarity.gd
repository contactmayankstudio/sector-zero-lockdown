extends SceneTree

func _init():
	print("=== Running Mountain Climb and Clarity Verification ===")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("ERROR: Could not load CityCarZombieArena.tscn")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Wait for scene tree and physics ready
	for i in range(10):
		await RenderingServer.frame_post_draw

	var car = arena.get_node_or_null("DrivableCar")
	var bike = arena.get_node_or_null("DrivableBike")
	var player = arena.get_node_or_null("Player")
	print("Car found: ", car != null)
	print("Bike found: ", bike != null)
	print("Player found: ", player != null)

	# 1. Create Photo Camera 1: Beautiful panoramic view of the mountain road, lake, and valley
	var photo_cam1 = Camera3D.new()
	photo_cam1.name = "PhotoCam_ValleyView"
	arena.add_child(photo_cam1)
	photo_cam1.global_position = Vector3(-15.0, 10.0, -90.0)
	photo_cam1.look_at(Vector3(-75.0, 18.0, -170.0), Vector3.UP)
	photo_cam1.current = true

	for i in range(15):
		await RenderingServer.frame_post_draw

	var vp = get_root().get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var p1 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_mountain_pass_clarity.png"
				var err1 = img.save_png(p1)
				print("Saved live_mountain_pass_clarity.png status: ", err1)

	# 2. Position Car on Mountain Road West to climb up the mountain
	if car and player:
		# Place car at the mountain base heading up the mountain
		car.global_position = Vector3(-35.0, 1.8, -125.0)
		car.rotation_degrees = Vector3(0, 40, 0)
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO

		# Photo Camera 2: Chase / 3/4 view behind the car climbing up the mountain slope
		var photo_cam2 = Camera3D.new()
		photo_cam2.name = "PhotoCam_CarClimbing"
		arena.add_child(photo_cam2)
		photo_cam2.global_position = car.global_position + Vector3(6.0, 3.5, 7.5)
		photo_cam2.look_at(car.global_position + Vector3(0.0, 0.8, 0.0), Vector3.UP)
		photo_cam2.current = true

		car.enter_vehicle(player)
		print("Entered car! Car is_occupied: ", car.is_occupied)
		var start_pos = car.global_position
		
		# Simulate 40 physics ticks applying forward throttle and torque
		for i in range(40):
			car._handle_driving_input(0.016, 40.0)
			await RenderingServer.frame_post_draw
			
		var end_pos = car.global_position
		print("Car climb test: start_pos=", start_pos, " end_pos=", end_pos, " delta_y=", end_pos.y - start_pos.y)

		if vp:
			var tex2 = vp.get_texture()
			if tex2:
				var img2 = tex2.get_image()
				if img2:
					var p2 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_car_on_mountain_road.png"
					var err2 = img2.save_png(p2)
					print("Saved live_car_on_mountain_road.png status: ", err2)

	print("=== Test Finished Successfully ===")
	arena.queue_free()
	quit(0)
