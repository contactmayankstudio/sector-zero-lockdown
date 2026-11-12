extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    print("inst scale: ", inst.scale)
    for c in inst.get_children():
        print("  child: ", c.name, " scale: ", c.scale, " pos: ", c.position)
        for gc in c.get_children():
            print("    grandchild: ", gc.name, " scale: ", gc.scale, " pos: ", gc.position)
    quit(0)
