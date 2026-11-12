class_name RewardPopup
extends Control

signal reward_claimed(amount: int)

@onready var panel = $Center/PanelContainer
@onready var title_label = $Center/PanelContainer/Margin/VBox/TitleLabel
@onready var amount_label = $Center/PanelContainer/Margin/VBox/AmountHBox/AmountLabel
@onready var claim_button = $Center/PanelContainer/Margin/VBox/ClaimButton
@onready var icon_rect = $Center/PanelContainer/Margin/VBox/AmountHBox/IconRect

var reward_amount: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if claim_button:
		claim_button.pressed.connect(_on_claim_pressed)

func show_reward(amount: int, title_text: String = "SECTOR BOUNTY SECURED"):
	reward_amount = amount
	if title_label:
		title_label.text = title_text
	if amount_label:
		amount_label.text = "+%s CASH" % _format_number(amount)
		
	visible = true
	modulate.a = 0.0
	panel.scale = Vector2(0.85, 0.85)
	panel.pivot_offset = panel.size / 2.0
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_victory"):
		audio_mgr.play_victory()

func _on_claim_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
		
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, 0.16)
	tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.16)
	await tw.finished
	visible = false
	reward_claimed.emit(reward_amount)

func _format_number(n: int) -> String:
	var s = str(abs(n))
	var out = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return out
