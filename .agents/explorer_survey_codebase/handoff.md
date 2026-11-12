# Codebase Architecture Survey Report: Sector Zero: Lockdown

## 1. Observation

Direct code examination of the Godot 4 project in `/home/am/targetkill` revealed the exact structural components, scripts, scene nodes, and resource definitions for all core game loops:

### A. Player & Viewmodel Subsystem
- **Scene File**: `scenes/player/Player.tscn`
  - Root: `CharacterBody3D` (Line 83, `groups=["player"]`, `collision_layer = 1`, `script = ExtResource("1_x8q2u")` -> `res://scenes/player/Player.gd`).
  - Collision: `CollisionShape3D` (Lines 87-89, `CapsuleShape3D` with `radius = 0.4`, `height = 1.8`, `transform = Transform3D(..., 0, 0.9, 0)`).
  - Body Mesh: `PlayerBody/MeshInstance3D` (Lines 91-96, `player_soldier.obj` overridden in `Player.gd` `_init_character_models()` at lines 121-130 with `res://assets/3d/characters/player_soldier.glb` and `cast_shadow = SHADOW_CASTING_SETTING_SHADOWS_ONLY`).
  - Camera & Rig: `Camera3D` at `(0, 1.65, 0)` with `fov = 72.0` (Lines 102-105).
    - `FPSArms`: `Node3D` at `(0.18, -0.18, -0.42)` (Lines 107-108). In `Player.gd` `_init_character_models()` (lines 131-143), instantiates `res://scenes/weapons/models/fps_arms.tscn` as child `CombatArmsModel` at local position `Vector3(-0.18, 0.03, 0.07)`.
    - `WeaponManager`: `Node3D` at `(0.18, -0.18, -0.42)` (Lines 114-116), matching `FPSArms` transform. Parent container for instantiated weapons.
    - `RayCast3D`: `target_position = Vector3(0, 0, -100)`, `collision_mask = 2` (Lines 117-120).
    - `ViewmodelLight`: `OmniLight3D` at `(0.15, -0.1, -0.35)`, color `Color(1, 0.96, 0.92)`, energy `0.45`, range `2.5m` (Lines 121-126).
    - `FrontFillLight`: `OmniLight3D` at `(0, 0, -0.5)`, color `Color(0.88, 0.92, 1)`, energy `0.3`, range `14.0m` (Lines 128-133).
- **Aiming & Rotation Logic** (`scenes/player/Player.gd`):
  - `rotate_camera(rot_x, rot_y)` (Lines 248-260):
    - Yaw rotation: `rotate_y(deg_to_rad(-rot_x * sensitivity))` provides unlimited 360-degree horizontal rotation.
    - Pitch rotation: `camera.rotate_x(deg_to_rad(rot_y * pitch_mult * sensitivity))`, clamped strictly between `min_pitch = -65.0` and `max_pitch = 65.0`.
    - Weapon & Arms Sway: `sway = deg_to_rad(-rot_x * sensitivity * sway_amount)`; `weapon_manager.rotation.y = lerp(weapon_manager.rotation.y, sway, 0.15)`; `fps_arms.rotation.y = lerp(fps_arms.rotation.y, sway, 0.15)`.
  - Auto-Aim Magnetism (`auto_aim(delta)`, Lines 353-378): scans nodes in `"zombie"`, checks `dot > 0.96` against camera forward vector `-camera.global_transform.basis.z`, and interpolates rotation via `current_transform.interpolate_with(target_transform, 5.0 * delta)`.
  - Stationary Boundary Clamping: `global_position.x = clamp(global_position.x, -move_limit, move_limit)` and `global_position.z = clamp(global_position.z, -move_limit, move_limit)` where `move_limit = 12.0` (Lines 441-443).
  - Procedural Breathing & Bobbing (Lines 445-470): figure-8 Lissajous breathing curves (`breath_x`, `breath_y`) and walk bobbing (`walk_bob_x`, `walk_bob_y`) applied to `weapon_manager.position` and `fps_arms.position`.

### B. Weapon System Subsystem
- **Weapon Definition & Resources**:
  - `scripts/WeaponData.gd` (`class_name WeaponData extends Resource`):
    - Exported fields: `weapon_id`, `display_name`, `base_damage`, `headshot_multiplier` (default 2.0), `base_fire_rate`, `base_mag_size`, `base_reserve_ammo`, `base_reload_time`, `spread`, `recoil`, `range` (100.0m), `pellet_count` (1 default, >1 for shotguns), `is_automatic`, `muzzle_fx`, `sound_set`, `unlock_price`.
    - Upgrade cost and stat scaling curves for 4 stats (up to 5 levels): `get_damage()`, `get_mag_size()`, `get_reload_time()`, `get_spread()`, `get_upgrade_cost()`.
  - Resource files in `resources/weapons/`: 16 weapon configurations including `pistol.tres`, `rifle.tres`, `shotgun.tres`, `m4a1.tres`, `ak47.tres`, `mp5.tres`, `awp.tres`, `desert_eagle.tres`, `combat_knife.tres`, `crossbow.tres`, `grenade_launcher.tres`, `minigun.tres`, `flatline.tres`, `car_smg.tres`, `sniper.tres`, `hawk_shotgun.tres`.
  - 3D Viewmodel scenes in `scenes/weapons/models/`: each weapon model has intact PBR materials (`Mat_Steel`, `Mat_DarkMetal`, `Mat_PolymerBlack`, etc.) and a designated `MuzzleSocket` (`Node3D` transform).
- **Weapon Instantiation & Switching** (`Player.gd` Lines 144-238):
  - In `_init_weapons()`: iterates through `SaveManager.data.unlocked_weapons`, instantiates `scenes/weapons/Weapon.tscn`, binds `weapon_data` and `aim_raycast`, instantiates the corresponding 3D model scene from `scenes/weapons/models/`, and connects `ammo_changed` and `weapon_reload_started`.
  - In `_apply_active_weapon()`: toggles `visible`, cancels inactive weapon reloads, executes `apply_upgrades()`, triggers reload if `current_ammo == 0`, and plays a vertical draw tween on both `fps_arms` and `weapon_manager` from `y = -0.36` to `y = -0.18` via `Tween.TRANS_BACK`.
- **Firing & Recoil Logic** (`scenes/weapons/Weapon.gd`):
  - `shoot()` (Lines 117-158): checks `can_shoot` and `not is_reloading`, decrements `current_ammo` (or triggers reload when empty), triggers `fire_timer` with `fire_rate`, triggers `muzzle_flash_fx()`, plays `sfx_shoot`, executes `apply_recoil()`, and invokes `_fire_projectiles()`.
  - Muzzle Flash: in `_ready()`, dynamically finds child `MuzzleSocket` from the weapon model and repositions `MuzzleFlash` (particles) and `MuzzleLight` (`OmniLight3D`, energy 3.5, color `Color(1, 0.85, 0.45)`) to the socket's exact position.
  - Recoil Simulation:
    - Weapon model: `position.z = 0.085 * recoil_kick`, `position.y = 0.018 * recoil_kick`, `rotation.x = deg_to_rad(recoil_rotation * recoil_kick)`, `rotation.z = deg_to_rad(randf_range(-1.4, 1.4) * recoil_kick)` with smooth per-frame lerp recovery.
    - FPS Arms: `_recoil_arms()` kicks `fps_arms.position.z += 0.04 * factor` and `rotation.x += deg_to_rad(3.0 * factor)`.
    - Camera kick: `apply_kick(-1.3 * kick_factor)` pushed upward and smoothly recovered via `recover = camera_kick * 12.0 * delta`.
  - Raycast Hit Resolution (`_fire_projectiles()`, Lines 159-249):
    - Direct space-state raycast using `aim_raycast.global_position` along `-target_ray.global_transform.basis.z`.
    - Applies spread cone in basis X/Y for multiple pellets if `pellet_count > 1`.
    - Checks collision: if `HitZone`, calls `take_hit()` (head: 2.5x, chest: 1.0x, limb: 0.7x); if regular collider with `take_damage()`, evaluates height (`hit_point.y > collider.global_position.y + 1.2`) for headshot multiplier.
    - Spawns blood or concrete particles via `ImpactPool`.
    - If hit: invokes `HUD.show_hitmarker(had_headshot)` and emits `EventBus.damage_dealt`.
- **Reloading System** (`Weapon.gd` & `Player.gd`):
  - `Weapon.gd` `reload()`: plays `sfx_reload`, emits `weapon_reload_started(reload_time)`, and sets an asynchronous timer.
  - `Player.gd` `_reload_arms(duration)`: runs 3-phase procedural tactical reload animation:
    - Phase 1 (0-25%): Arms and weapon lower (`position.y = -0.28`) and cant 14 degrees left (`rotation.z = 14°`).
    - Phase 2 (25-60%): Pause and magazine insertion jerk (`position.y = -0.25`).
    - Phase 3 (60-100%): Return to ready position (`position.y = -0.18`, `rotation.z = 0°`).

### C. Environment & Arena Subsystem
- **Current Combat Environments**:
  - `scenes/environments/UrbanStreet.tscn` (Mission 1 Arena): 70x70m ground plane with `mat_asphalt.tres`, `GTAGroveStreet` complex, bus stop, jersey barriers, traffic lights, trucks, and `UrbanStreet.gd` alpha-scissor foliage fix.
  - `scenes/environments/AirportServiceRoad.tscn` (Mission 2 Arena): 40x40m ground plane with `mat_asphalt.tres`, detailed roadside barriers, multi-colored hazard barrels (`barrel_02_big_yellow/red/blue.glb`), advertising column, pallets, traffic cones, bollards, roadblock trucks, city buildings, and `AtmosphereEnhancer`.
- **WorldEnvironment & Lighting Setup**:
  - Sky & Background: `ProceduralSkyMaterial` with warm sky horizon (`Color(0.86, 0.72, 0.54)`) and dark aggregate ground horizon (`Color(0.35, 0.38, 0.42)`).
  - Fog: `fog_enabled = false` in environment scenes to eliminate white fog glare / overexposure on mobile.
  - Tonemapping: `tonemap_mode = 2` (Filmic), `tonemap_exposure = 1.05`, `tonemap_white = 1.0`.
  - Sun: `DirectionalLight3D` at `(0, 22, 0)` angled down, warm color `Color(1.0, 0.94, 0.84)`, energy `1.85`, `shadow_enabled = true`, `shadow_bias = 0.04`.
  - Local Lighting: `RoadFloodLight1` & `RoadFloodLight2` (`OmniLight3D`, energy 1.2, range 16.0m) providing crisp perimeter illumination.
- **Zombie Spawner & Navigation**:
  - `NavigationRegion3D`: holds `NavigationMesh` covering the playable arena surface.
  - `ZombieSpawner` (`scripts/GameManager.gd`):
    - Spawn points array (`SpawnFront`, `SpawnLeft`, `SpawnRight`, `SpawnFrontLeft`, `SpawnFrontRight`) positioned 10m-22m from player.
    - Direction-aware spawning matching wave group specifications ("front", "left", "right", "back").
    - Concurrency throttling: throttles spawning when `zombies_alive >= max_active_zombies` (10).

### D. Combat & Zombie Loop Subsystem
- **Base Architecture** (`scripts/Zombies/EnemyBase.gd`):
  - Root: `CharacterBody3D` (`collision_layer = 2`, group `"zombies"`).
  - State Machine: `AIState` (`IDLE`, `WANDER`, `NOTICE_PLAYER`, `CHASE`, `ATTACK`, `STAGGER`, `SEARCH`, `LOST_PLAYER`, `DEAD`).
  - Archetypes: `normal` (50 HP, 1.4 m/s), `fast` (30 HP, 2.8 m/s), `heavy` (160 HP, 0.8 m/s), `spitter` (40 HP, 14m range, shoots `AcidSpit.tscn`), `dog` (50 HP, 4.5 m/s, ground-level capsule 0.45m), `boss` (500 HP, 1.1 m/s, 22 dmg).
  - Dead Target Visual Variants: randomizes clothing surfaces into 3 distinct palettes (Worker Orange, Civilian Indigo Denim, Necrotic Olive) with glowing red emissive eyes (`Color(0.9, 0.1, 0.05)`, emission energy 3.0) and blood stains.
  - Line-of-sight & Chasing: raycasts every 0.35s to player; rotates toward player with `look_at(player.global_position, Vector3.UP)`; moves via `velocity = dir * move_speed`; procedural gait oscillation on model rotation.
  - Attacks: transitions to `ATTACK` when `dist_to_player <= attack_range`; plays `attack` / `heavy_attack` anim and `sfx_attack`; calls `player.take_damage(attack_damage)` after 0.35s strike delay.
  - Damage Reactions:
    - Headshot: plays `headshot_reaction` / `hit_head`, rotates head back 32 degrees, triggers 0.45s `STAGGER`.
    - Body hit > 25 dmg: plays `stagger` anim, rotates body randomly, triggers 0.55s `STAGGER`.
  - Death: disables collision shapes, plays `death` anim, tilts back 75 degrees, awards cash via `SaveManager.add_cash(reward_on_kill)`, notifies `MissionManager`, and queues free after 2.2-2.5s.

### E. UI/HUD & Armory Subsystem
- **HUD** (`scenes/UI/HUD.tscn` & `scripts/HUD.gd`):
  - TopBar: displays HealthBar (green), numeric HP label, Wave indicator (`WAVE: X / Y`), Mission Name, Objective counter (`Zombies Remaining: X`), Cash display (`CASH: $X`), Weapon ammo (`WEAPON: Curr / Max`), and Pause Button.
  - Boss Bar: `BossHealthBar` at top center with `BossName` ("BOSS: THE ALPHA MUTANT").
  - Reticle & Feedback: `Crosshair` with center dot, dynamic bloom on weapon fire, `Hitmarker` (red diagonal ticks for body, golden yellow ticks + floating "HEADSHOT!" label for headshots), full-screen red damage flash and low-health vignette.
  - Mobile Touch Controls:
    - `VirtualJoystick` on bottom-left with touch tracking.
    - `LookArea` for swipe/drag aiming (supports touch drag and mouse drag emulation; strictly ignores joystick and fire touches).
    - `FireButton` on bottom-right for continuous firing on hold.
    - Tactical buttons: `ReloadButton`, `SwitchButton` (displays next weapon name), `GrenadeButton`.
  - Pause Menu: overlays Resume, Restart, Settings, and Exit buttons.
- **Armory UI** (`scenes/UI/ArmoryUI.tscn` & `scripts/UI/ArmoryUI.gd`):
  - 3D Preview: `SubViewport` with rotating `WeaponPivot` showcasing native 3D weapon models.
  - Weapon List: scrollable list of all 16 weapons.
  - Upgrade Matrix: 4 stat rows (Damage, Magazine, Reload, Accuracy) displaying current value and next-level upgrade cost.
  - Purchase & Economy: Unlock button ($5,000 cash or Rewarded Ad via `AdManager`), live balance updates through `EventBus.cash_changed`.

## 2. Logic Chain

1. From **Observation A**, the player scene mounts weapons under `Camera3D/WeaponManager` and first-person tactical arms under `Camera3D/FPSArms`. The stationary rotation is achieved by applying horizontal mouse/touch input directly to `Player.rotate_y()` for full 360-degree yaw, while pitching `Camera3D.rotate_x()` clamped between -65° and +65°. Movement is restricted within a 12-meter radius via position clamping, fulfilling the stationary shooter mechanic.
2. From **Observation B**, weapons are governed by `WeaponData` resource files that calculate damage, fire rate, ammo capacity, reload time, and accuracy across 5 upgrade levels. Weapon switching smoothly dips and raises the viewmodel via Godot Tweens. Raycasts collide with `HitZone` components or use height threshold calculations (>1.2m) to cleanly differentiate between headshots and body hits. Muzzle flash effects dynamically align with the model's `MuzzleSocket`.
3. From **Observation C**, environment scenes (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`, etc.) use PBR asphalt materials, procedural skies, and directional sun lighting with `fog_enabled = false` and filmic tonemapping to eliminate overexposed white glare. `GameManager` manages multi-wave spawning using distance-gated markers and group delays.
4. From **Observation D**, enemy AI inherits from `EnemyBase.gd`, utilizing an 8-state machine with navigation and direct line-of-sight raycasts. Zombies exhibit procedural hit reactions, directional stagger, and distinct Dead Target-style clothing palettes with emissive red eyes. Quadruped infected dogs use adjusted ground-level hitboxes and specialized audio streams.
5. From **Observation E**, `HUD.gd` integrates full mobile controls (virtual joystick, swipe-look area, fire/reload/switch/grenade buttons) while displaying real-time ammo, health, wave, objective, and hitmarker feedback. The Armory UI provides 3D inspection and an upgrade economy connected to `SaveManager` and `EventBus`.

## 3. Caveats

- **Network Mode**: CODE_ONLY mode was used; no external network requests were made.
- **Renderer**: The project targets Godot 4 `gl_compatibility` (GLES3/WebGL) for mobile compatibility; advanced desktop features like SSAO and volumetric fog are intentionally disabled in `QualityManager.gd`.
- **Audio Assets**: Audio streams in `scenes/weapons/Weapon.gd` and `scripts/Zombies/EnemyBase.gd` rely on WAV and TRES files in `audio/`; missing streams fall back to default sound effects without crashing.

## 4. Conclusion

The codebase architecture of "Sector Zero: Lockdown" is structured, modular, and fully aligned with the requirements of a high-clarity 3D mobile stationary zombie shooter:
1. **Player & Viewmodel**: Rigidly synchronized dual-node rig (`WeaponManager` + `FPSArms`) with responsive 360-degree rotation, procedural breathing, weapon sway, and tactical reload animations.
2. **Weapon Pipeline**: Resource-driven `WeaponData` system driving 16 weapons with 4 upgrade paths, dynamic muzzle flash socket alignment, recoil kicks, and raycast hit resolution.
3. **Arenas & Environments**: Realistic PBR staging (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`) configured with filmic tonemapping, crisp sun shadows, zero fog glare, and distance-gated wave spawning.
4. **Combat Loop**: Scalable `EnemyBase` state-machine supporting humanoids and quadruped dogs with skeletal animations, hit reactions, headshot multipliers, and randomized Dead Target aesthetic variations.
5. **Mobile UI/HUD**: Pure touch-compatible interface with virtual joystick, touch swipe aiming, firing, hitmarkers, boss health bar, and a functional Armory upgrade shop.

## 5. Verification Method

To independently verify the findings and current operational status of the codebase:

1. **Headless Test Suite Execution**:
   Run Godot's headless test runner:
   ```bash
   godot --headless scenes/test/TestRunner.tscn
   ```
   **Verified Runtime Result**: Executed during this survey with exit code 0; all **54 / 54 tests PASSED** across landscape display, touch controls, viewmodel arms, 3D weapons, recoil/kick, hitmarkers, 3D zombies, infected dogs, environments, and 12-mission progression.

2. **Inspect Core Component Files**:
   - Player & Viewmodel: `scenes/player/Player.tscn`, `scenes/player/Player.gd`
   - Weapon System: `scenes/weapons/Weapon.gd`, `scripts/WeaponData.gd`, `scenes/weapons/models/m4a1.tscn`, `scenes/weapons/models/fps_arms.tscn`
   - Environments: `scenes/environments/UrbanStreet.tscn`, `scenes/environments/AirportServiceRoad.tscn`
   - Zombie Loop: `scripts/Zombies/EnemyBase.gd`, `scenes/zombies/InfectedDog.gd`
   - UI & HUD: `scripts/HUD.gd`, `scripts/UI/ArmoryUI.gd`

3. **Invalidation Conditions**:
   - Any script failure or parse error when instantiating `Player.tscn` or `Weapon.tscn`.
   - Failure of `TestRunner.tscn` to pass runtime assertions.
