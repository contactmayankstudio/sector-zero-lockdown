# Investigation & Exploration Report: Requirements R2 & R3
**Agent**: `explorer_weapons_r7`  
**Date**: 2026-09-08T07:58:00Z  
**Project Root**: `/home/am/targetkill`  
**Target Milestone**: R2 (First-Person Tactical Firearms & SWAT Combat Arms) and R3 (Zombie Roster, Quadruped Infected Dogs, and AI Navigation)

---

## 1. Observation

### 1.1 Complete 3D Armory Inspection (15 Firearms & Weapons)
All 15 requested weapons were inspected across their data resources (`resources/weapons/`), viewmodel model scenes (`scenes/weapons/models/`), base weapon script (`scenes/weapons/Weapon.gd`), and runtime weapon manager configuration (`scenes/player/Player.gd` lines 42–68).

| # | Weapon Identifier | Resource Path | Viewmodel Scene Path | 3D Mesh / Model Asset | MuzzleSocket Present? | Sound Set / Trigger |
|---|---|---|---|---|:---:|---|
| 1 | `minigun` (M134 Vulcan Minigun) | `res://resources/weapons/minigun.tres` | `res://scenes/weapons/models/minigun.tscn` | `res://assets/3d/weapons/downloaded/minigun_m134.glb` | **YES** `(0.04, -0.06, -0.52)` | `sfx_minigun_shoot.wav` / `rifle` |
| 2 | `flatline` (VK-47 Flatline) | `res://resources/weapons/flatline.tres` | `res://scenes/weapons/models/flatline.tscn` | `res://assets/3d/weapons/downloaded/flatline_rifle.glb` | **YES** `(0.04, 0.0, -0.52)` | `sfx_flatline_shoot.wav` / `rifle` |
| 3 | `car_smg` (C.A.R. SMG) | `res://resources/weapons/car_smg.tres` | `res://scenes/weapons/models/car_smg.tscn` | `res://assets/3d/weapons/downloaded/car_smg.glb` | **YES** `(0.04, -0.02, -0.45)` | `sfx_car_shoot.wav` / `car_smg` |
| 4 | `sniper` (Vantage Ultimate Sniper) | `res://resources/weapons/sniper.tres` | `res://scenes/weapons/models/sniper.tscn` | `res://assets/3d/weapons/downloaded/sniper_vantage.glb` | **NO (GAP)** | `sfx_sniper_shoot.wav` / `rifle` |
| 5 | `hawk_shotgun` (Hawk 18.4mm Shotgun) | `res://resources/weapons/hawk_shotgun.tres` | `res://scenes/weapons/models/hawk_shotgun.tscn` | `res://assets/3d/weapons/downloaded/combat_shotgun.glb` | **NO (GAP)** | `sfx_hawk_shoot.wav` / `shotgun` |
| 6 | `usp45` / `pistol` (USP-45) | `res://resources/weapons/usp45.tres` | `res://scenes/weapons/models/usp45.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.2, -0.022)` | `sfx_pistol_shoot.wav` / `pistol` |
| 7 | `mp5` (MP5 Tactical) | `res://resources/weapons/mp5.tres` | `res://scenes/weapons/models/mp5.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.37, -0.035)` | `sfx_mp5_shoot.wav` / `mp5` |
| 8 | `m4a1` / `rifle` (M4A1 Sentinel) | `res://resources/weapons/m4a1.tres` | `res://scenes/weapons/models/m4a1.tscn` | Native ArrayMesh (5 PBR materials) | **YES** `(0, -0.53, -0.042)` | `sfx_rifle_shoot.wav` / `rifle` |
| 9 | `ak47` (AK-47 Vanguard) | `res://resources/weapons/ak47.tres` | `res://scenes/weapons/models/ak47.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.6, -0.032)` | `sfx_ak47_shoot.wav` / `ak47` |
| 10 | `remington870` / `shotgun` (Remington 870) | `res://resources/weapons/remington870.tres` | `res://scenes/weapons/models/remington870.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.6, -0.04)` | `sfx_shotgun_shoot.wav` / `shotgun` |
| 11 | `desert_eagle` (Desert Eagle .50 AE) | `res://resources/weapons/desert_eagle.tres` | `res://scenes/weapons/models/desert_eagle.tscn` | Native ArrayMesh (3 PBR materials) | **YES** `(0, -0.26, -0.032)` | `sfx_deagle_shoot.wav` / `deagle` |
| 12 | `awp` (AWP Arctic Warfare) | `res://resources/weapons/awp.tres` | `res://scenes/weapons/models/awp.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.9, -0.042)` | `sfx_awp_shoot.wav` / `awp` |
| 13 | `combat_knife` (Combat Knife) | `res://resources/weapons/combat_knife.tres` | `res://scenes/weapons/models/combat_knife.tscn` | Native ArrayMesh (3 PBR materials) | **YES** `(0, -0.26, -0.014)` | `sfx_knife_slash.wav` / `knife` |
| 14 | `crossbow` (Silent Hunter Crossbow) | `res://resources/weapons/crossbow.tres` | `res://scenes/weapons/models/crossbow.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.38, -0.046)` | `sfx_crossbow_shoot.wav` / `crossbow` |
| 15 | `grenade_launcher` (M79 Grenade Launcher) | `res://resources/weapons/grenade_launcher.tres` | `res://scenes/weapons/models/grenade_launcher.tscn` | Native ArrayMesh (4 PBR materials) | **YES** `(0, -0.44, -0.045)` | `sfx_grenade_launcher_shoot.wav` |

#### Identified Armory Gaps:
1. **Missing `MuzzleSocket` in Sniper & Hawk Shotgun**:
   In `scenes/weapons/models/sniper.tscn`:
   ```ini
   [node name="sniper" type="Node3D"]
   [node name="Model" parent="." instance=ExtResource("1_sniper")]
   transform = Transform3D(-0.016, 0, 0, 0, 0.016, 0, 0, 0, -0.016, 0.04, -0.06, -0.15)
   ```
   In `scenes/weapons/models/hawk_shotgun.tscn`:
   ```ini
   [node name="hawk_shotgun" type="Node3D"]
   [node name="Model" parent="." instance=ExtResource("1_shotgun")]
   transform = Transform3D(0, 0, -0.032, 0, 0.032, 0, 0.032, 0, 0, 0.04, -0.06, -0.12)
   ```
   Neither file contains a `MuzzleSocket` child node!
   In `scenes/weapons/Weapon.gd` lines 41–46:
   ```gdscript
   var socket = find_child("MuzzleSocket", true, false)
   if socket:
       if muzzle_flash:
           muzzle_flash.global_position = socket.global_position
       if muzzle_light:
           muzzle_light.global_position = socket.global_position
   ```
   Because `socket` is `null`, `muzzle_flash` and `muzzle_light` stay at `Weapon.tscn` default position `(0, 0, -0.3)`, failing to align with the barrel of the sniper and shotgun models.

2. **Unimported Weapon Audio Streams (Missing `.import` metadata)**:
   In `audio/weapons/`:
   - `sfx_minigun_shoot.wav` (91,982 bytes)
   - `sfx_flatline_shoot.wav` (474,958 bytes)
   - `sfx_car_shoot.wav` (463,182 bytes)
   - `sfx_hawk_shoot.wav` (415,566 bytes)
   - `sfx_sniper_shoot.wav` (449,358 bytes)
   - `sfx_reload_shotgun.wav` (768,354 bytes)
   - `sfx_reload_bolt.wav` (1,193,150 bytes)
   - `sfx_reload_slide.wav` (1,787,590 bytes)
   - `sfx_reload_mag.wav` (1,429,482 bytes)
   These `.wav` files were added without Godot engine `.import` metadata files and lack `.sample` cache entries in `.godot/imported/`.
   Verbatim console error emitted during test and mission load:
   ```
   ERROR: No loader found for resource: res://audio/weapons/sfx_minigun_shoot.wav (expected type: )
      at: _load (core/io/resource_loader.cpp:291)
   ERROR: No loader found for resource: res://audio/weapons/sfx_flatline_shoot.wav (expected type: )
      at: _load (core/io/resource_loader.cpp:291)
   ERROR: No loader found for resource: res://audio/weapons/sfx_car_shoot.wav (expected type: )
      at: _load (core/io/resource_loader.cpp:291)
   ```
   Note: The user request in `ORIGINAL_REQUEST.md` lines 254–255 explicitly specified linking `.ogg` files (`sfx_minigun_shoot.ogg`, `sfx_flatline_shoot.ogg`, etc.). These files exist in `audio/weapons/downloaded/q009/minigun.ogg`, etc., or the `.wav` files require import generation.

---

### 1.2 First-Person SWAT Combat Arms (`FPSArms`)
Inspected `scenes/player/Player.tscn`, `scenes/player/Player.gd`, and `scenes/weapons/models/fps_arms.tscn`.

1. **Scene Hierarchy (`Player.tscn` lines 102–116)**:
   ```ini
   [node name="Camera3D" type="Camera3D" parent="."]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.65, 0)
   current = true
   fov = 72.0

   [node name="FPSArms" type="Node3D" parent="Camera3D"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.18, -0.18, -0.42)

   [node name="WeaponManager" type="Node3D" parent="Camera3D"]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.18, -0.18, -0.42)
   ```

2. **Runtime Model Instantiation (`Player.gd` lines 140–152)**:
   ```gdscript
   if fps_arms:
       var arms_res = load("res://scenes/weapons/models/fps_arms.tscn")
       if arms_res is PackedScene:
           if fps_arms.has_node("MeshInstance3D"):
               fps_arms.get_node("MeshInstance3D").visible = false
           for c in fps_arms.get_children():
               if c.name == "CombatArmsModel":
                   c.queue_free()
           var arms_inst = arms_res.instantiate()
           arms_inst.name = "CombatArmsModel"
           arms_inst.position = Vector3(-0.18, 0.03, 0.07)
           fps_arms.add_child(arms_inst)
   ```
   - Relative offset `Vector3(-0.18, 0.03, 0.07)` inside `FPSArms` shifts the model origin to `Vector3(0.0, -0.15, -0.35)` relative to `Camera3D`, centering the dual arms evenly around the camera's sightline while the active firearm sits at `WeaponManager` position `(0.18, -0.18, -0.42)` with slight right offset for natural hipfire/sight posture.

3. **Material & Surface Definition (`scenes/weapons/models/fps_arms.tscn`)**:
   - `Mat_TacticalSleeve` (Surface 0): Albedo `Color(0.537, 0.566, 0.506)` (OD Green SWAT Sleeve), roughness 0.85.
   - `Mat_ArmSkin` (Surface 1): Albedo `Color(0.926, 0.843, 0.786)` (Caucasian Forearm Skin), roughness 0.55.
   - `Mat_TacticalGlove` (Surface 2): Albedo `Color(0.437, 0.449, 0.461)` (SWAT Charcoal Nomex Glove), roughness 0.7.
   - `Mat_CarbonKnuckle` (Surface 3): Albedo `Color(0.272, 0.272, 0.293)` (Carbon Fiber Reinforced Knuckles), metallic 0.4, roughness 0.22.
   - `Mat_WatchCase` (Surface 4): Albedo `Color(0.313, 0.313, 0.332)` (Tactical Watch Housing), roughness 0.5.
   - `Mat_WatchScreen` (Surface 5): Albedo `Color(0.485, 0.906, 0.955)`, Emission `Color(0.509, 0.949, 1.0)`, `emission_energy_multiplier = 2.7` (Cyan Active Tactical Watch Screen).

4. **Synchronized Procedural Viewmodel Kinetics (`Player.gd`)**:
   - **Idle Breathing & Walking Sway (lines 454–479)**:
     Figure-8 Lissajous breathing sway (`breathing_speed = 1.8`, `breathing_amount = 0.006`) and walk bobbing (`bob_speed = 8.5`, `bob_amount = 0.022`) dynamically drive both `weapon_manager.position` and `fps_arms.position` in exact lockstep.
   - **Weapon Recoil Kick (lines 320–324)**:
     ```gdscript
     func _recoil_arms(factor: float = 1.0):
         if fps_arms:
             fps_arms.position.z += 0.04 * factor
             fps_arms.rotation.x += deg_to_rad(3.0 * factor)
     ```
   - **Tactical Reload Motion (lines 325–346)**:
     3-phase tween drops both `weapon_manager` and `fps_arms` by `y = -0.28` and cants them `rotation:z = 14.0 deg`, jerks up `y = -0.25` on magazine seating, then smoothly returns to ready stance `y = -0.18`.
   - **Weapon Switch Transition (lines 229–235)**:
     Drops arms and weapon to `y = -0.36` and tweens back to `-0.18` over 0.22s with `Tween.TRANS_BACK` / `Tween.EASE_OUT`.

---

### 1.3 Gunplay Mechanics: Dynamic Muzzle Flashes, Recoil, Weapon Switching & Auto Reload
Inspected `scenes/weapons/Weapon.gd` and `scenes/player/Player.gd`.

1. **Dynamic Muzzle Flash (`scenes/weapons/Weapon.gd` lines 342–359)**:
   ```gdscript
   func muzzle_flash_fx():
       if weapon_data and weapon_data.muzzle_fx == "none":
           return
       if muzzle_light:
           muzzle_light.visible = true
       if muzzle_flash:
           muzzle_flash.show()
           if muzzle_flash is GPUParticles3D:
               muzzle_flash.restart()
               muzzle_flash.emitting = true
       if not is_inside_tree() or not get_tree():
           return
       await get_tree().create_timer(0.06).timeout
       if muzzle_light:
           muzzle_light.visible = false
       if muzzle_flash:
           muzzle_flash.hide()
   ```
   - Dynamic `muzzle_light` is an `OmniLight3D` (`light_color = Color(1, 0.85, 0.45)`, `light_energy = 3.5`, `omni_range = 6.0m`).
   - `MuzzleFlash` is a `GPUParticles3D` system displaying flame billboard quads.
   - Durational flash lasts 0.06s in synchronized lockstep with sound emission.

2. **Realistic Recoil Kick (`Weapon.gd` lines 360–371 & `Player.gd` lines 304–306, 489–497)**:
   - **Weapon Viewmodel Kick**:
     ```gdscript
     func apply_recoil():
         position.z = 0.085 * recoil_kick
         position.y = 0.018 * recoil_kick
         rotation.x = deg_to_rad(recoil_rotation * recoil_kick)
         rotation.z = deg_to_rad(randf_range(-1.4, 1.4) * recoil_kick)
     ```
     Damped via exponential lerp back to 0.0 at `12.0 * delta`.
   - **Camera Recoil Kick**:
     In `Player.gd`: `apply_kick(-1.3 * kick_factor)` pitches camera up, and recovers via `recover = camera_kick * 12.0 * delta`.
   - **Camera Shake**:
     In `Player.gd`: `apply_shake(0.20 * kick_factor)` applies procedural horizontal and vertical jitter decaying via `shake_fade = 5.0`.

3. **Weapon Switching (`Player.gd` lines 216–248)**:
   - `switch_weapon()` and `switch_to_weapon(index)` toggle active weapon visibility.
   - Ongoing reloads on inactive weapons are cleanly aborted via `weapons[i].cancel_reload()`, halting `sfx_reload` audio and clearing timers without freezing state.
   - Active weapon upgrades are verified and applied.
   - If switched to a weapon with `current_ammo == 0`, reload is automatically initiated.

4. **Automatic Magazine Reload on Ammo Exhaustion (`Weapon.gd` lines 158–170 & `Player.gd` lines 308–310)**:
   - Firing the final round (`current_ammo == 0`):
     ```gdscript
     current_ammo -= 1
     if current_ammo == 0:
         reload()
     ```
   - Attempting to shoot with 0 ammo (`current_ammo <= 0`):
     ```gdscript
     if current_ammo <= 0 and not is_knife:
         if sfx_empty: sfx_empty.play()
         if not is_reloading:
             reload()
         return
     ```
   - `Player.gd` line 308 acts as a redundant safeguard:
     ```gdscript
     if weapon.current_ammo <= 0 and not weapon.is_reloading:
         _trigger_reload()
     ```
   - Tested and verified by automated regression test `TC-B01: Empty Mag Auto-Reload Trigger` (PASSED).

---

### 1.4 Quadruped Infected Dogs (`InfectedDog.tscn`, `InfectedDog.gd`, `EnemyBase.gd`)
Inspected `scenes/zombies/InfectedDog.tscn`, `scenes/zombies/InfectedDog.gd`, `scenes/zombies/models/infected_dog.tscn`, and `scripts/Zombies/EnemyBase.gd`.
*(Note: As documented in section 1.6, the project stores enemy scenes under `scenes/zombies/` rather than `scenes/enemies/`.)*

1. **4-Legged Skeletal Canine Model**:
   - `scenes/zombies/models/infected_dog.tscn` contains an 18-bone quadruped armature (`Skeleton3D`) bound with weighted vertex skinning (`skin_data` & `bone_aabbs`).
   - Materials:
     - `Mat_DogFur`: Albedo `Color(0.437, 0.410, 0.396)`, roughness 0.85 (diseased canine fur).
     - `Mat_DogFlesh`: Albedo `Color(0.786, 0.437, 0.410)`, roughness 0.45 (mutilated flesh).
     - `Mat_DogTeeth`: Albedo `Color(0.931, 0.916, 0.865)`, roughness 0.30 (canine fangs).
     - `Mat_DogEyes`: Albedo `Color(0.931, 0.978, 0.424)`, Emission `Color(0.895, 1.0, 0.367)`, `emission_energy_multiplier = 1.8` (sickly yellow glowing eyes).

2. **Ground Collision & Hit Zones**:
   - **Root Collision**: `CollisionShape3D` with `BoxShape3D(0.45, 0.5, 0.9)` positioned at `(0, 0.35, 0)` — a lowered ground-level collision capsule tailored for quadrupeds.
   - **Head Hit Zone (`HeadHitZone`)**:
     - `Area3D` at `(0, 0.52, -0.45)`, `SphereShape3D(radius = 0.22)`.
     - `zone_type = HitZone.ZoneType.HEAD` (0), `damage_multiplier = 2.5`.
   - **Body Hit Zone (`BodyHitZone`)**:
     - `Area3D` at `(0, 0.38, 0.05)`, `BoxShape3D(0.45, 0.45, 0.7)`.
     - `zone_type = HitZone.ZoneType.CHEST` (1), `damage_multiplier = 1.0`.

3. **Complete Animation Playback**:
   - The dog animation player exposes 7 complete animations:
     `["attack", "death", "hit_body", "hit_head", "idle", "run", "walk"]`.
   - In `InfectedDog.gd` lines 47–63:
     - Headshots trigger `hit_head` and 0.35s stagger.
     - Body hits >= 20.0 dmg trigger `hit_body` and 0.40s stagger.
     - Death triggers `death`, disables all collision shapes, triggers `SfxDeath`, and awards $15 cash.

4. **Dedicated Canine Audio Streams**:
   - `SfxGrowl`: `res://audio/zombies/sfx_dog_bark.wav` (max distance 16m) — plays barking / growling.
   - `SfxAttack`: `res://audio/zombies/sfx_dog_attack.wav` (max distance 10m) — plays vicious bite attack.
   - `SfxDeath`: `res://audio/zombies/sfx_dog_death.wav` (max distance 14m) — plays dying whimper.

5. **AI Navigation & Stats**:
   - Speed: `move_speed = 4.5` (fast predator sprint), `attack_range = 2.0`, `attack_damage = 12.0`, `hp = 50.0`.
   - In `EnemyBase.gd` line 520: `var walk_anim = "run" if (archetype in ["fast", "dog"]) else ...` ensures dogs run full sprint during approach.
   - Configured in Mission 2 (`resources/missions/mission_02.tres`): 3 progressive waves spawning 32 dogs total (Wave 1: 6, Wave 2: 12 from front/left/right, Wave 3: 14 from front/back/left).

---

### 1.5 Humanoid Zombie Outfit Variations & Visual Styling
Inspected `scripts/Zombies/EnemyBase.gd` lines 244–296 and humanoid models (`zombie_normal.tscn`, `zombie_fast.tscn`, `zombie_heavy.tscn`, `zombie_boss.tscn`).

1. **Dead Target Outfit Variation Logic (`EnemyBase.gd` lines 244–296)**:
   When spawning humanoid zombies, surfaces are matched against material names and assigned randomized variations (`outfit_type = randi() % 3`):
   - **Glowing Red Eyes (All Humanoids)**:
     ```gdscript
     if mname.contains("eye") or mname.contains("iris") or mname.contains("sclera"):
         new_mat.albedo_color = Color(0.9, 0.1, 0.05, 1.0)
         new_mat.emission_enabled = true
         new_mat.emission = Color(1.0, 0.05, 0.02)
         new_mat.emission_energy_multiplier = 3.0
     ```
   - **Blood Stains**:
     ```gdscript
     if mname.contains("blood"):
         new_mat.albedo_color = Color(0.68, 0.04, 0.04, 1.0)
     ```
   - **Variant 0: DEAD TARGET WORKER**:
     - Shirt/vest/jacket: `Color(0.96, 0.45, 0.05, 1.0)` (Safety Orange Overalls)
     - Pants: `Color(0.18, 0.35, 0.65, 1.0)` (Work Blue Undershirt/Jeans)
     - Skin/pale/lips: `Color(0.72, 0.74, 0.68, 1.0)` (Pale Necrotic)
   - **Variant 1: DEAD TARGET CIVILIAN**:
     - Pants: `Color(0.22, 0.36, 0.60, 1.0)` (Denim Indigo Jeans)
     - Shirt: `Color(0.80, 0.80, 0.82, 1.0)` (Stained Light Grey Shirt)
     - Skin/pale/lips: `Color(0.75, 0.72, 0.68, 1.0)` (Ashen Skin)
   - **Variant 2: NECROTIC DISEASED**:
     - Skin/pale/lips: `Color(0.50, 0.62, 0.44, 1.0)` (Sickly Putrid Olive Flesh)
     - Shirt: `Color(0.28, 0.30, 0.26, 1.0)` (Grimy Dark Olive)
     - Pants: `Color(0.20, 0.20, 0.22, 1.0)` (Dark Charcoal)

---

### 1.6 Directory Structure & File Location Finding
- The prompt referenced `scenes/enemies/` (`infected_dog.tscn`, `InfectedDog.gd` or `EnemyDog.gd` / `EnemyBase.gd`).
- In this repository, the folder `scenes/enemies/` does not exist. All zombie and enemy scenes reside in:
  - `scenes/zombies/InfectedDog.tscn`
  - `scenes/zombies/InfectedDog.gd`
  - `scenes/zombies/models/infected_dog.tscn`
  - `scenes/zombies/Zombie.tscn`, `BossZombie.tscn`, `AcidSpit.tscn`
  - `scripts/Zombies/EnemyBase.gd`, `scripts/Zombies/ZombieAI.gd`, `scripts/Zombies/SpawnPoint.gd`

---

## 2. Logic Chain

1. **Armory 3D Mesh Integrity (Observation 1.1)**:
   - Verification showed that all 15 weapons have functional resource definitions (`.tres`) and corresponding viewmodel scenes (`.tscn`).
   - 10 weapons (`usp45`, `mp5`, `m4a1`, `ak47`, `remington870`, `desert_eagle`, `awp`, `combat_knife`, `crossbow`, `grenade_launcher`) use native Godot ArrayMeshes with dedicated StandardMaterial3D PBR materials (Steel, Dark Metal, Polymer Black, Rubber, Tritium glow, RedDot emission).
   - 5 weapons (`minigun`, `flatline`, `car_smg`, `sniper`, `hawk_shotgun`) load imported GLB scenes (`minigun_m134.glb`, `flatline_rifle.glb`, `car_smg.glb`, `sniper_vantage.glb`, `combat_shotgun.glb`).
   - However, `sniper.tscn` and `hawk_shotgun.tscn` omit the `MuzzleSocket` child node. In `Weapon.gd`, `find_child("MuzzleSocket")` evaluates to `null`, meaning their muzzle flash and muzzle light remain at the fallback position `(0, 0, -0.3)` rather than the end of the sniper/shotgun barrel.

2. **Weapon Audio Ingestion (Observation 1.1)**:
   - High-fidelity `.wav` files (`sfx_minigun_shoot.wav`, `sfx_flatline_shoot.wav`, `sfx_car_shoot.wav`, `sfx_hawk_shoot.wav`, `sfx_sniper_shoot.wav`, and 4 reload files) were placed into `audio/weapons/` without running the Godot asset importer.
   - Godot requires `.import` files to remap assets to `.godot/imported/*.sample`. Without them, `load("res://...")` throws `ERROR: No loader found for resource`.
   - Furthermore, `ORIGINAL_REQUEST.md` specifically requested linking `.ogg` files (`sfx_minigun_shoot.ogg`, etc.). Either generating the `.import` metadata or pointing to `.ogg` streams will eliminate this error.

3. **SWAT Combat Arms Viewmodel Alignment (Observation 1.2)**:
   - `Player.tscn` positions `FPSArms` at `(0.18, -0.18, -0.42)` and `WeaponManager` at `(0.18, -0.18, -0.42)`.
   - `Player.gd` instantiates `fps_arms.tscn` as `CombatArmsModel` with local offset `(-0.18, 0.03, 0.07)`, centering the two arms at `(0.0, -0.15, -0.35)` relative to the camera.
   - The arms feature distinct visual materials (tactical sleeve, forearm skin, tactical glove, carbon-fiber knuckles, glowing cyan watch display).
   - Dual-controller procedural motion in `Player.gd` ensures that Lissajous breathing, walk bobbing, weapon recoil, and tactical reloading animate both the firearm and the SWAT arms in perfect lockstep.

4. **Empty Magazine Auto Reload & Gunplay Loop (Observation 1.3)**:
   - `Weapon.gd` checks ammo state both when firing the last round (`current_ammo == 0 -> reload()`) and when attempting to shoot with 0 ammo (`current_ammo <= 0 -> reload()`).
   - `Player.gd` has a redundant check in `_trigger_shoot()`.
   - The test suite `TC-B01: Empty Mag Auto-Reload Trigger` directly tested and verified this behavior.

5. **Infected Dog Architecture (Observation 1.4)**:
   - `scenes/zombies/InfectedDog.tscn` instantiates `infected_dog.glb` with an 18-bone armature.
   - It possesses a lowered collision box (`y = 0.35`) and two distinct hit zones (`HeadHitZone` with 2.5x multiplier, `BodyHitZone` with 1.0x multiplier).
   - Dedicated audio streams (`sfx_dog_bark.wav`, `sfx_dog_attack.wav`, `sfx_dog_death.wav`) are wired to `SfxGrowl`, `SfxAttack`, and `SfxDeath`.
   - All 7 animations (`attack`, `death`, `hit_body`, `hit_head`, `idle`, `run`, `walk`) are functional, as verified by `test_infected_dog_scene.gd`.

6. **Humanoid Zombie Outfits (Observation 1.5)**:
   - `EnemyBase.gd` implements the Dead Target visual style through runtime material duplication and surface coloring.
   - It randomly selects between 3 distinct palettes (Worker Orange Jumpsuit, Civilian Denim Jeans, Necrotic Diseased) and applies glowing red eyes and blood stains.

---

## 3. Caveats

1. **Audio Importer Dependency**:
   - The newly introduced audio files in `audio/weapons/` (`sfx_minigun_shoot.wav`, etc.) throw Godot loader errors because they lack `.import` files. While the test runner gracefully tolerates this (because Godot `load()` returns `null` and `sfx_shoot.stream = null` does not crash), the gunfire audio for those 5 weapons is currently silent during gameplay until the import metadata is generated or valid `.ogg` paths are loaded.
2. **Directory Naming**:
   - The mission instructions referenced `scenes/enemies/`. The project's actual path is `scenes/zombies/` and `scripts/Zombies/`. Any automated tools or scripts referencing `scenes/enemies/` should point to `scenes/zombies/`.
3. **MuzzleSocket Visual Offset**:
   - On the Vantage Sniper and Hawk Shotgun, the missing `MuzzleSocket` means muzzle flashes originate from `(0, 0, -0.3)` rather than the barrel tip. Adding the socket node is a simple 2-line scene update.

---

## 4. Conclusion

Requirement R2 and Requirement R3 are **fundamentally implemented and architecturally solid**:
- All 15 weapons in the armory load complete 3D models with authentic PBR materials, weapon switching, recoil kick, and automatic reload.
- The first-person SWAT combat arms (`FPSArms`) are fully integrated with 6 distinct materials and synchronized procedural animations.
- The quadruped infected dog is a genuine 18-bone skeletal canine with all 7 animations, lowered ground collision, head/body hit zones, and dedicated barking/biting/death audio.
- Humanoid zombies feature randomized Dead Target-style outfit variations with glowing red eyes.

### Concrete Recommendations for Implementer:

1. **Add `MuzzleSocket` to `sniper.tscn`**:
   In `/home/am/targetkill/scenes/weapons/models/sniper.tscn`, append:
   ```ini
   [node name="MuzzleSocket" type="Node3D" parent="."]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.04, 0.01, -0.65)
   ```
2. **Add `MuzzleSocket` to `hawk_shotgun.tscn`**:
   In `/home/am/targetkill/scenes/weapons/models/hawk_shotgun.tscn`, append:
   ```ini
   [node name="MuzzleSocket" type="Node3D" parent="."]
   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.04, -0.01, -0.58)
   ```
3. **Resolve Weapon Audio Loader Errors in `scenes/weapons/Weapon.gd`**:
   Either:
   - Generate Godot `.import` files for the `.wav` files in `audio/weapons/`.
   - Or update `Weapon.gd` lines 59–68 to link existing `.ogg` files from `audio/weapons/downloaded/q009/` (`minigun.ogg`, `shotgun.ogg`, etc.) as specified in `ORIGINAL_REQUEST.md`.

---

## 5. Verification Method

To independently verify all findings and test suite passes:

1. **Run Full Regression Test Suite (54/54 tests)**:
   ```bash
   cd /home/am/targetkill
   godot --headless --scene scenes/test/TestRunner.tscn
   ```
   *Expected Output*: `TOTAL: 54 / 54 PASSED`, exit code 0.

2. **Run 4-Tier Realistic Overhaul E2E Suite (88/88 tests)**:
   ```bash
   cd /home/am/targetkill
   godot --headless --scene scenes/test/test_realistic_overhaul.tscn
   ```
   *Expected Output*: `TOTAL VERIFIED: 88 / 88 PASSED (0 FAILED)`, exit code 0.

3. **Run Dedicated Infected Dog Unit Test**:
   ```bash
   cd /home/am/targetkill
   godot --headless -s tools/test_infected_dog_scene.gd
   ```
   *Expected Output*:
   - `Head position: (0, 0.52, -0.45)`
   - `Body position: (0, 0.38, 0.05)`
   - `Dog animations: ["attack", "death", "hit_body", "hit_head", "idle", "run", "walk"]`
   - `Dog 18-bone quadruped armature verified`
   - `ALL DEDICATED INFECTED DOG TESTS PASSED!`, exit code 0.

4. **Inspect Missing MuzzleSocket**:
   ```bash
   grep -Hn "MuzzleSocket" scenes/weapons/models/*.tscn
   ```
   *Verify*: `sniper.tscn` and `hawk_shotgun.tscn` are absent from the grep results.
