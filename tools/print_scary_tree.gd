extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/zombie_scary.scn")
    var inst = res.instantiate()
    _print_node(inst, "")
    inst.free()
    quit()

func _print_node(n: Node, indent: String):
    var t_str = ""
    if n is Node3D:
        t_str = " pos=" + str(n.position) + " scale=" + str(n.scale)
    print(indent, n.name, " (", n.get_class(), ")", t_str)
    for c in n.get_children():
        _print_node(c, indent + "  ")
