extends SceneTree

func _init():
	print("=== Testing VehiclePhysicsHelper GDScript Bridge ===")
	var v_script = load("res://scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs")
	print("v_script: ", v_script)
	if v_script:
		print("v_script get_class: ", v_script.get_class())
		print("v_script has CalculateInclineAssist: ", "CalculateInclineAssist" in v_script or v_script.has_method("CalculateInclineAssist"))
		
		# Try calling static method on script
		if v_script.has_method("CalculateInclineAssist"):
			var res = v_script.call("CalculateInclineAssist", Vector3.ZERO, Vector3.FORWARD, 20.0, 1000.0)
			print("Direct static call result: ", res)
		else:
			print("v_script does NOT have method CalculateInclineAssist directly on Script object.")
			
		# Try instantiating (will fail if static class)
		if v_script.can_instantiate():
			var inst = v_script.new()
			print("Instantiated: ", inst)
		else:
			print("v_script can_instantiate() is FALSE (because it is a static C# class).")
	quit(0)
