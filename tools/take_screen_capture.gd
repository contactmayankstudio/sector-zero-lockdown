extends SceneTree

var _frames: int = 0
var _saved: bool = false

func _init():
	change_scene_to_file("res://scenes/environments/CityCarZombieArena.tscn")

func _process(_delta: float) -> bool:
	if _saved:
		return true
	var arena = root.get_node_or_null("CityCarZombieArena")
	if arena and arena.is_inside_tree():
		_frames += 1
		if _frames >= 100:
			_saved = true
			var vp = root.get_viewport()
			if vp:
				var tex = vp.get_texture()
				if tex:
					var img = tex.get_image()
					if img:
						img.save_png("/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/live_clear_drivable_preview.png")
						print("CAPTURED_SUCCESS!")
			quit(0)
			return true
	return false
