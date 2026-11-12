@tool
extends SceneTree

func _init():
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.005
	n.fractal_octaves = 4
	print("FastNoiseLite test sample: ", n.get_noise_2d(50, 100))
	print("FastNoiseLite is fully working!")
	quit(0)
