@tool
extends SceneTree

func _init():
	print("=== CHECKING BUILT-IN ANIMATIONS IN scary_zombie_pack.glb ===")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	doc.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state)
	var scene = doc.generate_scene(state)
	
	var aps = scene.find_children("*", "AnimationPlayer", true, false)
	print("Animation players found: ", aps.size())
	for ap in aps:
		print("AnimationPlayer: ", ap.name)
		for lib_name in ap.get_animation_library_list():
			var lib = ap.get_animation_library(lib_name)
			print("  Lib '", lib_name, "': ", lib.get_animation_list())
			for anim_name in lib.get_animation_list():
				var anim = lib.get_animation(anim_name)
				print("    Anim: ", anim_name, " len: ", anim.length, " tracks: ", anim.get_track_count())
				for t in range(anim.get_track_count()):
					var p = anim.track_get_path(t)
					if "hips" in str(p).to_lower():
						print("      Hips track: ", p, " type: ", anim.track_get_type(t))
						if anim.track_get_key_count(t) > 0:
							print("        Key 0: ", anim.track_get_key_value(t, 0))
	scene.queue_free()
	quit(0)
