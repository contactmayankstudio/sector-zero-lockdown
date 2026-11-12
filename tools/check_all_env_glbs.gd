extends SceneTree
func _init():
    var files = ["airport_terminal.glb", "airport_terminal_section.glb", "boss_arena.glb", "industrial_street.glb", "railway_station.glb", "train_carriage.glb"]
    for f in files:
        var p = "res://assets/3d/environments/" + f
        var res = load(p)
        if res:
            var inst = res.instantiate()
            print("=== File: ", f, " ===")
            for c in inst.get_children():
                if c is MeshInstance3D and c.mesh:
                    print("  ", c.name, " pos: ", c.position, " aabb: ", c.mesh.get_aabb())
    quit(0)
