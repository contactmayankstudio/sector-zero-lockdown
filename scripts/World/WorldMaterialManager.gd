# WorldMaterialManager.gd
# AGENT 8: GRAPHICS & ENVIRONMENT MATERIAL SYSTEM
# High-fidelity PBR materials, authentic road markings, glowing streetlights, and foliage.
class_name WorldMaterialManager
extends RefCounted

static var _mat_grass: StandardMaterial3D = null
static var _mat_soil: StandardMaterial3D = null
static var _mat_road: StandardMaterial3D = null
static var _mat_sidewalk: StandardMaterial3D = null
static var _mat_curb: StandardMaterial3D = null
static var _mat_rock: StandardMaterial3D = null
static var _mat_water: StandardMaterial3D = null
static var _mat_yellow_line: StandardMaterial3D = null
static var _mat_white_line: StandardMaterial3D = null
static var _mat_lamp_glow: StandardMaterial3D = null
static var _mat_building_brick: StandardMaterial3D = null
static var _mat_building_concrete: StandardMaterial3D = null
static var _mat_building_glass: StandardMaterial3D = null
static var _mat_wood: StandardMaterial3D = null
static var _mat_warehouse_metal: StandardMaterial3D = null
static var _mat_distant_mountain: StandardMaterial3D = null
static var _mat_terrain_shaders: Dictionary = {}
static var _mat_plaza: ShaderMaterial = null
static var _mat_distant_ground: StandardMaterial3D = null

# Dedicated PBR House Materials (Spanish, Modern, Ranch)
static var _mat_house_terracotta: StandardMaterial3D = null
static var _mat_house_shingle: StandardMaterial3D = null
static var _mat_house_stucco: StandardMaterial3D = null
static var _mat_house_siding: StandardMaterial3D = null
static var _mat_house_modern: StandardMaterial3D = null
static var _mat_house_wood_trim: StandardMaterial3D = null
static var _mat_house_garage: StandardMaterial3D = null
static var _mat_house_brick_chimney: StandardMaterial3D = null

static func get_grass_material() -> StandardMaterial3D:
	if _mat_grass != null:
		return _mat_grass
		
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/grass/vibrant_grass_diff_1k.jpg")
	var norm = load("res://textures/pbr/grass/vibrant_grass_nor_1k.jpg")
	var arm = load("res://textures/pbr/grass/vibrant_grass_arm_1k.jpg")
	
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(1.0, 1.0, 1.0)
	else:
		mat.albedo_color = Color(0.35, 0.55, 0.28)
		
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.8
		
	if arm:
		mat.roughness_texture = arm
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		mat.ao_enabled = true
		mat.ao_texture = arm
		mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	else:
		mat.roughness = 0.88
		
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(0.25, 0.25, 0.25)
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = false
	mat.uv1_triplanar_sharpness = 3.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_grass = mat
	return _mat_grass

static func get_soil_material() -> StandardMaterial3D:
	if _mat_soil != null:
		return _mat_soil
		
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/ground/brown_mud_diff_1k.jpg")
	var norm = load("res://textures/pbr/ground/brown_mud_nor_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.55, 0.45, 0.35)
	else:
		mat.albedo_color = Color(0.45, 0.36, 0.28)
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.35
	mat.roughness = 0.92
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(0.08, 0.08, 0.08)
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_triplanar_sharpness = 2.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_soil = mat
	return _mat_soil

static func get_road_material() -> StandardMaterial3D:
	if _mat_road != null:
		return _mat_road
		
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/asphalt/asphalt_02_diff_1k.jpg")
	var norm = load("res://textures/pbr/asphalt/asphalt_02_nor_gl_1k.jpg")
	var arm = load("res://textures/pbr/asphalt/asphalt_02_arm_1k.jpg")
		
	if diff:
		mat.albedo_texture = diff
		# Realistic dark GTA V asphalt tint, eradicating bright speckled noise
		mat.albedo_color = Color(0.18, 0.18, 0.20)
	else:
		mat.albedo_color = Color(0.18, 0.18, 0.20)
		
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.22
		
	if arm:
		mat.roughness_texture = arm
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		mat.ao_enabled = true
		mat.ao_texture = arm
		mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		mat.roughness = 0.88
	else:
		mat.roughness = 0.88
		
	mat.metallic = 0.0
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	# World-triplanar UV mapping with calibrated scale for seamless asphalt across all chunks
	mat.uv1_scale = Vector3(0.12, 0.12, 0.12)
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_triplanar_sharpness = 4.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_road = mat
	return _mat_road

static func get_yellow_line_material() -> StandardMaterial3D:
	if _mat_yellow_line != null:
		return _mat_yellow_line
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.96, 0.80, 0.12)
	mat.roughness = 0.45
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_yellow_line = mat
	return _mat_yellow_line

static func get_white_line_material() -> StandardMaterial3D:
	if _mat_white_line != null:
		return _mat_white_line
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.94, 0.94, 0.94)
	mat.roughness = 0.45
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_white_line = mat
	return _mat_white_line

static func get_sidewalk_material() -> StandardMaterial3D:
	if _mat_sidewalk != null:
		return _mat_sidewalk
		
	var mat = StandardMaterial3D.new()
	# Clean neutral architectural concrete slab - realistic GTA V muted pavement light grey
	var diff = load("res://textures/pbr/walls/concrete_block_diff_1k.jpg")
	var norm = load("res://textures/pbr/tex_concrete_normal.png")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.88, 0.88, 0.86)
	else:
		mat.albedo_color = Color(0.78, 0.78, 0.76)
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.10
	mat.roughness = 0.90
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(4.0, 4.0, 4.0)
	mat.uv1_triplanar = false
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_sidewalk = mat
	return _mat_sidewalk

static func get_curb_material() -> StandardMaterial3D:
	if _mat_curb != null:
		return _mat_curb
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.28, 0.30)
	mat.roughness = 0.9
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_curb = mat
	return _mat_curb

static func get_lamp_glow_material() -> StandardMaterial3D:
	if _mat_lamp_glow != null:
		return _mat_lamp_glow
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.95, 0.82)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.92, 0.75)
	mat.emission_energy_multiplier = 2.4
	_mat_lamp_glow = mat
	return _mat_lamp_glow

static func get_rock_material() -> StandardMaterial3D:
	if _mat_rock != null:
		return _mat_rock
		
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/mountain/cliff_diff_1k.jpg")
	var norm = load("res://textures/pbr/mountain/cliff_nor_1k.jpg")
	var arm = load("res://textures/pbr/mountain/cliff_arm_1k.jpg")
	
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.85, 0.85, 0.85)
	else:
		mat.albedo_color = Color(0.48, 0.44, 0.42)
		
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.45
		
	if arm:
		mat.roughness_texture = arm
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		mat.ao_enabled = true
		mat.ao_texture = arm
		mat.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	else:
		mat.roughness = 0.90
		
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(0.08, 0.08, 0.08)
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = false
	mat.uv1_triplanar_sharpness = 3.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_rock = mat
	return _mat_rock

static func get_water_material() -> StandardMaterial3D:
	if _mat_water != null:
		return _mat_water
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.38, 0.58, 0.88)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.12
	mat.metallic = 0.2
	_mat_water = mat
	return _mat_water

static func get_building_brick_material() -> StandardMaterial3D:
	if _mat_building_brick != null:
		return _mat_building_brick
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/walls/broken_brick_diff_1k.jpg")
	var norm = load("res://textures/pbr/walls/broken_brick_nor_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.88, 0.85, 0.82)
	else:
		mat.albedo_color = Color(0.68, 0.42, 0.35)
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
	mat.roughness = 0.85
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(4.0, 4.0, 4.0)
	mat.uv1_triplanar = false
	_mat_building_brick = mat
	return _mat_building_brick

static func get_building_concrete_material() -> StandardMaterial3D:
	if _mat_building_concrete != null:
		return _mat_building_concrete
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/walls/concrete_block_diff_1k.jpg")
	var norm = load("res://textures/pbr/walls/concrete_block_nor_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.85, 0.85, 0.82)
	else:
		mat.albedo_color = Color(0.65, 0.65, 0.66)
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.5
	mat.roughness = 0.88
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(0.25, 0.25, 0.25)
	mat.uv1_triplanar = true
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_building_concrete = mat
	return _mat_building_concrete

static func get_building_glass_material() -> StandardMaterial3D:
	if _mat_building_glass != null:
		return _mat_building_glass
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.20, 0.32, 0.95)
	mat.roughness = 0.10
	mat.metallic = 0.90
	mat.metallic_specular = 0.95
	mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX # Selective PBR specular reflection
	_mat_building_glass = mat
	return _mat_building_glass

static func set_night_window_glow(is_night: bool, is_sunset: bool = false):
	var glass = get_building_glass_material()
	if is_night:
		glass.emission_enabled = true
		glass.emission = Color(1.0, 0.88, 0.58)
		glass.emission_energy_multiplier = 0.85
	elif is_sunset:
		glass.emission_enabled = true
		glass.emission = Color(1.0, 0.70, 0.38)
		glass.emission_energy_multiplier = 0.35
	else:
		glass.emission_enabled = false
		glass.emission_energy_multiplier = 0.0

static func get_warehouse_metal_material() -> StandardMaterial3D:
	if _mat_warehouse_metal != null:
		return _mat_warehouse_metal
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/tex_train_metal.png")
	var norm = load("res://textures/pbr/tex_metal_normal.png")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.72, 0.74, 0.76)
	else:
		mat.albedo_color = Color(0.42, 0.44, 0.48)
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.6
	mat.metallic = 0.65
	mat.roughness = 0.45
	mat.metallic_specular = 0.60
	mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX # Selective PBR specular reflection
	mat.uv1_scale = Vector3(0.2, 0.2, 0.2)
	mat.uv1_triplanar = true
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_warehouse_metal = mat
	return _mat_warehouse_metal

static func get_house_roof_terracotta_material() -> StandardMaterial3D:
	if _mat_house_terracotta != null:
		return _mat_house_terracotta
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.70, 0.29, 0.17) # Warm Mediterranean terracotta S-tile
	mat.roughness = 0.82
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_terracotta = mat
	return _mat_house_terracotta

static func get_house_roof_shingle_material() -> StandardMaterial3D:
	if _mat_house_shingle != null:
		return _mat_house_shingle
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.24, 0.27) # Dark slate architectural shingles
	mat.roughness = 0.85
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_shingle = mat
	return _mat_house_shingle

static func get_house_stucco_material() -> StandardMaterial3D:
	if _mat_house_stucco != null:
		return _mat_house_stucco
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/walls/concrete_block_diff_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.94, 0.89, 0.80) # Warm California Spanish stucco
	else:
		mat.albedo_color = Color(0.92, 0.87, 0.78)
	mat.roughness = 0.88
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(0.3, 0.3, 0.3)
	mat.uv1_triplanar = true
	_mat_house_stucco = mat
	return _mat_house_stucco

static func get_house_siding_material() -> StandardMaterial3D:
	if _mat_house_siding != null:
		return _mat_house_siding
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.80, 0.72) # Suburban horizontal siding beige/sand
	mat.roughness = 0.80
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_siding = mat
	return _mat_house_siding

static func get_house_modern_material() -> StandardMaterial3D:
	if _mat_house_modern != null:
		return _mat_house_modern
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.88, 0.88, 0.86) # Modern crisp architectural off-white
	mat.roughness = 0.72
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_modern = mat
	return _mat_house_modern

static func get_house_wood_trim_material() -> StandardMaterial3D:
	if _mat_house_wood_trim != null:
		return _mat_house_wood_trim
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.20, 0.14) # Rich dark timber / entrance door
	mat.roughness = 0.65
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_wood_trim = mat
	return _mat_house_wood_trim

static func get_house_garage_material() -> StandardMaterial3D:
	if _mat_house_garage != null:
		return _mat_house_garage
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.86, 0.88) # Panelled white garage door
	mat.roughness = 0.55
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_garage = mat
	return _mat_house_garage

static func get_house_brick_chimney_material() -> StandardMaterial3D:
	if _mat_house_brick_chimney != null:
		return _mat_house_brick_chimney
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/walls/broken_brick_diff_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.82, 0.45, 0.36)
	else:
		mat.albedo_color = Color(0.62, 0.32, 0.24)
	mat.roughness = 0.85
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_house_brick_chimney = mat
	return _mat_house_brick_chimney

static func get_distant_mountain_material() -> StandardMaterial3D:
	if _mat_distant_mountain != null:
		return _mat_distant_mountain
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/mountain/cliff_diff_1k.jpg")
	var norm = load("res://textures/pbr/mountain/cliff_nor_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.55, 0.62, 0.70) # Majestic cool alpine slate tint
	else:
		mat.albedo_color = Color(0.45, 0.50, 0.58)
	if norm:
		mat.normal_enabled = true
		mat.normal_texture = norm
		mat.normal_scale = 0.5
	mat.roughness = 0.95
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.uv1_scale = Vector3(0.02, 0.02, 0.02) # 50m world repetition for distant scale
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = false
	mat.uv1_triplanar_sharpness = 3.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_distant_mountain = mat
	return _mat_distant_mountain



static func get_wood_material() -> StandardMaterial3D:
	if _mat_wood != null:
		return _mat_wood
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.28, 0.18)
	mat.roughness = 0.80
	mat.metallic_specular = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mat_wood = mat
	return _mat_wood

static func get_terrain_material(region_type: int = 0) -> ShaderMaterial:
	if _mat_terrain_shaders.has(region_type):
		return _mat_terrain_shaders[region_type]
		
	var shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_disabled;

uniform sampler2D grass_tex : source_color, filter_linear_mipmap;
uniform sampler2D soil_tex : source_color, filter_linear_mipmap;
uniform sampler2D rock_tex : source_color, filter_linear_mipmap;

uniform vec4 grass_color : source_color = vec4(0.35, 0.55, 0.28, 1.0);
uniform vec4 soil_color : source_color = vec4(0.50, 0.40, 0.30, 1.0);
uniform vec4 rock_color : source_color = vec4(0.68, 0.65, 0.62, 1.0);

uniform float uv_scale_grass = 0.20;
uniform float uv_scale_soil = 0.12;
uniform float uv_scale_rock = 0.08;
uniform int region_type = 0;

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(v_world_normal);
	float slope = clamp(n.y, 0.0, 1.0);
	
	// Smoothstep cliff rock transition on steep slopes (slope < 0.72)
	float rock_w = 1.0 - smoothstep(0.54, 0.76, slope);
	
	// Natural transitional soil blending on intermediate slopes
	float soil_w = (1.0 - rock_w) * (1.0 - smoothstep(0.74, 0.92, slope));
	
	// Coastal region bias or coastal depression below sea level
	if (region_type == 5) { // COASTAL
		soil_w = max(soil_w, 0.70 * (1.0 - rock_w));
	} else if (v_world_pos.y < 0.2) {
		float coast_t = clamp((0.2 - v_world_pos.y) * 0.6, 0.0, 0.85);
		soil_w = max(soil_w, coast_t * (1.0 - rock_w));
	}
	
	// High mountain alpine elevation bias
	if (v_world_pos.y > 22.0) {
		float m_t = clamp((v_world_pos.y - 22.0) * 0.035, 0.0, 0.55);
		rock_w = clamp(rock_w + m_t, 0.0, 1.0);
		soil_w *= (1.0 - m_t);
	}
	
	float grass_w = max(0.0, 1.0 - rock_w - soil_w);
	float total_w = grass_w + soil_w + rock_w;
	if (total_w > 0.001) {
		grass_w /= total_w;
		soil_w /= total_w;
		rock_w /= total_w;
	} else {
		grass_w = 1.0;
	}
	
	// World-space UV mapping for seamless chunk borders
	vec2 uv_g = v_world_pos.xz * uv_scale_grass;
	vec2 uv_s = v_world_pos.xz * uv_scale_soil;
	
	// Triplanar sampling for rock to eliminate vertical cliff stretching
	vec3 blend_weights = abs(n);
	blend_weights = max((blend_weights - 0.2) * 7.0, 0.0);
	blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);
	
	vec4 rock_xy = texture(rock_tex, v_world_pos.xy * uv_scale_rock);
	vec4 rock_zy = texture(rock_tex, v_world_pos.zy * uv_scale_rock);
	vec4 rock_xz = texture(rock_tex, v_world_pos.xz * uv_scale_rock);
	vec4 rock_samp = rock_xy * blend_weights.z + rock_zy * blend_weights.x + rock_xz * blend_weights.y;
	
	vec4 g_samp = texture(grass_tex, uv_g);
	vec4 s_samp = texture(soil_tex, uv_s);
	
	vec3 c_grass = g_samp.rgb * grass_color.rgb;
	vec3 c_soil = s_samp.rgb * soil_color.rgb;
	vec3 c_rock = rock_samp.rgb * rock_color.rgb;
	
	ALBEDO = c_grass * grass_w + c_soil * soil_w + c_rock * rock_w;
	ROUGHNESS = 0.95;
	METALLIC = 0.0;
	SPECULAR = 0.0;
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	
	var diff_grass = load("res://textures/pbr/grass/vibrant_grass_diff_1k.jpg")
	var diff_soil = load("res://textures/pbr/ground/brown_mud_diff_1k.jpg")
	var diff_rock = load("res://textures/pbr/mountain/cliff_diff_1k.jpg")
	
	if diff_grass: mat.set_shader_parameter("grass_tex", diff_grass)
	if diff_soil: mat.set_shader_parameter("soil_tex", diff_soil)
	if diff_rock: mat.set_shader_parameter("rock_tex", diff_rock)
	mat.set_shader_parameter("region_type", region_type)
	
	_mat_terrain_shaders[region_type] = mat
	return mat

static func get_plaza_shader_material() -> ShaderMaterial:
	if _mat_plaza != null:
		return _mat_plaza
		
	var shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_disabled;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap;
uniform vec4 plaza_color : source_color = vec4(0.86, 0.86, 0.84, 1.0);
uniform vec3 uv_scale = vec3(0.22, 0.22, 0.22);

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = v_world_pos.xz * uv_scale.xz;
	vec4 tex = texture(albedo_tex, uv);
	
	// Subtle architectural concrete pavement slab seams (every 2.5m)
	vec2 grid = abs(fract(v_world_pos.xz * 0.40) - 0.5);
	float line_mask = smoothstep(0.46, 0.49, max(grid.x, grid.y));
	vec3 slab_color = mix(tex.rgb * plaza_color.rgb, vec3(0.55, 0.55, 0.53), line_mask * 0.35);
	
	ALBEDO = slab_color;
	ROUGHNESS = 0.92;
	SPECULAR = 0.0;
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	var diff = load("res://textures/pbr/walls/concrete_block_diff_1k.jpg")
	if diff:
		mat.set_shader_parameter("albedo_tex", diff)
		
	_mat_plaza = mat
	return _mat_plaza

static func get_distant_ground_material() -> StandardMaterial3D:
	if _mat_distant_ground != null:
		return _mat_distant_ground
		
	var mat = StandardMaterial3D.new()
	var diff = load("res://textures/pbr/grass/vibrant_grass_diff_1k.jpg")
	if diff:
		mat.albedo_texture = diff
		mat.albedo_color = Color(0.42, 0.58, 0.35)
	else:
		mat.albedo_color = Color(0.35, 0.52, 0.28)
	mat.roughness = 0.95
	mat.metallic_specular = 0.0
	mat.uv1_scale = Vector3(0.04, 0.04, 0.04) # 25m world repetition for distant landscape
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_distant_ground = mat
	return _mat_distant_ground
