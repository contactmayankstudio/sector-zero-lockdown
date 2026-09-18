extends Control

@onready var cash_label = find_child("CashLabel", true, false)
@onready var cash_display = find_child("CashDisplay", true, false)
@onready var weapon_list = find_child("Scroll", true, false).get_node_or_null("VBox") if find_child("Scroll", true, false) else null
@onready var view_container = find_child("3DView", true, false)
@onready var pivot = find_child("WeaponPivot", true, false)

@onready var weapon_title = find_child("WeaponTitle", true, false)
@onready var weapon_subtitle = find_child("WeaponSubtitle", true, false)
@onready var status_badge = find_child("StatusBadge", true, false)

@onready var dmg_lbl = find_child("DamageRow", true, false).get_node_or_null("Label") if find_child("DamageRow", true, false) else null
@onready var dmg_val = find_child("DamageRow", true, false).get_node_or_null("Value") if find_child("DamageRow", true, false) else null
@onready var dmg_bar = find_child("DamageRow", true, false).get_node_or_null("DamageBar") if find_child("DamageRow", true, false) else null
@onready var dmg_btn = find_child("DamageRow", true, false).get_node_or_null("UpgradeBtn") if find_child("DamageRow", true, false) else null

@onready var mag_lbl = find_child("MagRow", true, false).get_node_or_null("Label") if find_child("MagRow", true, false) else null
@onready var mag_val = find_child("MagRow", true, false).get_node_or_null("Value") if find_child("MagRow", true, false) else null
@onready var mag_bar = find_child("MagRow", true, false).get_node_or_null("MagBar") if find_child("MagRow", true, false) else null
@onready var mag_btn = find_child("MagRow", true, false).get_node_or_null("UpgradeBtn") if find_child("MagRow", true, false) else null

@onready var rel_lbl = find_child("ReloadRow", true, false).get_node_or_null("Label") if find_child("ReloadRow", true, false) else null
@onready var reload_val = find_child("ReloadRow", true, false).get_node_or_null("Value") if find_child("ReloadRow", true, false) else null
@onready var reload_bar = find_child("ReloadRow", true, false).get_node_or_null("ReloadBar") if find_child("ReloadRow", true, false) else null
@onready var reload_btn = find_child("ReloadRow", true, false).get_node_or_null("UpgradeBtn") if find_child("ReloadRow", true, false) else null

@onready var acc_lbl = find_child("AccuracyRow", true, false).get_node_or_null("Label") if find_child("AccuracyRow", true, false) else null
@onready var acc_val = find_child("AccuracyRow", true, false).get_node_or_null("Value") if find_child("AccuracyRow", true, false) else null
@onready var acc_bar = find_child("AccuracyRow", true, false).get_node_or_null("AccuracyBar") if find_child("AccuracyRow", true, false) else null
@onready var acc_btn = find_child("AccuracyRow", true, false).get_node_or_null("UpgradeBtn") if find_child("AccuracyRow", true, false) else null

@onready var equip_btn = find_child("EquipBtn", true, false)
@onready var unlock_btn = find_child("UnlockBtn", true, false)
@onready var feedback_label = find_child("FeedbackLabel", true, false)

var card_prefab: PackedScene = preload("res://scenes/UI/Components/WeaponCard.tscn")

var current_weapon_id: String = "m4a1"
var active_mesh: Node3D = null
var current_res: WeaponData = null
var is_purchasing_locked: bool = false

# 10 Canonical Weapons
var weapons = [
	"usp45", "m4a1", "remington870", "ak47", "desert_eagle", 
	"mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"
]

var meshes = {
	"usp45": "res://scenes/weapons/models/usp45.tscn",
	"pistol": "res://scenes/weapons/models/usp45.tscn",
	"m4a1": "res://scenes/weapons/models/m4a1.tscn",
	"rifle": "res://scenes/weapons/models/m4a1.tscn",
	"remington870": "res://scenes/weapons/models/remington870.tscn",
	"shotgun": "res://scenes/weapons/models/remington870.tscn",
	"ak47": "res://scenes/weapons/models/ak47.tscn",
	"desert_eagle": "res://scenes/weapons/models/desert_eagle.tscn",
	"mp5": "res://scenes/weapons/models/mp5.tscn",
	"awp": "res://scenes/weapons/models/awp.tscn",
	"combat_knife": "res://scenes/weapons/models/combat_knife.tscn",
	"crossbow": "res://scenes/weapons/models/crossbow.tscn",
	"grenade_launcher": "res://scenes/weapons/models/grenade_launcher.tscn"
}

const WEAPON_ORIENTATIONS: Dictionary = {
	"usp45": Vector3(90, -90, 0),
	"pistol": Vector3(90, -90, 0),
	"m4a1": Vector3(90, -90, 0),
	"rifle": Vector3(90, -90, 0),
	"remington870": Vector3(90, -90, 0),
	"shotgun": Vector3(90, -90, 0),
	"ak47": Vector3(90, -90, 0),
	"desert_eagle": Vector3(90, -90, 0),
	"mp5": Vector3(90, -90, 0),
	"awp": Vector3(90, -90, 0),
	"combat_knife": Vector3(90, -90, 0),
	"crossbow": Vector3(90, -90, 0),
	"grenade_launcher": Vector3(90, -90, 0)
}

const WEAPON_TARGET_SIZES: Dictionary = {
	"usp45": 0.42,
	"pistol": 0.42,
	"desert_eagle": 0.46,
	"combat_knife": 0.38,
	"mp5": 0.60,
	"m4a1": 0.72,
	"rifle": 0.72,
	"remington870": 0.74,
	"shotgun": 0.74,
	"ak47": 0.74,
	"awp": 0.80,
	"crossbow": 0.68,
	"grenade_launcher": 0.70
}

# 3D Touch Interaction State
var is_dragging_weapon: bool = false
var last_touch_pos: Vector2 = Vector2.ZERO
var rot_yaw: float = 0.35
var rot_pitch: float = -0.06
var target_rot_yaw: float = 0.35
var target_rot_pitch: float = -0.06

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back()

func _ready():
	if not weapon_list:
		weapon_list = find_child("VBox", true, false)
		
	var back_btn = find_child("BackButton", true, false)
	if back_btn and not back_btn.pressed.is_connected(_on_back):
		back_btn.pressed.connect(_on_back)
		
	if dmg_btn and not dmg_btn.pressed.is_connected(_on_upgrade.bind("damage")):
		dmg_btn.pressed.connect(_on_upgrade.bind("damage"))
	if mag_btn and not mag_btn.pressed.is_connected(_on_upgrade.bind("mag")):
		mag_btn.pressed.connect(_on_upgrade.bind("mag"))
	if reload_btn and not reload_btn.pressed.is_connected(_on_upgrade.bind("reload")):
		reload_btn.pressed.connect(_on_upgrade.bind("reload"))
	if acc_btn and not acc_btn.pressed.is_connected(_on_upgrade.bind("accuracy")):
		acc_btn.pressed.connect(_on_upgrade.bind("accuracy"))
		
	if equip_btn and not equip_btn.pressed.is_connected(_on_equip):
		equip_btn.pressed.connect(_on_equip)
	if unlock_btn and not unlock_btn.pressed.is_connected(_on_unlock):
		unlock_btn.pressed.connect(_on_unlock)
		
	if view_container:
		view_container.gui_input.connect(_on_view_container_input)
		
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("cash_changed"):
		if not event_bus.cash_changed.is_connected(_on_cash_changed):
			event_bus.cash_changed.connect(_on_cash_changed)
		
	var banner = get_node_or_null("/root/BannerAdManager")
	if banner:
		banner.show_banner()
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr and save_mgr.has_method("get_equipped_weapon"):
		current_weapon_id = save_mgr.get_equipped_weapon()
	else:
		current_weapon_id = "m4a1"
		
	_populate_list()
	_select_weapon(current_weapon_id)
	_update_ui()

func _exit_tree():
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		var banner = tree.root.get_node_or_null("BannerAdManager")
		if banner and banner.has_method("hide_banner"):
			banner.hide_banner()

func _process(delta):
	if not is_dragging_weapon:
		target_rot_yaw += delta * 0.35
		
	rot_yaw = lerp_angle(rot_yaw, target_rot_yaw, delta * 8.0)
	rot_pitch = lerp(rot_pitch, target_rot_pitch, delta * 8.0)
	
	if pivot:
		pivot.rotation.y = rot_yaw
		pivot.rotation.x = rot_pitch

func _on_view_container_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging_weapon = event.pressed
			last_touch_pos = event.position
	elif event is InputEventScreenTouch:
		is_dragging_weapon = event.pressed
		last_touch_pos = event.position
	elif (event is InputEventMouseMotion and is_dragging_weapon) or event is InputEventScreenDrag:
		var delta_p = event.position - last_touch_pos
		last_touch_pos = event.position
		target_rot_yaw += delta_p.x * 0.012
		target_rot_pitch = clamp(target_rot_pitch + delta_p.y * 0.008, -0.35, 0.35)

func _populate_list():
	if not weapon_list: return
	for child in weapon_list.get_children():
		child.queue_free()
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	var equipped_wid = save_mgr.get_equipped_weapon() if save_mgr and save_mgr.has_method("get_equipped_weapon") else "m4a1"
	
	for wid in weapons:
		var d_name = wid.to_upper()
		var category = "Combat Firearm"
		var unlock_price = 1500
		
		var w_entry = WeaponManager.get_weapon_entry(wid)
		if not w_entry.is_empty():
			d_name = w_entry.get("display_name", d_name)
			category = w_entry.get("category", category)
			unlock_price = w_entry.get("unlock_price", unlock_price)
		else:
			var res_path = "res://resources/weapons/" + wid + ".tres"
			if ResourceLoader.exists(res_path):
				var res = load(res_path)
				if res and "display_name" in res:
					d_name = res.display_name
				if res and "unlock_price" in res:
					unlock_price = res.unlock_price
				
		var is_unlocked = WeaponManager.is_weapon_unlocked(wid, save_mgr) if save_mgr else true
		var is_equipped = (wid == equipped_wid or
			(equipped_wid in ["pistol", "usp45"] and wid in ["pistol", "usp45"]) or
			(equipped_wid in ["rifle", "m4a1"] and wid in ["rifle", "m4a1"]) or
			(equipped_wid in ["shotgun", "remington870"] and wid in ["shotgun", "remington870"]))
		
		var card = card_prefab.instantiate()
		card.name = "WepBtn_" + wid
		weapon_list.add_child(card)
		card.setup(wid, d_name, category, is_unlocked, is_equipped, unlock_price)
		card.weapon_card_selected.connect(_select_weapon)
		if wid == current_weapon_id:
			card.set_selected(true)

func _select_weapon(wid: String):
	current_weapon_id = wid
	if active_mesh:
		active_mesh.queue_free()
		active_mesh = null
	
	var mesh_path = meshes.get(wid)
	if not mesh_path or not ResourceLoader.exists(mesh_path):
		var w_entry = WeaponManager.get_weapon_entry(wid)
		mesh_path = w_entry.get("scene_path", "")
		
	if mesh_path and ResourceLoader.exists(mesh_path) and pivot:
		var m = load(mesh_path)
		if m is PackedScene:
			var inst = m.instantiate()
			pivot.add_child(inst)
			_setup_active_mesh(inst, wid)
			active_mesh = inst
		elif m is Mesh:
			var mi = MeshInstance3D.new()
			mi.mesh = m
			pivot.add_child(mi)
			_setup_active_mesh(mi, wid)
			active_mesh = mi
			
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()

	if weapon_list:
		for child in weapon_list.get_children():
			if child.has_method("set_selected"):
				var child_wid = child.name.replace("WepBtn_", "")
				child.set_selected(child_wid == current_weapon_id)

	var w_data = WeaponManager.get_weapon_data(wid)
	if not w_data:
		var res_path = "res://resources/weapons/" + wid + ".tres"
		if ResourceLoader.exists(res_path):
			w_data = load(res_path) as WeaponData
	current_res = w_data
	
	_update_ui()

func _setup_active_mesh(inst: Node3D, wid: String):
	var base_rot = WEAPON_ORIENTATIONS.get(wid, Vector3.ZERO)
	inst.rotation_degrees = base_rot
	
	# Calculate transformed AABB
	var aabb = AABB()
	var first = true
	var meshes_found = inst.find_children("*", "MeshInstance3D", true, false)
	if inst is MeshInstance3D: meshes_found.append(inst)
	for mi in meshes_found:
		if mi.mesh:
			var m_aabb = mi.transform * mi.mesh.get_aabb()
			if first:
				aabb = m_aabb
				first = false
			else:
				aabb = aabb.merge(m_aabb)
				
	if aabb.size.length() > 0.01:
		var center = aabb.get_center()
		var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
		var target_size = WEAPON_TARGET_SIZES.get(wid, 0.72)
		var s = target_size / max_dim
		inst.scale = Vector3(s, s, s)
		var rot_center = inst.transform.basis * center
		inst.position = -rot_center + Vector3(0, 0.04, 0)
	else:
		inst.scale = Vector3(2.2, 2.2, 2.2)
		inst.position = Vector3(0, 0.04, 0)

func _update_ui():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr or not current_res: return
	
	var cash = save_mgr.data.cash
	if cash_label:
		cash_label.text = "CASH: %s" % _format_number(cash)
	if cash_display and cash_display.has_method("set_cash"):
		cash_display.set_cash(cash, false)
	
	var w_entry = WeaponManager.get_weapon_entry(current_weapon_id)
	var category = w_entry.get("category", "Tactical Firearm")
	var is_unlocked = WeaponManager.is_weapon_unlocked(current_weapon_id, save_mgr)
	var unlock_price = w_entry.get("unlock_price", current_res.unlock_price if "unlock_price" in current_res and current_res.unlock_price > 0 else 1500)
	
	var equipped_wid = save_mgr.get_equipped_weapon() if save_mgr.has_method("get_equipped_weapon") else "m4a1"
	var is_equipped = (current_weapon_id == equipped_wid or
		(equipped_wid in ["pistol", "usp45"] and current_weapon_id in ["pistol", "usp45"]) or
		(equipped_wid in ["rifle", "m4a1"] and current_weapon_id in ["rifle", "m4a1"]) or
		(equipped_wid in ["shotgun", "remington870"] and current_weapon_id in ["shotgun", "remington870"]))
	
	if weapon_title:
		weapon_title.text = current_res.display_name.to_upper()
	if weapon_subtitle:
		weapon_subtitle.text = "[%s] // %s" % [category.to_upper(), w_entry.get("subtitle", "Combat Ready Specimen")]
	if status_badge:
		if is_equipped:
			status_badge.text = "STATUS: EQUIPPED IN COMBAT LOADOUT"
			status_badge.modulate = Color(0.2, 1.0, 0.5)
		elif is_unlocked:
			status_badge.text = "STATUS: OWNED // READY TO EQUIP"
			status_badge.modulate = Color(0.0, 0.85, 1.0)
		else:
			status_badge.text = "STATUS: LOCKED // AUTHORIZATION REQUIRED"
			status_badge.modulate = Color(1.0, 0.45, 0.3)
	
	var upgrades_dict = WeaponManager.get_upgrade_levels(current_weapon_id, save_mgr)
	var d_lvl = upgrades_dict.get("damage", 0)
	var m_lvl = upgrades_dict.get("mag", 0)
	var r_lvl = upgrades_dict.get("reload", 0)
	var a_lvl = upgrades_dict.get("accuracy", 0)
	
	# 1. Damage
	if dmg_lbl: dmg_lbl.text = "DAMAGE [L%d]" % d_lvl
	var cur_dmg = current_res.get_damage(d_lvl)
	var next_dmg = current_res.get_damage(d_lvl + 1)
	if dmg_bar: dmg_bar.value = cur_dmg
	if d_lvl >= WeaponData.MAX_UPGRADE_LEVEL:
		if dmg_val: dmg_val.text = "%.1f (MAX)" % cur_dmg
		if dmg_btn:
			dmg_btn.text = "MAX LEVEL"
			dmg_btn.disabled = true
	else:
		if dmg_val: dmg_val.text = "%.1f ➔ %.1f" % [cur_dmg, next_dmg]
		var cost = current_res.get_upgrade_cost("damage", d_lvl)
		if dmg_btn:
			if not is_unlocked:
				dmg_btn.text = "LOCKED"
				dmg_btn.disabled = true
			elif cash < cost:
				dmg_btn.text = "NEED %d CASH" % cost
				dmg_btn.disabled = true
			else:
				dmg_btn.text = "UPGRADE (%d CASH)" % cost
				dmg_btn.disabled = false
		
	# 2. Magazine
	if mag_lbl: mag_lbl.text = "AMMO [L%d]" % m_lvl
	var cur_mag = current_res.get_mag_size(m_lvl)
	var next_mag = current_res.get_mag_size(m_lvl + 1)
	if mag_bar: mag_bar.value = cur_mag
	if m_lvl >= WeaponData.MAX_UPGRADE_LEVEL:
		if mag_val: mag_val.text = "%d (MAX)" % cur_mag
		if mag_btn:
			mag_btn.text = "MAX LEVEL"
			mag_btn.disabled = true
	else:
		if mag_val: mag_val.text = "%d ➔ %d" % [cur_mag, next_mag]
		var cost = current_res.get_upgrade_cost("mag", m_lvl)
		if mag_btn:
			if not is_unlocked:
				mag_btn.text = "LOCKED"
				mag_btn.disabled = true
			elif cash < cost:
				mag_btn.text = "NEED %d CASH" % cost
				mag_btn.disabled = true
			else:
				mag_btn.text = "UPGRADE (%d CASH)" % cost
				mag_btn.disabled = false
		
	# 3. Reload
	if rel_lbl: rel_lbl.text = "RELOAD [L%d]" % r_lvl
	var cur_rel = current_res.get_reload_time(r_lvl)
	var next_rel = current_res.get_reload_time(r_lvl + 1)
	if reload_bar: reload_bar.value = clamp((5.0 - cur_rel) / 4.0 * 100.0, 10.0, 100.0)
	if r_lvl >= WeaponData.MAX_UPGRADE_LEVEL:
		if reload_val: reload_val.text = "%.2fs (MAX)" % cur_rel
		if reload_btn:
			reload_btn.text = "MAX LEVEL"
			reload_btn.disabled = true
	else:
		if reload_val: reload_val.text = "%.2fs ➔ %.2fs" % [cur_rel, next_rel]
		var cost = current_res.get_upgrade_cost("reload", r_lvl)
		if reload_btn:
			if not is_unlocked:
				reload_btn.text = "LOCKED"
				reload_btn.disabled = true
			elif cash < cost:
				reload_btn.text = "NEED %d CASH" % cost
				reload_btn.disabled = true
			else:
				reload_btn.text = "UPGRADE (%d CASH)" % cost
				reload_btn.disabled = false
		
	# 4. Accuracy
	if acc_lbl: acc_lbl.text = "ACCURACY [L%d]" % a_lvl
	var cur_acc = current_res.get_accuracy(a_lvl)
	var next_acc = current_res.get_accuracy(a_lvl + 1)
	if acc_bar: acc_bar.value = cur_acc
	if a_lvl >= WeaponData.MAX_UPGRADE_LEVEL:
		if acc_val: acc_val.text = "%d%% (MAX)" % int(cur_acc)
		if acc_btn:
			acc_btn.text = "MAX LEVEL"
			acc_btn.disabled = true
	else:
		if acc_val: acc_val.text = "%d%% ➔ %d%%" % [int(cur_acc), int(next_acc)]
		var cost = current_res.get_upgrade_cost("accuracy", a_lvl)
		if acc_btn:
			if not is_unlocked:
				acc_btn.text = "LOCKED"
				acc_btn.disabled = true
			elif cash < cost:
				acc_btn.text = "NEED %d CASH" % cost
				acc_btn.disabled = true
			else:
				acc_btn.text = "UPGRADE (%d CASH)" % cost
				acc_btn.disabled = false
		
	# Equip / Unlock Buttons
	if is_unlocked:
		if unlock_btn: unlock_btn.visible = false
		if equip_btn:
			equip_btn.visible = true
			if is_equipped:
				equip_btn.text = "EQUIPPED"
				equip_btn.disabled = true
			else:
				equip_btn.text = "EQUIP WEAPON"
				equip_btn.disabled = false
	else:
		if equip_btn: equip_btn.visible = false
		if unlock_btn:
			unlock_btn.visible = true
			if cash < unlock_price:
				unlock_btn.text = "INSUFFICIENT CASH (%s)" % _format_number(unlock_price)
				unlock_btn.disabled = true
			else:
				unlock_btn.text = "UNLOCK FOR %s CASH" % _format_number(unlock_price)
				unlock_btn.disabled = false

func _on_equip():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr: return
	
	var success = save_mgr.set_equipped_weapon(current_weapon_id)
	if success:
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("play_ui_click"):
			audio_mgr.play_ui_click()
		_show_feedback("EQUIPPED TO LOADOUT!", Color(0.2, 1.0, 0.5))
		_populate_list()
		_update_ui()

func _on_upgrade(type: String):
	if is_purchasing_locked: return
	is_purchasing_locked = true
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr or not current_res:
		is_purchasing_locked = false
		return
	
	var cost = WeaponManager.get_upgrade_cost(current_weapon_id, type, save_mgr)
	if save_mgr.data.cash < cost:
		if cash_display and cash_display.has_method("play_insufficient_feedback"):
			cash_display.play_insufficient_feedback()
		_show_feedback("INSUFFICIENT CASH FOR UPGRADE!", Color(1.0, 0.3, 0.3))
		is_purchasing_locked = false
		return
		
	var success = WeaponManager.purchase_upgrade(current_weapon_id, type, save_mgr)
	if success:
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("play_ui_click"):
			audio_mgr.play_ui_click()
		_show_feedback("%s CALIBRATED & UPGRADED!" % type.to_upper(), Color(0.2, 1.0, 0.6))
		_update_ui()
	else:
		if cash_display and cash_display.has_method("play_insufficient_feedback"):
			cash_display.play_insufficient_feedback()
	
	get_tree().create_timer(0.15).timeout.connect(func(): is_purchasing_locked = false)

func _on_unlock():
	if is_purchasing_locked: return
	is_purchasing_locked = true
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr:
		is_purchasing_locked = false
		return
	
	var success = WeaponManager.purchase_weapon(current_weapon_id, save_mgr)
	if success:
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("play_ui_click"):
			audio_mgr.play_ui_click()
		_show_feedback("WEAPON UNLOCKED & ACQUIRED!", Color(1.0, 0.85, 0.25))
		_populate_list()
		_update_ui()
	else:
		if cash_display and cash_display.has_method("play_insufficient_feedback"):
			cash_display.play_insufficient_feedback()
		_show_feedback("INSUFFICIENT CASH TO UNLOCK!", Color(1.0, 0.3, 0.3))
		
	get_tree().create_timer(0.2).timeout.connect(func(): is_purchasing_locked = false)

func _show_feedback(msg: String, col: Color):
	if feedback_label:
		feedback_label.text = msg
		feedback_label.modulate = col
		feedback_label.visible = true
		var tw = create_tween()
		tw.tween_property(feedback_label, "modulate:a", 0.0, 1.5).set_delay(1.0)

func _on_cash_changed(_amount: int):
	_update_ui()

func _on_back():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm:
		gsm.change_state(gsm.State.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")

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
