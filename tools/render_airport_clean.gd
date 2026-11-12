extends SceneTree
func _init():
    var scn = load("res://scenes/environments/AirportTerminal.tscn").instantiate()
    root.add_child(scn)
    
    # Remove AirportTerminalGLB
    var glb = scn.get_node_or_null("AirportTerminalGLB")
    if glb:
        glb.queue_free()
        
    var cam = Camera3D.new()
    cam.position = Vector3(0, 1.6, 0)
    cam.rotation_degrees = Vector3(0, 0, 0)
    cam.current = true
    scn.add_child(cam)
    
    # Wait 2 frames to render
    await process_frame
    await process_frame
    
    var img = root.get_viewport().get_texture().get_image()
    img.save_png("preview_airport_clean.png")
    print("SAVED preview_airport_clean.png")
    quit()
