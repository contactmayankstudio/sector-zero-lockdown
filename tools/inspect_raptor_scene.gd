@tool
extends SceneTree

func _init():
	print("=== DETAILED REALVELOCIRAPTOR.SCN INSPECTION ===")
	var scn = load("res://scenes/zombies/models/RealVelociraptor.scn")
	var inst = scn.instantiate()
	
	print("Root name: ", inst.name, " class: ", inst.get_class())
	_print_tree(inst, 0)
	
	var ap: AnimationPlayer = inst.find_children("*", "AnimationPlayer", true, false)[0]
	print("\n--- ANIMATIONS ---")
	for anim_name in ap.get_animation_list():
		var anim = ap.get_animation(anim_name)
		print("Anim '", anim_name, "' length: ", anim.length, " tracks: ", anim.get_track_count())
		for t in range(anim.get_track_count()):
			var path = anim.track_get_path(t)
			var type = anim.track_get_type(t)
			if "root" in str(path).to_lower() or "hip" in str(path).to_lower() or "spine" in str(path).to_lower():
				print("  track: ", path, " type: ", type)
				if type == Animation.TYPE_POSITION_3D:
					for k in range(min(3, anim.track_get_key_count(t))):
						print("    pos key ", k, ": ", anim.position_track_interpolate(t, anim.track_get_key_time(t, k)))
				elif type == Animation.TYPE_ROTATION_3D:
					for k in range(min(3, anim.track_get_key_count(t))):
						print("    rot key ", k, ": ", anim.rotation_track_interpolate(t, anim.track_get_key_time(t, k)))
	inst.free()
	quit(0)

func _print_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	var extra = ""
	if node is Node3D:
		extra = " pos=" + str(node.position) + " rot=" + str(node.rotation) + " scale=" + str(node.scale)
	print(indent, "- ", node.name, " (", node.get_class(), ")", extra)
	for c in node.get_children():
		_print_tree(c, depth + 1)
