# Handoff Report: Visceral Headshot Decapitation & Impact FX (Requirement R2)

## 1. Observation

### 1.1 Zombie Mesh & Skeletal Architecture
Direct inspection of the 3D models and skeletal hierarchies across all enemy scenes (`RealisticZombie.tscn`, `RealDoomZombie.scn`, `RealSoldierZombie.scn`, `RealAlienMutant.scn`, `RealReptileMutant.scn`, `infected_dog.tscn`, `zombie_boss.tscn`, etc.) revealed:

1. **`RealDoomZombie.scn` (Used for RealisticZombie Normal, Fast, Spitter archetypes)**:
   - **Skeleton3D**: Path `Sketchfab_model/root/GLTF_SceneRootNode/zombie_ARM_114/GLTF_created_0/Skeleton3D` (114 bones total).
   - **Head & Neck Bones**:
     - Bone 24: `ValveBiped.Bip01_Neck1_52` (Parent: Bone 23 `ValveBiped.Bip01_Spine4_108`)
     - Bone 25: `ValveBiped.Bip01_Head1_51` (Parent: Bone 24 `ValveBiped.Bip01_Neck1_52`)
     - Child Bones of Bone 25 (Face & Skull): Bones 26 (`jaw_part01_md_27`), 36-37 (`tpeyelid`), 38-40 (`lips`), 41-44 (`cheek`), 45-51 (`brow`), 52-53 (`puff`), 54-55 (`eye_result`), 56-57 (`ear`), 58 (`teeth_part01_tp_50`).
   - **MeshInstances**: Model contains 5 separate `MeshInstance3D` nodes bound to this skeleton:
     - `Object_7`: Material `zombie_tier1_eyes` (Eyes mesh)
     - `Object_8`: Material `zombie_tier1_head` (Head/Skull mesh)
     - `Object_9`: Material `zombie_tier1_arms`
     - `Object_10`: Material `zombie_tier1_torso`
     - `Object_11`: Material `zombie_tier1_legs`
   - **Empirical Bone Scaling Test**: Executing `skeleton.set_bone_pose_scale(25, Vector3.ZERO)` on `RealDoomZombie.scn` successfully scales Bone 25 and all 25 child facial bones to `Vector3(0, 0, 0)`. Concurrently setting `Object_8.visible = false` and `Object_7.visible = false` completely removes the head and eye geometry instantly.

2. **`RealSoldierZombie.scn` (Used for RealisticZombie Heavy archetype)**:
   - **Skeleton3D**: Path `Sketchfab_model/FatZombie_fbx/Object_2/RootNode/Object_4/Skeleton3D` (42 bones total).
   - **Head & Neck Bones**:
     - Bone 5: `mixamorig_Neck_05` (Parent: Bone 4 `mixamorig_Spine2_04`)
     - Bone 6: `mixamorig_Head_06` (Parent: Bone 5 `mixamorig_Neck_05`)
     - Bone 7: `mixamorig_HeadTop_End_07` (Parent: Bone 6 `mixamorig_Head_06`)
   - **MeshInstances**:
     - `Object_10`: Head & Helmet mesh (`AABB: P: (-11.59, 154.70, -11.06), S: (22.93, 25.53, 25.75)`)
     - `Object_8` & `Object_9`: Eyes and goggles (`Y: 165.8 - 167.7`)
     - `Object_7`: Torso and limbs (`Y: 0.0 - 173.4`)
   - **Empirical Bone Scaling Test**: Executing `skeleton.set_bone_pose_scale(6, Vector3.ZERO)` collapses the head. Setting `Object_8.visible = false`, `Object_9.visible = false`, and `Object_10.visible = false` ensures complete mesh removal.

3. **Animation Override Test**:
   - Inspected `AnimationPlayer` tracks across all zombie animations (`walk`, `death`, `stagger`, `attack`, `headshot_reaction`, `fast_walk`).
   - Output from `test_anim_scale.gd`: Every animation confirmed `has scale tracks: false`. Advancing the `AnimationPlayer` by 0.1s preserves the `Vector3.ZERO` bone scale without resetting.
   - In `RealisticZombie.gd` (`_on_died()`, lines 287-290), death does not even invoke `AnimationPlayer`; it runs a forward collapse Tween on `model_instance` (`rotation.x = deg_to_rad(80.0)`, `position.y = -0.75`).

4. **Other Archetypes**:
   - `infected_dog.tscn`: Bone 5 is `"Head"` (Parent: Bone 4 `"Neck"`).
   - `RealInfectedHound.scn`: Bone 9 is `"Head_08"`.
   - `zombie_normal.tscn`, `zombie_fast.tscn`, `zombie_heavy.tscn`, `zombie_boss.tscn`: Bone 5 is `"Head"`.
   - `RealAlienMutant.scn`: Bone 76 is `"CC_Base_Head_038"`.
   - `RealReptileMutant.scn`: Bone 46 is `"joint_Head_01_045"`.
   - `RealButcherBoss.scn`: 5 static meshes with 0 skeleton bones. Must be safely guarded (`if skeleton and b_head >= 0:`) to avoid decapitation on non-skeletal boss geometry.

### 1.2 Hit Detection & Damage Dispatch
Inspected `scripts/Combat/HitZone.gd`, `scenes/weapons/Weapon.gd`, `scripts/HealthComponent.gd`, and `scripts/Zombies/EnemyBase.gd`:

1. **`HitZone.gd` (lines 17-39)**:
   ```gdscript
   match zone_type:
       ZoneType.HEAD:
           damage_multiplier = 2.5
       ...
   func take_hit(base_damage: float, hit_dir: Vector3 = Vector3.ZERO) -> Dictionary:
       var final_damage = base_damage * damage_multiplier
       var is_headshot = (zone_type == ZoneType.HEAD)
       var zone_name = get_zone_name()
       if parent_entity and parent_entity.has_method("take_damage"):
           parent_entity.take_damage(final_damage, is_headshot, hit_dir)
       return {
           "final_damage": final_damage,
           "is_headshot": is_headshot,
           "zone": zone_name
       }
   ```
   - Existing automated test suites (`TestRunner.gd` line 314 & `test_realistic_overhaul_e2e.gd` line 359) assert `r_head.final_damage == 50.0 and r_head.is_headshot`. The method signature and return structure must remain intact.

2. **`HealthComponent.gd` (lines 13-18)**:
   ```gdscript
   func take_damage(amount: float):
       current_health -= amount
       health_changed.emit(current_health)
       if current_health <= 0:
           died.emit()
   ```
   - `died.emit()` is emitted **synchronously** during the `take_damage()` call.

3. **`EnemyBase.gd` (lines 404-419)**:
   ```gdscript
   func take_damage(amount: float, is_headshot: bool = false, hit_dir: Vector3 = Vector3.ZERO):
       if is_dead:
           return
       last_hit_was_headshot = is_headshot
       if is_headshot:
           if sfx_headshot: ... sfx_headshot.play() # Plays sfx_headshot_crunch
       if health_component:
           health_component.take_damage(amount)
       if is_dead:
           return
   ```
   - Notice: `last_hit_was_headshot` is set on line 407 *before* `health_component.take_damage(amount)`.
   - When `current_health <= 0`, `health_component.died` immediately invokes `_on_died()`.
   - In `_on_died()`, `is_dead` transitions to `true`.
   - **Key Gap Observed**: `hit_dir` is currently passed into `take_damage(amount, is_headshot, hit_dir)` but is not stored in an instance variable (unlike `last_hit_was_headshot`). Storing `var last_hit_dir: Vector3 = Vector3.ZERO` enables `_on_died()` to access the bullet vector.

### 1.3 Particle & Renderer Constraints
1. Project uses Godot 4.3 with rendering method `gl_compatibility` (OpenGL ES 3.0 profile target for mobile / low-spec AMD APU).
2. Existing `BloodEffect.tscn` is a `GPUParticles3D` with 10 particles.
3. Tested `CPUParticles3D` in `test_cpu_particles.gd` on Godot 4.3: Instantiated, parameterized (amount=25, velocity=4-8, spread=35°, quad billboard mesh), and emitted with 0 warnings/errors.
4. `AtmosphereEnhancer.gd` already uses `CPUParticles3D` for sunlight dust, confirming precedent for `CPUParticles3D` in this codebase.
5. In `ImpactPool.gd`, a pre-allocated pool of 16 nodes exists for `"blood"` and `"concrete"`.

### 1.4 Audio & Hitmarker Synchronization
1. `sfx_headshot_crunch.ogg` / `.wav` / `.tres` is located in `res://audio/impacts/sfx_headshot_crunch` and preloaded into `sfx_headshot` in `EnemyBase._resolve_nodes()`.
2. In `scenes/weapons/Weapon.gd` (lines 307-314):
   ```gdscript
   if total_hit_enemy:
       var hud_node = get_tree().get_first_node_in_group("hud")
       if hud_node and hud_node.has_method("show_hitmarker"):
           hud_node.show_hitmarker(had_headshot)
   ```
3. In `scripts/HUD.gd` (lines 315-341):
   - Golden hitmarker color `Color(1.0, 0.85, 0.2, 1.0)` is applied when `is_headshot == true`.
   - Spawns animated floating `"HEADSHOT!"` text label over crosshair.
4. Raycast, headshot audio, and hitmarker all execute synchronously in frame 0 of firing.

---

## 2. Logic Chain

1. **Lethal Headshot State Determination**:
   - `last_hit_was_headshot` is already set in `EnemyBase.take_damage()` before `health_component.take_damage(amount)`.
   - Adding `last_hit_dir = hit_dir` ensures the bullet trajectory is stored.
   - When `health_component.take_damage(amount)` reduces health to `<= 0`, `health_component.died` calls `_on_died()`.
   - In `_on_died()`, if `last_hit_was_headshot == true`:
     - This is guaranteed to be a lethal headshot.
     - `_trigger_decapitation(last_hit_dir)` can be called immediately.

2. **Decapitation Execution (Hybrid Bone Scaling + Mesh Hiding)**:
   - For `RealisticZombie`:
     - If `skeleton` is valid and `b_head >= 0`:
       Call `skeleton.set_bone_pose_scale(b_head, Vector3.ZERO)`. Because facial/jaw/helmet bones are hierarchical descendants of `b_head`, the entire head skeleton collapses to scale 0.
     - To prevent any vertex weighting stretching or pop, also hide head mesh nodes directly:
       - If `archetype in ["normal", "fast", "spitter"]`: `model_instance.find_child("Object_8", true, false).visible = false` (head) and `find_child("Object_7", ...).visible = false` (eyes).
       - If `is_soldier` (`heavy`): hide `Object_8`, `Object_9`, `Object_10`.
       - Generic fallback for any humanoid model: Iterate child `MeshInstance3D` nodes; if mesh name contains "head" or material contains "head" or "eye", set `visible = false`.
   - For generic `EnemyBase` models (`infected_dog.tscn`, `zombie_normal.tscn`):
     - Dynamically resolve head bone (`"Head"`, `"head"`, `"Head_08"`, `"CC_Base_Head_038"`) and set bone pose scale to `Vector3.ZERO`.

3. **Visceral Impact FX (Dual Emitter Design)**:
   - **Emitter 1: Directional Bullet Exit Spray**:
     - At `head_hit_zone.global_position`, spawn a high-velocity burst of crimson droplets aligned with `hit_dir.normalized() + Vector3(0, 0.2, 0)`.
     - Velocity: 5.0 - 8.5 m/s, spread: 35°, 20-25 particles, lifetime 0.5s.
     - 4-6 chunky flesh/skull gib particles with gravity -10.0 m/s² arc outwards and land on the ground.
   - **Emitter 2: Neck Stump Blood Fountain**:
     - Positioned at the severed neck stump (`Vector3(0, 1.45, 0)` on humanoids, `Vector3(0, 0.45, -0.35)` on dogs).
     - Added as a child of `model_instance` so that as `model_instance` tilts forward 80° during the death collapse tween in `RealisticZombie._on_died()`, the spurting blood fountain follows the falling torso down to the asphalt!
     - Emits for 1.5 seconds, then stops.

4. **Zero Memory Leak & Zero Orphaned Nodes Protocol**:
   - Emitter 2 is a child of the zombie. When `RealisticZombie` / `EnemyBase` executes `await get_tree().create_timer(3.0).timeout; queue_free()`, the emitter is freed automatically with the zombie.
   - Emitter 1 can be pooled in `ImpactPool` (e.g. `pools["blood_decapitation"]` with 8 pre-instantiated nodes) or created with a self-destructing timer `tw.tween_callback(p.queue_free)`. Pooling in `ImpactPool` guarantees 0 runtime node allocations and 0 leaks across extended sessions.

5. **Audio & Feedback Synchronization**:
   - `sfx_headshot_crunch.ogg` plays at the impact point.
   - An extra visceral squelch / bone snap can be layered or pitched for decapitations (`sfx_impact_flesh.wav`).
   - Crosshair hitmarker turns yellow/gold and shows `"HEADSHOT!"`.

---

## 3. Caveats

1. **Boss Archetype (`RealButcherBoss.scn`)**:
   - `RealButcherBoss.scn` does not have a `Skeleton3D` (it is comprised of 5 static `MeshInstance3D` nodes).
   - Calling bone operations on the boss would cause a null dereference. Decapitation logic must explicitly check `if skeleton and b_head >= 0:` and skip mesh decapitation for `archetype == "boss"`.
2. **Animation Overwrite Safeguard**:
   - While existing animations do not contain scale tracks, future imported animations might. To guarantee the head remains decapitated throughout the death state, applying `skeleton.set_bone_pose_scale(b_head, Vector3.ZERO)` on decapitation and flagging `is_decapitated = true` ensures it is maintained.
3. **Multiplayer / Replays**:
   - Not currently in scope for Sector Zero (single-player stationary campaign), but decapitation state is deterministic and local.
4. **Third-Party Model License**:
   - No external assets need to be imported; existing `RealDoomZombie.scn`, `RealSoldierZombie.scn`, and `sfx_headshot_crunch.ogg` already contain all necessary meshes, bones, and audio.

---

## 4. Conclusion & Recommended Architecture

### 4.1 Recommended Implementation Blueprint

#### Step A: `scripts/Zombies/EnemyBase.gd`
1. Add instance variables:
   ```gdscript
   var last_hit_dir: Vector3 = Vector3.ZERO
   var is_decapitated: bool = false
   ```
2. In `take_damage(amount, is_headshot, hit_dir)`:
   ```gdscript
   last_hit_was_headshot = is_headshot
   last_hit_dir = hit_dir
   ```
3. Add `_trigger_decapitation(hit_dir: Vector3)` method:
   - Identify head bone via `_find_head_bone_index(skeleton)`
   - Set bone pose scale to `Vector3.ZERO`
   - Spawn directional blood burst and neck fountain FX
   - Play enhanced crunch/squelch audio

#### Step B: `assets/zombies/RealisticZombie.gd`
1. Override `_trigger_decapitation(hit_dir: Vector3)`:
   - Hide specific head mesh instances:
     - If not soldier: Hide `Object_8` (head) and `Object_7` (eyes)
     - If soldier: Hide `Object_8`, `Object_9`, `Object_10`
   - Set `skeleton.set_bone_pose_scale(b_head, Vector3.ZERO)`
   - Attach a neck stump `CPUParticles3D` to `model_instance` at local position `Vector3(0, 1.45, 0)`. As the tween tilts `model_instance`, the blood spray angles downward with the neck.
   - Spawn directional blood burst in world space along `hit_dir`.
2. In `_on_died()`:
   - If `last_hit_was_headshot`:
     `_trigger_decapitation(last_hit_dir)`

#### Step C: Dedicated `DecapitationBloodFX.gd` / `ImpactPool.gd`
1. Create a lightweight `CPUParticles3D` prefab or helper for directional blood burst:
   - 25 blood droplets (`QuadMesh` with unshaded billboard material, `size = Vector2(0.1, 0.1)`, `albedo_color = Color(0.55, 0.02, 0.02, 0.95)`).
   - 4 skull/flesh chunks (`QuadMesh` or small box, `size = Vector2(0.15, 0.15)`).
   - Aligned to `hit_dir.normalized()`.
   - Pre-allocated in `ImpactPool` (pool size 8) or added as self-freeing node (`queue_free()` after 1.0s).

---

## 5. Verification Method

To independently verify the architecture and confirm zero regressions:

1. **Run 4-Tier Automated Regression Suite**:
   ```bash
   godot --headless scenes/test/test_realistic_overhaul.tscn
   ```
   *Expected Result*: 88/88 tests pass (100% PASS rate), specifically verifying `TC-F10-01` (2.5x headshot critical), `TC-F10-03` (golden hitmarker), `TC-F10-05` (zombie death), and `TC-C03` (headshot kill).

2. **Run Mission Consistency Validator**:
   ```bash
   godot --headless --script tools/validate_all_missions.gd
   ```
   *Expected Result*: All 13 missions pass with 0 errors.

3. **Headshot Decapitation Unit Test**:
   - Instantiate `res://assets/zombies/RealisticZombie.tscn`.
   - Obtain `HeadHitZone`.
   - Call `head_zone.take_hit(100.0, Vector3(0, 0, 1))`.
   - Assert:
     - `zombie.is_dead == true`
     - `zombie.is_decapitated == true`
     - Head mesh `Object_8` is not visible (`visible == false`)
     - Head bone pose scale is `Vector3.ZERO`
     - No orphaned nodes after `queue_free()`.
