# Requirement 2 Codebase Survey: Soldier Superbike Physics & Riding Posture

## 1. Observation

### 1.1 Superbike Architecture & Handling
- **File**: `/home/am/targetkill/scripts/Vehicles/DrivableBike.gd` (702 lines)
- **Scene**: `/home/am/targetkill/scenes/vehicles/DrivableBike.tscn` (1,048 lines)
- **Class**: `class_name DrivableBike extends CharacterBody3D` (line 1-2).
- **Physics implementation**:
  - The superbike uses `CharacterBody3D` with custom velocity integration rather than `VehicleBody3D` or raycast suspension:
    - Collision shape: `BoxShape3D(0.65, 1.15, 2.1)` at `(0, 0.58, 0)` in `scenes/vehicles/DrivableBike.tscn` lines 717-720.
    - Floor snap: `floor_snap_length = 0.3` (line 714).
    - Top speed: `210.0 km/h` (~58.33 m/s), reverse speed: `25.0 km/h` (lines 10-11).
    - Acceleration: `32.0 m/s^2` forward pull with torque curve `clampf(1.0 - (current_forward_velocity / max_fwd_ms) * 0.4, 0.28, 1.0)` (lines 173-175).
    - Braking: `38.0 m/s^2` front/rear disc brake, `48.0 m/s^2` rear handbrake drift (lines 13-14, 169-182).
    - Dynamic 2-wheel lean: `visual_wrapper.rotation.z` lerps smoothly towards `-current_steer_input * deg_to_rad(34.0) * speed_lean_ratio` (lines 195-205).
    - Steer fork: `fork_steer_node.rotation.y` smoothly steers front fork node `bone_wheel_F_steer` up to `22.0` degrees (lines 234-239).
    - Wheel spin: `Wheel_F` and `Wheel_B` rotate along X proportionally to `current_forward_velocity` (lines 240-246).
    - Engine audio: `EngineAudio` (`AudioStreamPlayer3D` with `res://audio/vehicles/engine.wav`) modulates pitch from `0.88` at idle to `2.35` at top speed, with a `+0.25` RPM rev surge during handbrake skid (lines 282-294).
    - Roadkill mechanics: `SmashZone` Area3D executes `_execute_roadkill()` at speeds > `12.0 km/h`, dealing `speed_kmh * 42.0` damage, spawning blood particles, playing impact audio, and adding killfeed entry (lines 474-518).
- **Physics Deficiencies Observed**:
  - **Slope / Terrain Pitch Missing**: In lines 214-224, `velocity.y` is set to `-0.5` on floor or `-gravity * delta` in air, and horizontal velocity is projected onto `-transform.basis.z`. There is no normal projection or body pitch alignment to the terrain surface. On highway slopes, ramps, or mountain terrain, the bike remains horizontally level rather than pitching with the incline.
  - **Headlight Initialization State**: Line 38 has `headlight_state: int = 0` (Off), but line 99-100 comments "Setup initial headlight state (Low beam active)" without setting `headlight_state = 1`. This causes `tools/test_drivable_bike.gd` assertion failure:
    `SCRIPT ERROR: Assertion failed: Initial state should be 1 (Low Beam)` at `_init` (res://tools/test_drivable_bike.gd:66).

### 1.2 Mounting & Dismounting Mechanics
- **Interaction Logic**:
  - Proximity detection: `mount_distance = 6.5m`, monitored in `_check_nearby_player_proximity()` (lines 267-281) and via `MountZone` Area3D (lines 457-470).
  - UI Prompt: `EnterPromptUI` displays `"PRESS [F] TO RIDE HAYABUSA SUPERBIKE"` (line 276, 463).
  - Key capture: In `_input(event)` (lines 435-445):
    ```gdscript
    var is_f_key = event.keycode in [KEY_F, KEY_ENTER] or event.physical_keycode in [KEY_F, KEY_ENTER]
    ```
  - State changes on Mount (`enter_vehicle()` lines 319-361):
    - `is_occupied = true`, `player_ref = player`
    - `rider_soldier.visible = true`
    - `player_ref.visible = false`
    - `player_ref.process_mode = Node.PROCESS_MODE_DISABLED`
    - `player_ref.collision_layer = 0`, `player_ref.collision_mask = 0`
    - `chase_camera.current = true`, `drive_hud.visible = true`
  - State changes on Dismount (`exit_vehicle()` lines 362-405):
    - `is_occupied = false`
    - `rider_soldier.visible = false`
    - Player positioned safely on bike's left: `var exit_pos = global_position + (-transform.basis.x * 1.5) + Vector3(0, 0.25, 0)`
    - `player_ref.global_position = exit_pos`, `player_ref.visible = true`, `player_ref.process_mode = PROCESS_MODE_INHERIT`
    - `player_ref.collision_layer = saved_player_layer`, `player_ref.collision_mask = saved_player_mask`
    - Camera restored to `player_cam.current = true`, `drive_hud.visible = false`
- **Mount/Dismount Deficiencies Observed**:
  - **Player World Position Desynchronization During Ride**: While mounted, `player_ref.global_position` is NEVER updated during `_physics_process`. `player_ref` remains frozen at the coordinate where the player originally entered the bike.
    - Consequence 1 (`scripts/Zombies/EnemyBase.gd` line 28, 35): AI zombies compute distance to `player.global_position` and chase the empty mount spot instead of attacking the rider.
    - Consequence 2 (`scripts/UI/GTAMinimap.gd` lines 49, 70, 124): The minimap centers its radar grid on `player.global_position`. Because the player is stationary at the mount spot, the minimap radar does not scroll with the bike across the city highway!

### 1.3 Soldier Model Riding Posture & Handlebars
- **Rider Soldier Setup**:
  - Model: Instantiates `scenes/characters/RealSoldier.scn` / `.tscn` (1.0 scale, 1.83m tall, Mixamo 65-bone skeleton).
  - Rifle attachment: Diagonal back sling via `BoneAttachment3D` on `mixamorig_Spine2` (`scenes/weapons/models/akx_scifi.scn`) (lines 563-576).
  - Animation: Plays `BikeRiding` from `RealSoldier.tscn` (authored by `tools/build_bike_riding_anim.gd`).
- **Measurements from Headless Diagnostic Execution (`inspect_rider_alignment.gd` & `find_geometry_points.gd`)**:
  - **Bike Contact Targets (Local to Bike)**:
    - Handlebar Steer Fork node `bone_wheel_F_steer`: `(-0.0, 0.891, -0.434)`
    - Left Handlebar Clip-on Grip: `(0.22, 0.88, -0.38)`
    - Right Handlebar Clip-on Grip: `(-0.22, 0.88, -0.38)`
    - Seat Cushion Center: `(0.00, 0.64, -0.05)`
    - Left Footpeg: `(0.20, 0.38, 0.08)`
    - Right Footpeg: `(-0.20, 0.38, 0.08)`
  - **Current Soldier Bone Positions (Local to Bike)**:
    - Root offset in code: `rider_soldier.position = Vector3(0.0, 0.44, -0.16)` (line 536).
    - Hips bone (`mixamorig_Hips`): `(-0.002, 1.501, -0.171)`
    - Left Hand bone (`mixamorig_LeftHand`): `(0.317, 1.833, -0.078)`
    - Right Hand bone (`mixamorig_RightHand`): `(-0.323, 1.833, -0.079)`
    - Left Foot bone (`mixamorig_LeftFoot`): `(0.054, 1.536, -0.521)`
    - Right Foot bone (`mixamorig_RightFoot`): `(-0.061, 1.533, -0.512)`
- **Severe Posture Gaps Observed**:
  1. **Floating In The Air (86 cm above seat)**:
     - Hips are at `Y = 1.501m`, whereas the bike seat is at `Y = 0.64m`. The soldier floats 86 cm in the air above the bike.
     - Cause: In `RealSoldier.tscn`, the `Character` node has scale 0.01 and -90° rotation, putting the rest Hips at `Y = 1.061m`. Adding `rider_soldier.position.y = 0.44m` resulted in `1.061 + 0.44 = 1.501m`.
  2. **Hands Floating ~1 Meter Above Handlebars**:
     - LeftHand Y is `1.833m`, Handlebar Grip Y is `0.880m` (Gap: `+0.953m` / nearly 1 meter too high, and `+0.30m` too far back).
     - Cause: Hardcoded Euler rotations in `build_bike_riding_anim.gd` (`-25°, -40°, 45°` on LeftArm) did not reach down to the bike's low clip-on handlebars.
  3. **Feet Floating at Chest Level**:
     - Feet are at `Y = 1.536m` (higher than the hips!), while footpegs are at `Y = 0.38m`.
     - Cause: In `build_bike_riding_anim.gd`, `mixamorig_LeftUpLeg` was set to rotation `-68°` around X, which in Mixamo rig space rotates thighs upward into the chest.
  4. **Kinematic Reachability Verified (`test_reachability.gd`)**:
     - When `rider_soldier.position` is shifted to `Vector3(0.0, -0.42, -0.04)` and Spine is tucked forward by 45°:
       - Hips sit directly on seat at `(0.0, 0.64, -0.05)`.
       - Left Shoulder is at `(0.205, 0.834, -0.414)` -> only **5.8 cm** from the left grip target `(0.22, 0.88, -0.38)`.
       - Right Shoulder is at `(-0.212, 0.833, -0.415)` -> only **5.8 cm** from the right grip target `(-0.22, 0.88, -0.38)`.
       - Left Hip is at `(0.095, 0.618, -0.003)` -> **27.3 cm** from the footpeg `(0.20, 0.38, 0.08)`, giving a natural 85° tucked sportbike knee bend.

### 1.4 Third-Person Chase Camera Follow
- **File**: `scenes/vehicles/DrivableBike.tscn` (lines 927-935)
- **Node Setup**:
  - `SpringArm3D` (position `(0, 1.35, 0)`, rotation `Vector3(10°, 0, 0)`, length `3.8m`, margin `0.25m`, collision mask `1`).
  - `ChaseCamera` (Camera3D) as direct child of `SpringArm3D`.
  - Dynamic FOV: Lerps between `72.0°` and `86.0°` based on speed ratio (`delta * 3.5`).
  - High-speed rumble: Adds random offset to `h_offset` and `v_offset` when `current_speed_kmh > 85.0`.
  - Manual orbit: Mouse motion and touch drag in `_unhandled_input` rotate `spring_arm.rotation.y` and `spring_arm.rotation.x`.
- **Camera Deficiencies Observed**:
  - **No Angular / Yaw Damping (Rigid Snapping)**:
    - Because `SpringArm3D` is a direct child of `DrivableBike`, any yaw rotation of the bike immediately rotates the camera without smoothing or trailing lag. In GTA 5 / PUBG, third-person vehicle cameras employ yaw damping (smooth trailing follow) that absorbs quick twitch corrections and provides a cinematic driving feel.
  - **No Look-Ahead Offset**:
    - The camera target point remains statically locked at `(0, 1.35, 0)`. It does not lead into the turn when steering or shift slightly forward/backward based on velocity.
  - **No Auto-Centering Recovery**:
    - If the user moves the mouse to inspect the side or rear of the bike, `spring_arm.rotation.y` stays permanently offset. Driving forward does not auto-recenter the camera back to rear chase view.
  - **No Vertical Pitch Compensation on Collision Compression**:
    - When `SpringArm3D` shortens due to obstacle collision behind the bike, the camera pushes directly into the back of the rider's neck/helmet instead of angling slightly upward to preserve visibility.

---

## 2. Logic Chain

1. **Premise 1 (Physics & Driving)**: The superbike script `DrivableBike.gd` uses `CharacterBody3D`, which is the optimal architectural choice for 2-wheel vehicles in Godot 4 (avoiding the notorious instability and tipping glitches of `VehicleBody3D`). It already implements torque curves, lean, fork steer, wheel spin, drift, and engine pitch. However, because it lacks surface normal detection, the vehicle does not pitch on highway inclines. Adding a ground raycast or `get_floor_normal()` projection to smoothly align the bike's pitch/roll to the terrain normal will produce realistic slope traversal.
2. **Premise 2 (Mount/Dismount & Gameplay Integrity)**: The mount/dismount sequence functionally toggles visibility, collision, cameras, HUD, and audio. However, leaving `player_ref.global_position` frozen at the original mount spot breaks core open-world systems (enemy AI navigation targeting and GTA minimap radar tracking). Continuously syncing `player_ref.global_position = global_position` while `is_occupied` is true solves both issues cleanly without side effects.
3. **Premise 3 (Riding Posture & Geometry)**:
   - Diagnostic script execution established that the Hayabusa model's seat is at `Y = 0.64m`, clip-on grips at `Y = 0.88m, Z = -0.38m, X = ±0.22m`, and footpegs at `Y = 0.38m, Z = 0.08m, X = ±0.20m`.
   - The current soldier model floats 86 cm above the seat and the hands float 95 cm above the handlebars because of:
     a) Incorrect root translation: `rider_soldier.position = Vector3(0.0, 0.44, -0.16)` instead of `Vector3(0.0, -0.42, -0.04)`.
     b) Guessed Euler rotations in `build_bike_riding_anim.gd` that rotated the thighs up into the chest and left arms high.
   - Adjusting the root position to `(0.0, -0.42, -0.04)` places the shoulders within **5.8 cm** of the clip-on grips and the hips within **27 cm** of the footpegs.
   - Regenerating the `BikeRiding` animation with precisely solved bone rotations for spine tuck, arms forward-reach, and tucked leg flexion (or adding TwoBoneIK / procedural bone pose overrides in `_physics_process`) will guarantee that both hands sit firmly on the handlebars and both feet rest on the footpegs.
   - Coupling the rider's torso/hand yaw to `fork_steer_node.rotation.y` will ensure the hands follow handlebar steering dynamically.
4. **Premise 4 (Chase Camera)**:
   - To achieve the requested "clean third-person chase camera follow", `SpringArm3D` needs decoupling from rigid yaw rotation:
     a) Implementing smooth yaw follow damping (e.g. `lerp_angle(camera_yaw, bike_yaw, delta * follow_speed)`).
     b) Adding a look-ahead offset in the direction of velocity/steering.
     c) Adding auto-centering timer: after 1.5 seconds of forward throttle without mouse motion, smoothly lerp `spring_arm.rotation.y` back to 0.

---

## 3. Caveats

1. **`RealSoldier.scn` vs `RealSoldier.tscn`**:
   - Both `.scn` (binary) and `.tscn` (text) exist in `scenes/characters/`. `DrivableBike.gd` line 525 attempts to load `.scn` first, falling back to `.tscn`. Any animation or skeleton update made to `RealSoldier.tscn` must also be re-saved to `RealSoldier.scn` (or `DrivableBike.gd` should consistently load `RealSoldier.tscn`) to avoid loading stale binary scene data.
2. **Mixamo Bone Coordinate Conventions**:
   - In `RealSoldier.tscn`, `Character` has a transform with `-90°` pitch (`Basis(Vector3(0.01, 0, 0), Vector3(0, 0, 0.01), Vector3(0, -0.01, 0))`). All bone rotations in animations must be calculated with this coordinate mapping in mind.
3. **Headless Execution Environment**:
   - Headless Godot runs with dummy physics and rendering servers (`RendererDummy`). Window and rendering tests run cleanly via `godot --headless`, but visual verification of camera lag and posture aesthetics requires rendering or screenshot capture.
4. **Android Export & Low-End Target**:
   - Complex multi-bone IK solvers running every frame on CPU can consume cycles on the target AMD Kabini / mobile device. An authored, baked `BikeRiding` animation library track with exact bone rotations is practically zero-cost on CPU compared to real-time CCDIK/FABRIK solvers, making it the most performant and stable solution.

---

## 4. Conclusion

Requirement 2 (Soldier Superbike Physics & Riding Posture) has a solid foundational implementation in `DrivableBike.gd` and `DrivableBike.tscn`, but has four concrete gaps that currently prevent it from satisfying the acceptance criteria:

| Component | Current State | Root Cause | Recommended Fix |
|---|---|---|---|
| **Rider Seat Position** | Soldier floats 86 cm in the air above bike seat (`Y = 1.50m` vs `0.64m`) | `rider_soldier.position` set to `Vector3(0.0, 0.44, -0.16)` in `DrivableBike.gd:536`, compounding Mixamo rest hips height (`1.06m`) | Change `rider_soldier.position` to `Vector3(0.0, -0.42, -0.04)` so hips align exactly with seat surface |
| **Handlebar Grip Posture** | Hands float 95 cm above and 30 cm behind handlebars; feet float at chest height | Hardcoded guess rotations in `tools/build_bike_riding_anim.gd` rotated thighs upward and arms backward | Update `build_bike_riding_anim.gd` with exact forward arm reach (`dist = 5.8cm` from shoulder to grip) and footpeg flexion, then re-bake `BikeRiding` anim |
| **Mount/Dismount Player Sync** | `player_ref.global_position` is frozen at initial mount spot during ride | `DrivableBike.gd` hides player but does not sync its position while riding | Add `player_ref.global_position = global_position` in `_handle_riding_physics()` so Minimap radar and zombie AI follow the bike |
| **Headlight State Assertion** | `headlight_state = 0` (Off) on spawn, causing test assertion failure in `tools/test_drivable_bike.gd` | Line 38 has `headlight_state = 0`, but `_apply_headlight_state()` was expected to start at 1 (Low Beam) | Initialize `headlight_state = 1` or explicitly set it in `_ready()` and `enter_vehicle()` |
| **Chase Camera Follow** | Rigid yaw follow, camera snaps instantly with bike; no auto-recenter; no look-ahead | `SpringArm3D` is direct child of `DrivableBike` without angular damping | Implement smooth yaw damping (`lerp_angle`), velocity look-ahead offset, and auto-centering on forward throttle |
| **Bike Slope Pitching** | Bike remains horizontally level on hills, ramps, and slopes | `DrivableBike.gd` sets constant `velocity.y = -0.5` without terrain normal alignment | Cast ground ray or use `get_floor_normal()` to smoothly pitch bike transform basis to match terrain slope |

---

## 5. Verification Method

### 5.1 Independent Headless Test Commands
1. **Rider Contact Points and Alignment Test**:
   ```bash
   cd /home/am/targetkill
   godot --headless -s .agents/teamwork/teamwork_preview_explorer_survey_2/inspect_rider_alignment.gd
   ```
   *Expected result*: Confirms whether LeftHand and RightHand are within 0.05m of handlebar grips, hips within 0.05m of seat cushion, and feet within 0.05m of footpegs.

2. **DrivableBike Comprehensive Unit Test Suite**:
   ```bash
   cd /home/am/targetkill
   godot --headless -s tools/test_drivable_bike.gd
   ```
   *Expected result*: Verifies scene instantiation, node hierarchy, headlight cycling, mount/dismount lifecycle, dynamic lean, and zombie roadkill gore execution with exit code 0.

3. **Bike Rider Lifecycle & Mounting Test**:
   ```bash
   cd /home/am/targetkill
   godot --headless -s tools/test_bike_rider_load.gd
   ```
   *Expected result*: Exits with code 0 and logs `ALL BIKE RIDER LOGIC VERIFIED SUCCESSFULLY!`.

4. **Full Open-World Arena Scene Loading Validation**:
   ```bash
   cd /home/am/targetkill
   godot --headless -s scenes/test/TestRunner.gd
   ```
   *Expected result*: Scene `scenes/environments/CityCarZombieArena.tscn` loads with exit code 0 and 0 fatal script errors.

### 5.2 Files to Inspect
- `/home/am/targetkill/scripts/Vehicles/DrivableBike.gd` (Lines 10-23, 195-209, 319-405, 522-576, 668-681)
- `/home/am/targetkill/scenes/vehicles/DrivableBike.tscn` (Lines 713-725, 927-935)
- `/home/am/targetkill/tools/build_bike_riding_anim.gd` (Lines 30-64)
- `/home/am/targetkill/scenes/characters/RealSoldier.tscn` (Lines 244-373, 2306-2328)
- `/home/am/targetkill/scripts/UI/GTAMinimap.gd` (Lines 70-75, 119-131)
- `/home/am/targetkill/scenes/environments/CityCarZombieArena.gd` (Lines 114-117)
