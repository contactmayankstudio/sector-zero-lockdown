extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/ak74u.tscn")
	var inst = s.instantiate()
	root.add_child(inst)
	await process_frame
	await process_frame
	
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", m.name, " vis: ", m.visible, " global_pos: ", m.global_position)
		
	var ap = inst.find_child("AnimationPlayer", true, false)
	if ap:
		print("Animations: ", ap.get_animation_list())
		print("Current animation: ", ap.current_animation)
		
	inst.free()
	quit(0)
