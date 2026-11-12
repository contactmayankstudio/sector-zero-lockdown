extends SceneTree

func _init():
    var s = load("res://scenes/environments/UrbanStreet.tscn")
    var inst = s.instantiate()
    root.add_child(inst)
    var p = inst.get_node_or_null("Player")
    print("Player node:", p)
    if p:
        print("Weapons count:", p.weapons.size())
        for i in range(p.weapons.size()):
            var w = p.weapons[i]
            var wid = w.weapon_data.weapon_id if w.weapon_data else "unknown"
            var wname = w.weapon_data.weapon_name if w.weapon_data else "unnamed"
            print("Weapon ", i, ": id=", wid, " name=", wname, " visible=", w.visible)
            for c in w.get_children():
                print("   child:", c.name, " type=", c.get_class(), " visible=", c.visible if "visible" in c else "n/a")
    inst.queue_free()
    quit(0)
