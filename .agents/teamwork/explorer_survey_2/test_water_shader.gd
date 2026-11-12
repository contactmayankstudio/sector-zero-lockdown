@tool
extends SceneTree

func _init():
	print("Testing comprehensive water shader compilation...")
	var shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_lambert, specular_schlick_ggx;

// Water Color & Depth uniforms
uniform vec4 shallow_color : source_color = vec4(0.22, 0.65, 0.62, 0.75);
uniform vec4 deep_color : source_color = vec4(0.04, 0.18, 0.28, 0.95);
uniform float depth_distance : hint_range(0.1, 50.0) = 4.0;
uniform float beer_factor : hint_range(0.0, 5.0) = 1.2;

// Wave Normal Maps
uniform sampler2D wave_normal1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D wave_normal2 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform vec2 wave_direction1 = vec2(1.0, 0.3);
uniform vec2 wave_direction2 = vec2(-0.4, 0.8);
uniform float wave_speed : hint_range(0.0, 2.0) = 0.05;
uniform float wave_scale : hint_range(0.01, 10.0) = 0.8;
uniform float normal_strength : hint_range(0.0, 5.0) = 0.6;

// Foam / Shoreline
uniform vec4 foam_color : source_color = vec4(0.92, 0.96, 0.98, 0.9);
uniform float foam_distance : hint_range(0.01, 5.0) = 0.45;
uniform float foam_peak_cutoff : hint_range(0.0, 1.0) = 0.55;

// Surface Optics (Fresnel & PBR)
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 0.1;
uniform float specular : hint_range(0.0, 1.0) = 0.8;
uniform float fresnel_power : hint_range(0.5, 10.0) = 4.0;
uniform float edge_fade : hint_range(0.0, 2.0) = 0.15;

// Scene Depth & Screen samplers
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float refraction_strength : hint_range(0.0, 0.2) = 0.02;

void fragment() {
	// 1. Dual Panning UVs
	vec2 uv1 = UV * wave_scale + TIME * wave_direction1 * wave_speed;
	vec2 uv2 = UV * (wave_scale * 1.37) + TIME * wave_direction2 * wave_speed;
	
	// Sample normals
	vec3 n1 = texture(wave_normal1, uv1).rgb * 2.0 - 1.0;
	vec3 n2 = texture(wave_normal2, uv2).rgb * 2.0 - 1.0;
	
	// Blend normals (Whiteout blend)
	vec3 blended_normal = normalize(vec3((n1.xy + n2.xy) * normal_strength, n1.z * n2.z));
	
	// TBN View Normal for Fresnel
	mat3 tbn = mat3(TANGENT, BINORMAL, NORMAL);
	vec3 view_normal = normalize(tbn * blended_normal);
	
	// 2. Linear Depth Calculation (Compatibility + Vulkan cross-compatible)
	float raw_depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 ndc;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	ndc = vec3(SCREEN_UV, raw_depth) * 2.0 - 1.0;
#else
	ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw_depth);
#endif
	vec4 scene_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	scene_view.xyz /= scene_view.w;
	float scene_depth = -scene_view.z;
	float surface_depth = -VERTEX.z;
	float depth_diff = max(scene_depth - surface_depth, 0.0);
	
	// 3. Depth color & absorption (Beer-Lambert law approx)
	float depth_ratio = clamp(depth_diff / depth_distance, 0.0, 1.0);
	float absorption = 1.0 - exp(-depth_diff * beer_factor);
	vec3 water_col = mix(shallow_color.rgb, deep_color.rgb, depth_ratio);
	
	// 4. Refraction from screen texture (optional subtle distortion)
	vec2 ref_uv = SCREEN_UV + (blended_normal.xy * refraction_strength * clamp(depth_diff, 0.0, 1.0));
	vec3 screen_col = textureLod(screen_texture, ref_uv, 0.0).rgb;
	// Blend water color with underwater background
	vec3 base_col = mix(screen_col * water_col, water_col, absorption);
	
	// 5. Shoreline Foam
	float foam_mask = clamp(1.0 - (depth_diff / max(foam_distance, 0.001)), 0.0, 1.0);
	// Use high frequencies of normal textures for foam ripples
	float foam_noise = clamp((n1.x + n2.y) * 0.5 + 0.5, 0.0, 1.0);
	float foam_intensity = smoothstep(0.3, 0.7, foam_mask * (foam_noise + 0.4));
	vec3 final_albedo = mix(base_col, foam_color.rgb, foam_intensity * foam_color.a);
	
	// 6. Fresnel Effect
	float fresnel = pow(1.0 - clamp(dot(view_normal, normalize(VIEW)), 0.0, 1.0), fresnel_power);
	
	// 7. Output assignments
	ALBEDO = final_albedo;
	NORMAL_MAP = blended_normal * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = normal_strength;
	ROUGHNESS = mix(roughness, 0.8, foam_intensity);
	METALLIC = metallic;
	SPECULAR = mix(specular, 0.1, foam_intensity);
	
	// Edge fade for smooth shoreline blending without hard clipping
	float alpha_shore = clamp(depth_diff / max(edge_fade, 0.001), 0.0, 1.0);
	ALPHA = clamp(mix(shallow_color.a, deep_color.a, depth_ratio) * alpha_shore + foam_intensity, 0.0, 1.0);
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	print("Comprehensive water shader compiled successfully!")
	quit(0)
