extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = scn.instantiate()
	get_root().add_child(arena)
	
	print("\n=== COLLISION SHAPES INSPECTION ===")
	_dump_physics(arena, 0)
	
	arena.queue_free()
	quit(0)

func _dump_physics(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	if node is StaticBody3D or node is RigidBody3D or node is Area3D:
		print("%s[%s] '%s' pos=%s col_layer=%d mask=%d" % [
			indent, node.get_class(), node.name, str(node.global_position),
			node.collision_layer, node.collision_mask
		])
		for c in node.get_children():
			if c is CollisionShape3D:
				var s = c.shape
				if s is BoxShape3D:
					print("%s  -> BoxShape3D size=%s pos=%s" % [indent, str(s.size), str(c.position)])
				elif s is ConcavePolygonShape3D:
					print("%s  -> ConcavePolygonShape3D faces=%d" % [indent, s.get_faces().size() / 3])
				elif s is ConvexPolygonShape3D:
					print("%s  -> ConvexPolygonShape3D points=%d" % [indent, s.points.size()])
				else:
					print("%s  -> Shape %s pos=%s" % [indent, str(s), str(c.position)])
	for child in node.get_children():
		_dump_physics(child, depth + 1)
