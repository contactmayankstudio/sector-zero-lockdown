extends SceneTree
func _init():
    print("--- VALIDATION START ---")
    var scenes = [
        "res://scenes/environments/AirportTerminal.tscn",
        "res://scenes/environments/UrbanStreet.tscn",
        "res://scenes/environments/AirportServiceRoad.tscn",
        "res://scenes/environments/RailwayStation.tscn",
        "res://scenes/environments/DarkIndustrial.tscn",
        "res://scenes/environments/FinalLockdown.tscn",
        "res://scenes/environments/AbandonedTrain.tscn",
        "res://scenes/zombies/Zombie.tscn",
        "res://scenes/player/Player.tscn"
    ]
    for sp in scenes:
        var res = load(sp)
        if not res:
            print("FAILED TO LOAD: ", sp)
        else:
            var inst = res.instantiate()
            print("LOADED OK: ", sp, " (", inst.name, ")")
            inst.free()
    print("--- VALIDATION SUCCESS ---")
    quit()
