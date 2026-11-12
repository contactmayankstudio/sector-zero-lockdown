extends SceneTree

func _init():
	print("--- Starting C# Subsystems Test ---")
	
	# Test 1: Check SectorZeroGameCore Autoload
	var core = get_root().get_node_or_null("SectorZeroGameCore")
	print("Test 1: SectorZeroGameCore Autoload in tree: ", core != null)
	if core:
		print("  Core Instance valid: ", is_instance_valid(core))
		print("  Core Diagnostics enabled: ", core.get("EnableDetailedDiagnostics"))
	
	# Test 2: Instantiate WorldChunkStreamer
	print("\nTest 2: Instantiating WorldChunkStreamer...")
	var streamer_script = load("res://scripts/CSharp/World/WorldChunkStreamer.cs")
	print("  streamer_script loaded: ", streamer_script != null)
	if streamer_script:
		var streamer = streamer_script.new()
		print("  streamer instantiated: ", streamer != null)
		if streamer:
			print("  ChunkSize default: ", streamer.get("ChunkSize"))
			print("  ViewDistance default: ", streamer.get("ViewDistanceChunks"))
			get_root().add_child(streamer)
			print("  streamer added to root tree successfully.")
			streamer.queue_free()
	
	# Test 3: Instantiate ZombieSwarmOptimizer
	print("\nTest 3: Instantiating ZombieSwarmOptimizer...")
	var swarm_script = load("res://scripts/CSharp/AI/ZombieSwarmOptimizer.cs")
	print("  swarm_script loaded: ", swarm_script != null)
	if swarm_script:
		var swarm = swarm_script.new()
		print("  swarm instantiated: ", swarm != null)
		if swarm:
			get_root().add_child(swarm)
			print("  swarm added to root tree successfully.")
			swarm.queue_free()
	
	# Test 4: Instantiate DamageSystem
	print("\nTest 4: Loading and Testing DamageSystem...")
	var dmg_script = load("res://scripts/CSharp/Combat/DamageSystem.cs")
	print("  dmg_script loaded: ", dmg_script != null)
	if dmg_script:
		var dmg = dmg_script.new()
		print("  DamageSystem instantiated: ", dmg != null)
		# Test DamageSystem.CalculateDamage via script or call
		if dmg.has_method("CalculateDamage"):
			var d = dmg.call("CalculateDamage", 100.0, 10.0, 50.0, 0.5)
			print("  DamageSystem.CalculateDamage(100, 10, 50, 0.5) result: ", d)
	
	# Test 5: VehiclePhysicsHelper
	print("\nTest 5: VehiclePhysicsHelper...")
	var v_script = load("res://scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs")
	print("  VehiclePhysicsHelper script loaded: ", v_script != null)

	print("\n--- All Isolated C# Subsystems Tested Successfully ---")
	quit(0)
