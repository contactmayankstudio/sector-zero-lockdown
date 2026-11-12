extends Node3D

const WeatherControllerScript = preload("res://scenes/environments/WeatherController.gd")

@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var lamps: Node3D = $StreetLamps
@onready var asphalt: MeshInstance3D = $HighwayAsphalt
@onready var weather: WeatherControllerScript = $WeatherController

var tests_passed: int = 0
var tests_failed: int = 0

func _record(test_name: String, success: bool, details: String = ""):
	if success:
		tests_passed += 1
		print("[PASS] %s%s" % [test_name, " - " + details if details != "" else ""])
	else:
		tests_failed += 1
		printerr("[FAIL] %s%s" % [test_name, " - " + details if details != "" else ""])

func _ready() -> void:
	print("==================================================")
	print("STARTING ATMOSPHERIC WEATHER & LIGHTING TEST SUITE")
	print("==================================================")
	
	# Allow one frame for all node ready calls to complete
	await get_tree().process_frame
	
	await _run_all_tests()

func _run_all_tests() -> void:
	# Test 1: Verification of auto-discovery
	_test_auto_discovery()
	
	# Test 2: 4 Presets verification (instant apply)
	_test_sunny_day()
	_test_golden_sunset()
	_test_cyberpunk_night()
	_test_stormy_rain()
	
	# Test 3: CPUParticles3D Rain Emitter Dimensions & Settings
	_test_rain_emitter()
	
	# Test 4: Dynamic Keyboard Switcher [T]
	_test_keyboard_cycling()
	
	# Test 5: GTA-Style On-Screen Notification Badge
	_test_gta_badge()
	
	# Test 6: 1.5s Smooth Tweening Over Time
	await _test_smooth_tweening()
	
	print("==================================================")
	print("TEST RESULTS: %d PASSED, %d FAILED" % [tests_passed, tests_failed])
	print("==================================================")
	
	if tests_failed == 0:
		print("ALL WEATHER SYSTEM TESTS PASSED SUCCESSFULLY!")
		get_tree().quit(0)
	else:
		printerr("SOME WEATHER TESTS FAILED!")
		get_tree().quit(1)

func _test_auto_discovery() -> void:
	_record("Auto-discover DirectionalLight3D", weather.directional_light == sun)
	_record("Auto-discover WorldEnvironment", weather.world_environment == world_env)
	_record("Auto-discover StreetLamps", weather._cached_street_lights.size() == 4)
	_record("Auto-discover Road Material", weather._cached_road_materials.size() >= 1)

func _test_sunny_day() -> void:
	weather.apply_weather_preset(WeatherControllerScript.WeatherPreset.SUNNY_DAY, 0.0, false)
	var sun_ok = abs(sun.light_energy - 1.3) < 0.01 and sun.light_color.is_equal_approx(Color(1.0, 0.95, 0.88, 1.0))
	var fog_ok = abs(weather._environment.fog_density - 0.002) < 0.0001
	var rain_ok = not weather.rain_emitter.emitting
	var lamp_ok = weather._cached_street_lights[0].light_energy == 0.0
	var road_ok = abs(weather._cached_road_materials[0].roughness - 0.88) < 0.02
	_record("SUNNY_DAY Preset", sun_ok and fog_ok and rain_ok and lamp_ok and road_ok,
		"Energy: %.2f (exp 1.30), Fog: %.4f (exp 0.002), Rain: %s, Lamps: %.1f, Road Roughness: %.2f" % [
			sun.light_energy, weather._environment.fog_density, weather.rain_emitter.emitting, weather._cached_street_lights[0].light_energy, weather._cached_road_materials[0].roughness
		])

func _test_golden_sunset() -> void:
	weather.apply_weather_preset(WeatherControllerScript.WeatherPreset.GOLDEN_SUNSET, 0.0, false)
	var sun_ok = abs(sun.light_energy - 1.5) < 0.01 and sun.light_color.is_equal_approx(Color(1.0, 0.55, 0.2, 1.0))
	var fog_ok = abs(weather._environment.fog_density - 0.005) < 0.0001
	var rain_ok = not weather.rain_emitter.emitting
	var angle_ok = sun.rotation_degrees.x < -10.0 and sun.rotation_degrees.x > -20.0
	_record("GOLDEN_SUNSET Preset", sun_ok and fog_ok and rain_ok and angle_ok,
		"Energy: %.2f (exp 1.50), Fog: %.4f (exp 0.005), Low Angle: %s" % [
			sun.light_energy, weather._environment.fog_density, sun.rotation_degrees
		])

func _test_cyberpunk_night() -> void:
	weather.apply_weather_preset(WeatherControllerScript.WeatherPreset.CYBERPUNK_NIGHT, 0.0, false)
	var sun_ok = abs(sun.light_energy - 0.25) < 0.01 and sun.light_color.is_equal_approx(Color(0.2, 0.25, 0.45, 1.0))
	var fog_ok = abs(weather._environment.fog_density - 0.004) < 0.0001
	var rain_ok = not weather.rain_emitter.emitting
	var lamp_boosted = weather._cached_street_lights[0].light_energy >= 2.5
	_record("CYBERPUNK_NIGHT Preset", sun_ok and fog_ok and rain_ok and lamp_boosted,
		"Moonlight: %.2f (exp 0.25), Fog: %.4f (exp 0.004), Streetlamp Boost: %.2f (exp >= 2.5)" % [
			sun.light_energy, weather._environment.fog_density, weather._cached_street_lights[0].light_energy
		])

func _test_stormy_rain() -> void:
	weather.apply_weather_preset(WeatherControllerScript.WeatherPreset.STORMY_RAIN, 0.0, false)
	var sun_ok = abs(sun.light_energy - 0.5) < 0.01 and sun.light_color.is_equal_approx(Color(0.5, 0.55, 0.6, 1.0))
	var fog_ok = abs(weather._environment.fog_density - 0.012) < 0.0001
	var rain_ok = weather.rain_emitter.emitting == true
	var road_ok = abs(weather._cached_road_materials[0].roughness - 0.18) < 0.01 and weather._cached_road_materials[0].metallic_specular >= 0.80
	_record("STORMY_RAIN Preset", sun_ok and fog_ok and rain_ok and road_ok,
		"Overcast: %.2f (exp 0.50), Heavy Fog: %.4f (exp 0.012), Rain: %s, Wet Roughness: %.2f, Specular: %.2f" % [
			sun.light_energy, weather._environment.fog_density, weather.rain_emitter.emitting, weather._cached_road_materials[0].roughness, weather._cached_road_materials[0].metallic_specular
		])

func _test_rain_emitter() -> void:
	var emitter = weather.rain_emitter
	var is_cpu = emitter is CPUParticles3D
	var box_ok = abs(emitter.emission_box_extents.x - 20.0) < 0.1 and abs(emitter.emission_box_extents.z - 20.0) < 0.1
	var amount_ok = emitter.amount >= 800
	_record("CPUParticles3D Rain Emitter", is_cpu and box_ok and amount_ok,
		"Is CPUParticles3D: %s, Coverage Box: %.1fx%.1fm, Particles: %d" % [
			is_cpu, emitter.emission_box_extents.x * 2.0, emitter.emission_box_extents.z * 2.0, emitter.amount
		])

func _test_keyboard_cycling() -> void:
	weather.current_preset = WeatherControllerScript.WeatherPreset.SUNNY_DAY
	var ev = InputEventKey.new()
	ev.pressed = true
	ev.keycode = KEY_T
	
	weather.call("_unhandled_input", ev)
	var step1 = weather.current_preset == WeatherControllerScript.WeatherPreset.GOLDEN_SUNSET
	weather.call("_unhandled_input", ev)
	var step2 = weather.current_preset == WeatherControllerScript.WeatherPreset.CYBERPUNK_NIGHT
	weather.call("_unhandled_input", ev)
	var step3 = weather.current_preset == WeatherControllerScript.WeatherPreset.STORMY_RAIN
	weather.call("_unhandled_input", ev)
	var step4 = weather.current_preset == WeatherControllerScript.WeatherPreset.SUNNY_DAY
	
	_record("Key [T] Real-Time Cycle", step1 and step2 and step3 and step4,
		"Cycled through all 4 presets sequentially")

func _test_gta_badge() -> void:
	var has_layer = weather._badge_layer != null
	var has_panel = weather._badge_panel != null
	var has_labels = weather._badge_title_label != null and weather._badge_subtitle_label != null
	var title_text = weather._badge_title_label.text
	_record("GTA 5 Style Badge UI", has_layer and has_panel and has_labels,
		"Layer: %s, Panel: %s, Current Title: '%s'" % [has_layer, has_panel, title_text])

func _test_smooth_tweening() -> void:
	print("[TWEEN] Testing smooth 1.5s transition from SUNNY_DAY -> GOLDEN_SUNSET...")
	weather.apply_weather_preset(WeatherControllerScript.WeatherPreset.SUNNY_DAY, 0.0, false)
	weather.apply_weather_preset(WeatherControllerScript.WeatherPreset.GOLDEN_SUNSET, 1.5, true)
	
	# Wait for transition duration + small margin
	await get_tree().create_timer(1.6).timeout
	
	var sun_tweened = abs(sun.light_energy - 1.5) < 0.05
	var fog_tweened = abs(weather._environment.fog_density - 0.005) < 0.0005
	_record("1.5s Smooth Tween Transition", sun_tweened and fog_tweened,
		"Final Energy: %.2f (target 1.50), Final Fog: %.4f (target 0.0050)" % [
			sun.light_energy, weather._environment.fog_density
		])
