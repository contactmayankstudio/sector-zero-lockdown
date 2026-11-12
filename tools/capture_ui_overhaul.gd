extends SceneTree

var frame = 0
var stage = 0
var active_node = null

func _process(delta):
	frame += 1
	if stage == 0:
		if frame == 1:
			var sc = load("res://scenes/UI/MainMenu.tscn")
			active_node = sc.instantiate()
			root.add_child(active_node)
		elif frame == 18:
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png("screenshots/ui_overhaul_mainmenu.png")
				print("[SAVED] screenshots/ui_overhaul_mainmenu.png")
			active_node.queue_free()
			active_node = null
			stage = 1
			frame = 0

	elif stage == 1:
		if frame == 1:
			var sc = load("res://scenes/UI/ArmoryUI.tscn")
			active_node = sc.instantiate()
			root.add_child(active_node)
		elif frame == 20:
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png("screenshots/ui_overhaul_armory.png")
				print("[SAVED] screenshots/ui_overhaul_armory.png")
			active_node.queue_free()
			active_node = null
			stage = 2
			frame = 0

	elif stage == 2:
		if frame == 1:
			var sc = load("res://scenes/UI/MissionSelect.tscn")
			active_node = sc.instantiate()
			root.add_child(active_node)
		elif frame == 20:
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png("screenshots/ui_overhaul_missionselect.png")
				print("[SAVED] screenshots/ui_overhaul_missionselect.png")
			active_node.queue_free()
			active_node = null
			stage = 3
			frame = 0

	elif stage == 3:
		if frame == 1:
			var sc = load("res://scenes/UI/ResultUI.tscn")
			active_node = sc.instantiate()
			root.add_child(active_node)
			var m = load("res://resources/missions/mission_01.tres")
			if active_node.has_method("_on_mission_completed"):
				active_node._on_mission_completed(m)
		elif frame == 30:
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png("screenshots/ui_overhaul_result.png")
				print("[SAVED] screenshots/ui_overhaul_result.png")
			active_node.queue_free()
			print("🎉 ALL UI OVERHAUL SCREENSHOTS CAPTURED!")
			quit(0)
