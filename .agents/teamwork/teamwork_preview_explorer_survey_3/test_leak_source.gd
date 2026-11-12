extends SceneTree
func _init():
	print("Testing Player scene...")
	var scn = load("res://scenes/player/Player.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(5):
		await process_frame
	inst.queue_free()
	for i in range(5):
		await process_frame
	print("Player cleaned up. Exiting...")
	quit(0)
