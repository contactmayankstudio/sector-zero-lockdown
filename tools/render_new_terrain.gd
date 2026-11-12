extends Node3D

func _ready():
	var arena_scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = arena_scene.instantiate()
	add_child(arena)
	
	# Place camera to see the highway, grass, real trees, and mountains
	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 72.0
	add_child(cam)
	
	# View 1: Standing on highway looking toward West Mountain, trees, and ground
	cam.global_position = Vector3(0.0, 3.5, -110.0)
	cam.look_at(Vector3(-70.0, 15.0, -160.0))
	
	await get_tree().create_timer(1.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	var path1 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/clean_photorealistic_valley_view1.png"
	img.save_png(path1)
	print("SAVED: " + path1)
	
	# View 2: High angle panoramic view of the whole alpine valley and pure sky
	cam.global_position = Vector3(15.0, 35.0, -30.0)
	cam.look_at(Vector3(-60.0, 15.0, -180.0))
	
	await get_tree().create_timer(0.6).timeout
	var img2 = get_viewport().get_texture().get_image()
	var path2 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/clean_photorealistic_valley_view2.png"
	img2.save_png(path2)
	print("SAVED: " + path2)
	
	get_tree().quit()
