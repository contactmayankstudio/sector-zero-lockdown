@tool
extends SceneTree
func _init():
    var files = [
        "res://scenes/zombies/models/zombie_scary.scn",
        "res://scenes/zombies/models/RealZombieOffice.scn",
        "res://scenes/zombies/models/RealZombieBiker.scn",
        "res://scenes/zombies/models/RealZombie6ft.scn",
        "res://scenes/zombies/models/RealVelociraptor.scn",
        "res://scenes/zombies/Zombie.tscn"
    ]
    for p in files:
        if ResourceLoader.exists(p):
            var res = load(p)
            var inst = res.instantiate()
            print("=== File: ", p, " ===")
            print("  Root class: ", inst.get_class(), " pos: ", inst.position)
            for c in inst.find_children("*", "VisualInstance3D", true, false):
                if c is GeometryInstance3D:
                    var aabb = c.get_aabb()
                    print("  Child: ", c.name, " (", c.get_class(), ") pos: ", c.position, " AABB: [P: ", aabb.position, " S: ", aabb.size, "] MinY: ", aabb.position.y, " MaxY: ", aabb.end.y)
    quit(0)
