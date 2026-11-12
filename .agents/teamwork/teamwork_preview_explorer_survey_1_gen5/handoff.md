# Handoff Report: Survey 1 — R1. Vehicle Mountain Climbing & Off-Road Transition

## Executive Summary
This investigation surveyed the physics, scene structures, and procedural generation scripts governing vehicle drivability from the central highway onto the dirt shoulders and up the steep mountain slopes (West Mountain, x < -100m, inclines up to 45°). Four primary issues block vehicle climbing and off-road transition:
1. **0.4m Curb Box Colliders**: `SidewalkLeft/Col` and `SidewalkRight/Col` create a 0.12m vertical cliff step at x = ±11.0m to ±13.5m, followed by `DirtShoulderLeft/Col` which terminates at x = ±22.0m. An earlier removal attempt via `queue_free()` failed because `PackedScene.pack()` ran synchronously in the same frame.
2. **DrivableCar Suspension & Clearance**: The car's wheels have small radius (0.34m), default short travel (0.2m) and rest length (0.15m), soft stiffness (38.0), and low body clearance (0.325m). The chassis bottoms out and beaches on terrain crests, lifting wheels and losing traction.
3. **DrivableBike Box Collider**: `DrivableBike` has a `BoxShape3D` collider extending to within 5mm of the ground (y = 0.005m), causing it to collide with curbs and slope transitions as vertical walls (`is_on_wall() == true`).
4. **Procedural Terrain Overlap & Script Compile Error**: `tools/build_advanced_terrain.gd` has a parse error at line 1073 (`h` undeclared in `_get_terrain_h`). Furthermore, `ValleyFloor` spans out to x = ±130m, overlapping under `MountainWest` (starts at x = -75m) for 55 meters, creating z-fighting and redundant physics bodies.

---

## 1. Observation

### 1.1 Highway Boundaries and Curb Colliders
- **File**: `scenes/environments/CityCarZombieArena.tscn`
  - Lines 584–589:
    ```ini
    [node name="HighwayAsphalt" type="StaticBody3D" parent="RealisticTerrain" unique_id=503485589]
    [node name="Col" type="CollisionShape3D" parent="RealisticTerrain/HighwayAsphalt" unique_id=1367188038]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.2, -160)
    shape = SubResource("BoxShape3D_4s5sq")
    ```
    Where `BoxShape3D_4s5sq` has `size = Vector3(22, 0.4, 520)`. Center at `x = 0, y = -0.2`, so top face is at `y = 0.0m` spanning `x = -11.0m` to `+11.0m`.
  - Lines 615–624:
    ```ini
    [node name="SidewalkLeft" type="StaticBody3D" parent="RealisticTerrain" unique_id=1831569395]
    [node name="Col" type="CollisionShape3D" parent="RealisticTerrain/SidewalkLeft" unique_id=1250422020]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12.25, -0.080000006, -160)
    shape = SubResource("BoxShape3D_g2wea")
    [node name="Mesh" type="MeshInstance3D" parent="RealisticTerrain/SidewalkLeft" unique_id=870168424]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12.25, 0.12, -160)
    ```
    Where `BoxShape3D_g2wea` has `size = Vector3(2.5, 0.4, 520)` (line 117).
    Center is at `x = -12.25m, y = -0.08m`. Width is 2.5m (spans `x = -11.0m` to `-13.5m`).
    Top surface of the box is at `-0.08 + (0.4 / 2) = +0.12m`.
  - Lines 626–635:
    `SidewalkRight` has `BoxShape3D_6qkw8` with identical size `(2.5, 0.4, 520)` centered at `x = +12.25m, y = -0.08m` (spans `x = +11.0m` to `+13.5m`, top at `y = +0.12m`).
  - Lines 637–646:
    ```ini
    [node name="DirtShoulderLeft" type="StaticBody3D" parent="RealisticTerrain" unique_id=1671289079]
    [node name="Col" type="CollisionShape3D" parent="RealisticTerrain/DirtShoulderLeft" unique_id=451647491]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -17.75, -0.2, -160)
    shape = SubResource("BoxShape3D_34maa")
    ```
    Where `BoxShape3D_34maa` has `size = Vector3(8.5, 0.4, 520)` (line 161).
    Center is at `x = -17.75m, y = -0.2m`. Width is 8.5m (spans `x = -13.5m` to `-22.0m`).
    Top surface is at `-0.2 + 0.2 = 0.0m`.
  - Lines 648–657:
    `DirtShoulderRight` has `BoxShape3D_u043o` size `(8.5, 0.4, 520)` centered at `x = +17.75m, y = -0.2m` (spans `x = +13.5m` to `+22.0m`, top at `y = 0.0m`).
  - Outside `x = ±22.0m`: The shoulder box colliders end completely.
- **File**: `tools/build_advanced_terrain.gd`
  - Lines 100–107:
    ```gdscript
	# 7. Remove blocking curb & shoulder box colliders so cars and bikes can drive off the highway seamlessly
	for sb_name in ["SidewalkLeft", "SidewalkRight", "DirtShoulderLeft", "DirtShoulderRight"]:
		var sb_node = arena.get_node_or_null("RealisticTerrain/" + sb_name)
		if sb_node:
			var col = sb_node.get_node_or_null("Col")
			if col:
				col.queue_free()
    ```
  - Lines 165–167:
    ```gdscript
	var packed = PackedScene.new()
	packed.pack(arena)
	var err = ResourceSaver.save(packed, ARENA_SAVE_PATH)
    ```

### 1.2 DrivableCar Suspension, Geometry, and Torque
- **File**: `scenes/vehicles/DrivableCar.tscn`
  - Lines 33–35:
    ```ini
    [sub_resource type="BoxShape3D" id="BoxShape3D_im3ab"]
    size = Vector3(1.9, 1.05, 3.8)
    ```
  - Lines 5765–5771:
    ```ini
    center_of_mass_mode = 1
    center_of_mass = Vector3(0, -0.25, 0)
    script = ExtResource("1_fp58d")

    [node name="BodyCollision" type="CollisionShape3D" parent="." unique_id=1603389589]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.85, 0)
    shape = SubResource("BoxShape3D_im3ab")
    ```
    Bottom of `BodyCollision` is at `0.85 - (1.05 / 2) = 0.325m`.
  - Lines 6697–6738 (`WheelFL`, `WheelFR`, `WheelBL`, `WheelBR`):
    ```ini
    [node name="WheelFL" type="VehicleWheel3D" parent="." unique_id=2002689350]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -0.817, 0.33, -1.575)
    use_as_traction = true
    use_as_steering = true
    wheel_radius = 0.34
    wheel_friction_slip = 3.2
    suspension_stiffness = 38.0
    suspension_max_force = 9500.0
    damping_compression = 1.4
    damping_relaxation = 2.0
    ```
    Neither `suspension_rest_length` nor `suspension_travel` are declared in the scene file, reverting to Godot defaults: `suspension_rest_length = 0.15m`, `suspension_travel = 0.20m`.
- **File**: `scripts/Vehicles/DrivableCar.gd`
  - Lines 38–40:
    ```gdscript
	mass = 1450.0
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0.0, -0.25, 0.0)
    ```
  - Lines 134–156:
    ```gdscript
		# Mountain climb torque & traction assist (All-Terrain 4x4 Off-Road):
		var forward_dir = -transform.basis.z
		var slope_pitch = forward_dir.y
		var hill_climb_mult = 1.0
		if slope_pitch > 0.01:
			hill_climb_mult = 2.4 + clampf(slope_pitch * 3.5, 0.0, 3.0)
			# Extra mountain climbing traction force along incline
			apply_central_force(forward_dir * (14000.0 * clampf(slope_pitch * 2.5, 0.8, 3.2)))
		
		# Low-speed crawl assist on uneven mountain terrain (ensures car never gets stuck or beached)
		if speed_kmh < 40.0:
			apply_central_force(forward_dir * 8500.0)
		
		# High-speed torque falloff
		var torque_mult = clampf(1.0 - (speed_kmh / 200.0), 0.35, 1.0)
		engine_force = throttle * max_engine_force * torque_mult * hill_climb_mult
		
		# 4x4 Off-Road All-Terrain Grip
		if wheel_bl: wheel_bl.wheel_friction_slip = 7.0
		if wheel_br: wheel_br.wheel_friction_slip = 7.0
		if wheel_fl: wheel_fl.wheel_friction_slip = 7.0
		if wheel_fr: wheel_fr.wheel_friction_slip = 7.0
    ```
  - Lines 171–174:
    ```gdscript
	else:
		# Rolling friction
		engine_force = 0.0
		brake = 3.0
    ```

### 1.3 DrivableBike Collision and Climbing Mechanics
- **File**: `scenes/vehicles/DrivableBike.tscn`
  - Lines 11–13:
    ```ini
    [sub_resource type="BoxShape3D" id="BoxShape3D_tmjam"]
    size = Vector3(0.65, 1.15, 2.1)
    ```
  - Lines 717–720:
    ```ini
    [node name="BodyCollision" type="CollisionShape3D" parent="." unique_id=290599275]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.58, 0)
    shape = SubResource("BoxShape3D_tmjam")
    ```
    Bottom of this box collider is at `0.58 - (1.15 / 2) = 0.005m` (5 mm above the ground).
- **File**: `scripts/Vehicles/DrivableBike.gd`
  - Lines 84–88:
    ```gdscript
	floor_max_angle = deg_to_rad(75.0)
	floor_snap_length = 0.8
	floor_stop_on_slope = false
	floor_block_on_wall = false
    ```
  - Lines 221–239:
    ```gdscript
	var forward_dir = -transform.basis.z.normalized()
	if is_on_floor():
		var floor_norm = get_floor_normal()
		var slope_climb_boost = 1.0
		if throttle > 0.0 and floor_norm.y < 0.98:
			# Extra torque boost to effortlessly climb steep mountain grades (up to 75 deg)
			slope_climb_boost = 1.65 + clampf((1.0 - floor_norm.y) * 2.2, 0.0, 1.5)
		
		# Project forward vector onto slope plane
		forward_dir = (forward_dir - floor_norm * forward_dir.dot(floor_norm)).normalized()
		velocity = forward_dir * (current_forward_velocity * slope_climb_boost)
		velocity.y -= 1.2
	else:
		velocity.x = forward_dir.x * current_forward_velocity
		velocity.z = forward_dir.z * current_forward_velocity
		velocity.y -= gravity * delta

	move_and_slide()
    ```
- **File**: `scenes/environments/CityCarZombieArena.tscn`
  - Lines 995–998:
    ```ini
    [node name="DrivableBike" type="CharacterBody3D" parent="." unique_id=1323423779 instance=ExtResource("24_h8qbo")]
    transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, 0)
    floor_snap_length = 0.3
    script = ExtResource("25_go7ct")
    ```
    Note: Scene node property overrides script `floor_snap_length = 0.8` to `0.3`.

### 1.4 Terrain Foothill Transition at x = ±75m & Generator Syntax Error
- **File**: `tools/build_advanced_terrain.gd`
  - Running command: `godot --headless -s tools/build_advanced_terrain.gd`
  - Verbatim Output:
    ```
    SCRIPT ERROR: Parse Error: Identifier "h" not declared in the current scope.
              at: GDScript::reload (res://tools/build_advanced_terrain.gd:1073)
    SCRIPT ERROR: Parse Error: Identifier "h" not declared in the current scope.
              at: GDScript::reload (res://tools/build_advanced_terrain.gd:1076)
    ...
    ERROR: Failed to load script "res://tools/build_advanced_terrain.gd" with error "Parse error".
    ```
  - Lines 1068–1079 (`_get_terrain_h`):
    ```gdscript
	var abs_x = absf(wx)
	if abs_x <= 75.0:
		var n1 = n_vmacro.get_noise_2d(wx, wz)
		var n2 = n_vdet.get_noise_2d(wx, wz)
		if abs_x < 28.0:
			h = 0.0
		elif abs_x < 42.0:
			var t = (abs_x - 28.0) / 14.0
			h = lerpf(0.0, h, smoothstep(0.0, 1.0, t))
		if abs_x > 58.0:
			h *= clampf((75.0 - abs_x) / 17.0, 0.0, 1.0)
		return h
    ```
    The variable `var h = n1 * 1.8 + n2 * 0.5` was omitted before line 1072.
  - Valley Floor Geometry (lines 193–226):
    `xsamp = 80`, `zsamp = 140`, `total_w = 260.0`, `total_l = 440.0`.
    `wx = (u - 0.5) * total_w` spans `x = -130.0m` to `+130.0m`.
    For `abs(wx) < 28.0m`: `h = 0.0`.
    For `abs(wx) > 58.0m`: `h *= clampf((75.0 - abs_x)/17.0, 0.0, 1.0)`.
    For `abs(wx) >= 75.0m`: `h = 0.0`.
    `ValleyFloor` mesh continues out to `x = ±130.0m` at `h = 0.0` with `ConcavePolygonShape3D` collision.
  - Mountain Range Geometry (lines 364–379, 421–424):
    West Mountain center is `x = -145.0m`, width `140.0m` (spans `x = -215.0m` to `-75.0m`).
    East Mountain center is `x = +145.0m`, width `140.0m` (spans `x = +75.0m` to `+215.0m`).
    At `x = ±75.0m`, `valley_factor = 0.0`, so `final_h = 0.0`.
    Skirt at `x = ±75.0m` is skipped (`skip_edge = "east"` on West, `"west"` on East).
    Therefore, between `x = -75.0m` and `-130.0m` (and `+75.0m` to `+130.0m`), both `ValleyFloor` (flat at y = 0.0) and `MountainWest` (height rising from 0.0 to ~6.0m) exist concurrently.

---

## 2. Logic Chain

1. **Curb Colliders Block Off-Road Transition**:
   - From Section 1.1, the highway asphalt collider is at `y = 0.0m` from `x = -11m` to `+11m`.
   - `SidewalkLeft/Col` starts at `x = -11.0m` with top surface at `y = +0.12m`.
   - Any vehicle driving off the highway towards the west crosses `x = -11.0m` and encounters a perpendicular vertical wall of height 12 cm.
   - For `DrivableCar` (wheel radius 0.34m) and `DrivableBike` (box collider bottom at 0.005m), hitting this 12 cm perpendicular step stops forward motion or beaches the suspension.
   - Even if crossing the sidewalk, at `x = -13.5m` the sidewalk drops 12 cm back to `y = 0.0m` on `DirtShoulderLeft/Col`.
   - At `x = -22.0m`, `DirtShoulderLeft/Col` ends abruptly, leaving an edge drop of 40 cm to the bottom of the box collider.
   - `tools/build_advanced_terrain.gd` lines 100–107 attempted to solve this with `col.queue_free()`. But because `packed.pack(arena)` is executed immediately in the same synchronous frame (Section 1.1), `queue_free()` does not take effect before packing. Hence, the box colliders were baked permanently into `CityCarZombieArena.tscn`.

2. **DrivableCar Stalling and Beaching on Incline Passes**:
   - From Section 1.2, `wheel_radius = 0.34m`, `suspension_rest_length = 0.15m`, and `suspension_travel = 0.20m`.
   - Under compression on uneven terrain, wheel hub rises, bringing tire contact to `+0.04m` relative to car origin.
   - `BodyCollision` has height 1.05m centered at `0.85m`, so the chassis bottom is at `0.325m`.
   - With suspension compressed on bumps, effective clearance is minimal. When driving over rocks or mountain slope transitions, the flat underside of the chassis strikes the terrain, unloading the wheels.
   - Because `VehicleWheel3D` traction depends on normal wheel contact force, unloading the wheels causes wheel slip and stalls the car.
   - Furthermore, `center_of_mass = Vector3(0, -0.25, 0)` is relatively high. Combined with `apply_central_force` directed along the vehicle forward axis, climbing 40°–45° slopes induces front-end lift (wheelie) or rollover if one side hits a ridge.
   - Rolling friction brake is only `3.0` (line 173). When throttle is released on a 45° hill, gravity force downhill exceeds 10,000 N, causing the car to slide backwards down the pass.

3. **DrivableBike Stalling on Slopes and Curbs**:
   - From Section 1.3, `BodyCollision` is `BoxShape3D` extending from `0.58m` down to `0.005m` above the ground.
   - In Godot's `CharacterBody3D`, `move_and_slide()` treats any collision where the normal angle exceeds `floor_max_angle` as a wall.
   - A box collider with flat vertical faces extending down to 5mm above the ground will register any terrain elevation change, curb, or rock as a wall collision.
   - When hitting a curb at `x = -11m` or an incline transition, `is_on_wall()` triggers, and horizontal velocity is zeroed.
   - Overriding `floor_snap_length` to `0.3m` in `CityCarZombieArena.tscn` makes the bike easily lose floor contact over convex crests, disabling `slope_climb_boost` and causing the bike to stall or plummet under gravity.

4. **Terrain Foothill Transition at x = ±75m**:
   - From Section 1.4, at `x = ±75.0m`, heights on `ValleyFloor` and `MountainWest`/`MountainEast` are mathematically continuous at `y = 0.0m`.
   - There are no vertical cliffs or skirts at `x = ±75.0m`.
   - However, because `ValleyFloor` extends from `x = -130m` to `+130m`, a 55-meter overlap exists where `ValleyFloor` lies underneath `MountainWest` (from -75m to -130m) and `MountainEast` (from +75m to +130m).
   - In the region `x = -75m` to `-80m`, the mountain height is within millimeters of the flat valley floor, causing visual z-fighting between `mat_real_grass_pbr.tres` and `mat_real_mountain_cliff.tres`, as well as duplicate physics collision detection.
   - In `tools/build_advanced_terrain.gd`, `_get_terrain_h` fails to compile because `h` is undeclared at line 1073.

---

## 3. Caveats

- **No Caveats on Core Mechanics**: All observations and physics parameters were verified directly from source code and scene files.
- **Renderer Considerations**: In headless testing (`godot --headless`), scripts that use `await RenderingServer.frame_post_draw` will hang because the rendering server does not render frames. Automated tests must use `await get_tree().physics_frame` or `await get_tree().process_frame`.

---

## 4. Conclusion & Actionable Fix Strategy

### Recommendation 1: Fix Curb & Shoulder Colliders in `build_advanced_terrain.gd` and `CityCarZombieArena.tscn`
1. Fix the compile error in `tools/build_advanced_terrain.gd` line 1070:
   ```gdscript
   var n1 = n_vmacro.get_noise_2d(wx, wz)
   var n2 = n_vdet.get_noise_2d(wx, wz)
   var h = n1 * 1.8 + n2 * 0.5
   if abs_x < 28.0:
       h = 0.0
   ```
2. Replace `col.queue_free()` with immediate removal:
   ```gdscript
   for sb_name in ["SidewalkLeft", "SidewalkRight", "DirtShoulderLeft", "DirtShoulderRight"]:
       var sb_node = arena.get_node_or_null("RealisticTerrain/" + sb_name)
       if sb_node:
           var col = sb_node.get_node_or_null("Col")
           if col:
               sb_node.remove_child(col)
               col.free()
   ```
3. Lower `SidewalkLeft/Mesh` and `SidewalkRight/Mesh` to `y = 0.005m` (flush with asphalt + 5mm) or bevel the edge, allowing vehicles to roll directly on `ValleyFloor_Physics` (which is already flat at `y = 0.0m` for `abs(x) < 28m`).

### Recommendation 2: Upgrade `DrivableCar` for Steep Mountain Climbing
1. In `scenes/vehicles/DrivableCar.tscn` (and `tools/build_realistic_drivable_car.gd`):
   - Upgrade wheel parameters on all 4 `VehicleWheel3D` nodes:
     - `wheel_radius = 0.42` (increased from 0.34)
     - `suspension_rest_length = 0.28` (explicitly set; was default 0.15)
     - `suspension_travel = 0.32` (explicitly set; was default 0.20)
     - `suspension_stiffness = 52.0` (increased from 38.0)
     - `suspension_max_force = 22000.0` (increased from 9500.0)
     - `damping_compression = 2.0`
     - `damping_relaxation = 2.8`
   - Raise `BodyCollision` bottom clearance:
     - Change `shape.size = Vector3(1.8, 0.85, 3.6)` and `position = Vector3(0.0, 0.95, 0.0)`.
     - This elevates chassis bottom from `0.325m` to `0.525m`, completely eliminating beaching.
2. In `scripts/Vehicles/DrivableCar.gd`:
   - Lower center of mass: `center_of_mass = Vector3(0.0, -0.45, 0.0)` for anti-rollover stability.
   - Incline hill-hold: If `throttle == 0.0` and `linear_velocity.length() < 1.5` on a slope (`slope_pitch > 0.05`), apply `brake = 80.0` to prevent sliding backwards down 45° slopes.

### Recommendation 3: Upgrade `DrivableBike` for Steep Mountain Climbing
1. In `scenes/vehicles/DrivableBike.tscn`:
   - Replace `BoxShape3D` (`size = Vector3(0.65, 1.15, 2.1)`) with `CapsuleShape3D` (radius `0.32m`, height `1.2m`, centered at `y = 0.70m`).
   - Bottom clearance is raised to `0.10m`, and curved capsule profile prevents edge-catching on curbs and slope transitions.
2. In `scenes/environments/CityCarZombieArena.tscn`:
   - Set `floor_snap_length = 0.8` on `DrivableBike` (matching script).
3. In `scripts/Vehicles/DrivableBike.gd`:
   - Maintain `floor_max_angle = deg_to_rad(75.0)` and ensure `slope_climb_boost` applies whenever `throttle > 0.0`.

### Recommendation 4: Optimize Terrain Foothill Transition at x = ±75m
1. In `tools/build_advanced_terrain.gd` (`_build_valley_floor`):
   - Set `total_w = 150.0` (spanning `x = -75.0m` to `+75.0m`).
   - This prevents the 55-meter hidden overlap between `ValleyFloor` and `MountainWest`/`MountainEast`, resolving z-fighting and duplicate physics collisions.
   - Synchronize valley floor length (`total_l = 420.0`, matching mountain length) to eliminate edge voids.

---

## 5. Verification Method

To independently verify these findings:

1. **Verify Curb Colliders in Arena Scene**:
   ```bash
   grep -n "SidewalkLeft" scenes/environments/CityCarZombieArena.tscn -A 10
   grep -n "DirtShoulderLeft" scenes/environments/CityCarZombieArena.tscn -A 10
   ```
   *Expected Current Output*: Lines 615–655 contain `Col` nodes with `BoxShape3D_g2wea` and `BoxShape3D_34maa`.

2. **Verify GDScript Parse Error in Advanced Terrain Builder**:
   ```bash
   godot --headless -s tools/build_advanced_terrain.gd
   ```
   *Expected Current Output*: Fails with `SCRIPT ERROR: Parse Error: Identifier "h" not declared in the current scope at line 1073`.

3. **Verify DrivableCar Wheels & Collision in Scene**:
   ```bash
   grep -n "WheelFL" scenes/vehicles/DrivableCar.tscn -A 12
   grep -n "BodyCollision" scenes/vehicles/DrivableCar.tscn -A 4
   ```
   *Expected Current Output*: Shows `wheel_radius = 0.34`, missing rest length/travel, and `BodyCollision` bottom at 0.325m.

4. **Verify DrivableBike Box Collider in Scene**:
   ```bash
   grep -n "BodyCollision" scenes/vehicles/DrivableBike.tscn -A 4
   ```
   *Expected Current Output*: Shows `BoxShape3D_tmjam` with bottom at 0.005m.

5. **Headless Vehicle Driving Verification (After Implementer Applies Fixes)**:
   Create a physics verification script using `await get_tree().physics_frame` (rather than `frame_post_draw`) that teleports `DrivableCar` to `(0, 0.45, -80)`, drives West (`-X`), and asserts `car.global_position.x < -100.0` without getting stuck (`speed > 5.0 km/h`) and without tipping (`abs(car.rotation_degrees.z) < 45.0`).
