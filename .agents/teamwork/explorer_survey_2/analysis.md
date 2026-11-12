# Technical Investigation & Analysis: Water Shader & Rendering in Godot 4 gl_compatibility

**Date:** 2026-10-09  
**Agent:** Explorer 2 (Water Shader & Rendering Technicalities)  
**Target Project:** Sector Zero: Lockdown (`/home/am/targetkill`)  
**Target Hardware:** AMD Kabini APU (Radeon HD 8280/8330 graphics, 128 GCN cores, 3.3 GB RAM)  
**Renderer:** Godot 4.7.2 `gl_compatibility` (OpenGL 3.3 / GLES3)

---

## 1. Executive Summary

This investigation analyzed the feasibility, syntax, rendering capabilities, and performance constraints for implementing a photorealistic lake water shader for a dense jungle environment in Godot 4 under `gl_compatibility` mode.

Key findings:
1. **Renderer Status:** `project.godot` specifies `renderer/rendering_method="gl_compatibility"`. Engine binary is Godot `4.7.2.stable.official`.
2. **Depth Texture Support:** `hint_depth_texture` **is fully supported** in `gl_compatibility`. However, OpenGL 3.3 uses Normalized Device Coordinates (NDC) Z in the range `[-1.0, 1.0]`, unlike Vulkan's `[0.0, 1.0]`. The view-space depth conversion requires `#if CURRENT_RENDERER == RENDERER_COMPATIBILITY` to avoid flattened or broken depth calculations.
3. **Reflections in gl_compatibility:** Screen-Space Reflections (SSR) are **strictly unavailable** in `gl_compatibility` (Vulkan Forward+ only). Realistic water reflections must instead be achieved through:
   - Dynamic GGX Specular Sun Glint from `DirectionalLight3D` (sun glitter along wave facets).
   - Image-Based Lighting (IBL) environment sky reflections (`mat_photorealistic_sky.tres`).
   - Static/One-time `ReflectionProbe` over the lake basin to capture trees and cliffs without runtime per-frame overhead.
4. **Bandwidth Optimization for AMD Kabini:** Screen color copying via `hint_screen_texture` introduces an extra FBO copy blit. To maintain steady 45–60 FPS on Kabini's memory-constrained DDR3 bus, a dual-mode approach is recommended: hardware alpha blending for depth fading (zero copy overhead) with optional subtle screen refraction.
5. **Wave Normals:** Two panning normal maps combined via Whiteout Reoriented Normal Blending generate organic, non-repeating ripples with high specular clarity. Seamless 256×256 normal textures provide maximum texture cache efficiency.

---

## 2. Project & Hardware Configuration Analysis

### 2.1 Project Configuration (`project.godot`)
```ini
[rendering]
environment/defaults/default_clear_color=Color(0.04, 0.05, 0.07, 1)
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
scaling_3d/scale=0.85
scaling_3d/mode=0 ; Bilinear
anti_aliasing/quality/msaa_3d=0
```

### 2.2 QualityManager Behavior (`scripts/QualityManager.gd`)
`QualityManager.gd` contains automatic hardware detection:
```gdscript
if adapter_lower.contains("kabini") or adapter_lower.contains("intel") or adapter_lower.contains("mali"):
    is_low_spec = true
```
When `is_low_spec` is true:
- Active Profile: `Profile.ANDROID_LEGACY`
- `scaling_3d_scale = 0.75`
- `scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR`
- `Light3D.shadow_enabled = false`
- `CPUParticles3D.emitting = false`
- Glow, SSAO, and Fog are stripped or disabled on legacy devices.

**Critical Implication for Atmosphere:** Any atmospheric wildlife/insects implemented using `CPUParticles3D` will be automatically disabled by `QualityManager` when running on a Kabini APU. Therefore, ambient jungle audio (`AudioStreamPlayer3D` or `AudioManager`) is the primary, reliable delivery mechanism for living atmosphere, with particle effects as an optional enhancement on higher profiles.

### 2.3 AMD Kabini APU Hardware Profile
- Architecture: AMD Jaguar CPU cores + GCN 1.0 GPU (Radeon HD 8280/8330).
- Compute: 128 stream processors @ 450–500 MHz (~115 GFLOPS).
- Memory: 3.3 GB total unified memory shared between CPU and GPU over a single-channel 64-bit DDR3-1333/1600 interface (~10.6–12.8 GB/s bandwidth).
- Bottleneck: **Memory Bandwidth & Texture Fill-Rate**. Any full-screen framebuffer copies, high-resolution textures, or deep texture sampling loops severely degrade framerate. The water shader must use compact textures (256x256 or 512x512), minimal sampler lookups (2–3 samplers max), and simple arithmetic.

---

## 3. Shader Technicalities in Godot 4 `gl_compatibility`

### 3.1 Depth Texture & NDC Coordinate Transformation
In Godot 4 spatial shaders, depth is accessed via:
```glsl
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
```

#### The OpenGL NDC Difference
In Vulkan (Forward+ and Mobile renderers), the NDC depth range is `[0.0, 1.0]`. In OpenGL 3.3 (gl_compatibility), the NDC depth range is `[-1.0, 1.0]`.

If a shader written for Vulkan is run in Compatibility without adjustment, the NDC reconstruction is mathematically corrupt:
```glsl
// INCORRECT in Compatibility (Vulkan only):
vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw_depth);

// CORRECT in Compatibility (OpenGL):
vec3 ndc = vec3(SCREEN_UV, raw_depth) * 2.0 - 1.0;
```

#### Cross-Compatible Preprocessor Implementation
We verified via `godot --headless` test execution that the preprocessor directive `#if CURRENT_RENDERER == RENDERER_COMPATIBILITY` compiles cleanly in Godot 4.7.2:
```glsl
float raw_depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
vec3 ndc;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
    ndc = vec3(SCREEN_UV, raw_depth) * 2.0 - 1.0;
#else
    ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw_depth);
#endif
vec4 scene_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
scene_view.xyz /= scene_view.w;
float scene_linear_depth = -scene_view.z;
float surface_linear_depth = -VERTEX.z;
float water_depth = max(scene_linear_depth - surface_linear_depth, 0.0);
```

### 3.2 Depth-Based Color Blending & Edge Softening
Using `water_depth`:
1. **Absorption / Color Blending:**
   ```glsl
   float depth_factor = clamp(water_depth / depth_distance, 0.0, 1.0);
   float absorption = 1.0 - exp(-water_depth * beer_factor);
   vec3 water_color = mix(shallow_color.rgb, deep_color.rgb, depth_factor);
   ```
2. **Shoreline Soft Edge Fade:**
   Prevents hard polygon intersection where the water plane meets the terrain shore:
   ```glsl
   float shore_fade = clamp(water_depth / max(edge_fade_distance, 0.001), 0.0, 1.0);
   ALPHA = clamp(mix(shallow_color.a, deep_color.a, depth_factor) * shore_fade + foam_intensity, 0.0, 1.0);
   ```

### 3.3 Dual Panning Wave Normal Maps & Blending
Water ripple movement is modeled using two wave normal maps panning across the surface in different directions and slightly detuned frequencies:
```glsl
vec2 uv1 = UV * wave_scale + TIME * wave_direction1 * wave_speed;
vec2 uv2 = UV * (wave_scale * 1.37) + TIME * wave_direction2 * wave_speed;

vec3 n1 = texture(wave_normal1, uv1).rgb * 2.0 - 1.0;
vec3 n2 = texture(wave_normal2, uv2).rgb * 2.0 - 1.0;
```
*Ratio 1.37:* Using an irrational scaling factor prevents visible repeat patterns and beat frequencies.

#### Reoriented Normal Blending (Whiteout Blend)
Instead of a simple average `(n1 + n2) * 0.5` which dampens wave crests, the Whiteout blend preserves surface steepness:
```glsl
vec3 blended_normal = normalize(vec3((n1.xy + n2.xy) * normal_strength, n1.z * n2.z));
```

### 3.4 Fresnel Optics & View Transformation
The Fresnel effect increases reflectivity as the angle between the viewer ray and water surface becomes shallower.
In Godot 4 spatial shaders:
- `VERTEX` is in view space.
- `VIEW` is `normalize(-VERTEX)`.
- `blended_normal` is in tangent space.

To calculate accurate Fresnel that reacts to the wave ripples:
```glsl
mat3 tbn = mat3(TANGENT, BINORMAL, NORMAL);
vec3 view_normal = normalize(tbn * blended_normal);
float fresnel = pow(1.0 - clamp(dot(view_normal, normalize(VIEW)), 0.0, 1.0), fresnel_power);
```

### 3.5 Reflection Analysis for `gl_compatibility`
| Reflection Technique | Supported in gl_compatibility? | Performance Cost | Recommendation |
|---|---|---|---|
| **Screen-Space Reflections (SSR)** | ❌ NO (Vulkan Forward+ only) | High | Do NOT attempt; engine will ignore or fail |
| **DirectionalLight3D Sun Glitter** | ✅ YES (GGX Specular) | Very Low | **MANDATORY**: Low roughness (0.05–0.1) creates stunning sun highlights on waves |
| **Environment Sky Reflections (IBL)** | ✅ YES (Panoramic / Skybox) | Very Low | **MANDATORY**: Water PBR material reflects `mat_photorealistic_sky.tres` automatically |
| **ReflectionProbe (UPDATE_ONCE)** | ✅ YES | Moderate (one-time bake) | **RECOMMENDED**: Place a probe over lake to capture jungle trees/mountains |
| **Screen Texture Planar Inversion** | ⚠️ Possible in shader | Moderate to High | NOT recommended; visual artifacts on uneven shorelines |

### 3.6 Shoreline Foam Synthesis
Foam naturally collects along shallow shorelines where `water_depth` is small. Rather than a flat color strip, foam is textured using the high-frequency components of the normal maps:
```glsl
float foam_mask = clamp(1.0 - (water_depth / max(foam_distance, 0.001)), 0.0, 1.0);
float foam_ripples = clamp((n1.x + n2.y) * 0.5 + 0.5, 0.0, 1.0);
float foam_intensity = smoothstep(0.35, 0.75, foam_mask * (foam_ripples + 0.35));

vec3 final_albedo = mix(water_color, foam_color.rgb, foam_intensity * foam_color.a);
```

---

## 4. Asset Analysis & Texture Strategy

### 4.1 Existing Project Textures
An inspection of `/home/am/targetkill/textures/` revealed:
- Terrains & Walls: Asphalt, grass, cliff, dirt, mud, concrete PBR textures.
- Sky: `barnaslingan_sky.png`, `gta5_cinematic_sky.png`, `mat_photorealistic_sky.tres`.
- **Water/Noise Textures:** None exist currently.

### 4.2 Wave Normal Map Delivery Options
1. **Option A: Runtime NoiseTexture2D with `as_normal_map = true`**
   - Godot 4 supports `NoiseTexture2D` with `FastNoiseLite`, `as_normal_map = true`, and `seamless = true`.
   - Generates normal maps procedurally in RAM.
2. **Option B: Pre-Baked 256×256 Normal Map PNGs (Optimal for Low-End APU)**
   - Creating two small seamless wave normal PNG textures (e.g., `res://textures/water/wave_normal_1.png` and `res://textures/water/wave_normal_2.png`).
   - Size: 256×256 pixels @ 8-bit RGB = ~192 KB uncompressed, ~50 KB PNG on disk.
   - Zero CPU startup time, zero noise calculation overhead, maximum GPU L1/L2 texture cache hits.

---

## 5. Atmosphere & Living Jungle Analysis

### 5.1 Environment Audio Integration
- Audio files existing in `audio/ambience/`:
  - `sfx_ambience_airport.wav`
  - `sfx_ambience_metro.wav`
  - `sfx_horror_drone.tres` / `sfx_horror_drone.wav`
- For a living jungle lake:
  - An `AudioStreamPlayer3D` attached to the lake node with natural water lapping, wind rustling, or bird chirps.
  - Using Godot's built-in `AudioStreamGenerator` or a dedicated ambient jungle loop seamlessly loops in 3D positional audio.
  - Audio runs independently of rendering threads and costs <0.1% CPU.

### 5.2 Particle vs Audio Resilience
Because `QualityManager.gd` disables `CPUParticles3D` on `ANDROID_LEGACY` (Kabini APU profile), any visual atmosphere particles (fireflies, water insects, floating mist) should:
- Be placed with conservative particle counts (16–32 particles max).
- Include a fallback check so their suppression does not cause script errors.

---

## 6. Lake Placement in `CityCarZombieArena`

Based on `build_advanced_terrain.gd`:
- Valley floor coordinates:
  - Width: `wx` from -130 to +130.
  - Length: `wz` from -430 to +10 (centered at -210).
  - Highway corridor: `abs(wx) < 13.0` (must remain unobstructed).
- Suggested Lake Basin Location:
  - East Valley clearing: `wx` between 40.0 and 95.0, `wz` between -160.0 and -220.0.
  - Elevation: `y = -0.4` to `0.0`.
  - Lake Mesh dimensions: 55m × 45m plane (`PlaneMesh` with 16×16 subdivisions).
  - Vegetation exclusion: In `_build_foliage_and_props()`, skip spawning trees, rocks, and bushes inside the lake rectangle.

---

## 7. Recommended Water Shader Blueprint

```glsl
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_lambert, specular_schlick_ggx;

// Water Color Palette (Tropical Jungle Lake)
uniform vec4 shallow_color : source_color = vec4(0.20, 0.62, 0.58, 0.72);
uniform vec4 deep_color : source_color = vec4(0.04, 0.16, 0.24, 0.95);
uniform float depth_distance : hint_range(0.1, 30.0) = 3.5;
uniform float beer_factor : hint_range(0.0, 5.0) = 1.0;

// Dual Panning Wave Normals
uniform sampler2D wave_normal1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D wave_normal2 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform vec2 wave_direction1 = vec2(1.0, 0.35);
uniform vec2 wave_direction2 = vec2(-0.4, 0.85);
uniform float wave_speed : hint_range(0.0, 1.0) = 0.04;
uniform float wave_scale : hint_range(0.01, 5.0) = 0.65;
uniform float normal_strength : hint_range(0.0, 3.0) = 0.75;

// Shoreline & Foam
uniform vec4 foam_color : source_color = vec4(0.92, 0.96, 0.98, 0.95);
uniform float foam_distance : hint_range(0.01, 3.0) = 0.35;
uniform float edge_fade_distance : hint_range(0.0, 2.0) = 0.15;

// Surface Optics (Fresnel & PBR)
uniform float roughness : hint_range(0.0, 1.0) = 0.06;
uniform float metallic : hint_range(0.0, 1.0) = 0.05;
uniform float specular : hint_range(0.0, 1.0) = 0.90;
uniform float fresnel_power : hint_range(0.5, 8.0) = 4.0;

// Scene Depth Texture
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void fragment() {
    // 1. Dual Panning UVs
    vec2 uv1 = UV * wave_scale + TIME * wave_direction1 * wave_speed;
    vec2 uv2 = UV * (wave_scale * 1.37) + TIME * wave_direction2 * wave_speed;
    
    // 2. Normal Sampling & Whiteout Blend
    vec3 n1 = texture(wave_normal1, uv1).rgb * 2.0 - 1.0;
    vec3 n2 = texture(wave_normal2, uv2).rgb * 2.0 - 1.0;
    vec3 blended_normal = normalize(vec3((n1.xy + n2.xy) * normal_strength, n1.z * n2.z));
    
    // 3. TBN Transformation for View Normal (Fresnel)
    mat3 tbn = mat3(TANGENT, BINORMAL, NORMAL);
    vec3 view_normal = normalize(tbn * blended_normal);
    
    // 4. Linear Depth Reconstruction (gl_compatibility OpenGL NDC vs Vulkan)
    float raw_depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
    vec3 ndc;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
    ndc = vec3(SCREEN_UV, raw_depth) * 2.0 - 1.0;
#else
    ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw_depth);
#endif
    vec4 scene_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    scene_view.xyz /= scene_view.w;
    float scene_linear_depth = -scene_view.z;
    float surface_linear_depth = -VERTEX.z;
    float water_depth = max(scene_linear_depth - surface_linear_depth, 0.0);
    
    // 5. Water Color Depth Blending
    float depth_factor = clamp(water_depth / depth_distance, 0.0, 1.0);
    vec3 water_color = mix(shallow_color.rgb, deep_color.rgb, depth_factor);
    
    // 6. Shoreline Foam
    float foam_mask = clamp(1.0 - (water_depth / max(foam_distance, 0.001)), 0.0, 1.0);
    float foam_ripples = clamp((n1.x + n2.y) * 0.5 + 0.5, 0.0, 1.0);
    float foam_intensity = smoothstep(0.35, 0.75, foam_mask * (foam_ripples + 0.35));
    vec3 final_albedo = mix(water_color, foam_color.rgb, foam_intensity * foam_color.a);
    
    // 7. Output Assignments
    ALBEDO = final_albedo;
    NORMAL_MAP = blended_normal * 0.5 + 0.5;
    NORMAL_MAP_DEPTH = normal_strength;
    ROUGHNESS = mix(roughness, 0.85, foam_intensity);
    METALLIC = metallic;
    SPECULAR = mix(specular, 0.1, foam_intensity);
    
    // Soft Shoreline Edge Fade
    float shore_fade = clamp(water_depth / max(edge_fade_distance, 0.001), 0.0, 1.0);
    ALPHA = clamp(mix(shallow_color.a, deep_color.a, depth_factor) * shore_fade + foam_intensity, 0.0, 1.0);
}
```
