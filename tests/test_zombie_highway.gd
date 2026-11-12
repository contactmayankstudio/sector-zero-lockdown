extends SceneTree

# ==============================================================================
# 600M LONG ZOMBIE HIGHWAY ROADKILL ARENA — E2E VERIFICATION TEST SUITE
# ==============================================================================

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init():
	call_deferred("_run_tests")

func assert_test(test_id: String, cond: bool, msg: String):
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  [PASS] [%s] %s" % [test_id, msg])
	else:
		failed_tests += 1
		printerr("  [FAIL] [%s] %s" % [test_id, msg])

func _run_tests():
	for i in range(5):
		await process_frame

	print("\n=======================================================")
	print("   600M LONG ZOMBIE HIGHWAY — AUTOMATED VERIFICATION")
	print("=======================================================\n")

	# Test 1: Load Scene
	var scene_path = "res://scenes/environments/ZombieNightHighway.tscn"
	assert_test("HW-01", ResourceLoader.exists(scene_path), "ZombieNightHighway.tscn exists on disk")
	
	var ps = load(scene_path) as PackedScene
	assert_test("HW-02", ps != null, "ZombieNightHighway.tscn loaded into PackedScene")
	
	var root = ps.instantiate() as Node3D
	assert_test("HW-03", root != null, "ZombieNightHighway instantiated successfully")
	get_root().add_child(root)
	
	for i in range(5):
		await process_frame

	# Test 2: Highway Asphalt & 600m PBR Road
	var highway = root.get_node_or_null("NavigationRegion3D/Ground/HighwayAsphalt") as MeshInstance3D
	assert_test("HW-04", highway != null, "HighwayAsphalt mesh exists in scene tree")
	if highway and highway.mesh is PlaneMesh:
		var pm = highway.mesh as PlaneMesh
		assert_test("HW-05", pm.size.y >= 500.0, "Highway is long (length = %.1fm)" % pm.size.y)
		var mat = highway.get_surface_override_material(0)
		assert_test("HW-06", mat != null, "HighwayAsphalt has PBR material assigned")

	# Test 3: Road Shoulders
	var shoulder_l = root.get_node_or_null("NavigationRegion3D/Ground/ShoulderLeft")
	var shoulder_r = root.get_node_or_null("NavigationRegion3D/Ground/ShoulderRight")
	assert_test("HW-07", shoulder_l != null and shoulder_r != null, "Left and Right road shoulders exist")

	# Test 4: Drivable Car
	var car = root.get_node_or_null("DrivableCar")
	assert_test("HW-08", car != null, "DrivableCar exists in the highway scene")
	if car:
		var smash = car.get_node_or_null("SmashZone")
		assert_test("HW-09", smash != null, "Car has SmashZone for running over zombies")
		var cam = car.get_node_or_null("ChaseCamera")
		assert_test("HW-10", cam != null, "Car has ChaseCamera")

	# Test 5: Guardrails down the highway
	var props = root.get_node_or_null("Props")
	assert_test("HW-11", props != null, "Props node exists")
	var guardrail_0 = root.get_node_or_null("Props/GuardrailL_0")
	var guardrail_10 = root.get_node_or_null("Props/GuardrailL_10")
	assert_test("HW-12", guardrail_0 != null and guardrail_10 != null, "Long highway modular guardrails installed")

	# Test 6: Overhead Highway Signs
	var hw_sign = root.get_node_or_null("Props/OverheadSign_60")
	assert_test("HW-13", hw_sign != null, "Overhead Highway Sign gantry exists")

	# Test 7: Explosive Barrels
	var b0 = root.get_node_or_null("ExplosiveBarrel_0")
	assert_test("HW-14", b0 != null, "Explosive Barrels placed down the highway")

	# Test 8: No Ceiling Fan
	var fan = root.find_child("IndustrialFan", true, false)
	assert_test("HW-15", fan == null, "No IndustrialFan / ceiling fan present anywhere in scene")

	# Test 9: Player
	var player = root.get_node_or_null("Player")
	assert_test("HW-16", player != null, "Player character instantiated")
	assert_test("HW-17", player != null and player.is_in_group("player"), "Player is registered in 'player' group")

	# Test 10: Roadkill HUD
	var roadkill_hud = root.get_node_or_null("RoadkillHUD")
	assert_test("HW-18", roadkill_hud != null, "RoadkillHUD overlay exists")

	# Test 11: Real Decayed Human Zombies (No Box/Sphere Placeholders)
	var zombie_scn = load("res://scenes/zombies/Zombie.tscn") as PackedScene
	assert_test("HW-19", zombie_scn != null, "Zombie base scene loads")
	if zombie_scn:
		var z_inst = zombie_scn.instantiate()
		root.add_child(z_inst)
		await process_frame
		assert_test("HW-20", z_inst.archetype_data.has("normal"), "Archetype data contains normal")
		assert_test("HW-21", z_inst.archetype_data["normal"]["mesh"] == "res://scenes/zombies/models/RealZombieOffice.scn", "Normal zombie uses RealZombieOffice.scn")
		assert_test("HW-22", z_inst.archetype_data["fast"]["mesh"] == "res://scenes/zombies/models/RealZombieBiker.scn", "Fast zombie uses RealZombieBiker.scn")
		assert_test("HW-23", z_inst.archetype_data["heavy"]["mesh"] == "res://scenes/zombies/models/RealTitanBrute.scn", "Heavy brute uses RealTitanBrute.scn")
		z_inst.queue_free()

	# Test 12: ImpactPool & ResultUI
	var pool = root.get_node_or_null("ImpactPool")
	var r_ui = root.get_node_or_null("ResultUI")
	assert_test("HW-24", pool != null, "ImpactPool exists for blood & crash effects")
	assert_test("HW-25", r_ui != null, "ResultUI exists")

	print("\n=======================================================")
	print("   TEST RESULTS: %d / %d PASSED (Failed: %d)" % [passed_tests, total_tests, failed_tests])
	print("=======================================================\n")

	root.queue_free()
	quit(0 if failed_tests == 0 else 1)
