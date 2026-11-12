# Handoff Report: Urban Arena Staging Strategy

**Explorer**: Explorer M1 Urban  
**Target Recipient**: Orchestrator / Worker M1  
**Working Directory**: `/home/am/targetkill/.agents/explorer_m1_urban`  
**Date**: 2026-09-07T21:56:00Z  

---

## 1. Observation

### 1.1 High-Fidelity Urban Assets Inspection
Direct inspection of the asset files via GLB header parsing and Godot 4.3 runtime analysis revealed:
1. `/home/am/targetkill/real assent grafix import karna he/street_city_7_for_games_free(1).glb`:
   - File Size: `13,328,128 bytes` (13.3 MB) — an optimized version of `street_city_7_for_games_free.glb` (17.7 MB) with image buffer 3 compressed from 6.36 MB down to 1.96 MB.
   - Node Count: `186 nodes`, `111 meshes`, `12 materials`.
   - Bounding Box in Godot: `[Position: (-15.39, -1.75, -26.49), Size: (53.72, 14.18, 52.90)]`.
   - Ground plane meshes (`Plane_006`, `Plane_Material_009_0`, `Plane_003`, `Plane_007`): Span X `[-10.32, 9.31]`, Z `[-16.65, 11.19]` at elevation `Y ≈ 0.00m` (ranging between `-0.01m` and `+0.03m`).
   - Center obstacles: Several market stall meshes (`Plane_020_Material_002_0` at `(1.0, 1.3, -0.1)` of size `(2.9, 2.6, 2.6)` and `Plane_025_Material_002_0` at `(1.4, 1.3, -1.7)`) overlap local coordinates `(0, 0, 0)` if the model is placed with transform `(0, 0, 0)` without translation offset.
   - Tested translation offsets for `street_city_7.glb`: Placing the model at translation `Vector3(3.0, 0, 1.0)` or `Vector3(-4.0, 0, 9.0)` positions the player origin `(0, 0.05, 0)` directly in an open street/plaza clearing with over `2.04m - 2.21m` radial clearance to any obstacle.
2. `/home/am/targetkill/real assent grafix import karna he/street_city_buildings_8.glb`:
   - File Size: `7,050,452 bytes` (7.05 MB).
   - Node Count: `114 nodes`, `73 meshes`, `9 materials`.
   - Bounding Box in Godot: `[Position: (-10.42, -0.08, -16.39), Size: (18.08, 7.78, 23.71)]`.
   - Ground plane `Plane_002_Material_010_0`: Center `(-0.0, 0.0, 0.1)`, size `(14.4, 0.0, 14.4)`.
   - Stylistic match: Shares the same author, texture format, and material nomenclature (`Material.001` - `Material.011`) as `street_city_7`.
3. Absence of `.gdignore`:
   - `real assent grafix import karna he/.gdignore` does not exist. The directory contains 750 MB of raw `.zip`, `.part`, and duplicated `.glb` files which triggers long background importer scans unless `.gdignore` is added.

### 1.2 Existing Scene Inspection (`scenes/environments/UrbanStreet.tscn`)
- Root: `UrbanStreet` (`Node3D`, script `res://scenes/environments/UrbanStreet.gd`).
- Existing Ground:
  ```
  [node name="NavigationRegion3D" type="NavigationRegion3D" parent="."]
  navigation_mesh = SubResource("NavigationMesh_urban")

  [node name="Ground" type="StaticBody3D" parent="NavigationRegion3D"]
  [node name="CollisionShape3D" type="CollisionShape3D" parent="NavigationRegion3D/Ground"]
  shape = SubResource("BoxShape3D_flr")
  ```
  where `SubResource("BoxShape3D_flr")` is a `BoxShape3D` of `size = Vector3(70, 0.2, 70)`.
  `SubResource("NavigationMesh_urban")` is a 2-polygon quad:
  `vertices = PackedVector3Array(-35, 0, -35, -35, 0, 35, 35, 0, 35, 35, 0, -35)`.
- Existing Model: `GTAGroveStreet` (`assets/external/downloads/environments/gta_grove_street.glb`) placed at `transform = Transform3D(3.0, 0, 0, 0, 3.0, 0, 0, 0, 3.0, 0, 0, -16)`.
- Existing Spawner:
  ```
  [node name="ZombieSpawner" type="Node3D" parent="." node_paths=PackedStringArray("spawn_points")]
  script = ExtResource("2_g001")
  zombie_scene = ExtResource("3_z001")
  spawn_points = [NodePath("SpawnFront"), NodePath("SpawnLeftAlley"), NodePath("SpawnRightAlley"), NodePath("SpawnFrontLeft"), NodePath("SpawnFrontRight")]
  ```
  Missing dedicated `SpawnBack`, `SpawnLeft`, and `SpawnRight` nodes!

### 1.3 Mission & Script Linkage
- `resources/missions/mission_01.tres` and `resources/missions/mission_07.tres`:
  - `scene_path = "res://scenes/environments/UrbanStreet.tscn"`
  - `mission_01.tres` Wave 3:
    `groups = [{"enemy_type": "normal", "count": 4, "spawn_direction": "back", "delay": 1.0}, {"enemy_type": "fast", "count": 2, "spawn_direction": "right", "delay": 1.2}]`
  - `mission_07.tres` Waves 1, 2, 3: require `"front"`, `"back"`, `"left"`, and `"right"` directions.
- `scripts/GameManager.gd` lines 120-134:
  ```gdscript
  var candidate_points: Array[Node3D] = []
  if direction != "":
      for sp in spawn_points:
          if sp and sp.name.to_lower().contains(direction.to_lower()):
              candidate_points.append(sp)
  if candidate_points.is_empty():
      for sp in spawn_points:
          if sp and sp.global_position.distance_to(player_pos) > 10.0:
              candidate_points.append(sp)
  ```
  Because `UrbanStreet.tscn` lacked any node with `"back"` in its name, when Wave 3 requests direction `"back"`, `candidate_points` was empty, forcing a fallback to random spawners.
- `scenes/environments/UrbanStreet.gd`:
  Safely guards the GTA model look-up:
  ```gdscript
  var gta = find_child("GTAGroveStreet", true, false)
  if not gta:
      return
  ```
  Replacing or removing `GTAGroveStreet` will not cause script crashes.

### 1.4 Test Verification Status
- `godot --headless scenes/test/TestRunner.tscn`: Executed and logged `54 / 54 PASSED`.
- `godot --headless assets_tests/Zombie360Test.tscn`: Executed and logged `100% PASS` across all 5 phases.
- `godot --headless -s tools/test_urban_street.gd`: Loaded and instantiated `UrbanStreet.tscn` cleanly.
- `godot --headless -s scripts/Tools/test_mission1_gameplay.gd`: Passed all directional spawner checks and 360-degree combat validation.

---

## 2. Logic Chain

1. **Asset Curation & Protection**:
   - `real assent grafix import karna he` holds 750 MB of raw files. Without `.gdignore`, Godot's resource daemon scans every file on editor/headless boot. Creating `/home/am/targetkill/real assent grafix import karna he/.gdignore` prevents this.
   - Copying `street_city_7_for_games_free(1).glb` to `assets/3d/environments/street_city_7.glb` and `street_city_buildings_8.glb` to `assets/3d/environments/street_buildings.glb` satisfies the layout specified in `PROJECT.md` (lines 16, 67).
2. **Preserving Mission 1 and Mission 7 Flow**:
   - Missions 1 and 7 directly reference `scenes/environments/UrbanStreet.tscn`. The node hierarchy, especially node names `Player`, `ZombieSpawner`, `NavigationRegion3D`, `Ground`, `ImpactPool`, and `ResultUI`, must be strictly preserved.
   - Wave 3 in `mission_01.tres` explicitly specifies `spawn_direction: "back"`. By adding `SpawnBack` to `ZombieSpawner`, `GameManager.gd` will correctly resolve the back-quadrant spawn points instead of falling back to random selection.
3. **Collision Strategy (Primitive BoxShape3D vs. Trimesh)**:
   - Generating trimesh static bodies on 111 raw meshes introduces thousands of collision polygons, which increases CPU physics cost on mobile (`gl_compatibility`) and causes `CharacterBody3D` (zombies) to snag or hitch on minor curb steps (`0.05m - 0.15m`).
   - A dedicated `Ground` `StaticBody3D` with a flat `BoxShape3D` of `size = Vector3(60, 0.2, 60)` at `y = -0.1` ensures a continuous ground plane at `y = 0.0`.
   - Discrete perimeter/wall colliders (`BoxShape3D`) on large buildings (left, right, front, back) prevent zombies and bullets from escaping the street arena.
4. **Navigation Region (360-Degree)**:
   - `NavigationMesh` should cover the walkable ground area `[-25, 25] x [-25, 25]` at `y = 0.0`.
   - Zombies spawned 10m-20m away in all 4 quadrants require clear lines of approach towards the stationary player at `(0, 0.05, 0)`.
   - Aligning the street corridor and clearing props within a 3m radius around `(0, 0, 0)` ensures zombies approaching from all 4 directions do not get stuck on stalls or poles.
5. **4-Quadrant Spawner Calibration & Cover Props**:
   - Spawners must be placed between 10m and 20m away to satisfy `GameManager.gd`'s `distance_to(player_pos) > 10.0` check.
   - Standard 4-quadrant naming:
     - `SpawnFront`: `Vector3(0, 0, -16.0)` (corridor behind concrete barriers)
     - `SpawnBack`: `Vector3(0, 0, 16.0)` (rear street behind bus stop)
     - `SpawnLeft`: `Vector3(-15.0, 0, 0.0)` (side alley behind pallets/barrels)
     - `SpawnRight`: `Vector3(15.0, 0, 0.0)` (side street behind barricade/traffic light)
     - Maintain `SpawnFrontLeft` `Vector3(-8, 0, -12)` and `SpawnFrontRight` `Vector3(8, 0, -12)` in `spawn_points` for backward compatibility.

---

## 3. Caveats

1. **Building Heights and Sky Clipping**:
   - The buildings in `street_city_7` are 8m to 12.4m tall. When using `ProceduralSkyMaterial`, the sky horizon is visible above the buildings. Directional sun angles should remain between 25° and 35° elevation to avoid unnatural harsh overhead shadows.
2. **GTAGroveStreet Cleanup**:
   - Existing `scenes/environments/UrbanStreet.gd` has custom code for GTA Grove foliage textures (`material_14`, `52`, etc.). When `street_city_7` is staged, that logic is inert (gracefully returns). The script can either be kept intact or extended to handle `street_city_7` PBR material properties.
3. **Texture Memory Budget**:
   - `street_city_7_for_games_free(1).glb` uses 13.3 MB VRAM footprint. Combined with `street_city_buildings_8.glb` (7 MB), total environment geometry is ~20 MB, well within the 100 MB mobile texture budget for Godot 4 `gl_compatibility`.

---

## 4. Conclusion & Actionable Recommendation for Worker M1

### Step 1: Asset Protection & Curation
1. Create `/home/am/targetkill/real assent grafix import karna he/.gdignore` to silence raw asset scanning.
2. Copy `/home/am/targetkill/real assent grafix import karna he/street_city_7_for_games_free(1).glb` to `/home/am/targetkill/assets/3d/environments/street_city_7.glb`.
3. Copy `/home/am/targetkill/real assent grafix import karna he/street_city_buildings_8.glb` to `/home/am/targetkill/assets/3d/environments/street_buildings.glb`.

### Step 2: Ground Collision Setup in `UrbanStreet.tscn`
1. Maintain `Ground` under `NavigationRegion3D`:
   - `CollisionShape3D` with `BoxShape3D` of `size = Vector3(60, 0.2, 60)` at `transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.1, 0)`.
   - `MeshInstance3D` with `PlaneMesh(60, 60)` and material `res://resources/materials/mat_asphalt.tres` to ensure a consistent dark aggregate asphalt foundation.

### Step 3: Geometry Staging
1. Replace `GTAGroveStreet` with:
   - Node `UrbanStreetGeometry` instantiating `res://assets/3d/environments/street_city_7.glb`.
   - Position: `transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3.0, 0, 1.0)` (or `(0, 0, -16.0)` if keeping corridor forward-facing). The `(3.0, 0, 1.0)` offset positions the stationary player in the open plaza with >2.0m radius of unobstructed aiming and movement.
2. Add perimeter buildings from `res://assets/3d/environments/street_buildings.glb` as `DistantBuildings` if needed to close open sightlines on boundaries.

### Step 4: Navigation Region Setup
1. Configure `NavigationRegion3D/NavigationMesh`:
   - Vertices: `PackedVector3Array(-25, 0, -25, -25, 0, 25, 25, 0, 25, 25, 0, -25)`.
   - Polygons: `[PackedInt32Array(0, 1, 2), PackedInt32Array(0, 2, 3)]`.
   - This provides a 50m x 50m flat navigation polygon encompassing all 4 spawn points and the player origin.

### Step 5: 4-Quadrant Zombie Spawners & Cover Props
1. In `UrbanStreet.tscn`, configure `ZombieSpawner`:
   ```
   [node name="ZombieSpawner" type="Node3D" parent="." node_paths=PackedStringArray("spawn_points")]
   script = ExtResource("2_g001")
   zombie_scene = ExtResource("3_z001")
   spawn_points = [NodePath("SpawnFront"), NodePath("SpawnBack"), NodePath("SpawnLeft"), NodePath("SpawnRight"), NodePath("SpawnFrontLeft"), NodePath("SpawnFrontRight")]

   [node name="SpawnFront" type="Node3D" parent="ZombieSpawner"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -16)

   [node name="SpawnBack" type="Node3D" parent="ZombieSpawner"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 16)

   [node name="SpawnLeft" type="Node3D" parent="ZombieSpawner"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -15, 0, 0)

   [node name="SpawnRight" type="Node3D" parent="ZombieSpawner"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 15, 0, 0)

   [node name="SpawnFrontLeft" type="Node3D" parent="ZombieSpawner"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -8, 0, -12)

   [node name="SpawnFrontRight" type="Node3D" parent="ZombieSpawner"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8, 0, -12)
   ```
2. Place props under `Props` node at 10m-14m distance:
   - Front: `concrete_jersey_barrier_01_large.glb` and `vehicle-truck-red.glb` at `(0, 0, -12)`.
   - Back: `bus_stop.glb` at `(0, 0, 12)` and `advertising_column_01_big.glb` at `(-2, 0, 13)`.
   - Left: `pallet_medium_large_01.glb` and `barrel_02_big_red.glb` at `(-11, 0, 0)`.
   - Right: `type_ii_barricade_01_large.glb` and `traffic_light_01_base_large_black.glb` at `(11, 0, 0)`.

---

## 5. Verification Method

To independently verify the implementation:

1. **Scene Instantiation Test**:
   ```bash
   godot --headless -s tools/test_urban_street.gd
   ```
   *Expected Result*: Output must contain `Loaded UrbanStreet.tscn` and `Instantiated UrbanStreet successfully` with exit code 0.
2. **Mission 1 Gameplay & 4-Quadrant Spawner Test**:
   ```bash
   godot --headless -s scripts/Tools/test_mission1_gameplay.gd
   ```
   *Expected Result*: Must confirm all 4 spawn points (`SpawnFront`, `SpawnBack`, `SpawnLeft`, `SpawnRight`) present and zombies navigating towards player without sticking.
3. **360-Degree Zombie Test**:
   ```bash
   godot --headless assets_tests/Zombie360Test.tscn
   ```
   *Expected Result*: Must report `[PASS] All 4 zombies actively navigating and approaching player from all 360° quadrants.` and `TOTAL: 5/5 PASSED`.
4. **Full Regression Suite**:
   ```bash
   godot --headless scenes/test/TestRunner.tscn
   ```
   *Expected Result*: Must maintain `54 / 54 PASSED` (100%).
5. **Invalidation Conditions**:
   - Any crash or error on loading `scenes/environments/UrbanStreet.tscn`.
   - Any regression in `TestRunner.tscn` (fewer than 54 passing tests).
   - Zombies spawned in Front, Back, Left, or Right colliding with stuck obstacles and failing to advance.
