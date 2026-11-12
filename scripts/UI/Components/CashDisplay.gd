class_name CashDisplay
extends PanelContainer

signal count_up_finished(final_amount: int)

@onready var icon_rect: TextureRect = find_child("IconRect", true, false)
@onready var header_label: Label = find_child("HeaderLabel", true, false)
@onready var cash_label: Label = find_child("CashLabel", true, false)

var current_displayed_amount: int = 0
var active_tween: Tween = null
var default_modulate: Color = Color.WHITE

func _ready():
	default_modulate = modulate
	var save_mgr = get_node_or_null("/root/SaveManager")
	var initial_cash = save_mgr.data.cash if save_mgr and "cash" in save_mgr.data else 0
	current_displayed_amount = initial_cash
	_update_text(initial_cash)
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("cash_changed"):
		if not event_bus.cash_changed.is_connected(_on_cash_changed):
			event_bus.cash_changed.connect(_on_cash_changed)

func _exit_tree():
	if active_tween and active_tween.is_valid():
		active_tween.kill()

func _on_cash_changed(new_amount: int):
	if new_amount > current_displayed_amount:
		play_reward_animation(new_amount - current_displayed_amount)
	elif new_amount < current_displayed_amount:
		play_spend_animation(current_displayed_amount - new_amount)
	else:
		_update_text(new_amount)

func _update_text(val: int):
	if cash_label:
		# Format with comma separators and explicit fictional in-game currency label
		cash_label.text = "CASH: %s" % _format_number(val)

func _format_number(n: int) -> String:
	var s = str(abs(n))
	var out = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	if n < 0:
		out = "-" + out
	return out

func set_cash(new_amount: int, animate: bool = true):
	if not animate:
		if active_tween and active_tween.is_valid():
			active_tween.kill()
		current_displayed_amount = new_amount
		_update_text(new_amount)
		return
		
	if new_amount > current_displayed_amount:
		play_reward_animation(new_amount - current_displayed_amount)
	elif new_amount < current_displayed_amount:
		play_spend_animation(current_displayed_amount - new_amount)
	else:
		_update_text(new_amount)

func play_reward_animation(earned_amount: int):
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	var start_val = current_displayed_amount
	var target_val = start_val + earned_amount
	
	active_tween = create_tween()
	active_tween.set_parallel(true)
	
	# Icon bounce & Cyan pulse
	if icon_rect:
		active_tween.tween_property(icon_rect, "scale", Vector2(1.25, 1.25), 0.15).set_trans(Tween.TRANS_BACK)
		active_tween.tween_property(icon_rect, "scale", Vector2.ONE, 0.25).set_delay(0.15)
	
	active_tween.tween_property(self, "modulate", Color(0.2, 1.0, 0.85), 0.15)
	active_tween.tween_property(self, "modulate", default_modulate, 0.35).set_delay(0.15)
	
	# Smooth count-up method
	active_tween.tween_method(func(val: int):
		current_displayed_amount = val
		_update_text(val)
	, start_val, target_val, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	active_tween.chain().tween_callback(func():
		current_displayed_amount = target_val
		_update_text(target_val)
		count_up_finished.emit(target_val)
	)

func play_spend_animation(spent_amount: int):
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	var start_val = current_displayed_amount
	var target_val = max(0, start_val - spent_amount)
	
	active_tween = create_tween()
	active_tween.set_parallel(true)
	
	# Amber/cyan spend pulse
	active_tween.tween_property(self, "modulate", Color(1.0, 0.7, 0.2), 0.12)
	active_tween.tween_property(self, "modulate", default_modulate, 0.25).set_delay(0.12)
	
	active_tween.tween_method(func(val: int):
		current_displayed_amount = val
		_update_text(val)
	, start_val, target_val, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	active_tween.chain().tween_callback(func():
		current_displayed_amount = target_val
		_update_text(target_val)
	)

func play_insufficient_feedback():
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	var original_pos = position
	active_tween = create_tween()
	
	# Red warning flash
	active_tween.tween_property(self, "modulate", Color(1.0, 0.3, 0.3), 0.08)
	
	# Horizontal shake sequence
	active_tween.tween_property(self, "position:x", original_pos.x - 8.0, 0.05)
	active_tween.tween_property(self, "position:x", original_pos.x + 8.0, 0.05)
	active_tween.tween_property(self, "position:x", original_pos.x - 5.0, 0.05)
	active_tween.tween_property(self, "position:x", original_pos.x + 5.0, 0.05)
	active_tween.tween_property(self, "position:x", original_pos.x, 0.05)
	
	active_tween.tween_property(self, "modulate", default_modulate, 0.2)
