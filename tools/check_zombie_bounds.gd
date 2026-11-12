extends SceneTree
func _init():
    var models = [
        "res://scenes/zombies/models/zombie_scary.scn",
        "res://scenes/zombies/models/RealZombieOffice.scn",
        "res://scenes/zombies/models/RealZombieBiker.scn",
        "res://scenes/zombies/models/RealZombie6ft.scn",
        "res://scenes/zombies/models/RealTitanBrute.scn",
        "res://scenes/zombies/models/RealVelociraptor.scn",
        "res://scenes/zombies/models/RealButcherBoss.scn",
        "res://scenes/zombies/models/zombie_realistic_human.scn"
    ]
    for path in models:
        if not ResourceLoader.exists(path):
            print("NOT FOUND: ", path)
            continue
        var res = load(path)
        var inst = res.instantiate()
        var aabb = AABB()
        var first = true
        var meshes = inst.find_children("*", "MeshInstance3D", true, false)
        for m in meshes:
            if m.mesh:
                var maabb = m.transform * m.mesh.get_aabb()
                if first:
                    aabb = maabb
                    first = false
                else:
                    aabb = aabb.merge(maabb)
        print("MODEL [%s]: AABB pos=%s size=%s (Y range: %.2f to %.2f)" % [path.get_file(), str(aabb.position), str(aabb.size), aabb.position.y, aabb.position.y + aabb.size.y])
        for m in meshes:
            print("   Mesh: %s, surfs=%d" % [m.name, m.mesh.get_surface_count() if m.mesh else 0])
            for i in range(m.mesh.get_surface_count() if m.mesh else 0):
                var mat = m.get_active_material(i)
                if mat and mat is StandardMaterial3D:
                    print("     Surf %d: mat=%s albedo_col=%s tex=%s" % [i, mat.resource_name, str(mat.albedo_color), "yes" if mat.albedo_texture else "no"])
        inst.free()
    quit()
