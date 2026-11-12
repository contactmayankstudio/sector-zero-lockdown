extends SceneTree
func _init():
    var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
    var inst = scn.instantiate()
    func_print(inst, "")
    quit(0)

func func_print(node, indent):
    print(indent + node.name + " (" + node.get_class() + ")")
    for c in node.get_children():
        func_print(c, indent + "  ")
