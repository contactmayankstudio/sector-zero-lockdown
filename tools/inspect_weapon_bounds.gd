extends SceneTree

func _init():
    var paths = [
        "res://assets/3d/weapons/downloaded/minigun_m134.glb",
        "res://assets/3d/weapons/downloaded/flatline_rifle.glb",
        "res://assets/3d/weapons/downloaded/car_smg.glb",
        "res://assets/3d/weapons/downloaded/sniper_vantage.glb",
        "res://assets/3d/weapons/downloaded/combat_shotgun.glb",
        "res://assets/3d/weapons/downloaded/tavor_rifle.glb",
        "res://assets/3d/weapons/downloaded/tactical_sword.glb"
    ]
    for p in paths:
        var res = load(p)
        if res:
            var inst = res.instantiate()
            var aabb = AABB()
            var first = true
            for c in inst.find_children("*", "VisualInstance3D"):
                if c is VisualInstance3D:
                    var baabb = c.get_aabb()
                    if first:
                        aabb = baabb
                        first = false
                    else:
                        aabb = aabb.merge(baabb)
            print(p.get_file(), " -> aabb pos:", aabb.position, " size:", aabb.size)
            inst.queue_free()
    quit(0)
