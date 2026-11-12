extends SceneTree
func _init():
    var res = load("res://assets/3d/environments/airport_terminal.glb")
    var inst = res.instantiate()
    var meshes = inst.find_children("*", "MeshInstance3D", true, false)
    for m in meshes:
        var aabb = m.transform * m.mesh.get_aabb()
        print("GLB Mesh: %s, pos=%s aabb_min=%s aabb_max=%s" % [m.name, m.position, aabb.position, aabb.position + aabb.size])
    inst.free()
    quit()
