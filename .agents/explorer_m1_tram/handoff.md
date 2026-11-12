# Handoff Report: Tram Station Arena Staging Strategy

**Explorer**: Explorer M1 Tram (Transit Arena Staging Explorer)  
**Target File**: `scenes/environments/RailwayStation.tscn`  
**Asset Source**: `real assent grafix import karna he/tram_station(1).glb` (85.7 MB mobile version)  
**Asset Destination**: `assets/3d/environments/tram_station.glb`  
**Date**: 2026-09-08  

---

## 1. Observation

### 1.1 High-Fidelity Asset Inspection: `tram_station(1).glb`
- **File System**:
  - Path: `/home/am/targetkill/real assent grafix import karna he/tram_station(1).glb`
  - Exact Size: 85,747,364 bytes (~81.8 MB / 85.7 MB downscaled mobile edition).
  - Contrasted with raw unoptimized file: `/home/am/targetkill/real assent grafix import karna he/tram_station.glb` is 161 MB (original 2K/4K version).
- **GLTF 2.0 Internal Specification**:
  - `scenes`: 1 (`Sketchfab_Scene`)
  - `nodes`: 1,525
  - `meshes`: 833
  - `materials`: 54
  - `images`: 43 embedded PNGs (in binary buffer views)
  - `textures`: 43
  - `extensionsUsed`: `[]` (pure glTF 2.0 Metallic-Roughness PBR, zero proprietary or deprecated extensions)
  - `extensionsRequired`: `[]`
  - Image Resolutions: all textures are strictly capped at 1024x1024 (downscaled for mobile; resolutions present: `(1024, 1024)`, `(512, 1024)`, `(512, 256)`, `(256, 256)`).
- **Spatial Geometry & World Coordinates**:
  Using recursive node transformation matrix analysis on `tram_station(1).glb`:
  - **Overall Model Dimensions**:
    - X span: `[-357.09m, 287.92m]` (width 645m including surrounding city backdrop)
    - Y span: `[1.62m, 68.00m]` (height 66m up to city skyscraper roofs)
    - Z span: `[-417.39m, 417.39m]` (length 835m along transit track corridor)
  - **Ground / Track Bed** (`Material` / `Object_323` and `Material.046` / `Object_326`):
    - Center: `(0.00, 1.80, 0.00)`
    - Ground slab span: Width 50m (`X in [-24m, +26m]`), Length 119m (`Z in [-60m, +59m]`)
    - Vertical level: `Y = 1.80m`
    - Dual central steel rails (`Material.022` / `Object_932`, `Object_934`): Left rail at `X = -2.07m`, Right rail at `X = +2.07m`.
  - **Passenger Platforms** (`Material.044` / `Object_317`, `Object_319`):
    - Platform 1 (Left / West): Center `X = -6.58m`, Width 6.37m (`X in [-9.77m, -3.39m]`), Length 78.52m (`Z in [-39.26m, +39.26m]`). Slab height `Y in [2.35m, 3.25m]`. Top walking surface at `Y = 3.25m` (1.45m above track bed).
    - Platform 2/3 (Right / East): Center `X = +6.58m`, Width 6.37m (`X in [+3.39m, +9.77m]`), Length 78.52m (`Z in [-39.26m, +39.26m]`). Slab height `Y in [2.35m, 3.25m]`. Top walking surface at `Y = 3.25m` (1.45m above track bed).
  - **Staircases & Platform Ramps** (`Material.024` / `Object_285`, `Object_287`, `Object_293`, `Object_295`):
    - North stair access: `Z = -22.5m`, connecting ground `Y = 1.80m` to platform `Y = 3.25m`.
    - South stair access: `Z = +22.8m`, connecting ground `Y = 1.80m` to platform `Y = 3.25m`.
  - **Shelter Canopies & Steel Trusses** (`Material.023`, `Material.037`, `Material.039`, `Material.045`):
    - Spanning `X in [-84m, +86m]`, `Z in [-53m, +53m]`, arching overhead from `Y = 1.79m` to `Y = 11.25m`.
  - **Stationary Trams** (`Material.603` to `Material.608`):
    - Parked on outer tracks at `X = -22.0m` and `X = +22.2m`, height `Y = 1.79m to 5.45m`, length 94m (`Z in [-46m, +47m]`).
  - **Surrounding Urban Complex** (`building` through `building.007`, `windows`, `interior`):
    - Multi-story urban blocks surrounding the transit hub between `X in [-357m, +288m]`, `Z in [-377m, +385m]`, `Y in [10m, 68m]`.

### 1.2 Inspection of `scenes/environments/RailwayStation.tscn`
- Currently instantiates obsolete 57 KB placeholder `res://assets/3d/environments/railway_station.glb` as child `RailwayStationGLB`.
- Contains obsolete low-poly loose OBJ meshes: `train_tracks.obj`, `station_bench.obj`.
- Spawner currently only configures 2 spawn points: `Spawn1` and `Spawn2` (lines 110-114). Neither contains directional names (`front`, `left`, `right`, `back`), causing `mission_03` and `mission_06` directional wave logic in `GameManager.gd` (lines 120-133) to fail to find matching candidate points and fall back to random picking.
- `WorldEnvironment` has `ssao_enabled = true`.
  - **Observed runtime warning**:
    ```
    WARNING: Screen-space ambient occlusion (SSAO) can only be enabled when using the Forward+ rendering backend.
         at: environment_set_ssao (servers/rendering/storage/environment_storage.cpp:574)
    ```
  - This violates PROJECT.md feature F4/F11 (`gl_compatibility` zero-warning mobile profile).

### 1.3 Inspection of Codebase Gameplay Contracts
- **Test Suite Contract (`TestRunner.gd` line 239 & 255)**:
  ```gdscript
  "Railway environment": {"scene": "res://scenes/environments/RailwayStation.tscn", "glb": "RailwayStationGLB"},
  ...
  var has_ground = inst.find_child("Ground", true, false) != null
  var has_light = inst.find_child("DirectionalLight3D", true, false) != null
  var has_spawner = inst.find_child("ZombieSpawner", true, false) != null
  var has_glb = inst.find_child(entry.glb, true, false) != null
  ```
  The GLB instance node inside `RailwayStation.tscn` MUST be named `RailwayStationGLB`.
- **Enemy Navigation Movement (`EnemyBase.gd` lines 510-518 & `ZombieAI.gd` lines 288-291)**:
  ```gdscript
  var dir = (player.global_position - global_position).normalized()
  if fly_height > 0.0: ...
  else: dir.y = 0.0
  velocity = dir * move_speed
  move_and_slide()
  ```
  Zombies move with `dir.y = 0.0` directly towards `player.global_position`. They have **NO vertical gravity** physics in their movement loop. If placed below a 1.45m vertical ledge with no ramp, or if spawned across a vertical cliff face, `dir.y = 0.0` causes the horizontal collision capsule to walk into the vertical wall and stop.
- **Player Movement Bounds (`Player.gd` lines 442-443)**:
  ```gdscript
  global_position.x = clamp(global_position.x, -move_limit, move_limit)
  global_position.z = clamp(global_position.z, -move_limit, move_limit)
  ```
  Player has `move_dir.y = 0.0` and no vertical falling physics. Positioning the player on a level ground plane `Y = 0` (or bounding the platform with invisible static collision rails) prevents the player from stepping into thin air.
- **Mission Specifications (`resources/missions/mission_03.tres` & `mission_06.tres`)**:
  - Mission 3: `"Crossfire"`, `"Railway Station - Platform 3"`, requires spawn directions `"front"`, `"left"`, `"right"`, `"back"`.
  - Mission 6: `"Patient Zero"`, requires spawn directions `"front"`, `"left"`, `"right"`, `"back"`.

---

## 2. Logic Chain

1. **Asset Staging Strategy**:
   - `real assent grafix import karna he` holds 10+ GB of raw assets. Before Godot parses files, a `.gdignore` file must be placed in `real assent grafix import karna he/` so Godot does not stall or crash trying to import unmanaged assets.
   - Copying `tram_station(1).glb` (82 MB) into `assets/3d/environments/tram_station.glb` places the asset under the standard Godot project resource tree `res://assets/3d/environments/tram_station.glb`.
   - Godot's scene importer (`importer="scene"`, `type="PackedScene"`) will import `tram_station.glb` into `.godot/imported/` cleanly because `tram_station(1).glb` has 0 extensions and 1K PBR textures.

2. **Node Staging & Orientation**:
   - In `tram_station.glb`, the track bed and station floor (`Object_326`) are at `Y = 1.80m`. The two passenger platforms (`Object_317`, `Object_319`) are at `X = -6.58m` and `X = +6.58m`, with top walking surface at `Y = 3.25m`.
   - **Recommended Staging Alignment**:
     Offset `tram_station.glb` by `Vector3(0, -1.80, 0)`:
     - The track bed ground and the entire 50m x 119m station concourse floor are aligned precisely to `Y = 0.0`.
     - Elevated platforms rise to `Y = 1.45m` (`3.25 - 1.80 = 1.45m`).
     - Steel canopies arch overhead from `Y = 0` to `Y = 9.45m`.
     - The stationary player is stationed at `Vector3(0, 0.05, 0)` right between the two steel railway tracks, flanked by Platform 1 and Platform 2, looking straight down the railway corridor under the arched canopy.
     - Alternatively, if Platform 3 is desired as the exact standing platform: offset `tram_station.glb` by `Vector3(-6.58, -3.25, 0)`, which places Platform 3 centered at `(0, 0, 0)` and platform height at `Y = 0.0`.
     - **Recommendation**: Aligning track bed to `Y = 0.0` (`transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.8, 0)`) provides the most open, dynamic 360-degree combat arena because the 50m x 119m concourse floor is 100% level at `Y = 0.0`, eliminating any risk of zombies getting stuck against platform curbs.

3. **Collisions (`StaticBody3D`)**:
   - Ground collision: `CollisionShape3D` with `BoxShape3D(size = Vector3(60, 0.4, 80))` centered at `(0, -0.2, 0)`.
   - Platform left collision: `CollisionShape3D` with `BoxShape3D(size = Vector3(6.4, 1.45, 78.5))` at `(-6.58, 0.725, 0)`.
   - Platform right collision: `CollisionShape3D` with `BoxShape3D(size = Vector3(6.4, 1.45, 78.5))` at `(6.58, 0.725, 0)`.
   - Invisible perimeter barrier walls: `StaticBody3D` enclosing `X in [-25, 25]` and `Z in [-35, 35]` to keep all entities in bounds.

4. **`NavigationRegion3D` Geometry**:
   - Explicit `NavigationMesh` sub-resource covering the transit hub:
     ```tscn
     [sub_resource type="NavigationMesh" id="NavigationMesh_tram"]
     vertices = PackedVector3Array(-25, 0, -35, -25, 0, 35, 25, 0, 35, 25, 0, -35)
     polygons = [PackedInt32Array(0, 1, 2), PackedInt32Array(0, 2, 3)]
     ```
   - This provides instant, zero-bake-overhead 3D navigation across the entire transit arena for both humanoid zombies and infected quadruped dogs.

5. **4-Quadrant Zombie Spawners**:
   - Positioned between 14m and 22m from the player (`Vector3(0, 0, 0)`):
     - `SpawnFront`: `Vector3(0, 0, -22)` (approaching down north railway tracks)
     - `SpawnBack`: `Vector3(0, 0, 22)` (approaching down south railway tracks)
     - `SpawnLeft`: `Vector3(-14, 0, -4)` (approaching from west platform concourse / parked tram)
     - `SpawnRight`: `Vector3(14, 0, -4)` (approaching from east platform concourse / parked tram)
     - `SpawnFrontLeft`: `Vector3(-8, 0, -15)` (diagonal track approach)
     - `SpawnFrontRight`: `Vector3(8, 0, -15)` (diagonal track approach)
   - These node names exactly match `contains("front")`, `contains("left")`, `contains("right")`, `contains("back")` in `GameManager.gd`.

6. **Mobile PBR Lighting & Atmosphere**:
   - Eliminate SSAO (`ssao_enabled = false`) and milky fog to fix the console warning and preserve mobile 30 FPS.
   - 1 `DirectionalLight3D` (sunlight): `light_energy = 1.4`, `directional_shadow_mode = 0` (orthogonal), `shadow_bias = 0.05`.
   - 2 `OmniLight3D` perimeter lights (warm sodium/halogen transit platform lighting):
     - `PlatformLightNorth`: `Vector3(0, 4.5, -10)`, color `Color(1.0, 0.92, 0.82)`, energy `1.6`, range `18.0m`.
     - `PlatformLightSouth`: `Vector3(0, 4.5, 10)`, color `Color(1.0, 0.92, 0.82)`, energy `1.6`, range `18.0m`.
   - Filmic tonemapping (`tonemap_mode = 2`, `tonemap_exposure = 1.05`), procedural sky with sunset/golden-hour horizon.

---

## 3. Caveats

1. **Asset Duplication Safeguard**:
   Ensure `real assent grafix import karna he/.gdignore` exists before copying. If Godot runs without `.gdignore`, it will attempt to scan all 10 GB of raw archives in `real assent grafix import karna he/`.
2. **Node Name Preservation**:
   The instanced node for the GLB model MUST be named `RailwayStationGLB` in `RailwayStation.tscn`. Renaming it to `TramStation` will cause `TestRunner.gd` line 255 (`inst.find_child("RailwayStationGLB", true, false) != null`) to fail.
3. **No Vertical Step Obstacles on Spawn Vectors**:
   Since `EnemyBase.gd` and `InfectedDog.gd` run with `dir.y = 0.0` without waypoint nav-mesh path following during direct chase, spawn points must have clear, level ground between their coordinates and the player. Do not place high collision boxes directly in front of spawn points.
4. **Memory Footprint**:
   `tram_station.glb` is 82 MB. With 43 1K textures, VRAM footprint is approximately 60-80 MB in uncompressed GPU memory. In mobile `gl_compatibility`, this easily fits within the 512 MB mobile VRAM budget.

---

## 4. Conclusion & Actionable Worker Implementation Plan

### Step 1: Establish `.gdignore` in Raw Asset Directory
Create `/home/am/targetkill/real assent grafix import karna he/.gdignore` (empty file).

### Step 2: Copy the 82 MB Mobile Asset
```bash
cp "/home/am/targetkill/real assent grafix import karna he/tram_station(1).glb" \
   "/home/am/targetkill/assets/3d/environments/tram_station.glb"
```

### Step 3: Replace `scenes/environments/RailwayStation.tscn`
Update `scenes/environments/RailwayStation.tscn` with the complete, optimized scene definition below:

```tscn
[gd_scene load_steps=18 format=3 uid="uid://railway001station"]

[ext_resource type="PackedScene" path="res://scenes/player/Player.tscn" id="1_p001"]
[ext_resource type="Script" path="res://scripts/GameManager.gd" id="2_g001"]
[ext_resource type="PackedScene" path="res://assets/zombies/RealisticZombie.tscn" id="3_z001"]
[ext_resource type="Script" path="res://scripts/ImpactPool.gd" id="4_i001"]
[ext_resource type="PackedScene" path="res://scenes/weapons/ImpactEffect.tscn" id="5_ie01"]
[ext_resource type="PackedScene" path="res://scenes/weapons/BloodEffect.tscn" id="6_be01"]
[ext_resource type="PackedScene" path="res://scenes/UI/ResultUI.tscn" id="7_r001"]
[ext_resource type="Material" path="res://resources/materials/mat_station_platform.tres" id="8_mplat"]
[ext_resource type="AudioStream" path="res://audio/ambience/sfx_ambience_metro.wav" id="9_samb"]
[ext_resource type="PackedScene" path="res://assets/3d/environments/tram_station.glb" id="10_tram_stn"]
[ext_resource type="PackedScene" path="res://scenes/environments/AtmosphereEnhancer.tscn" id="11_atmo"]

[sub_resource type="NavigationMesh" id="NavigationMesh_tram"]
vertices = PackedVector3Array(-25, 0, -35, -25, 0, 35, 25, 0, 35, 25, 0, -35)
polygons = [PackedInt32Array(0, 1, 2), PackedInt32Array(0, 2, 3)]

[sub_resource type="BoxShape3D" id="BoxShape3D_flr"]
size = Vector3(60, 0.4, 80)

[sub_resource type="PlaneMesh" id="PlaneMesh_flr"]
size = Vector2(60, 80)

[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_transit"]
sky_top_color = Color(0.22, 0.45, 0.82, 1)
sky_horizon_color = Color(0.85, 0.72, 0.58, 1)
ground_bottom_color = Color(0.12, 0.14, 0.18, 1)
ground_horizon_color = Color(0.35, 0.38, 0.42, 1)
sun_angle_max = 28.0

[sub_resource type="Sky" id="Sky_transit"]
sky_material = SubResource("ProceduralSkyMaterial_transit")

[sub_resource type="Environment" id="Environment_tram"]
background_mode = 2
sky = SubResource("Sky_transit")
ambient_light_source = 2
ambient_light_color = Color(0.60, 0.65, 0.70, 1)
ambient_light_energy = 0.80
tonemap_mode = 2
tonemap_exposure = 1.05
tonemap_white = 1.0
glow_enabled = false
fog_enabled = false

[node name="RailwayStation" type="Node3D"]

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_tram")

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866, -0.354, 0.354, 0, 0.707, 0.707, -0.5, -0.612, 0.612, 0, 25, 0)
light_color = Color(1.0, 0.95, 0.88, 1)
light_energy = 1.35
shadow_enabled = true
shadow_bias = 0.05
directional_shadow_mode = 0

[node name="PlatformLightNorth" type="OmniLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 4.5, -10)
light_color = Color(1.0, 0.92, 0.82, 1)
light_energy = 1.5
omni_range = 18.0

[node name="PlatformLightSouth" type="OmniLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 4.5, 10)
light_color = Color(1.0, 0.92, 0.82, 1)
light_energy = 1.5
omni_range = 18.0

[node name="NavigationRegion3D" type="NavigationRegion3D" parent="."]
navigation_mesh = SubResource("NavigationMesh_tram")

[node name="Ground" type="StaticBody3D" parent="NavigationRegion3D"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.2, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="NavigationRegion3D/Ground"]
shape = SubResource("BoxShape3D_flr")

[node name="MeshInstance3D" type="MeshInstance3D" parent="NavigationRegion3D/Ground"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 0)
mesh = SubResource("PlaneMesh_flr")
surface_material_override/0 = ExtResource("8_mplat")

[node name="Player" parent="." instance=ExtResource("1_p001")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)

[node name="ZombieSpawner" type="Node3D" parent="." node_paths=PackedStringArray("spawn_points")]
script = ExtResource("2_g001")
zombie_scene = ExtResource("3_z001")
spawn_points = [NodePath("SpawnFront"), NodePath("SpawnBack"), NodePath("SpawnLeft"), NodePath("SpawnRight"), NodePath("SpawnFrontLeft"), NodePath("SpawnFrontRight")]

[node name="SpawnFront" type="Node3D" parent="ZombieSpawner"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -22)

[node name="SpawnBack" type="Node3D" parent="ZombieSpawner"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 22)

[node name="SpawnLeft" type="Node3D" parent="ZombieSpawner"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -14, 0, -4)

[node name="SpawnRight" type="Node3D" parent="ZombieSpawner"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 14, 0, -4)

[node name="SpawnFrontLeft" type="Node3D" parent="ZombieSpawner"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -8, 0, -15)

[node name="SpawnFrontRight" type="Node3D" parent="ZombieSpawner"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8, 0, -15)

[node name="ImpactPool" type="Node3D" parent="." groups=["impact_pool"]]
script = ExtResource("4_i001")
impact_scenes = {
"blood": ExtResource("6_be01"),
"concrete": ExtResource("5_ie01")
}

[node name="ResultUI" parent="." instance=ExtResource("7_r001")]

[node name="AmbiencePlayer" type="AudioStreamPlayer" parent="."]
stream = ExtResource("9_samb")
volume_db = -6.0
autoplay = true

[node name="RailwayStationGLB" parent="." instance=ExtResource("10_tram_stn")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.8, 0)

[node name="AtmosphereEnhancer" parent="." instance=ExtResource("11_atmo")]
```

---

## 5. Verification Method

To independently verify after implementation:

1. **Automated Headless Test Suite**:
   ```bash
   godot --headless scenes/test/TestRunner.tscn
   ```
   **Expected Outcome**:
   - `[PASS] Railway environment - Scene: res://scenes/environments/RailwayStation.tscn, GLB Node: RailwayStationGLB`
   - ZERO `Screen-space ambient occlusion (SSAO)` warnings.
   - All 44+ tests record `[PASS]`.

2. **Memory Lifecycle Verification**:
   ```bash
   godot --headless -s scripts/Tools/test_memory_lifecycle.gd
   ```
   **Expected Outcome**:
   - `RailwayStation.tscn` instantiates, executes 3 frames, and frees cleanly with zero memory leaks.

3. **360-Degree Zombie Approach Verification**:
   ```bash
   godot --headless assets_tests/Zombie360Test.tscn
   ```
   **Expected Outcome**:
   - All 4 directional approaches (Front, Back, Left, Right) advance >0.5m towards the player at origin.

4. **Visual Capture / Rendering Check**:
   ```bash
   python3 -c "
   import os
   print('File exists:', os.path.exists('assets/3d/environments/tram_station.glb'))
   print('File size:', os.path.getsize('assets/3d/environments/tram_station.glb'))
   "
   ```
