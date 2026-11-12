@tool
extends SceneTree

func _init():
	print("=== DIAGNOSING SAND COLLISION ===")
	var scn = load("res://scenes/environments/ZombieNightHighway.tscn") as PackedScene
	if not scn:
		print("ERROR: Scene not found")
		quit(1)
		return
	var root = scn.instantiate()
	var ground = root.get_node_or_null("NavigationRegion3D/Ground")
	print("Ground: ", ground)
	var col_l = root.get_node_or_null("NavigationRegion3D/Ground/ColDunesLeft")
	var col_r = root.get_node_or_null("NavigationRegion3D/Ground/ColDunesRight")
	print("ColDunesLeft: ", col_l != null)
	print("ColDunesRight: ", col_r != null)
	if col_l and col_l.shape is ConcavePolygonShape3D:
		var faces = col_l.shape.get_faces()
		print("ColDunesLeft faces count: ", faces.size())
		if faces.size() >= 3:
			var p0 = faces[0]
			var p1 = faces[1]
			var p2 = faces[2]
			var norm = (p1 - p0).cross(p2 - p0).normalized()
			print("Triangle 0 normal: ", norm)
			
	if col_r and col_r.shape is ConcavePolygonShape3D:
		var faces = col_r.shape.get_faces()
		print("ColDunesRight faces count: ", faces.size())
		if faces.size() >= 3:
			var p0 = faces[0]
			var p1 = faces[1]
			var p2 = faces[2]
			var norm = (p1 - p0).cross(p2 - p0).normalized()
			print("Right Triangle 0 normal: ", norm)

	# Also check roadside guardrail placement!
	# Are the guardrails blocking or falling?
	var props = root.get_node_or_null("Props")
	var guardrails = props.find_children("Guardrail*", "", true, false)
	print("Guardrails count: ", guardrails.size())
	if not guardrails.is_empty():
		print("Guardrail 0 position: ", guardrails[0].position)
		var g_cols = guardrails[0].find_children("*", "CollisionShape3D", true, false)
		print("Guardrail 0 collisions: ", g_cols.size())

	root.free()
	quit(0)
