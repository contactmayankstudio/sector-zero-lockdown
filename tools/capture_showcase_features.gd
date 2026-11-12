extends SceneTree

var frame_count = 0
var street_instance = null
var player = null
var boss = null
var ammo_drop = null

func _process(delta):
	frame_count += 1
	
	if frame_count == 1:
		var scene = load("res://scenes/environments/UrbanStreet.tscn")
		street_instance = scene.instantiate()
		root.add_child(street_instance)
		
		player = street_instance.find_child("Player", true, false)
		if player:
			# Switch to AK74u
			for idx in range(player.weapons.size()):
				if player.weapons[idx].weapon_data and player.weapons[idx].weapon_data.weapon_id == "ak74u":
					player.switch_to_weapon(idx)
					print("[CAPTURE] Equipped AK-74u at weapon index ", idx)
					break
		
		# Spawn Butcher Boss directly ahead in clear view
		var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
		if boss_scene:
			boss = boss_scene.instantiate()
			boss.position = Vector3(0.0, 0.0, -7.5)
			boss.rotation.y = 0.0 # Facing player
			street_instance.add_child(boss)
			print("[CAPTURE] Spawned Butcher Boss at ", boss.position)
		
		# Spawn Ammo Pickup Box on the road in clear view
		var ammo_scene = load("res://scenes/pickups/AmmoPickup.tscn")
		if ammo_scene:
			ammo_drop = ammo_scene.instantiate()
			ammo_drop.position = Vector3(0.6, 0.1, -2.8)
			street_instance.add_child(ammo_drop)
			print("[CAPTURE] Spawned 3D Ammo Pickup at ", ammo_drop.position)

	elif frame_count == 25:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/showcase_ak74u_butcher_boss.png")
			print("[CAPTURE] Saved screenshots/showcase_ak74u_butcher_boss.png")
			
	elif frame_count == 30:
		# Angle camera slightly towards the wrecked police car on the left
		if player:
			var cam = player.find_child("Camera3D", true, false)
			if cam:
				cam.rotation_degrees.y = 25.0
				cam.rotation_degrees.x = -6.0
				
	elif frame_count == 35:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/showcase_wrecked_police_cars.png")
			print("[CAPTURE] Saved screenshots/showcase_wrecked_police_cars.png")
		quit(0)
