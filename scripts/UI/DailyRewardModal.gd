extends Control

signal closed
signal reward_claimed(amount: int)

@onready var cards_container = $Panel/Margin/VBox/CardsContainer
@onready var claim_button = $Panel/Margin/VBox/ClaimButton
@onready var close_button = $Panel/Margin/VBox/TopBar/CloseButton
@onready var status_label = $Panel/Margin/VBox/StatusLabel

const REWARDS = [
	{"day": 1, "cash": 100, "label": "₹100", "sub": "ESSENTIALS"},
	{"day": 2, "cash": 150, "label": "₹150", "sub": "AMMO SUPPLY"},
	{"day": 3, "cash": 200, "label": "₹200", "sub": "FIELD SUPPORT"},
	{"day": 4, "cash": 250, "label": "₹250", "sub": "SURVIVAL KIT"},
	{"day": 5, "cash": 350, "label": "₹350", "sub": "ELITE SUPPLIES"},
	{"day": 6, "cash": 500, "label": "₹500", "sub": "HEAVY SUPPLY"},
	{"day": 7, "cash": 800, "label": "₹800", "sub": "WEEKLY CACHE"}
]

func _ready():
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if claim_button:
		claim_button.pressed.connect(_on_claim_pressed)
	refresh_ui()

func refresh_ui():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr: return
	
	var info = save_mgr.get_daily_reward_info()
	var cur_day = info.current_day
	var is_claimable = info.claimable
	var claimed_days = info.claimed_days
	
	if is_claimable:
		status_label.text = "DAY %d SUPPLY CRATE IS READY FOR COLLECTION!" % cur_day
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		claim_button.disabled = false
		claim_button.text = "CLAIM DAY %d REWARD" % cur_day
	else:
		status_label.text = "TODAY'S SUPPLY COLLECTED! NEXT CRATE IN NEXT LOGIN."
		status_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 1.0))
		claim_button.disabled = true
		claim_button.text = "ALREADY CLAIMED TODAY"
		
	# Update all 7 cards
	var card_nodes = cards_container.get_children()
	for i in range(mini(card_nodes.size(), REWARDS.size())):
		var card = card_nodes[i]
		var r_data = REWARDS[i]
		var day_num = r_data.day
		
		var title_node = card.get_node_or_null("Margin/VBox/DayLabel")
		var cash_node = card.get_node_or_null("Margin/VBox/CashLabel")
		var sub_node = card.get_node_or_null("Margin/VBox/SubLabel")
		var badge_node = card.get_node_or_null("Margin/VBox/BadgeLabel")
		
		if title_node: title_node.text = "DAY %d" % day_num
		if cash_node: cash_node.text = r_data.label
		if sub_node: sub_node.text = r_data.sub
		
		var is_claimed = claimed_days.has(day_num)
		var is_ready = (day_num == cur_day and is_claimable)
		
		var card_style = StyleBoxFlat.new()
		card_style.corner_radius_top_left = 6
		card_style.corner_radius_top_right = 6
		card_style.corner_radius_bottom_right = 6
		card_style.corner_radius_bottom_left = 6
		
		if is_claimed:
			card_style.bg_color = Color(0.08, 0.14, 0.10, 0.9)
			card_style.border_color = Color(0.2, 0.7, 0.3, 0.7)
			card_style.border_width_left = 2
			card_style.border_width_right = 2
			card_style.border_width_top = 2
			card_style.border_width_bottom = 2
			if badge_node:
				badge_node.text = "✓ CLAIMED"
				badge_node.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
			card.modulate = Color(0.75, 0.85, 0.75, 0.8)
		elif is_ready:
			card_style.bg_color = Color(0.22, 0.18, 0.06, 0.95)
			card_style.border_color = Color(1.0, 0.85, 0.2, 1.0)
			card_style.border_width_left = 3
			card_style.border_width_right = 3
			card_style.border_width_top = 3
			card_style.border_width_bottom = 3
			if badge_node:
				badge_node.text = "★ READY"
				badge_node.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
			card.modulate = Color(1.1, 1.1, 1.1, 1.0)
			# Subtle pulsing scale for ready card
			var tw = create_tween().set_loops(4)
			tw.tween_property(card, "scale", Vector2(1.04, 1.04), 0.4).set_ease(Tween.EASE_OUT)
			tw.tween_property(card, "scale", Vector2.ONE, 0.4).set_ease(Tween.EASE_IN)
		else:
			# Future locked day
			card_style.bg_color = Color(0.06, 0.08, 0.11, 0.85)
			card_style.border_color = Color(0.18, 0.22, 0.28, 0.6)
			card_style.border_width_left = 1
			card_style.border_width_right = 1
			card_style.border_width_top = 1
			card_style.border_width_bottom = 1
			if badge_node:
				badge_node.text = "🔒 LOCKED"
				badge_node.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6))
			card.modulate = Color(0.65, 0.65, 0.7, 0.65)
			
		card.add_theme_stylebox_override("panel", card_style)

func _on_claim_pressed():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr: return
	
	var res = save_mgr.claim_daily_reward()
	if res.get("success", false):
		var cash = res.get("cash", 0)
		reward_claimed.emit(cash)
		
		# Play victory sound
		var audio = get_node_or_null("/root/AudioManager")
		if audio:
			var s_path = "res://audio/ui/sfx_victory.wav"
			if ResourceLoader.exists(s_path):
				var p = AudioStreamPlayer.new()
				p.stream = load(s_path)
				p.bus = "SFX"
				add_child(p)
				p.finished.connect(p.queue_free)
				p.play()
				
		refresh_ui()
		
		# Popup reward banner
		status_label.text = "★ REWARD COLLECTED: +₹%d CASH!" % cash
		status_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
		
		var tw = create_tween()
		tw.tween_property(status_label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT)
		tw.tween_property(status_label, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN)

func _on_close_pressed():
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_ui_click"):
		audio.play_ui_click()
	closed.emit()
	queue_free()
