@tool
extends SceneTree

func _init():
	print("--- TESTING MOUNTAIN TERRAIN COLLISION & PHYSICS ---")
	var packed = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not packed:
		print("FAILED to load scene")
		quit(1)
		return
	var scene = packed.instantiate()
	root.add_child(scene)
	if scene.has_method("_ready"):
		scene._ready()
	
	var adv = scene.get_node_or_null("AdvancedTerrain")
	if adv:
		var m_west = adv.get_node_or_null("MountainWest")
		if m_west:
			var cols = m_west.find_children("*", "CollisionShape3D", true, false)
			print("MountainWest CollisionShape3D count after _ready(): ", cols.size())
			for c in cols:
				print("  Found collision shape: ", c.name, " inside ", c.get_parent().name)
		var valley = adv.get_node_or_null("ValleyFloor")
		if valley:
			var cols = valley.find_children("*", "CollisionShape3D", true, false)
			print("ValleyFloor CollisionShape3D count after _ready(): ", cols.size())

	scene.queue_free()
	quit(0)
