extends SceneTree

var frame = 0
var player = null
var current_idx = 0
var weapon_ids = ["p90", "negev_ng7", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]

func _init():
	print("--- RENDER ALL WEAPONS VISUAL CHECK ---")
	var s = load("res://scenes/environments/UrbanStreet.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	player = inst.find_child("Player", true, false)

func _process(delta):
	frame += 1
	if frame % 10 == 5:
		if current_idx < weapon_ids.size():
			var wid = weapon_ids[current_idx]
			# Switch to weapon
			for i in range(player.weapons.size()):
				if player.weapons[i].weapon_data and player.weapons[i].weapon_data.weapon_id == wid:
					player.switch_to_weapon(i)
					print("Switched to ", wid)
					break
		elif current_idx == weapon_ids.size():
			print("All screenshots captured!")
			quit(0)
	elif frame % 10 == 9:
		if current_idx < weapon_ids.size():
			var wid = weapon_ids[current_idx]
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				var path = "screenshots/weapon_" + wid + ".png"
				img.save_png(path)
				print("[CAPTURED] ", path)
			current_idx += 1
