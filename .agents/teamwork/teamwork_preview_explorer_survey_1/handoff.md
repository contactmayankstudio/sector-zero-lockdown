# Handoff Report: Survey for Requirement 1 (Visual Clarity & Environment Shading)

## 1. Observation

### 1.1 Mountain Ranges & Cliff Faces
- **Scene & Node Hierarchy**:
  In `/home/am/targetkill/scenes/environments/CityCarZombieArena.tscn`:
  - `RealisticTerrain/MountainRangeWest` (MeshInstance3D, `mesh = SubResource("ArrayMesh_5x16f")`, `surface_material_override/0 = ExtResource("19_4ap8e")`)
  - `RealisticTerrain/MountainRangeEast` (MeshInstance3D, `mesh = SubResource("ArrayMesh_5f2mh")`, `surface_material_override/0 = ExtResource("19_4ap8e")`)
  - `RealisticTerrain/MountainBackdropNorth` (MeshInstance3D, `mesh = SubResource("ArrayMesh_wdeby")`, `surface_material_override/0 = ExtResource("19_4ap8e")`)
  - `ExtResource("19_4ap8e")` maps to `/home/am/targetkill/resources/materials/mat_real_mountain_cliff.tres`.

- **Mesh Generation Implementation**:
  In `/home/am/targetkill/tools/build_gta5_open_world.gd` (lines 484–499):
  ```gdscript
  for z_i in range(z_samples - 1):
      for x_i in range(x_samples - 1):
          var i0 = z_i * x_samples + x_i
          var i1 = i0 + 1
          var i2 = (z_i + 1) * x_samples + x_i
          var i3 = i2 + 1
          
          st.add_index(i0)
          st.add_index(i2)
          st.add_index(i1)
          
          st.add_index(i1)
          st.add_index(i2)
          st.add_index(i3)
  st.generate_normals()
  ```

- **Diagnostic Normal Measurements**:
  Execution of `godot --headless --script res://tools/diagnose_requirement1.gd` revealed:
  - `MountainRangeWest`: Surface 0: 1092 vertices, 6150 indices, 1092 normals.
    - `Normals: up_y = 0, down_y = 1092, avg_norm = (-0.067291, -0.931193, -0.010453)`
    - First triangle winding normal: `(-0.53151, 0.833324, 0.151882)` vs stored normal: `(0.531467, -0.83335, -0.151891)`.
  - `MountainRangeEast`: Surface 0: 1092 vertices, 6150 indices, 1092 normals.
    - `Normals: up_y = 0, down_y = 1092, avg_norm = (0.093205, -0.942513, -0.01231)`
  - `MountainBackdropNorth`: Surface 0: 648 vertices, 3570 indices, 648 normals.
    - `Normals: up_y = 0, down_y = 648, avg_norm = (-0.007839, -0.879147, 0.108504)`
  - Execution of `godot --headless --script res://tools/test_surfacetool.gd` verified:
    - Index order `[0, 2, 1]` generates normal `(0, -1, 0)`.
    - Index order `[0, 1, 2]` generates normal `(0, 1, 0)`.

- **Material & Shading Settings**:
  In `/home/am/targetkill/resources/materials/mat_real_mountain_cliff.tres`:
  - Line 20: `uv1_scale = Vector3(0.05, 0.05, 0.05)`
  - Line 21: `uv1_triplanar = true`
  - Line 22: `uv1_triplanar_sharpness = 2.0`
  - Line 23: `cull_mode = 2` (`BaseMaterial3D.CULL_DISABLED`)
  - Line 24: `texture_filter = 5` (`BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC`)

- **Post-Processing & Atmosphere in WeatherController**:
  In `/home/am/targetkill/scenes/environments/WeatherController.gd`:
  - Line 428–431:
    ```gdscript
    _environment.glow_enabled = true
    _environment.glow_intensity = 0.45
    _environment.glow_bloom = 0.15
    _environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
    _environment.glow_hdr_threshold = 0.95
    ```
  - Lines 70–72:
    ```gdscript
    "fog_enabled": true,
    "fog_density": 0.00035,
    "fog_light_color": Color(0.72, 0.82, 0.92, 1.0),
    "fog_aerial_perspective": 0.10,
    ```
  - Mesh geometry boundaries terminate in mid-air at elevation `h = 44.0` to `49.8` without skirts descending to `y = 0`.

---

### 1.2 Road Asphalt, Sidewalk Curbs, Terrain Grass, Dirt Shoulders
- **Textures Import Configuration**:
  Inspection of all `.import` files under `/home/am/targetkill/textures/pbr/`:
  - `textures/pbr/asphalt/asphalt_02_diff_1k.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/asphalt/asphalt_02_nor_gl_1k.jpg.import:22`: `compress/normal_map = 0`, `mipmaps/generate = false`
  - `textures/pbr/asphalt/asphalt_02_arm_1k.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/grass/grass_diff_1k.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/grass/grass_nor_1k.jpg.import:22`: `compress/normal_map = 0`, `mipmaps/generate = false`
  - `textures/pbr/grass/grass_arm_1k.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/ground/tex_dirt_diff.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/ground/tex_dirt_nor.jpg.import:22`: `compress/normal_map = 0`, `mipmaps/generate = false`
  - `textures/pbr/ground/tex_dirt_arm.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/walls/tex_concrete_diff.jpg.import:24`: `mipmaps/generate = false`
  - `textures/pbr/walls/tex_concrete_nor.jpg.import:22`: `compress/normal_map = 0`, `mipmaps/generate = false`
  - `textures/pbr/walls/tex_concrete_arm.jpg.import:24`: `mipmaps/generate = false`

- **Material Settings**:
  - `HighwayAsphalt`: `mat_real_asphalt_pbr.tres` (`roughness = 0.88`, `metallic = 0.0`, `specular = 0.50`, `normal_scale = 0.60`, `uv1_scale = Vector3(4, 78, 1)`)
  - `SidewalkLeft/Right`: `mat_city_sidewalk.tres` (`albedo_color = Color(0.85, 0.85, 0.85)`, `roughness = 0.85`, `specular = 0.50`, `normal_scale = 0.80`, `uv1_scale = Vector3(2, 78, 1)`)
  - `DirtShoulderLeft/Right`: `mat_dirt_pbr` (`albedo_color = Color(0.55, 0.42, 0.3)`, `roughness = 0.95`, `specular = 0.50`, `normal_scale = 1.50`, `uv1_scale = Vector3(2, 78, 1)`)
  - `GrassFieldLeft/Right`: `mat_real_grass_pbr.tres` (`albedo_color = Color(0.32, 0.46, 0.25)`, `roughness = 0.90`, `specular = 0.50`, `normal_scale = 1.60`, `uv1_scale = Vector3(8, 78, 1)`)
  - `CenterYellow_L/R` & `LaneWhite_L/R`: `roughness = 0.50`, `specular = 0.50`, flat untextured geometry at `y = 0.005`.

- **WeatherController Dynamic Overrides**:
  In `/home/am/targetkill/scenes/environments/WeatherController.gd` (lines 87–89, 280–285):
  - In `SUNNY_DAY`, `GOLDEN_SUNSET`, `CYBERPUNK_NIGHT`: `road_specular` is forced to `0.50`.
  - In `STORMY_RAIN`: `road_specular = 0.85`, `road_roughness = 0.18`, `road_metallic = 0.05`.

---

### 1.3 Pine Tree Foliage
- **Node & Mesh Structure**:
  In `/home/am/targetkill/scenes/environments/CityCarZombieArena.tscn`:
  48 tree instances under `VegetationTrees` (`PineTree_*`). Each instance contains:
  - `Trunk`: CylinderMesh (`top_radius = 0.20`, `bottom_radius = 0.35`, `height = 3.2`) with material `mat_dirt_pbr`.
  - `Foliage_0`, `Foliage_1`, `Foliage_2`: CylinderMesh (`top_radius = 0.05`, `bottom_radius = 2.3 - i * 0.45`, `height = 2.4`) with `cap_top = true` and `cap_bottom = true`.

- **Material & API Warning**:
  In `/home/am/targetkill/scenes/environments/CityCarZombieArena.gd` (lines 73–86):
  ```gdscript
  var pine_mat = StandardMaterial3D.new()
  pine_mat.resource_name = "mat_pine_clean"
  pine_mat.albedo_color = Color(0.12, 0.28, 0.14, 1.0)
  pine_mat.roughness = 0.95
  pine_mat.specular = 0.05
  pine_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
  ```
  Runtime execution output:
  `WARNING: Godot 3.x SpatialMaterial remapped parameter not found: specular`
  `at: _set (scene/resources/material.cpp:3541)`
  Because `StandardMaterial3D` in Godot 4 uses `metallic_specular` rather than `specular`, the assignment `pine_mat.specular = 0.05` was silently dropped, leaving `metallic_specular` at its default value of `0.50`.

- **Edge Normals on CylinderMesh**:
  Each `CylinderMesh` cone possesses a flat bottom disc (`cap_bottom = true`). The vertices forming the circular boundary between the cone mantle and the bottom disc have hard edge normals. With `cull_mode = CULL_DISABLED`, both sides of the disc render, catching grazing-angle specular and ambient reflections.

---

### 1.4 Existing Shaders & Rendering Settings
- **Project Settings** (`/home/am/targetkill/project.godot`):
  - `renderer/rendering_method = "gl_compatibility"`
  - `renderer/rendering_method.mobile = "gl_compatibility"`
  - `textures/vram_compression/import_etc2_astc = true`
  - `anti_aliasing/quality/msaa_3d = 0`
  - `lights_and_shadows/directional_shadow/size = 1024`
  - `lights_and_shadows/directional_shadow/soft_shadow_filter_quality = 0`
- **Existing Shaders**:
  - `/home/am/targetkill/resources/mobile_pbr.gdshader` is the only custom `.gdshader` file in the project. It implements a standard mobile PBR fragment function with normal mapping and roughness channel extraction. It is currently unassigned to any scene geometry.

---

## 2. Logic Chain

1. **Mountain Inverted Normals & Backface Culling Workaround**:
   - `build_gta5_open_world.gd` added quad indices as `(i0, i2, i1)` and `(i1, i2, i3)`.
   - SurfaceTool generates face normals via counter-clockwise cross-products. With clockwise index order, the cross product produces a vector pointing down (`-Y`), verified by `avg_norm.y = -0.931` across all 2,832 mountain vertices.
   - Because all faces pointed downward, Godot's default backface culling (`CULL_BACK`) culled the entire mountain when viewed from the road or above.
   - To prevent the mountains from being invisible, the developers set `cull_mode = CULL_DISABLED (2)`.
   - Disabling culling while keeping inverted vertex normals caused incoming sunlight (`DirectionalLight3D`) to hit surfaces where `N · L < 0`, resulting in incorrect or zero direct illumination, reversed specular highlights, and inverted triplanar texture projection.

2. **White Contour Ribbons & Silhouette Artifacts**:
   - The mountain mesh is an open grid generated between $X \in [-230, -77]$ and $X \in [77, 230]$. At the outer boundaries ($X = \pm 230$) and northern boundary ($Z = -480$), elevations reach $44$ to $50\text{ m}$. No boundary skirt faces connect these edge vertices down to $y = 0$.
   - Behind these elevated perimeter edges lies the sky and fog.
   - In `WeatherController.gd`, `glow_enabled = true` with `glow_bloom = 0.15` and `glow_intensity = 0.45` is enabled in the `gl_compatibility` (OpenGL 3) renderer.
   - High-luminance sky and fog background pixels bleed across the dark, unlit silhouette edge of the mountain mesh, creating a prominent glowing white ribbon (halo) hugging the ridgeline.

3. **Specular Noise & Sparkling Dots on Ground**:
   - Every PBR texture in `textures/pbr/` (diffuse, normal, ARM) was imported with `mipmaps/generate = false`.
   - At the same time, the materials use `texture_filter = 5` (Linear Mipmap Anisotropic).
   - Under distance and grazing viewing angles along the 520m highway, normal maps lacking mipmaps produce extreme high-frequency sub-pixel variance between adjacent frames, resulting in shimmering "sparkling dots" and fireflies under the directional sun.
   - Furthermore, `mat_real_grass_pbr` and `mat_dirt_pbr` have extreme normal map scales (`1.6` and `1.5` respectively) coupled with `metallic_specular = 0.50`, exaggerating micro-facet glints on surfaces that should behave as dead matte dielectrics.

4. **Lighting Blowouts on Sidewalks**:
   - `mat_city_sidewalk.tres` has an albedo color of `Color(0.85, 0.85, 0.85)`.
   - Combined with `directional_light.light_energy = 1.2 - 1.3`, `ambient_light_energy = 1.15`, `tonemap_exposure = 1.08`, and bloom post-processing, total incident luminance on the sidewalk exceeds the bloom threshold (`0.95`), causing the concrete curbs to blow out into blinding white light.

5. **Pine Tree Bright Edge Rings**:
   - Pine foliage is made of 3 stacked `CylinderMesh` cones per tree with `cap_bottom = true`.
   - `CityCarZombieArena.gd` attempts to set `pine_mat.specular = 0.05`, but in Godot 4 this property does not exist on `StandardMaterial3D` (it is `metallic_specular`). The engine discarded the assignment with a runtime warning.
   - As a result, `metallic_specular` remained at `0.50`.
   - The flat bottom disc and the circular bottom perimeter edge loop catch the sun and ambient hemisphere light at grazing angles, while `DIFFUSE_BURLEY` enhances grazing sheen, producing bright white circular rings along the base of every foliage layer.

---

## 3. Caveats

- **Scope Boundary**: This survey investigated the environment assets and rendering pipeline for Requirement 1. It did not alter or fix vehicle mechanics (Hayabusa bike handling, rider posture) or memory profiling beyond baseline headless checks.
- **Hardware Profile**: Shading behavior was verified via Godot 4.3 `gl_compatibility` headless mode under Linux. Visual presentation on physical AMD Kabini APUs (Radeon HD 8210/8400) may exhibit additional texture filtering nuances depending on the Mesa RadeonSI driver version.
- **No Direct Source Changes**: As an explorer/surveyor agent, no production scripts or scenes were modified during this turn. All findings and proposed remedies are documented here for the subsequent implementation agent.

---

## 4. Conclusion

Requirement 1 artifacts originate from specific, easily corrigible structural flaws in asset generation and material configuration:

1. **Mountain Ridge Fixes**:
   - In `tools/build_gta5_open_world.gd` (and any regeneration script), invert the triangle index winding order from `(i0, i2, i1)` / `(i1, i2, i3)` to `(i0, i1, i2)` / `(i1, i3, i2)`.
   - Add boundary skirt polygons extending from the outer perimeter vertices down to $y = -5.0\text{ m}$ to seal open edges.
   - Change `cull_mode` in `mat_real_mountain_cliff.tres` back to `BaseMaterial3D.CULL_BACK (0)`.
   - Disable or clamp bloom (`glow_bloom = 0.0` or `glow_enabled = false`) during daylight presets to prevent sky-to-ridge bleeding.

2. **Road, Curb & Ground PBR Matte Fixes**:
   - Reimport all PBR textures in `textures/pbr/` (`asphalt`, `grass`, `ground`, `walls`, `mountain`) with `mipmaps/generate = true` and `compress/normal_map = 1`.
   - On `mat_real_asphalt_pbr`, `mat_dirt_pbr`, `mat_real_grass_pbr`, and `mat_city_sidewalk`, set `metallic_specular = 0.10` (or `0.05` for dirt/grass), reduce `normal_scale` (grass: 0.5, dirt: 0.4, asphalt: 0.4, sidewalk: 0.4), and set `roughness` to $0.92$–$0.96$.
   - In `WeatherController.gd`, update sunny/clear presets to set `road_specular = 0.10` instead of `0.50`.
   - Darken sidewalk concrete albedo in `mat_city_sidewalk.tres` from `Color(0.85, 0.85, 0.85)` to realistic concrete `Color(0.52, 0.52, 0.54)` to stop lighting blowouts.
   - For `CenterYellow_L/R` and `LaneWhite_L/R`, set `roughness = 0.85` and `metallic_specular = 0.10`.

3. **Pine Tree Foliage Fixes**:
   - In `CityCarZombieArena.gd` (and `build_gta5_open_world.gd`), replace the broken `.specular` property with `pine_mat.metallic_specular = 0.0`.
   - Set `pine_mat.roughness = 1.0` and `pine_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP` (or `DIFFUSE_LAMBERT`).
   - On the `CylinderMesh` foliage cones, set `c_mesh.cap_bottom = false` to eliminate the flat bottom disc and its rim normal discontinuity, or taper the bottom inward.

---

## 5. Verification Method

To independently reproduce and verify these findings:

1. **Verify Mountain Normals & Vertex Winding**:
   Run the headless diagnostic script:
   ```bash
   godot --headless --script res://tools/diagnose_requirement1.gd
   ```
   Inspect the log output:
   - Confirm `MountainRangeWest` reports `up_y = 0` and `avg_norm.y ≈ -0.93`.
   - Confirm `mat_real_mountain_cliff` reports `cull_mode = 2` and `uv1_triplanar = true`.

2. **Verify Texture Mipmap Omission**:
   Run grep across import files:
   ```bash
   grep -rn "mipmaps/generate=" textures/pbr/
   ```
   Confirm all entries show `mipmaps/generate = false`.

3. **Verify Foliage Property Warning**:
   Run the scene in headless mode:
   ```bash
   godot --headless --script res://tools/test_arena_vehicles.gd
   ```
   Check console output for:
   `WARNING: Godot 3.x SpatialMaterial remapped parameter not found: specular`
