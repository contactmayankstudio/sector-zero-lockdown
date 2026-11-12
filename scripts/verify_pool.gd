extends SceneTree
func _init():
	var pool = CasingPool.new()
	root.add_child(pool)
	print("Pool count: ", pool.get_child_count())
	print("Group: ", pool.is_in_group("casing_pool"))
	quit()
