extends Control

@onready var label = $Panel/Label
@onready var next_btn = $Panel/NextButton

var steps = [
	"Welcome to Sector Zero. Drag anywhere to aim.",
	"Tap the screen to shoot. Aim for the head for extra damage.",
	"Your ammo is limited. Tap RELOAD when empty.",
	"Zombies are approaching. Clear the sector to earn cash.",
	"Use cash in the UPGRADE HUB to improve your weapons."
]
var current_step = 0

func _get_save_manager():
	if is_inside_tree():
		return get_node_or_null("/root/SaveManager")
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null("SaveManager")
	return null

func _ready():
	var save_mgr = _get_save_manager()
	if save_mgr and not save_mgr.data.get("is_first_launch", true):
		queue_free()
		return
	update_step()

func _on_next_button_pressed():
	current_step += 1
	if current_step >= steps.size():
		var save_mgr = _get_save_manager()
		if save_mgr:
			save_mgr.data.is_first_launch = false
			save_mgr.save_game()
		queue_free()
	else:
		update_step()

func update_step():
	label.text = steps[current_step]
