extends SceneTree

var frame_count = 0
var scene_inst = null

func _process(delta):
	frame_count += 1
	if frame_count == 1:
		var s = load("res://scenes/environments/UrbanStreet.tscn")
		scene_inst = s.instantiate()
		root.add_child(scene_inst)
		var player = scene_inst.find_child("Player", true, false)
		if player:
			for idx in range(player.weapons.size()):
				if player.weapons[idx].weapon_data and player.weapons[idx].weapon_data.weapon_id == "flatline":
					player.switch_to_weapon(idx)
					break
	elif frame_count == 50:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/gameplay_real_grove_flatline.png")
			print("Saved screenshots/gameplay_real_grove_flatline.png")
	elif frame_count == 80:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/gameplay_real_grove_zombies_advancing.png")
			print("Saved screenshots/gameplay_real_grove_zombies_advancing.png")
		quit(0)
