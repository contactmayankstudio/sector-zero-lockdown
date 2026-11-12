extends SceneTree

func _init():
	var win = root
	var world_3d = World3D.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.12, 0.14, 0.18)
	world_3d.environment = env
	win.world_3d = world_3d
	
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60, 30, 0)
	sun.light_energy = 2.0
	win.add_child(sun)
	
	# Isometric / top-side camera looking at origin
	var cam = Camera3D.new()
	cam.position = Vector3(1.0, 1.2, 1.2)
	cam.look_at(Vector3.ZERO, Vector3.UP)
	cam.current = true
	win.add_child(cam)
	
	# Origin node
	var n = Node3D.new()
	win.add_child(n)
	
	# Load Negev
	var res = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = res.instantiate()
	inst.name = "Gun"
	n.add_child(inst)
	
	# Add axis indicators:
	# RED = +X
	var x_axis = MeshInstance3D.new()
	var x_cyl = CylinderMesh.new()
	x_cyl.top_radius = 0.01
	x_cyl.bottom_radius = 0.01
	x_cyl.height = 0.5
	x_axis.mesh = x_cyl
	x_axis.rotation_degrees = Vector3(0, 0, 90)
	x_axis.position = Vector3(0.25, 0, 0)
	var x_mat = StandardMaterial3D.new()
	x_mat.albedo_color = Color(1, 0, 0)
	x_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	x_axis.material_override = x_mat
	n.add_child(x_axis)
	
	# GREEN = +Y
	var y_axis = MeshInstance3D.new()
	var y_cyl = CylinderMesh.new()
	y_cyl.top_radius = 0.01
	y_cyl.bottom_radius = 0.01
	y_cyl.height = 0.5
	y_axis.mesh = y_cyl
	y_axis.position = Vector3(0, 0.25, 0)
	var y_mat = StandardMaterial3D.new()
	y_mat.albedo_color = Color(0, 1, 0)
	y_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	y_axis.material_override = y_mat
	n.add_child(y_axis)
	
	# BLUE = +Z
	var z_axis = MeshInstance3D.new()
	var z_cyl = CylinderMesh.new()
	z_cyl.top_radius = 0.01
	z_cyl.bottom_radius = 0.01
	z_cyl.height = 0.5
	z_axis.mesh = z_cyl
	z_axis.rotation_degrees = Vector3(90, 0, 0)
	z_axis.position = Vector3(0, 0, 0.25)
	var z_mat = StandardMaterial3D.new()
	z_mat.albedo_color = Color(0, 0.3, 1)
	z_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	z_axis.material_override = z_mat
	n.add_child(z_axis)
	
	call_deferred("_render", win)

func _render(win: Window):
	for f in range(6):
		await RenderingServer.frame_post_draw
	var img = win.get_texture().get_image()
	img.save_png("/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/negev_raw_axes.png")
	print("Saved negev_raw_axes.png")
	quit(0)
