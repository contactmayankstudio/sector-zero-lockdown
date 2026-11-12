@tool
extends SceneTree

func _init():
	var n = Node3D.new()
	# In Godot, forward is -Z.
	# When turning left, bike turns toward -X.
	# We want the top of the bike (Y=1) to tilt toward -X (left).
	n.rotation.z = 0.3 # positive Z rotation
	var top_vec = n.transform.basis.y
	print("Positive Z rot top_vec: ", top_vec)
	# If rot.z > 0, does top_vec.x go negative (left) or positive (right)?
	n.free()
	quit(0)
