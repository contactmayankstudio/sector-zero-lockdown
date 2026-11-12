extends SceneTree
func _init():
	print("Testing Zombie scene...")
	var scn = load("res://scenes/zombies/Zombie.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(5):
		await process_frame
	inst.queue_free()
	for i in range(5):
		await process_frame
	print("Zombie cleaned up. Exiting...")
	quit(0)
