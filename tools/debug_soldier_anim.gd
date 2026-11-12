extends SceneTree

func _init():
	print("--- Debugging RealSoldier AnimationPlayer ---")
	var soldier_scene = load("res://scenes/characters/RealSoldier.scn")
	var soldier = soldier_scene.instantiate()
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	if not anim:
		print("ERROR: AnimationPlayer NOT FOUND via find_child!")
		quit(1)
		return
	print("Found anim player: ", anim.get_path(), " active: ", anim.active)
	print("Has 'BikeRiding'? ", anim.has_animation("BikeRiding"))
	
	# Let's inspect the tracks of 'BikeRiding' and where the root node is pointing!
	print("AnimationPlayer root_node: ", anim.root_node)
	var a = anim.get_animation("BikeRiding")
	if a:
		print("Animation track 0 path: ", a.track_get_path(0))
		var resolved_node = anim.get_node_or_null(a.track_get_path(0))
		print("Can AnimationPlayer resolve track 0 ('", a.track_get_path(0), "') from root_node ('", anim.root_node, "')? Result: ", resolved_node)
		
	var root_node = anim.get_node(anim.root_node)
	print("Root node object: ", root_node.name)
	for c in soldier.get_children():
		print("  Soldier child: ", c.name, " (", c.get_class(), ")")
		for cc in c.get_children():
			print("    Child: ", cc.name, " (", cc.get_class(), ")")
	
	print("AnimationPlayer parent: ", anim.get_parent().name)
	print("Target path needed: ", anim.get_node_or_null(NodePath(str(anim.root_node) + "/Character/Skeleton3D")))
	print("Direct get from root: ", soldier.get_node_or_null("Character/Skeleton3D"))
	quit(0)
