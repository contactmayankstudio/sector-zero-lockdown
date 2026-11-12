extends SceneTree
func _init():
	print("Testing Zombie scene with physics frames cleanup...")
	var scn = load("res://scenes/zombies/Zombie.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(10):
		await physics_frame
	inst.queue_free()
	for i in range(20):
		await physics_frame
	print("Finished cleanup. Exiting...")
	quit(0)
