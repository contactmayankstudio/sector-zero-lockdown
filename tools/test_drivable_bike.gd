@tool
extends SceneTree

const DrivableBikeScript = preload("res://scripts/Vehicles/DrivableBike.gd")

func _init():
	print("=== Running Comprehensive DrivableBike Test Suite ===")
	
	# 1. Load Packed Scene
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	if not bike_scene:
		printerr("[FAIL] Could not load res://scenes/vehicles/DrivableBike.tscn")
		quit(1)
		return
	print("[PASS] Scene loaded successfully.")

	# 2. Instantiate in Root
	var bike = bike_scene.instantiate()
	root.add_child(bike)
	bike._ready()
	print("[PASS] Instantiated DrivableBike node and invoked _ready().")

	# 3. Verify All Essential Child Nodes
	var required_nodes = [
		"BodyCollision",
		"VisualWrapper",
		"VisualWrapper/HayabusaMesh",
		"SpringArm3D",
		"SpringArm3D/ChaseCamera",
		"Headlight",
		"HeadlightGlow",
		"Taillight",
		"EngineAudio",
		"ImpactAudio",
		"HornAudio",
		"MountZone",
		"SmashZone",
		"EnterPromptUI",
		"DriveHUD"
	]
	for n_path in required_nodes:
		var node = bike.get_node_or_null(n_path)
		if node:
			print("  [OK] Found node: ", n_path, " (", node.get_class(), ")")
		else:
			printerr("  [FAIL] Missing node: ", n_path)
			quit(1)
			return

	# 4. Verify Groups
	assert(bike.is_in_group("vehicles"), "Bike should be in 'vehicles' group")
	assert(bike.is_in_group("bikes"), "Bike should be in 'bikes' group")
	print("[PASS] Vehicle groups verified.")

	# 5. Verify Internal Mesh Nodes (Steer Fork & Wheels)
	print("  fork_steer_node: ", bike.fork_steer_node.name if bike.fork_steer_node else "null")
	print("  front_wheel_node: ", bike.front_wheel_node.name if bike.front_wheel_node else "null")
	print("  rear_wheel_node: ", bike.rear_wheel_node.name if bike.rear_wheel_node else "null")
	assert(bike.fork_steer_node != null, "fork_steer_node should be resolved")
	assert(bike.front_wheel_node != null, "front_wheel_node should be resolved")
	assert(bike.rear_wheel_node != null, "rear_wheel_node should be resolved")
	print("[PASS] Steering fork and wheel nodes resolved.")

	# 6. Test Headlight State Cycling
	print("Testing Headlight High-Beam toggle...")
	assert(bike.headlight_state == 1, "Initial state should be 1 (Low Beam)")
	bike._toggle_headlight()
	assert(bike.headlight_state == 2, "State after 1 toggle should be 2 (High Beam)")
	assert(bike.headlight.light_energy > 5.0, "High beam energy should be bright (> 5.0)")
	bike._toggle_headlight()
	assert(bike.headlight_state == 0, "State after 2 toggles should be 0 (Off)")
	assert(bike.headlight.visible == false, "Headlight should be hidden when off")
	bike._toggle_headlight()
	assert(bike.headlight_state == 1, "State after 3 toggles should wrap to 1 (Low Beam)")
	print("[PASS] Headlight low beam / high beam / off cycling verified.")

	# 7. Test Mount / Dismount Lifecycle
	print("Testing Mount / Dismount Lifecycle...")
	var mock_player = CharacterBody3D.new()
	mock_player.name = "MockPlayer"
	mock_player.add_to_group("player")
	var p_cam = Camera3D.new()
	p_cam.name = "Camera3D"
	mock_player.add_child(p_cam)
	var p_hud = CanvasLayer.new()
	p_hud.name = "HUD"
	mock_player.add_child(p_hud)
	root.add_child(mock_player)

	# Enter
	bike.enter_vehicle(mock_player)
	assert(bike.is_occupied == true, "Bike should be marked occupied")
	assert(mock_player.visible == false, "Player should be hidden while mounted")
	assert(mock_player.process_mode == Node.PROCESS_MODE_DISABLED, "Player processing disabled")
	assert(bike.drive_hud.visible == true, "DriveHUD should be visible")
	assert(bike.chase_camera.current == true, "ChaseCamera should be current")
	print("  [OK] enter_vehicle succeeded.")

	# Simulate 10 physics frames of driving
	bike.current_forward_velocity = 25.0 # ~90 KM/H
	bike.current_steer_input = -1.0 # Turn left
	for i in range(10):
		bike._physics_process(0.016)

	assert(bike.visual_wrapper.rotation.z > 0.1, "Bike visual wrapper should lean positive (left) when turning left at speed!")
	print("  [OK] Dynamic Lean verified: lean_angle = %.2f deg (%.3f rad)" % [rad_to_deg(bike.visual_wrapper.rotation.z), bike.visual_wrapper.rotation.z])

	# Exit
	bike.exit_vehicle()
	assert(bike.is_occupied == false, "Bike should not be occupied after exit")
	assert(mock_player.visible == true, "Player should be restored visible")
	assert(mock_player.process_mode == Node.PROCESS_MODE_INHERIT, "Player processing restored")
	assert(bike.drive_hud.visible == false, "DriveHUD should be hidden")
	assert(p_cam.current == true, "Player camera should be restored")
	print("  [OK] exit_vehicle succeeded.")

	# 8. Test Roadkill Gore Damage Execution
	print("Testing Zombie Roadkill collision...")
	var mock_zombie = Node3D.new()
	mock_zombie.name = "MockZombie"
	mock_zombie.add_to_group("enemies")
	mock_zombie.set_script(load("res://tools/mock_zombie.gd"))
	root.add_child(mock_zombie)

	# Execute roadkill at 80 KM/H
	bike._execute_roadkill(mock_zombie, 80.0)
	assert(mock_zombie.get("damage_received") > 1000.0, "Zombie should receive over 1000 damage at 80 KM/H")
	print("  [OK] Roadkill damage applied: %.1f damage!" % mock_zombie.get("damage_received"))
	print("[PASS] Zombie roadkill gore mechanics verified.")

	mock_zombie.queue_free()
	mock_player.queue_free()
	bike.queue_free()

	print("\n=== ALL SUPERBIKE TESTS PASSED PERFECTLY (100% SUCCESS) ===")
	quit(0)
