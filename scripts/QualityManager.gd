extends Node

const ErrorHandler = preload("res://scripts/Core/ErrorHandler.gd")

enum Quality { LOW = 0, MEDIUM = 1, HIGH = 2 }
enum Profile { ANDROID_LEGACY = 0, ANDROID_BALANCED = 1, ANDROID_HIGH = 2 }

var current_quality: int = Quality.MEDIUM
var capabilities: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)
	capabilities = detect_device_capabilities()
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	var chosen = capabilities.recommended_profile
	if save_mgr and save_mgr.data.has("selected_quality"):
		chosen = save_mgr.data.selected_quality
	elif OS.get_name() == "Android":
		chosen = Profile.ANDROID_LEGACY
		
	apply_quality(chosen)
	print("[%d ms] [BOOT:04] QualityManager ready (Device: %s, Profile: %s, Vulkan: %s)" % [
		Time.get_ticks_msec(),
		capabilities.adapter_name if capabilities.adapter_name != "" else capabilities.os,
		get_profile_name(current_quality),
		str(capabilities.is_vulkan)
	])

func _on_node_added(node: Node):
	if current_quality == Profile.ANDROID_LEGACY:
		if node is Light3D:
			node.shadow_enabled = false
		elif node is WorldEnvironment and node.environment:
			node.environment.glow_enabled = false
			node.environment.ssao_enabled = false
			node.environment.fog_enabled = false
		elif node is CPUParticles3D:
			node.emitting = false
			node.visible = false

func detect_device_capabilities() -> Dictionary:
	var info = {}
	info["os"] = OS.get_name()
	info["os_version"] = OS.get_version()
	info["model_name"] = OS.get_model_name()
	info["adapter_name"] = RenderingServer.get_video_adapter_name()
	info["adapter_vendor"] = RenderingServer.get_video_adapter_vendor()
	info["is_vulkan"] = (RenderingServer.get_rendering_device() != null)
	info["screen_size"] = DisplayServer.screen_get_size()
	info["refresh_rate"] = DisplayServer.screen_get_refresh_rate()
	info["static_ram_mb"] = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	
	var is_low_spec = false
	var adapter_lower = info["adapter_name"].to_lower()
	if not info["is_vulkan"] or OS.get_name() == "Android":
		is_low_spec = true
	if adapter_lower.contains("kabini") or adapter_lower.contains("intel") or adapter_lower.contains("mali") or adapter_lower.contains("llvmpipe") or adapter_lower.contains("virgl"):
		is_low_spec = true
	if OS.get_processor_count() <= 2:
		is_low_spec = true
		
	var recommended = Profile.ANDROID_LEGACY if is_low_spec else Profile.ANDROID_BALANCED
	info["recommended_profile"] = recommended
	return info

func get_profile_name(level: int) -> String:
	match level:
		Profile.ANDROID_LEGACY: return "ANDROID_LEGACY"
		Profile.ANDROID_BALANCED: return "ANDROID_BALANCED"
		Profile.ANDROID_HIGH: return "ANDROID_HIGH"
		_: return "ANDROID_BALANCED"

func apply_quality(level: int):
	current_quality = clamp(level, 0, 2)
	match current_quality:
		Profile.ANDROID_LEGACY:
			setup_legacy_profile()
		Profile.ANDROID_BALANCED:
			setup_balanced_profile()
		Profile.ANDROID_HIGH:
			setup_high_profile()
			
	_update_shadows(current_quality)
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.quality_changed.emit(get_profile_name(current_quality))

func setup_legacy_profile():
	var vp = get_viewport()
	if vp:
		vp.msaa_3d = Viewport.MSAA_DISABLED
		vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		vp.use_hdr_2d = false
		vp.scaling_3d_scale = 0.75
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	_update_environment(false, false, false)
	_strip_shadows_and_particles()

func _strip_shadows_and_particles():
	if not is_inside_tree() or not get_tree() or not get_tree().root:
		return
	for light in get_tree().root.find_children("*", "Light3D", true, false):
		if light is Light3D:
			light.shadow_enabled = false
	for part in get_tree().root.find_children("*", "CPUParticles3D", true, false):
		if part is CPUParticles3D:
			part.emitting = false
			part.visible = false

func setup_balanced_profile():
	var vp = get_viewport()
	if vp:
		vp.msaa_3d = Viewport.MSAA_2X
		if RenderingServer.get_rendering_device() != null:
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		else:
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		vp.use_hdr_2d = true
		vp.scaling_3d_scale = 0.85
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	_update_environment(true, false, true)

func setup_high_profile():
	var vp = get_viewport()
	if vp:
		vp.msaa_3d = Viewport.MSAA_4X
		if RenderingServer.get_rendering_device() != null:
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		else:
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		vp.use_hdr_2d = true
		vp.scaling_3d_scale = 1.0
	_update_environment(true, true, true)

# Legacy aliases for backwards compatibility with tests
func setup_low_quality(): setup_legacy_profile()
func setup_medium_quality(): setup_balanced_profile()
func setup_high_quality(): setup_high_profile()

func _update_shadows(level: int):
	if not is_inside_tree() or not get_tree() or not get_tree().root:
		return
	var lights = get_tree().root.find_children("*", "Light3D", true, false)
	for light in lights:
		if light is Light3D:
			match level:
				Profile.ANDROID_LEGACY:
					light.shadow_enabled = false
				Profile.ANDROID_BALANCED:
					if light is DirectionalLight3D:
						light.shadow_enabled = true
						light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
					else:
						light.shadow_enabled = false
				Profile.ANDROID_HIGH:
					light.shadow_enabled = true
					if light is DirectionalLight3D:
						light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS

func _update_environment(glow: bool, ssao: bool, fog: bool):
	var world_env = get_tree().root.find_child("WorldEnvironment", true, false)
	if world_env and world_env.environment:
		var env = world_env.environment
		env.glow_enabled = glow
		# Gracefully guard SSAO on non-Vulkan / compatibility
		if ssao and RenderingServer.get_rendering_device() == null:
			env.ssao_enabled = false
			ErrorHandler.report_error(ErrorHandler.Category.GRAPHICS_FALLBACK, "SSAO disabled on GLES3/Compatibility renderer")
		else:
			env.ssao_enabled = ssao
		env.fog_enabled = fog
