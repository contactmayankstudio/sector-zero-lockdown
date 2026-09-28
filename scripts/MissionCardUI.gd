extends PanelContainer

signal mission_selected(data: MissionData)

@onready var title_label = $HBox/VBox/Title
@onready var obj_label = $HBox/VBox/Objective
@onready var reward_label = $HBox/VBox/Reward
@onready var status_label = $HBox/VBox/Status
@onready var threat_label = get_node_or_null("HBox/VBox/Threat")
@onready var play_button = $HBox/Margin/PlayButton
@onready var thumbnail = $HBox/ThumbnailPanel/Thumbnail

var mission_data: MissionData

const THUMB_MAP = {
	"mission_01": "res://screenshots/mission_01_gameplay.png",
	"mission_02": "res://screenshots/showcase_airport_service_road.png",
	"mission_03": "res://screenshots/test_railway_render.png",
	"mission_04": "res://screenshots/test_industrial_render.png",
	"mission_05": "res://screenshots/test_industrial_render.png",
	"mission_06": "res://screenshots/showcase_apartment_complex.png",
	"mission_07": "res://screenshots/showcase_apartment_complex.png",
	"mission_08": "res://screenshots/showcase_night_city_street.png",
	"mission_09": "res://screenshots/showcase_airport_service_road.png",
	"mission_10": "res://screenshots/test_industrial_render.png",
	"mission_11": "res://screenshots/test_industrial_render.png",
	"mission_12": "res://screenshots/showcase_new_creatures.png",
	"mission_endless": "res://screenshots/showcase_wrecked_police_cars.png"
}

func setup(data: MissionData):
	mission_data = data
	title_label.text = data.display_name
	
	# Load authentic mission environment thumbnail
	if thumbnail:
		var thumb_path = THUMB_MAP.get(data.mission_id, "screenshots/mission_01_gameplay.png")
		thumb_path = thumb_path.replace("res://", "")
		if FileAccess.file_exists(thumb_path):
			var img = Image.load_from_file(thumb_path)
			if img:
				thumbnail.texture = ImageTexture.create_from_image(img)
	
	var obj_text = "Eliminate hostile contacts."
	match data.objective_type:
		MissionData.ObjectiveType.KILL_COUNT:
			obj_text = "Eliminate %d infected hosts." % data.target_count
		MissionData.ObjectiveType.SURVIVE_WAVES:
			if "is_endless" in data and data.is_endless:
				obj_text = "Survive Infinite Waves — Endless Horde!"
			else:
				obj_text = "Survive %d hostile waves." % data.wave_count
		MissionData.ObjectiveType.BOSS_KILL:
			obj_text = "Neutralize the Sector Apex Alpha specimen."
	obj_label.text = "Objective: " + obj_text
	
	var stars_count = data.difficulty_stars if "difficulty_stars" in data else 1
	var stars_str = ""
	for i in range(5):
		stars_str += "★" if i < stars_count else "☆"
	if threat_label:
		threat_label.text = "THREAT: " + stars_str
	
	var is_unlocked = true
	if data.unlock_requirement_id != "":
		var save_mgr = get_node_or_null("/root/SaveManager")
		if save_mgr:
			is_unlocked = save_mgr.is_mission_completed(data.unlock_requirement_id)
	
	play_button.disabled = false
	if not is_unlocked:
		modulate = Color(0.65, 0.65, 0.65, 0.9)
		status_label.text = "STATUS: LOCKED"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		reward_label.text = "UNLOCK: COMPLETE MISSION 3" if data.is_endless else "BOUNTY: %d CASH (SINGLE-CLAIM)" % data.reward_cash
		play_button.text = "LOCKED"
		play_button.disabled = true
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		var save_mgr = get_node_or_null("/root/SaveManager")
		if "is_endless" in data and data.is_endless:
			var highest = save_mgr.get_highest_wave() if save_mgr and save_mgr.has_method("get_highest_wave") else 0
			status_label.text = "STATUS: UNLOCKED (ENDLESS)"
			status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
			reward_label.text = "BEST: WAVE %d  (+15 CASH/KILL)" % highest
			play_button.text = "SURVIVE"
		else:
			var is_completed = save_mgr.is_mission_completed(data.mission_id) if save_mgr else false
			if is_completed:
				var mission_stars = save_mgr.get_mission_stars(data.mission_id) if save_mgr.has_method("get_mission_stars") else 0
				var earned_stars = ""
				for i in range(3):
					earned_stars += "★" if i < mission_stars else "☆"
				status_label.text = "STATUS: COMPLETED  %s" % earned_stars
				status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
				reward_label.text = "BOUNTY: %d CASH (CLAIMED)" % data.reward_cash
				play_button.text = "REPLAY"
			else:
				status_label.text = "STATUS: ACTIVE"
				status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
				reward_label.text = "BOUNTY: %d CASH (FIRST CLEAR)" % data.reward_cash
				play_button.text = "DEPLOY"

func _on_play_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr: audio_mgr.play_ui_click()

	if play_button.disabled or mission_data == null:
		return
		
	mission_selected.emit(mission_data)
