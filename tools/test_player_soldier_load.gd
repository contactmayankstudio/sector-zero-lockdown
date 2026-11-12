extends SceneTree

func _init():
	var player_scene = load("res://scenes/player/Player.tscn")
	if not player_scene:
		print("ERROR: Failed to load Player.tscn")
		quit(1)
		return

	var player = player_scene.instantiate()
	get_root().add_child(player)
	if not player.is_node_ready():
		player._ready()

	print("Player instantiated successfully!")
	var soldier = player.find_child("CombatSoldier", true, false)
	print("CombatSoldier found: ", soldier != null)
	if soldier:
		print("Soldier visible: ", soldier.visible)
		var anim = soldier.find_child("AnimationPlayer", true, false)
		print("Soldier anim playing: ", anim.current_animation if anim else "None")
		var rifle = soldier.find_child("HeldRifle", true, false)
		print("HeldRifle attached: ", rifle != null)

	# Test camera perspective toggle
	print("Initial camera position: ", player.camera.position, " is_third_person: ", player.is_third_person)
	player.toggle_camera_perspective()
	print("After toggle 1: ", player.camera.position, " is_third_person: ", player.is_third_person)
	player.toggle_camera_perspective()
	print("After toggle 2: ", player.camera.position, " is_third_person: ", player.is_third_person)

	player.queue_free()
	print("PLAYER SOLDIER LOAD TEST PASSED!")
	quit(0)
