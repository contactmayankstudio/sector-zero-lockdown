extends SceneTree

var frame = 0
var player = null
var current_test = 0

var tests = [
	{"rot": Vector3(-15.0, 0.0, 0.0), "offset": Vector3(-0.06, 0.0, 0.0), "scale": Vector3(0.7, 0.7, 0.7)},
	{"rot": Vector3(-25.0, 0.0, 0.0), "offset": Vector3(-0.06, 0.02, 0.05), "scale": Vector3(0.65, 0.65, 0.65)},
	{"rot": Vector3(-35.0, 0.0, 0.0), "offset": Vector3(-0.06, 0.04, 0.08), "scale": Vector3(0.65, 0.65, 0.65)},
	{"rot": Vector3(-45.0, 0.0, 0.0), "offset": Vector3(-0.06, 0.05, 0.1), "scale": Vector3(0.65, 0.65, 0.65)}
]

func _init():
	var s = load("res://scenes/environments/UrbanStreet.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	player = inst.find_child("Player", true, false)

func _process(delta):
	frame += 1
	if frame % 8 == 3:
		if current_test < tests.size():
			var t = tests[current_test]
			for i in range(player.weapons.size()):
				if player.weapons[i].weapon_data and player.weapons[i].weapon_data.weapon_id == "akx_scifi":
					player.switch_to_weapon(i)
					var wm = player.weapons[i].get_node_or_null("WeaponModel")
					if wm:
						wm.rotation_degrees = t.rot
						wm.position = t.offset
						wm.scale = t.scale
					break
		else:
			quit(0)
	elif frame % 8 == 7:
		if current_test < tests.size():
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				var path = "screenshots/tune_akx_" + str(current_test) + ".png"
				img.save_png(path)
				print("[CAPTURED] ", path)
			current_test += 1
