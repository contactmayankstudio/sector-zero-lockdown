extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    print("zombie_scary root class: ", inst.get_class(), " scale=", inst.scale)
    for c in inst.get_children():
        print("  child: ", c.name, " class=", c.get_class(), " scale=", c.scale, " pos=", c.position)
        for gc in c.get_children():
            print("    gc: ", gc.name, " class=", gc.get_class(), " scale=", gc.scale, " pos=", gc.position)
    inst.free()
    quit()
