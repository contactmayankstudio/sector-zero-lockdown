extends SceneTree
func _init():
    var sky = load("res://resources/materials/mat_hdri_sky.tres")
    print("SKY: ", sky)
    var env = load("res://resources/materials/env_apocalyptic_hdri.tres")
    print("ENV: ", env)
    if env:
        print("tonemap_mode:", env.tonemap_mode)
        print("ambient_energy:", env.ambient_light_energy)
        print("sky:", env.sky)
    quit(0)
