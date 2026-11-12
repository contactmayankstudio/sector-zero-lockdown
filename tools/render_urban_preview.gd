extends Node3D

func _ready():
	var scn = load("res://scenes/environments/UrbanStreet.tscn")
	var level = scn.instantiate()
	add_child(level)
	
	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 75.0
	add_child(cam)
	
	# Position camera behind player looking down the barricade street
	cam.global_position = Vector3(0.0, 2.2, 3.2)
	cam.look_at(Vector3(0.0, 1.2, -10.0))
	
	await get_tree().create_timer(1.0).timeout
	
	var img = get_viewport().get_texture().get_image()
	var path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/preview_urban_street.png"
	img.save_png(path)
	print("SAVED: " + path)
	get_tree().quit()
