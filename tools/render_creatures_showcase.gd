extends SceneTree

var frame = 0
var active_scene_node = null

func _process(delta):
	frame += 1
	if frame == 1:
		var s = load("res://scenes/environments/ApartmentComplex.tscn")
		active_scene_node = s.instantiate()
		root.add_child(active_scene_node)
		
		# Spawn Infected Dog (Hound)
		var dog_scene = load("res://scenes/zombies/InfectedDog.tscn")
		if dog_scene:
			var dog = dog_scene.instantiate()
			dog.position = Vector3(-0.6, 0.0, -3.0)
			dog.rotation.y = PI * 0.85
			active_scene_node.add_child(dog)
			
		# Spawn Alien Mutant using RealisticZombie
		var rz_scene = load("res://assets/zombies/RealisticZombie.tscn")
		if rz_scene:
			var mutant = rz_scene.instantiate()
			mutant.archetype = "mutant"
			mutant.position = Vector3(0.0, 0.0, -3.8)
			mutant.rotation.y = PI
			active_scene_node.add_child(mutant)
			
			# Spawn Reptile Mutant
			var reptile = rz_scene.instantiate()
			reptile.archetype = "reptile"
			reptile.position = Vector3(0.7, 0.0, -4.2)
			reptile.rotation.y = PI * 1.15
			active_scene_node.add_child(reptile)
			
		# Ensure player camera is positioned facing them
		var player = active_scene_node.find_child("Player", true, false)
		if player:
			player.position = Vector3(0.0, 0.0, 0.0)
			player.rotation.y = 0.0

	elif frame == 25:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			DirAccess.make_dir_absolute("screenshots")
			img.save_png("screenshots/showcase_new_creatures.png")
			print("[CAPTURED] screenshots/showcase_new_creatures.png")
		quit(0)
