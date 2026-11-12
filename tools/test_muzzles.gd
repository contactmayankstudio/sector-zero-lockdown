extends SceneTree

func _init():
	var weapons = [
		"usp45", "m4a1", "remington870", "ak47", "desert_eagle",
		"mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"
	]
	
	for wid in weapons:
		var scene_path = "res://scenes/weapons/models/%s.tscn" % wid
		if not ResourceLoader.exists(scene_path): continue
		var inst = load(scene_path).instantiate()
		var muzzle = inst.find_child("MuzzleSocket", true, false)
		var m_pos = muzzle.position if muzzle else Vector3.ZERO
		print("Weapon: ", wid, " MuzzlePos: ", m_pos)
		inst.free()
	quit()
