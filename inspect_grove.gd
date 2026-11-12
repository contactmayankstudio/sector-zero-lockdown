
extends SceneTree
func _init():
    var s = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
    if s:
        var inst = s.instantiate()
        print("Root:", inst.name, "children:", inst.get_child_count())
        for c in inst.get_children():
            print(" -", c.name, "(", c.get_class(), ")")
    quit(0)
