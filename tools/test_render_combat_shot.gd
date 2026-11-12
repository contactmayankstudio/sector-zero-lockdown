extends SceneTree

var frame_count: int = 0
var scene_inst: Node3D = null
var player: Node3D = null
var zombie: Node3D = null

const REALISTIC_ZOMBIE_SCN = preload("res://assets/zombies/RealisticZombie.tscn")

func _process(delta: float):
	frame_count += 1
	
	if frame_count == 1:
		var s = load("res://scenes/environments/UrbanStreet.tscn") as PackedScene
		scene_inst = s.instantiate()
		root.add_child(scene_inst)
		
	elif frame_count == 8:
		player = scene_inst.find_child("Player", true, false)
		if player:
			# Equip Flatline rifle (index 2)
			for idx in range(player.weapons.size()):
				var w = player.weapons[idx]
				if w.weapon_data and w.weapon_data.weapon_id == "flatline":
					player.switch_to_weapon(idx)
					break
			var cam = player.find_child("Camera3D", true, false)
			if cam:
				cam.rotation_degrees.x = -8.0
				
		# Spawn soldier zombie directly in crosshair range
		zombie = REALISTIC_ZOMBIE_SCN.instantiate()
		zombie.archetype = "soldier"
		scene_inst.add_child(zombie)
		zombie.global_position = Vector3(0.0, 0.05, -2.6)
		# Face towards the player
		zombie.rotation.y = 0.0
		
	elif frame_count == 35:
		# Capture weapon aimed directly at approaching zombie
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/live_gameplay_zombie_aim.png")
			print("[SAVED] screenshots/live_gameplay_zombie_aim.png")
			
		# Fire lethal headshot
		print("[COMBAT] FIRING LETHAL HEADSHOT!")
		if zombie and is_instance_valid(zombie):
			zombie.take_damage(500.0, true, Vector3(0, 0, -1))
			
	elif frame_count == 42:
		# Capture mid-air arterial blood fountain and headless neck socket
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/live_gameplay_headshot_burst.png")
			print("[SAVED] screenshots/live_gameplay_headshot_burst.png")
		quit(0)
