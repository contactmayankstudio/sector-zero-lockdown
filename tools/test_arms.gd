
extends SceneTree
func _init():
	var res = load("res://assets/3d/weapons/fps_arms_realistic.glb")
	if not res:
		print("FAILED to load fps_arms_realistic.glb")
		quit(1)
		return
	print("SUCCESS! Loaded fps_arms_realistic.glb:", res)
	var inst = res.instantiate()
	print("Root inst:", inst.name)
	for child in inst.get_children():
		print("  Child:", child.name, " type:", child.get_class())
	quit(0)
