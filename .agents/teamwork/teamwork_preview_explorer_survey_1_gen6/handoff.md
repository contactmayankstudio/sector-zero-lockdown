# Handoff Report: Survey R1 — Permanent 3D Terrain Collision & Mountain Vehicle Climbing

**Author**: Explorer 1 (Survey R1)  
**Date**: 2026-10-10T18:38:00Z  
**Working Directory**: `/home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_1_gen6`  
**Parent Conversation ID**: `9b0d70d2-fb33-4bea-a8d5-73de0e0182f7`  
**Type**: Hard Handoff (Investigation Complete)  

---

## 1. Observation

### 1.1 Terrain and Mountain Meshes Collision Status (`CityCarZombieArena.tscn`)
Direct inspection of `scenes/environments/CityCarZombieArena.tscn` revealed the following node hierarchy:

1. **`AdvancedTerrain` Meshes**:
   - `ValleyFloor` (line 1202): `MeshInstance3D` with `ArrayMesh_bnpk3`. Sibling `ValleyFloor_Physics` (line 1206) is an empty `StaticBody3D` with **zero** `CollisionShape3D` children.
   - `MountainWest` (line 1224): `MeshInstance3D` with `ArrayMesh_dw6tl`. Sibling `MountainWest_Physics` (line 1228) is an empty `StaticBody3D` with **zero** `CollisionShape3D` children.
   - `MountainEast` (line 1231): `MeshInstance3D` with `ArrayMesh_v3gem`. Sibling `MountainEast_Physics` (line 1235) is an empty `StaticBody3D` with **zero** `CollisionShape3D` children.
   - `MountainNorthWall` (line 1238) & `MountainSouthWall` (line 1244): `MeshInstance3D` nodes with empty sibling `StaticBody3D` nodes (lines 1242, 1248) and no collision shapes.
   - `DirtPath_West` (line 1208), `DirtPath_East` (line 1212), `MountainRoad_West` (line 1216), `MountainRoad_East` (line 1220): `MeshInstance3D` nodes with **no** collision shapes or physics bodies in `.tscn`.
2. **`RealisticTerrain` Meshes**:
   - `HighwayAsphalt` (line 581): `StaticBody3D` with `CollisionShape3D` named `Col` (line 583) using `BoxShape3D_4s5sq` (size: `Vector3(22.0, 0.4, 520.0)`). **This is the only ground collider pre-baked in the .tscn!**
   - `SidewalkLeft` (line 612) & `SidewalkRight` (line 619): `StaticBody3D` nodes containing only child `MeshInstance3D` named `Mesh` (lines 614, 621). **Zero collision shapes in the .tscn**.
   - `DirtShoulderLeft` (line 626) & `DirtShoulderRight` (line 633): `StaticBody3D` nodes containing only child `MeshInstance3D` named `Mesh` (lines 628, 635). **Zero collision shapes in the .tscn**.
3. **ConcavePolygonShape3D in `.tscn`**:
   - `grep_search` query `ConcavePolygonShape3D` on `scenes/environments/CityCarZombieArena.tscn` returned **0 results**. There are **no pre-baked ConcavePolygonShape3D colliders** in the `.tscn` file.

### 1.2 Runtime Collision Generation (`scenes/environments/CityCarZombieArena.gd`)
In `scenes/environments/CityCarZombieArena.gd` lines 159–208:
```gdscript
func _ensure_solid_terrain_collisions() -> void:
    var adv = get_node_or_null("AdvancedTerrain")
    if adv:
        var target_meshes = ["ValleyFloor", "MountainWest", "MountainEast", "MountainRoad_West", 
                             "MountainRoad_East", "DirtPath_West", "DirtPath_East", "MountainNorthWall", "MountainSouthWall"]
        for m_name in target_meshes:
            var mi = adv.get_node_or_null(m_name) as MeshInstance3D
            if mi and mi.mesh:
                var existing_col = mi.find_children("*", "CollisionShape3D", true, false)
                if existing_col.is_empty():
                    mi.create_trimesh_collision()
```
- At runtime during `_ready()`, `mi.create_trimesh_collision()` creates a child `StaticBody3D` with a `ConcavePolygonShape3D` dynamically.
- `CityCarZombieArena.gd` lines 209–227 contains a fall watchdog because vehicles and player fall through into the void if spawned before or during collision generation (`global_position.y < -35.0`).

### 1.3 Generator Scripts (`tools/build_advanced_terrain.gd` & `tools/bake_terrain_colliders.gd`)
1. In `tools/build_advanced_terrain.gd`:
   - Lines 100–107: Explicitly removed box colliders from `SidewalkLeft`, `SidewalkRight`, `DirtShoulderLeft`, and `DirtShoulderRight` via `col.free()`.
   - Lines 266–276 & 446–460: Attempted to create static bodies and `ConcavePolygonShape3D` colliders, but called `cs.owner = owner` before `sb` was added to `parent` in the scene tree, resulting in unsaved collision shapes in the packed scene.
   - Lines 1304–1395: `_build_dirt_paths()` creates only `MeshInstance3D` nodes for `DirtPath_West`, `DirtPath_East`, `MountainRoad_West`, and `MountainRoad_East`, with no physics bodies.
2. In `tools/bake_terrain_colliders.gd`:
   - An offline tool designed to load `CityCarZombieArena.tscn`, generate `create_trimesh_shape()`, attach `CollisionShape3D` to the physics bodies, set `owner = scene`, and re-save the `.tscn`.
   - Has not yet been executed to update `CityCarZombieArena.tscn`.
   - Adds `CollisionShape3D` into sibling bodies `MountainWest_Physics`, but `CityCarZombieArena.gd` line 179 checks `mi.find_children("*", "CollisionShape3D")` on the `MeshInstance3D`, which would cause redundant runtime duplication unless updated.

### 1.4 Shoulder & Mountain Transitions (x = ±11m to ±28m and ±75m)
1. **At x = ±11.0m** (`HighwayAsphalt` to `SidewalkLeft/Right`):
   - `HighwayAsphalt` ends at `x = ±11.0m`, `y = 0.0m` with a vertical 0.4m box edge dropping to `y = -0.4m`.
   - `SidewalkLeft/Right` mesh is positioned at `y = 0.12m` (`transform = Transform3D(..., ±12.25, 0.12, -160)`).
   - This creates a **0.12m (12cm) vertical curb step** where the sidewalk rises above the asphalt.
2. **At x = ±13.5m** (`SidewalkLeft/Right` to `DirtShoulderLeft/Right`):
   - Sidewalk ends at `x = ±13.5m`, `y = +0.12m`.
   - Dirt shoulder mesh is at `y = 0.0m` (`transform = Transform3D(..., ±17.75, 0, -160)`).
   - This creates a **0.12m vertical drop lip** onto the dirt shoulder.
3. **Concrete Barriers on Highway Edges**:
   - Lines 904–926 of `CityCarZombieArena.tscn`: Eight `ConcreteBarrierA.scn` static bodies (`Barrier_0` through `Barrier_7`) are positioned at `x = ±10.5m`, `z = -40, -110, -180, -260`. These physical barriers obstruct vehicles driving off the highway.
4. **At x = ±22.0m to ±28.0m** (`DirtShoulder` to `ValleyFloor` & `DirtPath`):
   - `DirtShoulderLeft/Right` ends at `x = ±22.0m`.
   - `DirtPath_West/East` is generated centered at `x = ±22.0m` with width 12.0m (x = ±16m to ±28m) at `y = h + 0.08m` (an 8cm vertical lip above the ground).
   - `ValleyFloor` has `h = 0.0m` for `|x| < 28m`.
5. **At x = ±75.0m** (`ValleyFloor` to `MountainWest/East`):
   - Mathematically, `ValleyFloor` clamps height to `0.0m` at `|x| >= 75m` (`build_advanced_terrain.gd:1079`).
   - `MountainWest/East` blends height to `0.0m` at `|x| <= 75m` (`build_advanced_terrain.gd:1089`).
   - Both meshes touch at `y = 0.0m`, but lack pre-baked colliders, so vehicles fall between them if runtime generation lags.

### 1.5 Vehicle Climbing Mechanics (`DrivableCar` & `VehiclePhysicsHelper.cs`)
1. **`scenes/vehicles/DrivableCar.tscn`**:
   - `BodyCollision` (`BoxShape3D_im3ab`, lines 33–34, 5769–5771): Size `Vector3(1.65, 0.70, 2.5)`, position `Vector3(0, 0.95, -0.1)`. Bottom face is at `y = 0.60m`.
   - Direct wheels (`WheelFL`, `WheelFR`, `WheelBL`, `WheelBR`, lines 6697–6742):
     - `wheel_radius = 0.44m`
     - `wheel_friction_slip = 8.5`
     - `suspension_travel = 0.45m`
     - `suspension_stiffness = 22.0`
     - `suspension_max_force = 18000.0`
     - `damping_compression = 1.2`, `damping_relaxation = 1.8`
     - `suspension_rest_length`: Unspecified in `.tscn`, defaulting to Godot's `0.15m`.
     - Wheel attachment Y: `0.33m`. Ground contact: `0.33 - 0.15 - 0.44 = -0.26m`.
     - Bottom clearance: `0.60 - (-0.26) = 0.86m`.
   - All 4 wheels have `use_as_traction = true` (4x4 drive).
2. **`scripts/Vehicles/DrivableCar.gd`**:
   - `mass = 1450.0`, `center_of_mass = Vector3(0.0, -0.25, 0.0)`.
   - `max_engine_force = 16000.0`.
   - In `_handle_driving_input` (lines 135–158):
     - Forward force: `apply_central_force(forward_dir * 32000.0)`.
     - Low-speed momentum assist: `if speed_kmh < 45.0: linear_velocity += forward_dir * (22.0 * delta)`.
     - Incline multiplier: `hill_climb_mult = 2.8 + clampf(slope_pitch * 4.0, 0.0, 3.5)` (up to 6.3x).
     - Incline climbing force: `apply_central_force(forward_dir * (18000.0 * clampf(slope_pitch * 2.5, 0.8, 3.5)))` (up to 63,000 N).
     - Anti-dig lift: `apply_central_force(Vector3.UP * (mass * 9.8 * 0.40))` (5,684 N upwards).
     - Friction slip: `8.5` applied dynamically to all 4 wheels.
3. **`scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs`**:
   - Contains `CalculateInclineAssist(linearVelocity, forwardDir, slopeAngleDeg, baseForce)`.
   - Projects assist direction as `(forwardDir + Vector3.Up * 0.25f).Normalized()`.
   - **Grep confirmed `VehiclePhysicsHelper` is never called anywhere in `DrivableCar.gd` or any other script.**

### 1.6 Headless Test Scripts
- Existing scripts: `tools/test_mountain_physics.gd`, `tools/verify_mountain_climb_and_clarity.gd`, `tools/test_mountain_climb_and_clarity.gd`, `tools/diagnose_car_drive_to_mountain.gd`.
- Execution observation:
  - Scripts using `await RenderingServer.frame_post_draw` in a loop run at 1–2 FPS in headless software rendering mode on AMD Kabini hardware.
  - Scripts using `await process_frame` or `get_tree().physics_frame` execute in under 3 seconds without rendering stall.
  - `tools/test_mountain_physics.gd` completed with exit code 0, verifying that `MountainWest` and `ValleyFloor` acquire `CollisionShape3D` only after `_ready()` runs.

---

## 2. Logic Chain

```
Observation 1: CityCarZombieArena.tscn has 0 ConcavePolygonShape3D shapes; MountainWest_Physics & ValleyFloor_Physics are empty StaticBody3D nodes.
Observation 2: CityCarZombieArena.gd:_ensure_solid_terrain_collisions() calls create_trimesh_collision() during _ready().
  └──> Step 1: Terrain collisions do not exist on scene instantiate; they are dynamically computed at runtime.
  └──> Step 2: Any physics tick prior to _ready() completion causes rigid bodies to fall into the void, requiring the watchdog fall recovery.

Observation 3: HighwayAsphalt is at y = 0.0m; SidewalkLeft/Right is at y = 0.12m; DirtShoulder is at y = 0.0m; DirtPath is at y = 0.08m.
Observation 4: HighwayProps contains 8 ConcreteBarrierA static bodies at x = ±10.5m.
  └──> Step 3: Vehicles face a 12cm vertical step when crossing onto sidewalks, a 12cm drop to dirt shoulders, an 8cm lip to dirt paths, and physical concrete barriers at x = ±10.5m.

Observation 5: VehiclePhysicsHelper.cs has CalculateInclineAssist() but is never called in DrivableCar.gd.
Observation 6: DrivableCar.gd applies Vector3.UP * (mass * 9.8 * 0.40) on inclines.
Observation 7: sedan_real.glb front bumper extends 0.775m ahead of the front wheel axle.
Observation 8: build_advanced_terrain.gd halves mountain height along trail waves (final_h *= 0.50), creating steep ledges.
  └──> Step 4: The car struggles on steep mountain peaks because:
       (a) Vector3.UP lift reduces tire normal contact force on steep slopes, causing VehicleWheel3D rays to lose ground contact.
       (b) Front overhang collides with steep terrain before the front wheels make contact (bumper grounding).
       (c) Generator switchback ledges produce sudden slope discontinuities rather than continuous drivable ramps.
       (d) VehiclePhysicsHelper.cs slope-aligned crawl assist is inactive.

Observation 9: Headless test scripts that loop on RenderingServer.frame_post_draw stall at 1-2 FPS.
  └──> Step 5: Headless automated climbing tests must step physics frames (process_frame / physics_frame) rather than waiting on render draw calls.
```

---

## 3. Caveats

1. **Memory Budget**: The target environment has 3.3 GB of total system RAM. Parsing the 4.2 MB text `.tscn` file takes ~40–50 seconds on this CPU. Pre-baking collision shapes will increase `.tscn` file size unless compressed or saved as binary `.scn`, or cleanly formatted.
2. **GLTF Embedded Wheels**: `DrivableCar.tscn` contains imported GLTF wheel nodes (`generic_122`, etc.) that were assigned `VehicleWheel3D` types inside `CarMeshWrapper`. While only direct children are referenced in `DrivableCar.gd`, the implementer should verify whether Godot's internal VehicleBody3D physics server registers the internal nodes.
3. **No Direct Code Modifications Made**: Explorer 1 is read-only. All evidence was gathered via inspection, search, and headless script execution.

---

## 4. Conclusion

1. **Pre-baked Colliders**: No mountain or valley colliders are pre-baked in `CityCarZombieArena.tscn`. They are 100% generated at runtime in `CityCarZombieArena.gd:_ensure_solid_terrain_collisions()`. Pre-baking `ConcavePolygonShape3D` directly into the scene file will eliminate load delay and prevent falling through.
2. **Transition Lips & Barriers**: Vehicles are obstructed by:
   - 0.12m vertical lips between Highway (0.0m) and Sidewalk (+0.12m).
   - 0.12m drops between Sidewalk (+0.12m) and Dirt Shoulder (0.0m).
   - Concrete barriers (`Barrier_0`–`Barrier_7`) at x = ±10.5m.
   - Smoothing sidewalk heights to 0.0m or adding beveled transition ramps and clearing highway edge barriers will provide seamless off-road access.
3. **Vehicle Climbing Limitations**:
   - Upward lift (`Vector3.UP * 0.40 * gravity`) reduces tire normal force on slopes > 30°.
   - Front bumper overhang (0.775m ahead of axle) beaches on steep approach angles.
   - `VehiclePhysicsHelper.cs` is unused and should be integrated into `DrivableCar.gd`.
   - Mountain trail generator creates 50% height step ledges that must be smoothed into gradual grades.
4. **Headless Verification**: Headless tests must step physics via `get_tree().physics_frame` or `process_frame` without blocking on `RenderingServer.frame_post_draw`.

---

## 5. Verification Method

### 5.1 Inspect Pre-Baked Collision in Scene File
Verify with `grep_search`:
```bash
grep -n "ConcavePolygonShape3D" scenes/environments/CityCarZombieArena.tscn
```
*Current state*: 0 matches.  
*Pass condition after implementation*: Matches exist for `MountainWest`, `MountainEast`, `ValleyFloor`, `MountainRoad_West`, `MountainRoad_East`, `DirtPath_West`, `DirtPath_East`.

### 5.2 Verify Frame 0 Collision Without `_ready()` Generation
Run `tools/test_mountain_physics.gd`:
```bash
godot --headless -s tools/test_mountain_physics.gd
```
Verify that `CollisionShape3D` exists inside `MountainWest_Physics` and `ValleyFloor_Physics` immediately upon instantiation (before `_ready()` is called).

### 5.3 Automated Headless Mountain Climbing Test
Run `tools/verify_mountain_climb_and_clarity.gd`:
```bash
godot --headless -s tools/verify_mountain_climb_and_clarity.gd
```
Pass criteria:
- Car starts at highway/foothill (`x = -45m, y = 1.2m, z = -130m`).
- Drives West up the mountain slope (`x < -75m, y > 8.0m`).
- Moves distance > 15m up the incline without falling below `y = -10.0m` or flipping.
- Exits cleanly with code 0.
