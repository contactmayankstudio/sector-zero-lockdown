extends SceneTree
func _init():
    var res = load("res://scenes/zombies/models/RealVelociraptor.scn")
    var inst = res.instantiate()
    var meshes = inst.find_children("*", "MeshInstance3D", true, false)
    for m in meshes:
        for i in range(m.mesh.get_surface_count()):
            var mat = m.get_active_material(i)
            if mat and mat is StandardMaterial3D:
                print(m.name, " surf ", i, " mat: ", mat.resource_name, " tex: ", mat.albedo_texture.resource_path if mat.albedo_texture else "NONE", " col: ", mat.albedo_color, " rough: ", mat.roughness, " metal: ", mat.metallic)
    inst.free()
    quit()
