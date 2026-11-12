extends Control

@onready var title_label = $Center/Panel/Margin/VBox/Title
@onready var description_label = $Center/Panel/Margin/VBox/Description
@onready var progress_label = $Center/Panel/Margin/VBox/Progress
@onready var progress_bar = $Center/Panel/Margin/VBox/ProgressBar
@onready var reward_label = $Center/Panel/Margin/VBox/Reward
@onready var action_button = $Center/Panel/Margin/VBox/ActionButton

func _ready():
	var manager = get_node_or_null("/root/ChallengeManager")
	if manager:
		_refresh(manager)
		if not manager.challenge_changed.is_connected(_on_challenge_changed):
			manager.challenge_changed.connect(_on_challenge_changed)
	$Center/Panel/Margin/VBox/BackButton.pressed.connect(_on_back_pressed)
	action_button.pressed.connect(_on_action_pressed)

func _refresh(manager):
	var challenge = manager.get_daily_challenge()
	var progress = manager.get_progress()
	var target = int(challenge.get("target", 1))
	var complete = manager.is_completed()
	var claimed = manager.is_claimed()
	title_label.text = "DAILY OPS  //  " + str(challenge.get("title", "FIELD TASK"))
	description_label.text = str(challenge.get("description", "Complete today's field task."))
	progress_label.text = "PROGRESS  %d / %d" % [progress, target]
	progress_bar.max_value = target
	progress_bar.value = progress
	reward_label.text = "REWARD  +$300 CASH" if not claimed else "REWARD  CLAIMED"
	if claimed:
		action_button.text = "RETURN TO OPERATIONS"
	elif complete:
		action_button.text = "CLAIM REWARD"
	else:
		action_button.text = "GO TO MISSIONS"

func _on_challenge_changed(_challenge: Dictionary, _progress: int, _complete: bool):
	var manager = get_node_or_null("/root/ChallengeManager")
	if manager:
		_refresh(manager)

func _on_action_pressed():
	var manager = get_node_or_null("/root/ChallengeManager")
	if manager and manager.is_completed() and not manager.is_claimed():
		manager.claim_reward()
		_refresh(manager)
		return
	get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
