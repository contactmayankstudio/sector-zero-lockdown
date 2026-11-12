extends SceneTree

var frame = 0
var active_scene_node = null

func _process(delta):
    frame += 1
    if frame == 1:
        # Stage 0: Urban Street with Flatline
        var s = load("res://scenes/environments/UrbanStreet.tscn")
        active_scene_node = s.instantiate()
        root.add_child(active_scene_node)
        var player = active_scene_node.find_child("Player", true, false)
        if player:
            for idx in range(player.weapons.size()):
                if player.weapons[idx].weapon_data and player.weapons[idx].weapon_data.weapon_id == "flatline":
                    player.switch_to_weapon(idx)
                    break
    elif frame == 14:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        if img:
            img.save_png("screenshots/gameplay_urban_flatline.png")
            print("[CAPTURED] screenshots/gameplay_urban_flatline.png")
        
        # Switch to Minigun
        var player = active_scene_node.find_child("Player", true, false)
        if player:
            for idx in range(player.weapons.size()):
                if player.weapons[idx].weapon_data and player.weapons[idx].weapon_data.weapon_id == "minigun":
                    player.switch_to_weapon(idx)
                    break
    elif frame == 24:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        if img:
            img.save_png("screenshots/gameplay_urban_minigun.png")
            print("[CAPTURED] screenshots/gameplay_urban_minigun.png")
            
        active_scene_node.queue_free()
        active_scene_node = null
        
    elif frame == 26:
        # Stage 1: Airport Service Road with CAR SMG
        var s = load("res://scenes/environments/AirportServiceRoad.tscn")
        active_scene_node = s.instantiate()
        root.add_child(active_scene_node)
        var player = active_scene_node.find_child("Player", true, false)
        if player:
            for idx in range(player.weapons.size()):
                if player.weapons[idx].weapon_data and player.weapons[idx].weapon_data.weapon_id == "car_smg":
                    player.switch_to_weapon(idx)
                    break
    elif frame == 38:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        if img:
            img.save_png("screenshots/gameplay_airport_car_smg.png")
            print("[CAPTURED] screenshots/gameplay_airport_car_smg.png")
            
        active_scene_node.queue_free()
        active_scene_node = null
        
    elif frame == 40:
        # Stage 2: Daily Ops UI
        var s = load("res://scenes/UI/DailyOps.tscn")
        active_scene_node = s.instantiate()
        root.add_child(active_scene_node)
    elif frame == 48:
        var vp = root.get_viewport()
        var img = vp.get_texture().get_image()
        if img:
            img.save_png("screenshots/ui_daily_ops.png")
            print("[CAPTURED] screenshots/ui_daily_ops.png")
        print("ALL CAPTURES COMPLETED SUCCESSFULLY!")
        quit(0)
