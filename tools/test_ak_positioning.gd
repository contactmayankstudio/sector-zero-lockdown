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
			# Adjust ak74u Model transform
			var ak_model_root = player.find_child("ak74u", true, false)
			if ak_model_root:
				var m = ak_model_root.find_child("Model", true, false)
				if m:
					# Offset to cancel the animation's bone offset:
					# Bone 44 is at (-0.067, -0.173, 1.435)
					# Let's align to camera weapon mount point:
					m.position = Vector3(0.067, 0.173, -1.435)
					print("Applied offset to Model: ", m.position)
	elif frame_count == 35:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/test_ak74u_offset_1.png")
			print("[SAVED] screenshots/test_ak74u_offset_1.png")
		quit(0)
