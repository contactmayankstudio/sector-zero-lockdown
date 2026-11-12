class_name EnemyHealthBar3D
extends Node3D

# Visceral Combat: Procedural 3D Overhead Health Bar with Catchup & Damage Popups
# Zero SubViewports for maximum mobile / OpenGL3 performance!

const BAR_WIDTH: int = 110
const BAR_HEIGHT: int = 14
const BORDER_COLOR: Color = Color(0.12, 0.12, 0.16, 0.95)
const BG_COLOR: Color = Color(0.06, 0.06, 0.08, 0.85)
const CATCHUP_COLOR: Color = Color(1.0, 0.8, 0.2, 0.95)
const HEADSHOT_FLASH_COLOR: Color = Color(1.0, 0.95, 0.4, 1.0)

var sprite_bar: Sprite3D
var label_damage: Label3D
var label_hp: Label3D

var max_health: float = 100.0
var current_health: float = 100.0
var catchup_health: float = 100.0

var bar_image: Image
var bar_texture: ImageTexture

var visibility_timer: float = 0.0
var fade_alpha: float = 0.0
var is_active: bool = false
var damage_popup_timer: float = 0.0

func _init():
	_create_nodes()

func _create_nodes():
	# 1. Main Billboard Health Bar Sprite
	sprite_bar = Sprite3D.new()
	sprite_bar.name = "BarSprite"
	sprite_bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_bar.no_depth_test = true
	sprite_bar.render_priority = 2
	sprite_bar.pixel_size = 0.0075
	sprite_bar.modulate.a = 0.0
	add_child(sprite_bar)
	
	# 2. Procedural Image & Texture
	bar_image = Image.create(BAR_WIDTH, BAR_HEIGHT, false, Image.FORMAT_RGBA8)
	_draw_bar_pixels(1.0, 1.0)
	bar_texture = ImageTexture.create_from_image(bar_image)
	sprite_bar.texture = bar_texture
	
	# 3. Floating Damage Popup Label (CRIT! -75, -25)
	label_damage = Label3D.new()
	label_damage.name = "DamagePopup"
	label_damage.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_damage.no_depth_test = true
	label_damage.render_priority = 3
	label_damage.font_size = 22
	label_damage.outline_size = 6
	label_damage.outline_modulate = Color(0, 0, 0, 0.9)
	label_damage.position.y = 0.18
	label_damage.modulate.a = 0.0
	add_child(label_damage)
	
	# 4. Compact HP Text Label (e.g. "45/60 HP")
	label_hp = Label3D.new()
	label_hp.name = "HPText"
	label_hp.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_hp.no_depth_test = true
	label_hp.render_priority = 3
	label_hp.font_size = 14
	label_hp.outline_size = 4
	label_hp.outline_modulate = Color(0, 0, 0, 0.95)
	label_hp.position.y = -0.12
	label_hp.modulate = Color(0.9, 0.9, 0.9, 0.0)
	add_child(label_hp)

func setup(max_hp: float, height_offset: float = 2.1):
	max_health = max_hp
	current_health = max_hp
	catchup_health = max_hp
	position.y = height_offset
	visibility_timer = 0.0
	fade_alpha = 0.0
	_update_alpha(0.0)

func on_damaged(new_hp: float, max_hp: float, damage: float, is_headshot: bool):
	max_health = max_hp
	current_health = clamp(new_hp, 0.0, max_hp)
	visibility_timer = 2.8 # Stay visible for 2.8 seconds
	fade_alpha = 1.0
	is_active = true
	
	# Trigger Damage Popup
	damage_popup_timer = 0.95
	label_damage.position.y = 0.18
	if new_hp <= 0.0:
		if is_headshot:
			label_damage.text = "CRIT KILL -" + str(int(damage)) + "!"
			label_damage.modulate = Color(1.0, 0.2, 0.25, 1.0)
		else:
			label_damage.text = "KILL -" + str(int(damage))
			label_damage.modulate = Color(1.0, 0.6, 0.1, 1.0)
	elif is_headshot:
		label_damage.text = "CRIT -" + str(int(damage)) + "!"
		label_damage.modulate = HEADSHOT_FLASH_COLOR
	else:
		label_damage.text = "-" + str(int(damage))
		label_damage.modulate = Color(1.0, 0.45, 0.2, 1.0)
		
	# Update HP Text
	label_hp.text = str(int(max(0.0, current_health))) + " / " + str(int(max_health))
	
	_redraw_bar()
	_update_alpha(1.0)

func on_died():
	# Fade out health bar, but allow damage popup to finish its floating animation
	fade_alpha = 0.0
	if sprite_bar:
		sprite_bar.modulate.a = 0.0
	if label_hp:
		label_hp.modulate.a = 0.0

func _process(delta: float):
	if not is_active and fade_alpha <= 0.0:
		return
		
	# Catch-up bar decay towards current health
	if catchup_health > current_health:
		catchup_health = move_toward(catchup_health, current_health, (max_health * 0.8) * delta)
		_redraw_bar()
		
	# Visibility countdown
	if visibility_timer > 0.0:
		visibility_timer -= delta
	else:
		# Smooth fade out
		fade_alpha = move_toward(fade_alpha, 0.0, 2.5 * delta)
		if fade_alpha <= 0.0:
			is_active = false
			
	_update_alpha(fade_alpha)
	
	# Float and fade damage popup
	if damage_popup_timer > 0.0:
		damage_popup_timer -= delta
		label_damage.position.y += 0.25 * delta # Float upward
		var popup_a = clamp(damage_popup_timer / 0.4, 0.0, 1.0)
		label_damage.modulate.a = popup_a
	else:
		label_damage.modulate.a = 0.0

func _update_alpha(alpha: float):
	if sprite_bar:
		sprite_bar.modulate.a = alpha
	if label_hp:
		label_hp.modulate.a = alpha * 0.9

var _last_hp_w: int = -1
var _last_catchup_w: int = -1

func _redraw_bar():
	var hp_pct = clamp(current_health / max_health, 0.0, 1.0)
	var catchup_pct = clamp(catchup_health / max_health, 0.0, 1.0)
	var inner_w = BAR_WIDTH - 2
	var catchup_w = int(inner_w * catchup_pct)
	var hp_w = int(inner_w * hp_pct)
	if hp_w == _last_hp_w and catchup_w == _last_catchup_w:
		return
	_last_hp_w = hp_w
	_last_catchup_w = catchup_w
	_draw_bar_pixels(hp_pct, catchup_pct)
	bar_texture.update(bar_image)

func _draw_bar_pixels(hp_pct: float, catchup_pct: float):
	# Fast native C++ border & background fills (Zero GDScript pixel loops)
	bar_image.fill(BORDER_COLOR)
	var inner_w = BAR_WIDTH - 2
	var inner_h = BAR_HEIGHT - 2
	bar_image.fill_rect(Rect2i(1, 1, inner_w, inner_h), BG_COLOR)
	
	var catchup_w = int(inner_w * catchup_pct)
	var hp_w = int(inner_w * hp_pct)
	
	# 1. Draw Catchup bar (yellow/orange)
	if catchup_w > 0:
		bar_image.fill_rect(Rect2i(1, 1, catchup_w, inner_h), CATCHUP_COLOR)
		
	# 2. Draw Current Health bar (gradient: green -> orange -> red based on HP)
	if hp_w > 0:
		var fill_col: Color
		if hp_pct > 0.6:
			fill_col = Color(0.2, 0.85, 0.25, 1.0).lerp(Color(0.95, 0.75, 0.1, 1.0), (1.0 - hp_pct) / 0.4)
		elif hp_pct > 0.25:
			fill_col = Color(0.95, 0.75, 0.1, 1.0).lerp(Color(0.95, 0.2, 0.15, 1.0), (0.6 - hp_pct) / 0.35)
		else:
			fill_col = Color(0.95, 0.15, 0.15, 1.0) # Danger crimson
			
		bar_image.fill_rect(Rect2i(1, 1, hp_w, inner_h), fill_col)
		# Gloss highlight line
		bar_image.fill_rect(Rect2i(1, 1, hp_w, 1), fill_col.lightened(0.28))
