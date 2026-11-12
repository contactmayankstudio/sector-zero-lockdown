extends SceneTree

var frame: int = 0
var player: CharacterBody3D = null

func _init():
	var s = load("res://scenes/environments/UrbanStreet.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	player = inst.find_child("Player", true, false)
	for z in inst.find_children("*", "EnemyBase", true, false):
		z.queue_free()

func _process(delta: float) -> bool:
	frame += 1
	if frame == 4:
		for i in range(player.weapons.size()):
			if player.weapons[i].weapon_data and player.weapons[i].weapon_data.weapon_id == "akx_scifi":
				player.switch_to_weapon(i)
				var wm = player.weapons[i].get_node_or_null("WeaponModel")
				if wm:
					wm.rotation_degrees = Vector3(90.0, 0.0, 180.0)
					wm.position = Vector3(0.12, -0.16, -0.35)
					wm.scale = Vector3(0.85, 0.85, 0.85)
				break
	elif frame == 10:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			var path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_akx_perfect_front.png"
			img.save_png(path)
			print("[CAPTURED] ", path)
		return true
	return false
