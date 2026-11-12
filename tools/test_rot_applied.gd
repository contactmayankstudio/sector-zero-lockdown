extends SceneTree

func _init():
	var test_weapons = ["usp45", "m4a1", "ak47", "remington870", "desert_eagle", "mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"]
	
	for wid in test_weapons:
		var scene_path = "res://scenes/weapons/models/%s.tscn" % wid
		var inst = load(scene_path).instantiate()
		inst.rotation_degrees = Vector3(90, -90, 0)
		var t = inst.transform
		# In Blender:
		# Z is back (+Z), so +Z should point towards -X (stock/handle)
		# Y was up in Blender (+Y), but in Godot was -Z or whatever
		# Let's see how local (0, 0, 1) and (0, 1, 0) and (1, 0, 0) transform:
		print("Weapon: %16s | basis.x: %s | basis.y: %s | basis.z: %s" % [
			wid, str(t.basis.x), str(t.basis.y), str(t.basis.z)
		])
		inst.free()
	quit()
