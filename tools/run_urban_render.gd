extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)
	var scn_script = load("res://tools/render_urban_preview.gd")
	root.set_script(scn_script)
