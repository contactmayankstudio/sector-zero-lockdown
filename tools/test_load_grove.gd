extends SceneTree
func _init():
	var t0 = Time.get_ticks_msec()
	var g = load("res://quarantine_suspect_assets/gta_grove_street.glb")
	print("Load result: ", g, " in ", Time.get_ticks_msec() - t0, " ms")
	quit(0)
