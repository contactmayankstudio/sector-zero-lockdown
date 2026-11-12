extends Node3D

func _ready():
	var dl = get_node_or_null("DirectionalLight3D")
	if dl:
		dl.shadow_bias = 0.04
		dl.light_energy = 1.35
		dl.light_color = Color(1.0, 0.98, 0.92, 1.0)

	var we = get_node_or_null("WorldEnvironment")
	if we and we.environment:
		var env = we.environment
		env.fog_enabled = false
		env.ambient_light_energy = 0.95

