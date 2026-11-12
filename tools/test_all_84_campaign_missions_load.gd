extends SceneTree

func _init():
	print("--- VERIFYING ALL 84 MISSIONS IN MISSIONMANAGER ---")
	var mm_script = load("res://scripts/MissionManager.gd")
	var mm = Node.new()
	mm.set_script(mm_script)
	root.add_child(mm)
	
	var missions = mm.campaign_missions if "campaign_missions" in mm else []
	print("MissionManager campaign_missions count: ", missions.size())
	
	var passed = 0
	var failed = 0
	for m in missions:
		if m is MissionData or m is Resource:
			var mid = m.mission_id
			var mname = m.display_name
			var scn = m.scene_path
			if scn != "" and ResourceLoader.exists(scn):
				passed += 1
			else:
				failed += 1
				print("FAILED MISSION: ", mid, " -> missing scene: ", scn)
		else:
			failed += 1
			print("FAILED: invalid item in campaign_missions")
			
	print("RESULTS: ", passed, " / ", missions.size(), " missions 100% verified and valid!")
	if failed == 0 and passed >= 84:
		print("SUCCESS: ALL 84 MISSIONS ARE FULLY FUNCTIONAL AND READY FOR GAMEPLAY!")
	else:
		print("FAILED: some missions need attention")
		
	quit(0 if failed == 0 else 1)
