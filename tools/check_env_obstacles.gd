extends SceneTree
func _init():
    var envs = [
        "res://scenes/environments/AirportTerminal.tscn",
        "res://scenes/environments/AirportServiceRoad.tscn",
        "res://scenes/environments/UrbanStreet.tscn",
        "res://scenes/environments/RailwayStation.tscn",
        "res://scenes/environments/DarkIndustrial.tscn",
        "res://scenes/environments/FinalLockdown.tscn",
        "res://scenes/environments/AbandonedTrain.tscn"
    ]
    for ep in envs:
        if not ResourceLoader.exists(ep): continue
        var scn = load(ep).instantiate()
        var p = scn.get_node_or_null("Player")
        var ppos = p.position if p else Vector3.ZERO
        print("SCENE: ", ep.get_file(), " Player pos: ", ppos)
        
        # Check all StaticBody3D or MeshInstance3D in front of player (X in [-2, 2], Y in [0, 2], Z between 0 and -5 relative to player)
        var meshes = scn.find_children("*", "MeshInstance3D", true, false)
        for m in meshes:
            if not m.is_visible_in_tree() or not m.mesh: continue
            var m_pos = m.global_position
            var rel = m_pos - ppos
            if abs(rel.x) < 2.5 and rel.z < 0.5 and rel.z > -4.0 and rel.y > -0.5 and rel.y < 2.5:
                print("   OBSTACLE in front of player: ", m.name, " parent=", m.get_parent().name, " rel_pos=", rel)
        scn.free()
    quit()
