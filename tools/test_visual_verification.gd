extends Node

var timer: float = 0.0
var step: int = 0
var player: Node3D = null
var bike: DrivableBike = null

func _ready():
	print("[VERIFY] Visual verification test started!")

func _process(delta: float):
	timer += delta
	
	if step == 0 and timer > 2.0:
		step = 1
		player = get_tree().get_first_node_in_group("player")
		var bikes = get_tree().get_nodes_in_group("bikes")
		if not bikes.is_empty():
			bike = bikes[0]
			
		print("[VERIFY] Step 1: Switching player to 3rd person to capture soldier with gun...")
		if player and player.has_method("toggle_camera_perspective"):
			player.toggle_camera_perspective()
			
	elif step == 1 and timer > 3.5:
		step = 2
		_capture_screen("soldier_on_foot_gun.png")
		print("[VERIFY] Step 2: Mounting player onto Hayabusa superbike...")
		if bike and player:
			bike.enter_vehicle(player)
			
	elif step == 2 and timer > 5.5:
		step = 3
		_capture_screen("soldier_riding_hayabusa.png")
		print("[VERIFY] Step 3: Driving and steering bike left to demonstrate lean...")
		if bike:
			bike.current_steer_input = -0.85
			bike.current_forward_velocity = 15.0 # ~54 km/h
			
	elif step == 3 and timer > 7.0:
		step = 4
		_capture_screen("soldier_bike_steering_lean.png")
		print("[VERIFY] Step 4: Dismounting player from bike...")
		if bike:
			bike.exit_vehicle()
			
	elif step == 4 and timer > 8.5:
		step = 5
		_capture_screen("soldier_dismounted_ready.png")
		print("[VERIFY] All verification screenshots captured successfully!")
		get_tree().quit(0)

func _capture_screen(filename: String):
	var img = get_viewport().get_texture().get_image()
	if img:
		var dir = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/"
		var full_path = dir + filename
		img.save_png(full_path)
		print("[VERIFY] Captured screenshot: ", full_path)
	else:
		print("[VERIFY] ERROR: Failed to get image from viewport")
