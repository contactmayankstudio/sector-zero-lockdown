class_name WeaponCard
extends Button

signal weapon_card_selected(weapon_id: String)

@onready var icon_rect: TextureRect = find_child("IconRect", true, false)
@onready var name_label: Label = find_child("NameLabel", true, false)
@onready var category_label: Label = find_child("CategoryLabel", true, false)
@onready var status_badge: Label = find_child("StatusBadge", true, false)
@onready var price_label: Label = find_child("PriceLabel", true, false)
@onready var selection_bar: ColorRect = find_child("SelectionBar", true, false)

var weapon_id: String = ""
var is_card_selected: bool = false
var is_unlocked: bool = false
var is_equipped: bool = false

const CATEGORY_ICONS: Dictionary = {
	"pistol": "res://assets/ui/icon_wep_pistol.svg",
	"usp45": "res://assets/ui/icon_wep_pistol.svg",
	"desert_eagle": "res://assets/ui/icon_wep_pistol.svg",
	"rifle": "res://assets/ui/icon_wep_rifle.svg",
	"m4a1": "res://assets/ui/icon_wep_rifle.svg",
	"ak47": "res://assets/ui/icon_wep_rifle.svg",
	"shotgun": "res://assets/ui/icon_wep_shotgun.svg",
	"remington870": "res://assets/ui/icon_wep_shotgun.svg",
	"mp5": "res://assets/ui/icon_wep_smg.svg",
	"awp": "res://assets/ui/icon_wep_sniper.svg",
	"combat_knife": "res://assets/ui/icon_wep_knife.svg",
	"crossbow": "res://assets/ui/icon_wep_crossbow.svg",
	"grenade_launcher": "res://assets/ui/icon_wep_launcher.svg"
}

func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)

var is_rented: bool = false

func setup(wid: String, display_name: String, category: String, unlocked: bool, equipped: bool, price: int, rented: bool = false):
	weapon_id = wid
	is_unlocked = unlocked
	is_equipped = equipped
	is_rented = rented
	name = "WepBtn_" + wid
	
	if name_label:
		name_label.text = display_name.to_upper()
	if category_label:
		category_label.text = category.to_upper()
		
	# Setup icon
	var icon_path = CATEGORY_ICONS.get(wid, "res://assets/ui/icon_wep_rifle.svg")
	if icon_rect and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
		
	# Setup status badges
	if is_equipped:
		if status_badge:
			if is_rented:
				status_badge.text = "RENTED"
				status_badge.modulate = Color(1.0, 0.85, 0.2) # Gold
			else:
				status_badge.text = "EQUIPPED"
				status_badge.modulate = Color(0.2, 1.0, 0.5) # Bright green
			status_badge.visible = true
		if price_label: price_label.visible = false
	elif is_rented:
		if status_badge:
			status_badge.text = "RENTED (1M)"
			status_badge.modulate = Color(1.0, 0.85, 0.2) # Gold
			status_badge.visible = true
		if price_label: price_label.visible = false
	elif is_unlocked:
		if status_badge:
			status_badge.text = "OWNED"
			status_badge.modulate = Color(0.0, 0.85, 1.0) # Tactical Cyan
			status_badge.visible = true
		if price_label: price_label.visible = false
	else:
		if status_badge:
			status_badge.text = "LOCKED"
			status_badge.modulate = Color(1.0, 0.45, 0.3) # Orange / amber
			status_badge.visible = true
		if price_label:
			price_label.text = "%s CASH" % _format_number(price)
			price_label.modulate = Color(1.0, 0.8, 0.2)
			price_label.visible = true
			
	_update_style()

func set_selected(selected: bool):
	is_card_selected = selected
	if selection_bar:
		selection_bar.visible = selected
	_update_style()

func _update_style():
	var s_box = StyleBoxFlat.new()
	s_box.corner_radius_top_left = 6
	s_box.corner_radius_top_right = 6
	s_box.corner_radius_bottom_right = 6
	s_box.corner_radius_bottom_left = 6
	
	if is_card_selected:
		s_box.bg_color = Color(0.1, 0.16, 0.22, 0.95)
		s_box.border_width_left = 4
		s_box.border_width_top = 1
		s_box.border_width_right = 1
		s_box.border_width_bottom = 2
		s_box.border_color = Color(0.0, 0.9, 1.0, 1.0) # Bright cyan glow
		s_box.shadow_color = Color(0.0, 0.8, 1.0, 0.25)
		s_box.shadow_size = 6
	else:
		s_box.bg_color = Color(0.06, 0.08, 0.11, 0.85)
		s_box.border_width_left = 1
		s_box.border_width_top = 1
		s_box.border_width_right = 1
		s_box.border_width_bottom = 1
		if is_equipped:
			s_box.border_color = Color(0.2, 0.85, 0.4, 0.6)
		elif is_unlocked:
			s_box.border_color = Color(0.18, 0.28, 0.36, 0.6)
		else:
			s_box.border_color = Color(0.25, 0.2, 0.2, 0.4)
			
	add_theme_stylebox_override("normal", s_box)
	add_theme_stylebox_override("hover", s_box)
	add_theme_stylebox_override("pressed", s_box)
	add_theme_stylebox_override("focus", s_box)

func _on_pressed():
	weapon_card_selected.emit(weapon_id)

func _on_hover():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_hover"):
		audio_mgr.play_ui_hover()

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
