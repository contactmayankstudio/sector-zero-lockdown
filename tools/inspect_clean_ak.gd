extends SceneTree

func _init():
	var scn = load("res://scenes/weapons/models/AK74uClean.scn") as PackedScene
	if not scn:
		print("Failed to load AK74uClean.scn")
		quit(1)
		return
	var inst = scn.instantiate()
	root.add_child(inst)
	print("Clean AK-74u hierarchy:")
	for c in inst.find_children("*", "Node", true, false):
		print(" - ", c.name, " (", c.get_class(), ")")
		if c is MeshInstance3D and c.mesh:
			print("   aabb: ", c.get_aabb(), " pos: ", c.position)
	var ap = inst.find_child("AnimationPlayer", true, false)
	if ap:
		print("Animations in clean AK-74u: ", ap.get_animation_list())
	inst.free()
	quit(0)
