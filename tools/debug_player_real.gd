extends SceneTree

var frame_count = 0

func _process(delta):
    frame_count += 1
    if frame_count == 2:
        var save_mgr = root.get_node_or_null("SaveManager")
        print("SaveManager: ", save_mgr)
        if save_mgr:
            print("unlocked_weapons: ", save_mgr.data.get("unlocked_weapons"))

        var s = load("res://scenes/player/Player.tscn")
        var p = s.instantiate()
        root.add_child(p)
        print("Player weapons count: ", p.weapons.size())
        for i in range(p.weapons.size()):
            var w = p.weapons[i]
            print(" Weapon ", i, ": id=", w.weapon_data.weapon_id if w.weapon_data else "none", " visible=", w.visible)
            for c in w.get_children():
                print("    c: ", c.name, " vis=", c.visible if "visible" in c else "n/a")
        p.queue_free()
        quit(0)
