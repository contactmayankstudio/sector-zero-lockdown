extends SceneTree
func _init():
	var q = Quaternion(0.251641, 0.630789, 0.682918, 0.269084)
	print("Euler degrees:", q.get_euler() * 180.0 / PI)
	var q_walk = Quaternion(-0.01515, 0.718885, 0.69491, -0.008705)
	print("Walk Euler degrees:", q_walk.get_euler() * 180.0 / PI)
	quit(0)
