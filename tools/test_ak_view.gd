extends SceneTree

var frame_count: int = 0
var scene_inst: Node3D = null
var player: Node3D = null

func _process(delta: float):
	frame_count += 1
	if frame_count == 1:
		var s = load("res://scenes/environments/UrbanStreet.tscn") as PackedScene
		scene_inst = s.instantiate()
		root.add_child(scene_inst)
	elif frame_count == 10:
		player = scene_inst.find_child("Player", true, false)
		if player:
			for idx in range(player.weapons.size()):
				var w = player.weapons[idx]
				if w.weapon_data and w.weapon_data.weapon_id == "ak74u":
					player.switch_to_weapon(idx)
					print("Switched to AK-74u at index: ", idx)
					break
			var cam = player.find_child("Camera3D", true, false)
			if cam:
				cam.rotation_degrees.x = -8.0
	elif frame_count == 35:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/test_ak74u_in_hands.png")
			print("[SAVED] screenshots/test_ak74u_in_hands.png")
		quit(0)
