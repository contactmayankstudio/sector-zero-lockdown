@tool
extends SceneTree

func _init():
	print("Testing NoiseTexture2D generation with as_normal_map...")
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.02
	noise.fractal_octaves = 3
	
	var noise_tex = NoiseTexture2D.new()
	noise_tex.width = 256
	noise_tex.height = 256
	noise_tex.seamless = true
	noise_tex.as_normal_map = true
	noise_tex.bump_strength = 6.0
	noise_tex.noise = noise
	
	print("NoiseTexture2D configured cleanly!")
	quit(0)
