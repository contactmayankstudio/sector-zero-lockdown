extends SceneTree
func _init():
    var res = load("res://scenes/environments/AirportTerminal.tscn")
    var scene = res.instantiate()
    var glb = scene.get_node_or_null("AirportTerminalGLB")
    print("AirportTerminalGLB: ", glb)
    # Check triangles near (0, 1.6, 0)
    var meshes = glb.find_children("*", "MeshInstance3D", true, false)
    for m in meshes:
        var m_data = m.mesh
        for s in range(m_data.get_surface_count()):
            var arrs = m_data.surface_get_arrays(s)
            var verts = arrs[Mesh.ARRAY_VERTEX]
            var near_count = 0
            for v in verts:
                var gv = m.global_transform * v
                if abs(gv.x) < 2.0 and abs(gv.y - 1.6) < 1.5 and gv.z > -3.0 and gv.z < 2.0:
                    near_count += 1
            print("Surface ", s, " has ", near_count, " vertices within 2m of player face!")
    scene.free()
    quit()
