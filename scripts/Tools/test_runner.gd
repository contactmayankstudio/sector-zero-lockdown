extends SceneTree

# ==============================================================================
# DEAD TARGET TEST RUNNER DELEGATOR
# ==============================================================================
# Executes tests/test_quarantine_defense.gd headlessly and reports exit code.
# Run via:
#   godot --headless -s scripts/Tools/test_runner.gd
# ==============================================================================

func _init():
	print("======================================================================")
	print("[TEST RUNNER] Launching Quarantine Defense E2E Test Suite...")
	print("======================================================================")
	var output: Array = []
	var executable = OS.get_executable_path()
	var args = ["--headless", "-s", "tests/test_quarantine_defense.gd"]
	var exit_code = OS.execute(executable, args, output, true)
	for line in output:
		print(line)
	print("======================================================================")
	print("[TEST RUNNER] Finished with exit code: %d" % exit_code)
	print("======================================================================")
	quit(exit_code)
