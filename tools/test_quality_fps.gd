extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)
	
	var qm = get_root().get_node_or_null("QualityManager")
	if qm:
		qm.apply_quality(0) # LEGACY / LOW SPEC
		
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	root.add_child(level)
	
	# Keep only DirectionalLight, PoliceLights, and Streetlamp1
	var to_disable = ["PerimeterFloodlightRight", "Streetlamp2", "AlertStrobe"]
	for node_name in to_disable:
		var n = level.find_child(node_name, true, false)
		if n:
			for l in n.find_children("*", "Light3D", true, false):
				l.visible = false
				
	for i in range(30):
		await process_frame
		
	var start_time = Time.get_ticks_usec()
	for i in range(60):
		await process_frame
	var elapsed = (Time.get_ticks_usec() - start_time) / 1000000.0
	var fps = 60.0 / elapsed
	print(">>> DEAD TARGET FPS (Optimized 3 Lights): ", fps)
	print("Primitives in frame: ", Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	print("Draw calls in frame: ", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	quit(0)
