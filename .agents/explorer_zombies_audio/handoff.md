# Handoff Report: Zombie Roster, Quadruped Infected Dogs, and Audio (R2)

**Agent:** `explorer_zombies_audio`  
**Handoff Type:** Hard (Investigation complete)  
**Target Path:** `/home/am/targetkill/.agents/explorer_zombies_audio/handoff.md`  
**Detailed Report:** `/home/am/targetkill/.agents/explorer_zombies_audio/report.md`  

---

## 1. Observation

1. **TestRunner.gd Failure**:
   Running `godot --headless -s scenes/test/TestRunner.gd` produced:
   ```
   [FAIL] Mission 2 Dog Spawner & Hit Zones - M2 dog config: true, HitZones Head(2.5x)/Body(1.0x): true, Dog archetype: false
   Total: 53 | Passed: 52 | Failed: 1
   ```
   Inspection of `scenes/test/TestRunner.gd` lines 573-580:
   ```gdscript
   var dog_archetype_ok = false
   var dog_scene_path = "res://scenes/zombies/InfectedDog.tscn"
   if ResourceLoader.exists(dog_scene_path):
       var dog_scene = load(dog_scene_path)
       if dog_scene:
           var dog_inst = dog_scene.instantiate()
           dog_archetype_ok = dog_inst != null and dog_inst.is_in_group("zombies")
           dog_inst.queue_free()
   ```

2. **Accidental Overwrite of `InfectedDog.tscn`**:
   `git diff scenes/zombies/InfectedDog.tscn` reveals `scenes/zombies/InfectedDog.tscn` was overwritten by the visual model `infected_dog.tscn`. The root node became `[node name="infected_dog" type="Node3D"]` instead of `CharacterBody3D`, removing `groups=["zombies"]`, `script = ExtResource("1_script")` (`InfectedDog.gd`), `HealthComponent`, `CollisionShape3D`, `HeadHitZone`, `BodyHitZone`, `SfxGrowl`, `SfxAttack`, `SfxDeath`, and `SfxTimer`.
   In contrast, `git show HEAD:scenes/zombies/InfectedDog.tscn` contains the complete `CharacterBody3D` entity with:
   - `groups=["zombies"]`
   - `move_speed = 4.5`, `attack_range = 2.0`, `attack_damage = 12.0`, `attack_interval = 1.8`
   - Ground collision box: `BoxShape3D` `(0.45, 0.5, 0.9)`, center `y = 0.35`
   - `HeadHitZone`: `position = Vector3(0, 0.52, -0.45)`, `zone_type = 0` (HEAD), `damage_multiplier = 2.5`
   - `BodyHitZone`: `position = Vector3(0, 0.38, 0.05)`, `zone_type = 1` (CHEST), `damage_multiplier = 1.0`
   - `SfxGrowl` (`sfx_dog_bark.wav`), `SfxAttack` (`sfx_dog_attack.wav`), `SfxDeath` (`sfx_dog_death.wav`)
   - `SkeletalModel` instancing `assets/3d/zombies/infected_dog.glb`

3. **Infected Dog Model & Armature (`infected_dog.glb`)**:
   Model has an 18-bone armature (`Root`, `Pelvis`, `Spine`, `Chest`, `Neck`, `Head`, `UpperLeg.FL/FR/BL/BR`, `LowerLeg.FL/FR/BL/BR`, `Paw.FL/FR/BL/BR`) and 7 complete animations: `idle`, `walk`, `run`, `attack`, `hit_head`, `hit_body`, `death`.

4. **Enemy Stats Discrepancy in `EnemyBase.gd`**:
   `git diff scripts/Zombies/EnemyBase.gd` lines 49-115 showed uncommitted changes:
   - `dog`: hp changed to 38.0 (contract: 50.0), speed to 2.5 (contract: 4.5), damage to 6.0 (contract: 12.0), attack_range to 1.9 (contract: 2.0).
   - `normal`: hp changed to 45.0 (contract: 50.0).
   - `fast`: hp changed to 28.0 (contract: 30.0), speed to 2.0 (contract: 2.8).
   - `heavy`: hp changed to 130.0 (contract: 160.0), damage to 12.0 (contract: 14.0).
   - `boss`: hp changed to 280.0 (contract: 500.0), damage to 18.0 (contract: 22.0).
   Existing tests (`tools/test_enemy_variants.gd` and `tools/stress_test_enemy_hierarchy_boss.gd`) assert these exact canonical contract numbers and fail if altered.

5. **Humanoid Zombie Material & Glowing Eyes**:
   `EnemyBase.gd` lines 247-278 indexed materials by hardcoded integers (`s_idx in [1, 3, 11, 14]`), coloring shoes and hair orange instead of clothes, while leaving eyes non-emissive.
   In-engine inspection of model surfaces showed semantic material names:
   - `zombie_normal`: `Mat_HumanSkin*`, `Mat_HumanHair`, `Mat_HumanEyeSclera`, `Mat_HumanEyeIris`, `Mat_HumanBlood`, `Mat_OxfordShirt`, `Mat_DenimJeans`.
   - `zombie_fast`: `Mat_HumanSkinFast`, `Mat_ScleraFast`, `Mat_EyesFast`, `Mat_RunnerJacket`, `Mat_RunnerShorts`.
   - `zombie_heavy`: `Mat_HumanSkinHeavy`, `Mat_WorkerShirt`, `Mat_SafetyVest`, `Mat_CanvasWorkPants`.
   - `infected_dog`: `Mat_DogFur`, `Mat_DogFlesh`, `Mat_DogTeeth`, `Mat_DogEyes`.

6. **GameManager Spawner Delegation**:
   `scenes/environments/AirportServiceRoad.tscn` line 136 sets `zombie_scene = "res://scenes/zombies/Zombie.tscn"`. In `scripts/GameManager.gd` lines 136-139:
   ```gdscript
   var arch = specific_archetype if specific_archetype != "" else _pick_archetype()
   var zombie = zombie_scene.instantiate()
   zombie.archetype = arch
   ```
   This spawns humanoid `Zombie.tscn` when `"dog"` or `"boss"` is requested, bypassing `InfectedDog.tscn` and `BossZombie.tscn`.

---

## 2. Logic Chain

1. **From Observation 1 & 2**: `TestRunner.gd` Test 50 specifically instantiates `res://scenes/zombies/InfectedDog.tscn` and checks `dog_inst.is_in_group("zombies")`. Because the working tree file was overwritten with the raw model node instead of the `CharacterBody3D` entity, it is not in the `zombies` group, causing Test 50 to fail. Restoring `InfectedDog.tscn` from git `HEAD` will immediately restore the group, HitZones, collision, and audio players, resolving Test 50 and `tools/test_infected_dog_scene.gd`.
2. **From Observation 4**: `tools/test_enemy_variants.gd` lines 12-24 explicitly assert `normal: 50hp/1.4spd`, `fast: 30hp/2.8spd`, `heavy: 160hp/0.8spd`, `dog: 50hp/4.5spd/2.0range`, and `boss: 500hp/1.1spd`. The uncommitted stat reductions in `EnemyBase.gd` directly cause assertion failures in regression suites. Keeping the canonical contract numbers in `EnemyBase.gd` is essential for suite integrity.
3. **From Observation 5**: Dead Target mobile reference visuals feature vibrant safety orange worker overalls, blue denim civilian jeans, necrotic skin, and glowing red eyes. Using substring matching on `mat.resource_name` (`"shirt"`, `"vest"`, `"jean"`, `"pant"`, `"blood"`, `"eye"`, `"iris"`, `"sclera"`) guarantees correct material tinting regardless of surface order differences between normal, fast, and heavy zombie meshes. Setting `emission_enabled = true` with red albedo and 3.0x energy on eye materials faithfully reproduces the glowing red eyes seen in benchmark screenshots.
4. **From Observation 6**: `Weapon.gd` lines 192-208 handle damage via `HitZone` first, falling back to humanoid height (`hit_point.y > y + 1.2`). Because canine height is < 0.6m, dogs without `HeadHitZone` can never be headshot. By updating `GameManager.spawn_zombie()` to instantiate `res://scenes/zombies/InfectedDog.tscn` for `"dog"` (and `BossZombie.tscn` for `"boss"`), gameplay accurately leverages dedicated HitZones (Head 2.5x, Body 1.0x), 18-bone animations, and canine audio.

---

## 3. Caveats

1. The raw skeletal mesh scene `scenes/zombies/models/infected_dog.tscn` must remain in `scenes/zombies/models/` while `scenes/zombies/InfectedDog.tscn` serves as the game entity `CharacterBody3D`. They must not be conflated.
2. In `AirportServiceRoad.tscn`, `SpawnBack` is positioned at `(0, 0, -18)` (in front of the player). While functional for linear road gameplay, true 360° rear ambushes would place it at `(0, 0, 18)`.
3. Audio streams (`sfx_dog_bark.wav`, `sfx_dog_attack.wav`, `sfx_dog_death.wav`) are mono 44.1kHz. `AudioStreamPlayer3D` handles spatial attenuation cleanly across 10-16m radii.

---

## 4. Conclusion

The R2 overhaul for zombies and audio is fully analyzed with root causes identified and clean solutions designed:
1. **Restore `scenes/zombies/InfectedDog.tscn`** from git `HEAD` (re-enabling 18-bone quadruped entity, 4.5 m/s speed, 50 HP, Head 2.5x / Body 1.0x HitZones, and dedicated dog audio).
2. **Revert `EnemyBase.gd` stats** to canonical contracts and implement semantic material name matching with glowing red eyes emission.
3. **Update `GameManager.gd`** to dispatch `"dog"` to `InfectedDog.tscn` and `"boss"` to `BossZombie.tscn`.
4. **Implement verification scripts** `test_m2_play.gd`, `test_capture_mission2.gd`, and `test_p_verify.gd` as blueprinted in `report.md`.

---

## 5. Verification Method

To independently verify the findings and solutions:

1. **Verify Test 50 & Dog Scene**:
   ```bash
   git checkout HEAD -- scenes/zombies/InfectedDog.tscn
   godot --headless -s tools/test_infected_dog_scene.gd
   godot --headless -s scenes/test/TestRunner.gd
   ```
   *Expected:* All 53/53 tests pass, including "Test 50: Mission 2 Dog Spawner & Hit Zones".

2. **Verify Enemy Archetypes & Contracts**:
   ```bash
   godot --headless -s tools/test_enemy_variants.gd
   godot --headless -s tools/stress_test_enemy_hierarchy_boss.gd
   ```
   *Expected:* All 8 variants (normal, fast, heavy, special, dog, rat, bat, boss) pass with zero assertion errors.

3. **Verify Mission 2 Play & Frame Capture**:
   ```bash
   godot --headless -s test_m2_play.gd
   godot --headless -s test_capture_mission2.gd
   ```
   *Expected:* Mission 2 completes 3 waves of dog encounters; `test_real_m2_capture.png` is generated with 720p resolution and visible animated canine pack.

