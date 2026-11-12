# Requirement 2 Investigation Report: Crystal-Clear Ground & Alpine Visuals

**Date**: 2026-10-10  
**Surveyor**: Explorer 2 (Survey 2 - Gen 5)  
**Working Directory**: `/home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_2_gen5`  
**Project Root**: `/home/am/targetkill`  
**Authoritative Reference**: `/home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md` (Follow-up 2026-10-10T07:36:14Z)

---

## 1. Observation

### 1.1 Ground Grass (`mat_real_grass_pbr.tres`) & Dirt Tracks (`mat_dirt_pbr.tres`)

#### A. Disk Material Resources
- **Ground Grass Material**: `/home/am/targetkill/resources/materials/mat_real_grass_pbr.tres`
  ```ini
  [gd_resource type="StandardMaterial3D" load_steps=4 format=3 uid="uid://mat_real_grass_pbr"]
  [ext_resource type="Texture2D" uid="uid://v2m5w4pvm7m6" path="res://textures/pbr/grass/grass_diff_1k.jpg" id="1_diff"]
  [ext_resource type="Texture2D" uid="uid://b7ba2o55rlnb3" path="res://textures/pbr/grass/grass_nor_1k.jpg" id="2_nor"]
  [ext_resource type="Texture2D" uid="uid://datsvi1ykvsyi" path="res://textures/pbr/grass/grass_arm_1k.jpg" id="3_arm"]

  [resource]
  resource_name = "mat_real_grass_pbr"
  albedo_color = Color(1, 1, 1, 1)
  albedo_texture = ExtResource("1_diff")
  metallic_specular = 0.20
  roughness = 0.82
  roughness_texture = ExtResource("3_arm")
  roughness_texture_channel = 1
  normal_enabled = true
  normal_scale = 1.10
  normal_texture = ExtResource("2_nor")
  ao_enabled = true
  ao_texture = ExtResource("3_arm")
  ao_texture_channel = 0
  uv1_scale = Vector3(1, 1, 1)
  texture_filter = 5
  ```
  - **Status on disk**: `albedo_color = Color(1, 1, 1, 1)` (Full brightness), `uv1_scale = Vector3(1, 1, 1)`, `texture_filter = 5` (Linear Mipmap Anisotropic).

- **Dirt Tracks Material**: `/home/am/targetkill/resources/materials/mat_dirt_pbr.tres`
  ```ini
  [gd_resource type="StandardMaterial3D" load_steps=4 format=3 uid="uid://mat_dirt_pbr_alias"]
  [ext_resource type="Texture2D" uid="uid://du3ksriqd0av0" path="res://textures/pbr/ground/tex_dirt_diff.jpg" id="1_diff"]
  [ext_resource type="Texture2D" uid="uid://boicqwcln02o5" path="res://textures/pbr/ground/tex_dirt_nor.jpg" id="2_nor"]
  [ext_resource type="Texture2D" uid="uid://bxwhap3pyxybx" path="res://textures/pbr/ground/tex_dirt_arm.jpg" id="3_arm"]

  [resource]
  resource_name = "mat_dirt_pbr"
  albedo_color = Color(1, 1, 1, 1)
  albedo_texture = ExtResource("1_diff")
  roughness = 0.90
  roughness_texture = ExtResource("3_arm")
  roughness_texture_channel = 1
  metallic_specular = 0.08
  normal_enabled = true
  normal_scale = 0.85
  normal_texture = ExtResource("2_nor")
  ao_enabled = true
  ao_texture = ExtResource("3_arm")
  ao_texture_channel = 0
  uv1_scale = Vector3(1, 1, 1)
  texture_filter = 5
  ```
  - **Status on disk**: `albedo_color = Color(1, 1, 1, 1)`, `uv1_scale = Vector3(1, 1, 1)`.

- **Legacy Dirt Material**: `/home/am/targetkill/resources/materials/mat_dirt.tres`
  ```ini
  albedo_color = Color(0.55, 0.42, 0.30, 1)
  uv1_scale = Vector3(4, 180, 1)
  ```
  This legacy resource is used for pine tree trunks (`Tree_Pine` ArrayMesh line 429 in `CityCarZombieArena.tscn`), but was previously confusing dirt track lookups.

#### B. The Root Cause of the Grey-Blue Wash & Mipmap Smear
Despite `mat_real_grass_pbr.tres` having `Color(1, 1, 1, 1)` on disk, the game currently displays a dull, dark grey-blue wash due to two critical runtime and scene overrides:

1. **Runtime Override in `scenes/environments/CityCarZombieArena.gd` (Lines 111-120)**:
   ```gdscript
   var valley_mesh = get_node_or_null("AdvancedTerrain/ValleyFloor") as MeshInstance3D
   if valley_mesh:
       var v_mat = valley_mesh.get_surface_override_material(0)
       if v_mat is StandardMaterial3D:
           v_mat.albedo_color = Color(0.38, 0.56, 0.22, 1.0)
           v_mat.roughness = 0.72
           v_mat.metallic_specular = 0.25
           v_mat.normal_scale = 0.95
           v_mat.uv1_scale = Vector3(5.0, 5.0, 1.0)
   ```
   - **Line 115**: Explicitly darkens the grass albedo by over 60% with `Color(0.38, 0.56, 0.22, 1.0)`.
   - **Line 119**: Multiplies UV coordinates by 5.0 (`Vector3(5.0, 5.0, 1.0)`). Combined with the mesh's vertex UV of `0.15` (1 tile / 6.67m), this forces 1 tile per 1.33m, generating dense high-frequency repetition that triggers lower mipmap levels and produces a flat grey-blue smear when viewed from vehicle distance.

2. **Embedded SubResource in `scenes/environments/CityCarZombieArena.tscn` (Lines 217-231 & 1221-1223)**:
   ```ini
   [sub_resource type="StandardMaterial3D" id="StandardMaterial3D_mkia1"]
   resource_name = "mat_real_grass_pbr"
   albedo_color = Color(0.38, 0.56, 0.22, 1)
   albedo_texture = ExtResource("14_rs2kr")
   metallic_specular = 0.25
   roughness = 0.72
   roughness_texture = ExtResource("15_v3gem")
   roughness_texture_channel = 1
   normal_enabled = true
   normal_scale = 0.95
   normal_texture = ExtResource("16_i25co")
   ao_enabled = true
   ao_texture = ExtResource("15_v3gem")
   uv1_scale = Vector3(5, 5, 1)
   texture_filter = 5
   ...
   [node name="ValleyFloor" type="MeshInstance3D" parent="AdvancedTerrain" unique_id=529098646]
   mesh = SubResource("ArrayMesh_bnpk3")
   surface_material_override/0 = SubResource("StandardMaterial3D_mkia1")
   ```
   `ValleyFloor` does not link directly to `res://resources/materials/mat_real_grass_pbr.tres`; it uses an embedded copy with the degraded `Color(0.38, 0.56, 0.22, 1)` and `uv1_scale = Vector3(5, 5, 1)`.

3. **Terrain Generation in `tools/build_advanced_terrain.gd` (Lines 229-231, 252-260)**:
   ```gdscript
   # World-space UV mapping: 1 crisp texture tile every 6.67 meters
   st.set_uv(Vector2(wx * 0.15, wz * 0.15))
   st.add_vertex(pos)
   ...
   var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
   if grass_mat:
       var gm = grass_mat.duplicate()
       gm.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
       gm.roughness = 0.82
       gm.metallic_specular = 0.20
       gm.normal_scale = 1.10
       gm.uv1_scale = Vector3(1.0, 1.0, 1.0)
       mi.set_surface_override_material(0, gm)
   ```
   `build_advanced_terrain.gd` correctly applies `Color(1, 1, 1, 1)` and `Vector3(1, 1, 1)`. However, running the game triggers `CityCarZombieArena.gd:115` which overwrites it.

---

### 1.2 `JungleLake` in `CityCarZombieArena.tscn` and `tools/build_advanced_terrain.gd`

#### A. Current Position and Dimensions
- **In `scenes/environments/CityCarZombieArena.tscn` (Lines 1293-1301)**:
  ```ini
  [node name="JungleLake_Shore" type="MeshInstance3D" parent="AdvancedTerrain" unique_id=1751092435]
  transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.35, -250)
  mesh = SubResource("PlaneMesh_xiww5") # Size: Vector2(118.0, 180.0)
  surface_material_override/0 = ExtResource("34_mkia1")

  [node name="JungleLake" type="MeshInstance3D" parent="AdvancedTerrain" unique_id=172258650]
  transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.45, -250)
  mesh = SubResource("PlaneMesh_hhol4") # Size: Vector2(100.0, 160.0)
  surface_material_override/0 = SubResource("ShaderMaterial_4q0xv")
  ```
- **In `tools/build_advanced_terrain.gd` (Lines 1400-1420)**:
  ```gdscript
  shore_mi.name = "JungleLake_Shore"
  shore_plane.size = Vector2(118.0, 180.0)
  shore_mi.position = Vector3(0.0, 0.35, -250.0)
  ...
  lake_mi.name = "JungleLake"
  plane.size = Vector2(100.0, 160.0)
  lake_mi.position = Vector3(0.0, 0.45, -250.0)
  ```

#### B. Defect Analysis
- The central highway asphalt spans `x = -11.0` to `x = +11.0`, with shoulders up to `x = ±28.0`.
- `JungleLake` is currently centered at `x = 0.0, z = -250.0` with a width of `100.0m` (`x` from `-50.0` to `+50.0`) and length of `160.0m` (`z` from `-330.0` to `-170.0`).
- **Consequence**: The lake plane sits directly on top of the central highway asphalt at elevation `y = 0.45` (above the asphalt at `y = 0.0`). Driving north on the highway forces vehicles directly through open water, obscuring the road ahead and completely blocking mountain pass visibility.

#### C. East Valley Relocation Target (`Vector3(55, 0.45, -190)`)
- **Topography Analysis**:
  - Central highway + shoulders end at `x = ±28.0m`.
  - East Valley floor extends from `x = 28.0m` to `x = 75.0m` (a 47m wide natural depression).
  - East Mountain foothills begin at `x = 75.0m`.
  - Centering `JungleLake` at `Vector3(55.0, 0.45, -190.0)` places it in the East Valley basin.
  - To prevent the lake from spilling west onto the highway shoulder (`x < 28.0m`), the lake half-width must be `<= 26.0m` (maximum width `<= 52.0m`).
  - Recommended dimensions:
    - `JungleLake`: `size = Vector2(48.0, 96.0)`, `position = Vector3(55.0, 0.45, -190.0)`. Bounds: `x` from `31.0m` to `79.0m` (3m clear of shoulder), `z` from `-238.0m` to `-142.0m`.
    - `JungleLake_Shore`: `size = Vector2(56.0, 108.0)`, `position = Vector3(55.0, 0.35, -190.0)`.
    - `JungleInsects` (CPUParticles3D): Currently at `Vector3(0.0, 3.5, -200.0)`. Relocate to `Vector3(55.0, 3.5, -190.0)` with emission extents `Vector3(30.0, 5.0, 50.0)`.

---

### 1.3 Mountain Cliff Faces (`mat_real_mountain_cliff.tres`)

#### A. Disk Material Resource
- **File**: `/home/am/targetkill/resources/materials/mat_real_mountain_cliff.tres`
  ```ini
  [gd_resource type="StandardMaterial3D" load_steps=4 format=3 uid="uid://mat_real_mountain_cliff"]
  [ext_resource type="Texture2D" uid="uid://bfyqok18v8ykm" path="res://textures/pbr/mountain/cliff_diff_1k.jpg" id="1_diff"]
  [ext_resource type="Texture2D" uid="uid://dfgiwcrwy2fsn" path="res://textures/pbr/mountain/cliff_nor_1k.jpg" id="2_nor"]
  [ext_resource type="Texture2D" uid="uid://b4katy3u3350t" path="res://textures/pbr/mountain/cliff_arm_1k.jpg" id="3_arm"]

  [resource]
  resource_name = "mat_real_mountain_cliff"
  albedo_color = Color(0.92, 0.90, 0.88, 1)
  albedo_texture = ExtResource("1_diff")
  roughness = 0.82
  roughness_texture = ExtResource("3_arm")
  roughness_texture_channel = 1
  normal_enabled = true
  normal_scale = 1.35
  normal_texture = ExtResource("2_nor")
  ao_enabled = true
  ao_texture = ExtResource("3_arm")
  ao_texture_channel = 0
  uv1_scale = Vector3(0.05, 0.05, 0.05)
  uv1_triplanar = true
  uv1_triplanar_sharpness = 3.5
  cull_mode = 2
  texture_filter = 5
  ```
  - `uv1_triplanar = true`, `uv1_triplanar_sharpness = 3.5`: Eliminates texture stretching along vertical cliff faces.
  - `cull_mode = 2`: Double-sided culling avoids silhouette wireframing or backface gaps.
  - `texture_filter = 5`: High-resolution anisotropic sampling.

#### B. Defect Observed in Scene SubResources
- In `scenes/environments/CityCarZombieArena.tscn` (Lines 298-385):
  ```ini
  [sub_resource type="StandardMaterial3D" id="StandardMaterial3D_fvscg"]
  resource_name = "mat_real_mountain_cliff"
  cull_mode = 2
  albedo_color = Color(0.48, 0.46, 0.44, 1)
  ...
  [sub_resource type="StandardMaterial3D" id="StandardMaterial3D_i25co"]
  resource_name = "mat_real_mountain_cliff"
  cull_mode = 2
  albedo_color = Color(0.48, 0.46, 0.44, 1)
  ...
  [sub_resource type="StandardMaterial3D" id="StandardMaterial3D_8l3lf"]
  resource_name = "mat_real_mountain_cliff"
  cull_mode = 2
  albedo_color = Color(0.48, 0.46, 0.44, 1)
  ...
  [sub_resource type="StandardMaterial3D" id="StandardMaterial3D_wc8wh"]
  resource_name = "mat_real_mountain_cliff"
  cull_mode = 2
  albedo_color = Color(0.48, 0.46, 0.44, 1)
  ```
  All four mountain range meshes (`MountainWest`, `MountainEast`, `MountainNorthWall`, `MountainSouthWall`) use embedded subresources with `albedo_color = Color(0.48, 0.46, 0.44, 1)`.
- This halves the brightness of the cliff textures, giving them a muddy, shadowed, low-contrast appearance instead of vibrant daylight rock faces.

---

### 1.4 Fog & Tonemapping Investigation

#### A. Discrepancies in `scenes/environments/WeatherController.gd`
- **Lines 69-72 (`WeatherPreset.SUNNY_DAY`)**:
  ```gdscript
  "fog_enabled": true,
  "fog_density": 0.00018,
  "fog_light_color": Color(0.78, 0.85, 0.92, 1.0),
  "fog_aerial_perspective": 0.08,
  ```
  - `fog_density` is `0.00018` instead of required `0.00010`.
  - `fog_aerial_perspective` is `0.08` instead of required `0.0`.
- **Line 433 (`_setup_environment()`)**:
  ```gdscript
  _environment.tonemap_exposure = 1.14
  ```
  - `tonemap_exposure` is `1.14` instead of required `1.15`.

#### B. Discrepancies in `scenes/environments/CityCarZombieArena.gd`
- **Lines 36-43 (`_ready()`)**:
  ```gdscript
  var env = world_env.environment
  env.tonemap_mode = Environment.TONE_MAPPER_ACES
  env.tonemap_exposure = 1.05
  env.fog_enabled = true
  env.fog_density = 0.00018
  env.fog_light_color = Color(0.78, 0.85, 0.92)
  env.fog_aerial_perspective = 0.08
  ```
  - Overwrites environment on start with `tonemap_exposure = 1.05`, `fog_density = 0.00018`, and `fog_aerial_perspective = 0.08`.

#### C. Discrepancies in `scenes/environments/CityCarZombieArena.tscn`
- **Lines 51-62**:
  ```ini
  tonemap_mode = 3
  tonemap_exposure = 1.05
  fog_enabled = true
  fog_light_color = Color(0.78, 0.85, 0.92, 1)
  fog_density = 0.00018
  fog_aerial_perspective = 0.08
  ```

#### D. Discrepancies in `tools/build_advanced_terrain.gd`
- **Lines 57-67**:
  ```gdscript
  var env = world_env.environment
  env.tonemap_mode = Environment.TONE_MAPPER_ACES
  env.tonemap_exposure = 1.05   # <-- redundant/conflicting assignment
  env.fog_enabled = true
  env.fog_density = 0.00010
  env.fog_light_color = Color(0.78, 0.85, 0.92, 1.0)
  env.fog_aerial_perspective = 0.0
  env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
  env.ambient_light_color = Color(0.85, 0.90, 0.96, 1.0)
  env.ambient_light_energy = 0.95
  env.tonemap_exposure = 1.15   # <-- overrides line 59
  ```

---

## 2. Logic Chain

1. **Premise 1 (Ground Grass & Dirt Texture Washout)**:
   - Observation 1.1 shows `mat_real_grass_pbr.tres` on disk already has `albedo_color = Color(1, 1, 1, 1)` and `uv1_scale = (1, 1, 1)`.
   - However, `CityCarZombieArena.gd` line 115 forcibly multiplies `v_mat.albedo_color` by `Color(0.38, 0.56, 0.22, 1.0)` and sets `uv1_scale = Vector3(5, 5, 1)` at runtime.
   - Additionally, `CityCarZombieArena.tscn` lines 217-231 embed this exact dark tint in `StandardMaterial3D_mkia1`.
   - Therefore, the grass looks dark grey-blue because Godot multiplies the diffuse texture by `Color(0.38, 0.56, 0.22)`, and the UV repetition of `5.0 * 0.15 = 0.75` causes texture tiling every 1.33m, triggering distant mipmap blending.
   - Synchronizing `CityCarZombieArena.gd` and `CityCarZombieArena.tscn` to `Color(1, 1, 1, 1)` and `uv1_scale = Vector3(1, 1, 1)` will restore 100% true-color grass blade detail.

2. **Premise 2 (JungleLake Highway Obstruction)**:
   - Observation 1.2 shows that `JungleLake` and its shore are positioned at `(0, 0.45, -250)` with width 100m.
   - Since the highway runs along `x = 0` between `z = -440` and `z = 0`, the lake directly bisects the roadway at `z = -250`.
   - Relocating `JungleLake` to `Vector3(55, 0.45, -190)` with width `48.0m` places the lake between `x = 31.0m` and `x = 79.0m`.
   - Because the highway and shoulder end at `x = 28.0m`, this guarantees a 3.0m buffer zone, leaving the central highway completely clear and providing unobstructed views of the road and mountain passes.

3. **Premise 3 (Mountain Cliff Shading)**:
   - Observation 1.3 shows `mat_real_mountain_cliff.tres` has `albedo_color = Color(0.92, 0.90, 0.88, 1.0)` with crisp triplanar rock details.
   - However, the scene subresources (`StandardMaterial3D_fvscg`, `StandardMaterial3D_i25co`, `StandardMaterial3D_8l3lf`, `StandardMaterial3D_wc8wh`) have `albedo_color = Color(0.48, 0.46, 0.44, 1.0)`.
   - Updating these subresources to `Color(0.92, 0.90, 0.88, 1.0)` (or full `Color(1, 1, 1, 1)`) will ensure mountain ridges render as bright, solid rock faces without muddy dark shading.

4. **Premise 4 (Atmospheric Clarity & Fog)**:
   - Observation 1.4 confirms that `fog_aerial_perspective = 0.08` introduces a blue-gray haze over distant terrain, while `fog_density = 0.00018` creates a thick veil that washes out mountain ridges.
   - Setting `fog_aerial_perspective = 0.0` eliminates the horizon tinting layer.
   - Setting `fog_density = 0.00010` provides clean atmospheric depth without obscuring geometry.
   - Setting `tonemap_exposure = 1.15` in `WeatherController.gd`, `CityCarZombieArena.gd`, `CityCarZombieArena.tscn`, and `build_advanced_terrain.gd` produces uniform, vibrant daylight rendering across both static scene loads and dynamic weather cycles.

---

## 3. Caveats

1. **MultiMesh Foliage Exclusion at East Valley Lake**:
   - In `tools/build_advanced_terrain.gd` (lines 800-980), MultiMesh instances for pine trees, rocks, and bushes are procedurally distributed across the terrain.
   - While the algorithm checks `absf(j_wx) <= 22.0` to avoid the road, it does not currently check the lake boundary.
   - When moving the lake to `Vector3(55, 0.45, -190)` with bounds `[31m <= x <= 79m, -238m <= z <= -142m]`, a simple distance or AABB exclusion check should be added to prevent trees and rocks from generating submerged under the lake water plane.

2. **Milestone 1 Test Assertions (`verify_m1.gd` & `forensic_m1_audit.gd`)**:
   - `tools/verify_m1.gd` (lines 120, 136) and `tools/forensic_m1_audit.gd` (lines 79, 85) contain legacy assertions expecting `mat_grass.albedo_color == Color(0.32, 0.50, 0.20, 1.0)` and `mat_cliff.albedo_color == Color(0.48, 0.46, 0.44, 1.0)`.
   - If old M1 audit scripts are executed, they will flag the new bright PBR materials. The new test harness (`scenes/test/TestRunner.gd` and R2 verification tests) must assert the R2 specification: `albedo_color = Color(1, 1, 1, 1)` and `Color(0.92, 0.90, 0.88, 1.0)`.

3. **Scene Generation vs. Scene File Editing**:
   - `tools/build_advanced_terrain.gd` can rebuild `CityCarZombieArena.tscn` from scratch.
   - If `build_advanced_terrain.gd` is modified and executed, it automatically generates and saves the updated scene.
   - However, since `CityCarZombieArena.gd` executes at runtime when the scene loads, BOTH `CityCarZombieArena.gd` AND `build_advanced_terrain.gd` (or `CityCarZombieArena.tscn`) must be updated to keep values in sync.

---

## 4. Conclusion

Requirement 2 (Crystal-Clear Ground & Alpine Visuals) requires localized fixes across four files to achieve razor-sharp visuals and unobstructed views:

| Target Component | File to Modify | Current State | Proposed Fix |
|---|---|---|---|
| **Grass & UV Tiling** | `scenes/environments/CityCarZombieArena.gd` (lines 115, 119) | `v_mat.albedo_color = Color(0.38, 0.56, 0.22, 1.0)`<br>`v_mat.uv1_scale = Vector3(5, 5, 1)` | `v_mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)`<br>`v_mat.uv1_scale = Vector3(1.0, 1.0, 1.0)` |
| **Grass SubResource** | `scenes/environments/CityCarZombieArena.tscn` (lines 219, 230) | `albedo_color = Color(0.38, 0.56, 0.22, 1)`<br>`uv1_scale = Vector3(5, 5, 1)` | `albedo_color = Color(1, 1, 1, 1)`<br>`uv1_scale = Vector3(1, 1, 1)` |
| **JungleLake Relocation** | `tools/build_advanced_terrain.gd` (lines 1404, 1406, 1416, 1420) | Position: `Vector3(0, 0.45, -250)`<br>Size: `Vector2(100, 160)` | Position: `Vector3(55.0, 0.45, -190.0)`<br>Size: `Vector2(48.0, 96.0)` |
| **Lake Shore Relocation** | `tools/build_advanced_terrain.gd` (line 1406) | Position: `Vector3(0, 0.35, -250)`<br>Size: `Vector2(118, 180)` | Position: `Vector3(55.0, 0.35, -190.0)`<br>Size: `Vector2(56.0, 108.0)` |
| **Lake Scene Nodes** | `scenes/environments/CityCarZombieArena.tscn` (lines 1294, 1299) | `transform = ... (0, 0.35, -250)`<br>`transform = ... (0, 0.45, -250)` | `transform = ... (55, 0.35, -190)`<br>`transform = ... (55, 0.45, -190)` |
| **Mountain Cliff Faces** | `scenes/environments/CityCarZombieArena.tscn` (lines 301, 336, 371) | `albedo_color = Color(0.48, 0.46, 0.44, 1)` | `albedo_color = Color(0.92, 0.90, 0.88, 1)` |
| **Fog & Tonemapping** | `scenes/environments/WeatherController.gd` (lines 70, 72, 433) | `fog_density = 0.00018`<br>`fog_aerial_perspective = 0.08`<br>`tonemap_exposure = 1.14` | `fog_density = 0.00010`<br>`fog_aerial_perspective = 0.0`<br>`tonemap_exposure = 1.15` |
| **Arena Environment** | `scenes/environments/CityCarZombieArena.gd` (lines 39, 41, 43) | `tonemap_exposure = 1.05`<br>`fog_density = 0.00018`<br>`fog_aerial_perspective = 0.08` | `tonemap_exposure = 1.15`<br>`fog_density = 0.00010`<br>`fog_aerial_perspective = 0.0` |
| **Scene Environment** | `scenes/environments/CityCarZombieArena.tscn` (lines 52, 60, 61) | `tonemap_exposure = 1.05`<br>`fog_density = 0.00018`<br>`fog_aerial_perspective = 0.08` | `tonemap_exposure = 1.15`<br>`fog_density = 0.00010`<br>`fog_aerial_perspective = 0.0` |
| **Builder Environment**| `tools/build_advanced_terrain.gd` (lines 59, 61, 63, 67) | `tonemap_exposure = 1.05` (redundant) | Remove line 59, keep line 67 `env.tonemap_exposure = 1.15` |

---

## 5. Verification Method

### 5.1 Independent Headless Test Commands
1. **Verify Material and Environment Settings via Script**:
   Create and execute a standalone verification script:
   ```bash
   godot --headless -s tools/verify_r2_visuals.gd
   ```
   *Expected result*:
   - `mat_real_grass_pbr.tres`: `albedo_color == Color(1, 1, 1, 1)`, `uv1_scale == Vector3(1, 1, 1)`.
   - `mat_dirt_pbr.tres`: `albedo_color == Color(1, 1, 1, 1)`, `uv1_scale == Vector3(1, 1, 1)`.
   - `mat_real_mountain_cliff.tres`: `albedo_color == Color(0.92, 0.90, 0.88, 1)`, `uv1_triplanar == true`, `uv1_triplanar_sharpness == 3.5`.
   - `JungleLake`: `global_position.x == 55.0`, `global_position.z == -190.0`, no overlap with highway at `abs(x) < 28.0`.
   - `WorldEnvironment`: `fog_density == 0.00010`, `fog_aerial_perspective == 0.0`, `tonemap_exposure == 1.15`.
   - Exits with return code 0.

2. **Re-build Advanced Terrain (If Executed)**:
   ```bash
   godot --headless -s tools/build_advanced_terrain.gd
   ```
   *Expected result*: Scene compiles, generates MultiMesh instances, relocates lake to East Valley, and saves to `CityCarZombieArena.tscn` without error.

3. **Arena Scene Loading Validation**:
   ```bash
   godot --headless -s scenes/test/TestRunner.gd
   ```
   *Expected result*: Loads `scenes/environments/CityCarZombieArena.tscn` with exit code 0.

### 5.2 Files to Inspect
- `/home/am/targetkill/resources/materials/mat_real_grass_pbr.tres`
- `/home/am/targetkill/resources/materials/mat_dirt_pbr.tres`
- `/home/am/targetkill/resources/materials/mat_real_mountain_cliff.tres`
- `/home/am/targetkill/scenes/environments/WeatherController.gd` (Lines 58-91, 431-444)
- `/home/am/targetkill/scenes/environments/CityCarZombieArena.gd` (Lines 36-52, 111-120)
- `/home/am/targetkill/scenes/environments/CityCarZombieArena.tscn` (Lines 51-65, 217-232, 298-385, 1221-1242, 1293-1302)
- `/home/am/targetkill/tools/build_advanced_terrain.gd` (Lines 54-76, 225-263, 1395-1475)
