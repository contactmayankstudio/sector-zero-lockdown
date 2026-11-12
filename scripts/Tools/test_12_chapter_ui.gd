extends SceneTree

var passed: int = 0
var failed: int = 0

func _check(desc: String, condition: bool):
	if condition:
		passed += 1
		print("  [PASS] %s" % desc)
	else:
		failed += 1
		printerr("  [FAIL] %s" % desc)

func _init():
	print("==================================================")
	print("AUDITING 12-CHAPTER TACTICAL MAP UI (84 MISSIONS)")
	print("==================================================")
	
	# 1. Instantiate MissionSelectUI scene
	var ms_scene = load("res://scenes/UI/MissionSelectUI.tscn")
	_check("MissionSelectUI.tscn loaded", ms_scene != null)
	if not ms_scene:
		quit(1)
		return
		
	var ms = ms_scene.instantiate()
	root.add_child(ms)
	await process_frame
	await process_frame
	
	# 2. Check ChapterBar components
	var ch_bar = ms.find_child("ChapterBar", true, false)
	_check("ChapterBar exists", ch_bar != null)
	
	var prev_btn = ms.find_child("PrevChapterBtn", true, false)
	_check("PrevChapterBtn exists", prev_btn != null)
	
	var next_btn = ms.find_child("NextChapterBtn", true, false)
	_check("NextChapterBtn exists", next_btn != null)
	
	var title_lbl = ms.find_child("ChapterTitleLabel", true, false)
	_check("ChapterTitleLabel exists", title_lbl != null and "CHAPTER 01" in title_lbl.text)
	
	var status_lbl = ms.find_child("ChapterStatusLabel", true, false)
	_check("ChapterStatusLabel exists", status_lbl != null and "LOCATION:" in status_lbl.text)
	
	# 3. Check MissionMap integration
	var map = ms.find_child("MissionMap", true, false)
	_check("MissionMap exists", map != null)
	_check("MissionMap has 7 sub-mission nodes for Chapter 1", map.mission_nodes.size() == 7)
	
	# 4. Check Capstone Boss node
	if map.mission_nodes.size() >= 7:
		var node7 = map.mission_nodes[6]
		_check("Node 7 is marked as Boss", node7.is_boss == true)
		_check("Node 7 is Capstone mission 1-7", node7.mission_data.mission_id == "1-7")
		
		var node1 = map.mission_nodes[0]
		_check("Node 1 is First Breach mission 1-1", node1.mission_data.mission_id == "1-1")
		_check("Node 1 is unlocked initially", node1.is_unlocked == true)
		
	# 5. Test Chapter Navigation
	_check("Prev button disabled on Chapter 1", prev_btn.disabled == true)
	
	# Test unlocking Chapter 2 by mocking completion of 1-7 in SaveManager
	var save_mgr = root.get_node_or_null("SaveManager")
	if save_mgr:
		save_mgr.complete_mission("1-7")
		ms.setup_chapter(1) # Switch to Chapter 2
		await process_frame
		
		_check("Title updated to Chapter 2", "CHAPTER 02" in title_lbl.text)
		_check("MissionMap updated to Chapter 2 nodes", map.mission_nodes.size() == 7)
		if map.mission_nodes.size() >= 7:
			_check("Chapter 2 Node 1 is mission 2-1", map.mission_nodes[0].mission_data.mission_id == "2-1")
			_check("Chapter 2 Node 7 is Capstone 2-7", map.mission_nodes[6].mission_data.mission_id == "2-7")
			
		_check("Prev button enabled on Chapter 2", prev_btn.disabled == false)
		
		# Navigate back to Chapter 1
		ms._on_prev_chapter_pressed()
		await process_frame
		_check("Navigated back to Chapter 1", "CHAPTER 01" in title_lbl.text)
		
		# Clean up test save state
		save_mgr.data.completed_missions.erase("1-7")
		save_mgr.save_game()

	# 6. Check Info Panel display
	var info_panel = ms.find_child("MissionInfoPanel", true, false)
	_check("MissionInfoPanel exists", info_panel != null)
	
	print("\n==================================================")
	print("12-CHAPTER UI AUDIT: %d PASSED, %d FAILED" % [passed, failed])
	print("==================================================")
	
	ms.queue_free()
	if failed > 0:
		quit(1)
	else:
		quit(0)
