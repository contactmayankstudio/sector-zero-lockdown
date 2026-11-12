extends SceneTree
func _init():
    var res = load("res://scenes/environments/AirportTerminal.tscn")
    var scene = res.instantiate()
    print("--- AirportTerminal Children ---")
    for c in scene.get_children():
        print(c.name, " (", c.get_class(), ") pos=", c.position if "position" in c else "")
        if c.name == "AirportTerminalGLB":
            for gc in c.get_children():
                print("   GLB child: ", gc.name, " pos=", gc.position if "position" in gc else "")
                for ggc in gc.get_children():
                    print("      GLB gchild: ", ggc.name, " pos=", ggc.position if "position" in ggc else "")
        elif c.name == "Props":
            for gc in c.get_children():
                print("   Prop: ", gc.name, " pos=", gc.position if "position" in gc else "")
    scene.free()
    quit()
