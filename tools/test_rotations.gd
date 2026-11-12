extends SceneTree

func _init():
	print("--- TESTING BASES & EULERS ---")
	
	# Desired target basis for AKX SciFi:
	# fwd = (0, 0, -1)
	# up = (0, 1, 0)
	# right = (1, 0, 0)
	# Original vectors in model:
	# fwd_orig = (0, -1, 0)
	# up_orig = (0, 0, 1)
	# right_orig = (1, 0, 0)
	
	var src_basis = Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0)) # right, up, -fwd
	var tgt_basis = Basis(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)) # right, up, -fwd
	var r = tgt_basis * src_basis.inverse()
	var euler = r.get_euler() * (180.0 / PI)
	print("AKX SciFi Euler (degrees): ", euler)
	
	# Verify
	var test_fwd = (Basis.from_euler(r.get_euler()) * Vector3(0, -1, 0))
	var test_up = (Basis.from_euler(r.get_euler()) * Vector3(0, 0, 1))
	print("Verified AKX fwd: ", test_fwd, " up: ", test_up)
	
	# Now verify Negev NG7:
	# fwd_orig = (-1, 0, 0)
	# up_orig = (0, 1, 0)
	var src_negev = Basis(Vector3(0, 0, -1), Vector3(0, 1, 0), Vector3(1, 0, 0))
	var r_negev = tgt_basis * src_negev.inverse()
	var euler_negev = r_negev.get_euler() * (180.0 / PI)
	print("\nNegev Euler (degrees): ", euler_negev)
	print("Verified Negev fwd: ", Basis.from_euler(r_negev.get_euler()) * Vector3(-1, 0, 0))
	print("Verified Negev up: ", Basis.from_euler(r_negev.get_euler()) * Vector3(0, 1, 0))

	# Now verify P90:
	print("\nP90 Euler (degrees): ", euler_negev)
	print("Verified P90 fwd: ", Basis.from_euler(r_negev.get_euler()) * Vector3(-1, 0, 0))
	print("Verified P90 up: ", Basis.from_euler(r_negev.get_euler()) * Vector3(0, 1, 0))

	# Now verify AK-74 with Bayonet:
	# fwd_orig = (0, 0, 1)
	# up_orig = (0, 1, 0)
	var src_ak = Basis(Vector3(-1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, -1))
	var r_ak = tgt_basis * src_ak.inverse()
	var euler_ak = r_ak.get_euler() * (180.0 / PI)
	print("\nAK-74 Euler (degrees): ", euler_ak)
	print("Verified AK-74 fwd: ", Basis.from_euler(r_ak.get_euler()) * Vector3(0, 0, 1))
	print("Verified AK-74 up: ", Basis.from_euler(r_ak.get_euler()) * Vector3(0, 1, 0))

	# Now verify N7 Rifle:
	# fwd_orig = (0, 0, -1)
	# up_orig = (0, 1, 0)
	print("\nN7 Rifle Euler (degrees): (0, 0, 0)")
	print("CAR SMG Euler (degrees): (0, 0, 0)")

	quit(0)
