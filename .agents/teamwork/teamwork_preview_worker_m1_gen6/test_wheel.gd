extends SceneTree

func _init():
	var packed = load("res://scenes/vehicles/DrivableCar.tscn")
	var car = packed.instantiate()
	var w = car.get_node("WheelFL")
	print("Car instantiated successfully!")
	print("WheelFL wheel_rest_length: ", w.wheel_rest_length)
	print("WheelFL suspension_travel: ", w.suspension_travel)
	print("WheelFL suspension_stiffness: ", w.suspension_stiffness)
	car.queue_free()
	quit(0)
