extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_res.instantiate()
	var mesh_inst: MeshInstance3D = soldier.find_child("vanguard_Mesh", true, false)
	if mesh_inst and mesh_inst.mesh:
		print("Mesh AABB: ", mesh_inst.mesh.get_aabb())
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	if anim:
		anim.play("Walk")
		anim.advance(0.1)
		print("Walk animation playing smoothly")
	soldier.queue_free()
	quit(0)
