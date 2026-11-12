@tool
extends SceneTree
func _init():
    var s = load("res://assets/3d/vehicles/police.glb")
    var inst = s.instantiate()
    for c in inst.get_children():
        print(c.name, " pos:", c.position)
    quit(0)
