extends SceneTree

func _init():
    var save_mgr = root.get_node_or_null("SaveManager")
    print("SaveManager in tree: ", save_mgr)
    if save_mgr:
        print("SaveManager data: ", save_mgr.data)
        print("unlocked_weapons: ", save_mgr.data.get("unlocked_weapons"))

    var s = load("res://scenes/player/Player.tscn")
    var p = s.instantiate()
    root.add_child(p)
    print("p.weapons: ", p.weapons.size())
    p.queue_free()
    quit(0)
