@tool
extends SceneTree

func _init():
	print("=== CHECKING ALL ANIMATIONS POSITION TRACKS ===")
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	doc.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state)
	var scene = doc.generate_scene(state)
	var ap: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
	
	for anim_name in ["Idle", "Walk", "Attack_mixamo_vitruvian", "Death_mixamo_vitruvian", "HitReaction_mixamo_vitruvian"]:
		if not ap.has_animation(anim_name):
			print("Missing: ", anim_name)
			continue
		var anim = ap.get_animation(anim_name)
		print("\nAnim: ", anim_name, " len=", anim.length)
		for t in range(anim.get_track_count()):
			if anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
				var p = anim.track_get_path(t)
				var k0 = anim.track_get_key_value(t, 0)
				print("  Pos track: ", p, " k0=", k0)
				
	scene.queue_free()
	quit(0)
