extends SceneTree

var frame_count = 0
var scene_inst = null

func _process(delta):
    frame_count += 1
    if frame_count == 1:
        var urban = load("res://scenes/environments/UrbanStreet.tscn")
        scene_inst = urban.instantiate()
        root.add_child(scene_inst)
        var player = scene_inst.find_child("Player", true, false)
        if player and player.weapons.size() > 2:
            player.current_weapon_idx = 2
            player._update_weapon_visibility()
    elif frame_count == 8:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        if img:
            img.save_png("screenshots/showcase_urban_street.png")
            print("CAPTURED: screenshots/showcase_urban_street.png (", img.get_width(), "x", img.get_height(), ")")
        quit(0)
