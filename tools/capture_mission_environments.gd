extends SceneTree

var current_scene_index = 0
var scenes = [
	{
		"path": "res://scenes/environments/ApartmentComplex.tscn",
		"out": "screenshots/showcase_apartment_complex.png",
		"name": "Apartment Complex (Missions 06 & 07)"
	},
	{
		"path": "res://scenes/environments/NightCityStreet.tscn",
		"out": "screenshots/showcase_night_city_street.png",
		"name": "Night City Street (Mission 08)"
	},
	{
		"path": "res://scenes/environments/AirportServiceRoad.tscn",
		"out": "screenshots/showcase_airport_service_road.png",
		"name": "Airport Service Road (Mission 02)"
	}
]

var active_inst = null
var scene_timer = 0

func _process(delta):
	scene_timer += 1
	
	if active_inst == null and current_scene_index < scenes.size():
		var sc_data = scenes[current_scene_index]
		print("[CAPTURE] Loading: ", sc_data["name"])
		var sc = load(sc_data["path"])
		active_inst = sc.instantiate()
		root.add_child(active_inst)
		scene_timer = 0
		
	elif active_inst != null:
		if scene_timer == 20:
			var sc_data = scenes[current_scene_index]
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png(sc_data["out"])
				print("[CAPTURE] Successfully saved: ", sc_data["out"])
			active_inst.queue_free()
			active_inst = null
			current_scene_index += 1
			scene_timer = 0
			
	elif current_scene_index >= scenes.size():
		print("[CAPTURE] All showcase captures finished!")
		quit(0)
