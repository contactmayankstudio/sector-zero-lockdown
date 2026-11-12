@tool
extends SceneTree

func _init():
	print("=== CHECKING vitruvian_full_rigged.glb ANIMATION TRACKS ===")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	doc.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state)
	var scene = doc.generate_scene(state)
	
	var ap: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
	var anim = ap.get_animation("Walk")
	print("Walk track count: ", anim.get_track_count())
	for t in range(anim.get_track_count()):
		var p = anim.track_get_path(t)
		var type = anim.track_get_type(t)
		if type == Animation.TYPE_POSITION_3D:
			print("POSITION track: ", p)
			for k in range(min(5, anim.track_get_key_count(t))):
				print("   key ", k, " t=", anim.track_get_key_time(t, k), " val=", anim.track_get_key_value(t, k))
	
	scene.queue_free()
	quit(0)
