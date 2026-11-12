extends Node3D

## Dead Target Quarantine Outpost Controller
## Handles dynamic emergency strobe flashing, headlights, and audio ambience.

@onready var police_flasher_red = get_node_or_null("Props/PoliceLights/RedFlasher") as OmniLight3D
@onready var police_flasher_blue = get_node_or_null("Props/PoliceLights/BlueFlasher") as OmniLight3D
@onready var streetlamp_1 = get_node_or_null("Props/Streetlamp1/Light") as OmniLight3D

var _flash_timer: float = 0.0
var _flicker_timer: float = 0.0

func _ready():
	print("[DEAD TARGET] Quarantine Checkpoint 04 initialized.")
	
	# Ensure WorldEnvironment is active with dark atmospheric fog
	var we = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if we and we.environment:
		we.environment.fog_enabled = true
		we.environment.fog_density = 0.008

func _process(delta: float):
	# Alternating Red/Blue Emergency Beacon on Police Cruiser
	_flash_timer += delta * 6.0
	var flash_phase = int(_flash_timer) % 2
	if police_flasher_red:
		police_flasher_red.visible = (flash_phase == 0)
	if police_flasher_blue:
		police_flasher_blue.visible = (flash_phase == 1)
		
	# Subtle realistic sodium streetlamp flicker
	_flicker_timer += delta
	if _flicker_timer > 0.08:
		_flicker_timer = 0.0
		if streetlamp_1:
			streetlamp_1.light_energy = randf_range(1.6, 2.1)
