extends SceneTree
func _init():
    var s = load("res://assets/3d/environments/railway_station.glb")
    var inst = s.instantiate()
    print("RailwayStationGLB children:")
    for c in inst.get_children():
        print("  child: ", c.name, " type: ", c.get_class(), " pos: ", c.position)
        if c is MeshInstance3D and c.mesh:
            print("    mesh bounds: ", c.mesh.get_aabb())
    quit(0)
