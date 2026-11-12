@tool
extends SceneTree

func _init():
	print("=== CHECKING HIPS POSITION TRACK IN WALK ANIMATION ===")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	doc.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state)
	var scene = doc.generate_scene(state)
	var ap: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
	var anim = ap.get_animation("Walk")
	
	for t in range(anim.get_track_count()):
		var p = anim.track_get_path(t)
		if "Hips" in str(p) and anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			print("Total keys: ", anim.track_get_key_count(t))
			var first_val = anim.track_get_key_value(t, 0)
			var last_val = anim.track_get_key_value(t, anim.track_get_key_count(t) - 1)
			print("First key (t=0): ", first_val)
			print("Last key (t=", anim.track_get_key_time(t, anim.track_get_key_count(t) - 1), "): ", last_val)
			print("Z delta over animation: ", last_val.z - first_val.z)
			
	scene.queue_free()
	quit(0)
