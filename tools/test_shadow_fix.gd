extends SceneTree

var frame_count = 0
var scene_inst = null

func _process(delta):
    frame_count += 1
    if frame_count == 1:
        var s = load("res://scenes/environments/UrbanStreet.tscn")
        scene_inst = s.instantiate()
        var light = scene_inst.get_node_or_null("DirectionalLight3D")
        if light:
            light.shadow_bias = 0.15
            light.directional_shadow_normal_bias = 2.0
            light.directional_shadow_max_distance = 50.0
            light.light_energy = 0.95
        root.add_child(scene_inst)
    elif frame_count == 6:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        img.save_png("preview_shadow_fixed.png")
        print("Saved preview_shadow_fixed.png")
        quit(0)
