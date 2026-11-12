extends SceneTree
func _init():
    var res = load("res://assets/3d/environments/railway_station.glb")
    var inst = res.instantiate()
    var mi = inst.get_child(0) as MeshInstance3D
    var m = mi.mesh
    print("Surfaces: ", m.get_surface_count())
    for i in range(m.get_surface_count()):
        var mat = m.surface_get_material(i)
        print("  mat ", i, ": ", mat)
        if mat is StandardMaterial3D:
            print("    albedo: ", mat.albedo_color, " tex: ", mat.albedo_texture)
    quit(0)
