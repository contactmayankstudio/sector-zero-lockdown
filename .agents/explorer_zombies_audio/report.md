# Investigation Report: Zombie Roster, Quadruped Infected Dogs, and Audio (R2)

**Author:** `explorer_zombies_audio`  
**Date:** 2026-09-07  
**Scope:** R2 Visual & Audio Overhaul: Quadruped Infected Dog Archetype, Dead Target Humanoid Zombie Variations, Complete 12-Mission Enemy Roster, Audio Triggers, and Verification Scripts (`test_m2_play.gd`, `test_capture_mission2.gd`, `test_p_verify.gd`).

---

## 1. Executive Summary

An exhaustive investigation of the zombie roster, quadruped canine system, audio pipeline, and mission spawners was conducted on Godot Engine v4.3.stable.

### Core Discoveries:
1. **Critical Defect in `InfectedDog.tscn`**:
   The entity scene `res://scenes/zombies/InfectedDog.tscn` was accidentally overwritten in the working tree with the raw mesh model scene (`scenes/zombies/models/infected_dog.tscn`). It was stripped of its `CharacterBody3D` root, `InfectedDog.gd` script, `zombies` group registration, `HealthComponent`, `CollisionShape3D`, `HeadHitZone`, `BodyHitZone`, and audio nodes (`SfxGrowl`, `SfxAttack`, `SfxDeath`). This is the root cause of the failure in `TestRunner.gd` Test 50 ("Mission 2 Dog Spawner & Hit Zones") and `tools/test_infected_dog_scene.gd`. Restoring the canonical `CharacterBody3D` definition from git `HEAD` immediately resolves this failure.
2. **Canonical Enemy Stats Regression in `EnemyBase.gd`**:
   Uncommitted edits in `scripts/Zombies/EnemyBase.gd` altered canonical stats across multiple archetypes (e.g. Dog HP dropped from 50.0 to 38.0, speed dropped from 4.5 to 2.5, damage from 12.0 to 6.0; Normal HP dropped from 50.0 to 45.0; Fast speed from 2.8 to 2.0; Boss HP from 500.0 to 280.0). These stat regressions break existing regression tests (`tools/test_enemy_variants.gd`, `tools/stress_test_enemy_hierarchy_boss.gd`, `tools/test_infected_dog_scene.gd`, and `assets_tests/InfectedDogTest.gd`). The stats dictionary in `EnemyBase.gd` must be reverted to its canonical contract values.
3. **Flawed Humanoid Material Indexing vs Semantic Names**:
   An attempt to add Dead Target outfit variations in `EnemyBase.gd` (lines 247-278) used hardcoded surface indices (`s_idx in [1, 3, 11, 14]`). On `zombie_normal.obj`, surface 1 is Hair, 3 is Eye Iris, 11 is Belt, and 14 is Shoes—resulting in safety orange hair and shoes rather than jumpsuits. On `zombie_fast.tscn`, only 8 surfaces exist, causing array out-of-bounds or bizarre coloring. Sclera and Iris never had `emission` enabled, missing Dead Target's signature glowing red zombie eyes. By switching to semantic name matching on `mat.resource_name` (`Mat_HumanSkin*`, `Mat_OxfordShirt`, `Mat_DenimJeans`, `Mat_SafetyVest`, `Mat_HumanEye*`, `Mat_Dog*`), outfit palettes (Safety Orange Worker, Civilian Denim, Necrotic Diseased) and glowing red eyes can be applied accurately across all zombie models.
4. **Mission 2 Spawner Delegation**:
   `scenes/environments/AirportServiceRoad.tscn` sets `zombie_scene = "res://scenes/zombies/Zombie.tscn"`. `GameManager.gd`'s `spawn_zombie()` instantiates `zombie_scene` directly for all enemies. When `"dog"` is spawned, it spawns a humanoid `Zombie.tscn` without `HeadHitZone` or `BodyHitZone`, falling back to `Weapon.gd`'s humanoid height check (`hit_point.y > y + 1.2`), which makes headshots on dogs impossible since their height is < 0.6m. Updating `GameManager.spawn_zombie()` to instantiate `res://scenes/zombies/InfectedDog.tscn` when `archetype == "dog"` (and `res://scenes/zombies/BossZombie.tscn` when `archetype == "boss"`) ensures the genuine 4-legged skeletal dog with proper HitZones and audio spawns in Mission 2 and all subsequent dog-enabled missions.
5. **Canine Audio Pipeline**:
   Dedicated audio files exist in `audio/zombies/`:
   - `sfx_dog_bark.wav` / `sfx_dog_bark.tres` (44KB/75KB, bark and snarl)
   - `sfx_dog_attack.wav` / `sfx_dog_attack.tres` (44KB/58KB, vicious bite attack)
   - `sfx_dog_death.wav` / `sfx_dog_death.tres` (95KB/127KB, death whimper/collapse)
   The audio streams are fully functional, correctly imported, and ready for integration via `SfxGrowl`, `SfxAttack`, and `SfxDeath`.

---

## 2. Deep Dive: Quadruped Infected Dog Archetype

### 2.1 Scene Hierarchy & Structural Integrity
The canonical entity structure for `scenes/zombies/InfectedDog.tscn` is:
```
InfectedDog (CharacterBody3D, groups=["zombies"], script=InfectedDog.gd)
├── CollisionShape3D (BoxShape3D: size Vector3(0.45, 0.5, 0.9), transform: y=0.35)
├── MeshInstance3D (visible = false)
├── AnimationPlayer (fallback player)
├── NavigationAgent3D (path_desired_distance=0.5, target_desired_distance=0.5)
├── HealthComponent (max_health=50.0)
├── SfxGrowl (AudioStreamPlayer3D, stream=sfx_dog_bark.wav, max_distance=16.0)
├── SfxAttack (AudioStreamPlayer3D, stream=sfx_dog_attack.wav, max_distance=10.0)
├── SfxDeath (AudioStreamPlayer3D, stream=sfx_dog_death.wav, max_distance=14.0)
├── SfxTimer (Timer, one_shot=true, timeout -> _on_sfx_timer_timeout)
├── SkeletalModel (instance of res://assets/3d/zombies/infected_dog.glb)
├── HeadHitZone (Area3D, script=HitZone.gd, zone_type=HEAD(0), multiplier=2.5, pos=(0, 0.52, -0.45))
│   └── CollisionShape3D (SphereShape3D: radius=0.22)
└── BodyHitZone (Area3D, script=HitZone.gd, zone_type=CHEST(1), multiplier=1.0, pos=(0, 0.38, 0.05))
    └── CollisionShape3D (BoxShape3D: size=Vector3(0.45, 0.45, 0.7))
```

### 2.2 18-Bone Armature & Skeletal Rig
The model in `assets/3d/zombies/infected_dog.glb` (and `scenes/zombies/models/infected_dog.tscn`) contains an authentic 18-bone quadruped canine skeleton:
- `bones/0`: `Root` (parent: -1)
- `bones/1`: `Pelvis` (parent: 0, pos: (0, 0.45, 0.35))
- `bones/2`: `Spine` (parent: 1, pos: (0, 0.25, 0))
- `bones/3`: `Chest` (parent: 2, pos: (0, 0.25, 0))
- `bones/4`: `Neck` (parent: 3, pos: (0, 0.18, 0))
- `bones/5`: `Head` (parent: 4, pos: (0, 0.17, 0))
- `bones/6 - 8`: `UpperLeg.FL` -> `LowerLeg.FL` -> `Paw.FL` (Front Left leg)
- `bones/9 - 11`: `UpperLeg.FR` -> `LowerLeg.FR` -> `Paw.FR` (Front Right leg)
- `bones/12 - 14`: `UpperLeg.BL` -> `LowerLeg.BL` -> `Paw.BL` (Back Left leg)
- `bones/15 - 17`: `UpperLeg.BR` -> `LowerLeg.BR` -> `Paw.BR` (Back Right leg)

### 2.3 Animations
The animation library contains 7 complete tracks:
1. `idle`: Panting, subtle chest/spine heave, low head position.
2. `walk`: 4-legged quadruped trot.
3. `run`: Aggressive low-slung sprint with paws reaching forward.
4. `attack`: Pounce/leap forward with jaws snapping.
5. `hit_head`: Head jerks backward violently upon receiving headshot.
6. `hit_body`: Midsection recoils from high-caliber body impact.
7. `death`: Hind legs buckle, forelegs collapse, dog rolls sideways onto ground.

### 2.4 Ground-Level Collision & HitZones
- **Base Collision Shape**: `BoxShape3D` of size `(0.45, 0.5, 0.9)` centered at `y = 0.35`. Unlike tall humanoid capsules (height 1.8m, center 0.9m), the canine capsule is low to the ground, matching the physical volume of a charging predator.
- **HeadHitZone**: Centered at `(0, 0.52, -0.45)` with `SphereShape3D(radius=0.22)`. Configured with `zone_type = HitZone.ZoneType.HEAD` (enum 0) and `damage_multiplier = 2.5`.
- **BodyHitZone**: Centered at `(0, 0.38, 0.05)` with `BoxShape3D(0.45, 0.45, 0.7)`. Configured with `zone_type = HitZone.ZoneType.CHEST` (enum 1) and `damage_multiplier = 1.0`.
- **Hit Detection Synergy**: `Weapon.gd` lines 192-198 directly check `if hit_collider is HitZone:`. When a raycast strikes `HeadHitZone`, it yields an immediate headshot, 2.5x critical damage, and triggers `had_headshot = true`.

### 2.5 Audio Behavior
- **Ambient Growling / Barking (`SfxGrowl`)**: Driven by `SfxTimer` which triggers every 4.0 to 8.0 seconds via `_on_sfx_timer_timeout()`. Plays `audio/zombies/sfx_dog_bark.wav`.
- **Attack Pounce (`SfxAttack`)**: Triggered in `EnemyBase.gd` inside `_perform_attack()` when the dog reaches melee range (2.0m). Plays `audio/zombies/sfx_dog_attack.wav`.
- **Death Whimper (`SfxDeath`)**: Triggered in `InfectedDog.gd` inside `_on_died()`. Plays `audio/zombies/sfx_dog_death.wav` with 14m attenuation falloff.

---

## 3. Humanoid Zombie Variations (Dead Target Benchmark Match)

Inspection of reference visuals in `/home/am/Music/real/` shows the hallmark visual identity of Dead Target mobile:
1. High-contrast, gritty industrial aesthetics.
2. Safety orange worker jumpsuits stained with dark blood.
3. Civilian clothing: light shirts and indigo blue denim jeans torn and bloody.
4. Diseased necrotic flesh with putrid olive/green undertones.
5. Menacing, glowing red eyes that pierce darkness and fog.

### 3.1 Model Surface Analysis
Running dynamic material introspection across the model assets revealed the following exact surface names:

| Model | Surfaces & Materials |
|---|---|
| `zombie_normal` | 0: `Mat_HumanSkin`<br>1: `Mat_HumanHair`<br>2: `Mat_HumanEyeSclera`<br>3: `Mat_HumanEyeIris`<br>4: `Mat_HumanSkinPale`<br>5: `Mat_HumanLips`<br>6: `Mat_HumanTeeth`<br>7: `Mat_HumanBlood`<br>8: `Mat_OxfordShirt`<br>9: `Mat_MetalBuckle`<br>10: `Mat_DriedBlood`<br>11: `Mat_LeatherBelt`<br>12: `Mat_DenimJeans`<br>13: `Mat_WristWatch`<br>14: `Mat_LeatherShoes` |
| `zombie_fast` | 0: `Mat_HumanSkinFast`<br>1: `Mat_ScleraFast`<br>2: `Mat_EyesFast`<br>3: `Mat_HumanHairFast`<br>4: `Mat_BloodFast`<br>5: `Mat_RunnerJacket`<br>6: `Mat_RunnerShorts`<br>7: `Mat_RunningShoes` |
| `zombie_heavy` | 0: `Mat_HumanSkinHeavy`<br>1: `Mat_HumanHairHeavy`<br>2: `Mat_WorkerShirt`<br>3: `Mat_SafetyVest`<br>4: `Mat_ReflectiveStripe`<br>5: `Mat_Rebar`<br>6: `Mat_BloodHeavy`<br>7: `Mat_CanvasWorkPants`<br>8: `Mat_WorkBoots` |
| `zombie_boss` | 0: `Mat_HumanSkinBoss`<br>1: `Mat_TacticalVestBoss`<br>2: `Mat_TacticalBDU`<br>3: `Mat_ExoBlade`<br>4: `Mat_BioHazardGlow`<br>5: `Mat_CombatBootsBoss` |
| `infected_dog` | 0: `Mat_DogFur`<br>1: `Mat_DogFlesh`<br>2: `Mat_DogTeeth`<br>3: `Mat_DogEyes` |

### 3.2 Semantic Outfit Palettes Implementation
Rather than brittle integer indices, `_apply_archetype()` in `EnemyBase.gd` must match by lowercase substring on `mat.resource_name`:

```gdscript
# Select 1 of 3 Dead Target visual archetypes per spawned humanoid zombie
var outfit_variant = randi() % 3

for s_idx in range(sk_mesh.mesh.get_surface_count()):
	var mat = sk_mesh.get_active_material(s_idx)
	if not mat is StandardMaterial3D:
		continue
	var new_mat = mat.duplicate()
	var mname = mat.resource_name.to_lower()
	
	# 1. Glowing Red Eyes (All Humanoids)
	if mname.contains("eye") or mname.contains("iris") or mname.contains("sclera"):
		new_mat.albedo_color = Color(0.9, 0.1, 0.05, 1.0)
		new_mat.emission_enabled = true
		new_mat.emission = Color(1.0, 0.05, 0.02)
		new_mat.emission_energy_multiplier = 3.0
		sk_mesh.set_surface_override_material(s_idx, new_mat)
		continue
		
	# 2. Blood Stains
	if mname.contains("blood"):
		new_mat.albedo_color = Color(0.68, 0.04, 0.04, 1.0)
		sk_mesh.set_surface_override_material(s_idx, new_mat)
		continue

	# 3. Outfit Variation Application
	match outfit_variant:
		0: # DEAD TARGET WORKER (Safety Orange Overalls & Blue Undershirt)
			if mname.contains("shirt") or mname.contains("vest") or mname.contains("jacket"):
				new_mat.albedo_color = Color(0.96, 0.45, 0.05, 1.0) # Vivid Orange
			elif mname.contains("jean") or mname.contains("pant") or mname.contains("short"):
				new_mat.albedo_color = Color(0.18, 0.35, 0.65, 1.0) # Work Blue
			elif mname.contains("skin") or mname.contains("pale") or mname.contains("lips"):
				new_mat.albedo_color = Color(0.72, 0.74, 0.68, 1.0) # Pale necrotic
				
		1: # DEAD TARGET CIVILIAN (Worn Denim Jeans & Light Stained Shirt)
			if mname.contains("jean") or mname.contains("pant") or mname.contains("short"):
				new_mat.albedo_color = Color(0.22, 0.36, 0.60, 1.0) # Denim Indigo
			elif mname.contains("shirt") or mname.contains("vest") or mname.contains("jacket"):
				new_mat.albedo_color = Color(0.80, 0.80, 0.82, 1.0) # Stained Light Grey
			elif mname.contains("skin") or mname.contains("pale") or mname.contains("lips"):
				new_mat.albedo_color = Color(0.75, 0.72, 0.68, 1.0) # Ashen skin
				
		2: # NECROTIC DISEASED (Putrid Olive Flesh & Dark Grime Attire)
			if mname.contains("skin") or mname.contains("pale") or mname.contains("lips"):
				new_mat.albedo_color = Color(0.50, 0.62, 0.44, 1.0) # Sickly olive-green
			elif mname.contains("shirt") or mname.contains("vest") or mname.contains("jacket"):
				new_mat.albedo_color = Color(0.28, 0.30, 0.26, 1.0) # Grimy Olive/Charcoal
			elif mname.contains("jean") or mname.contains("pant") or mname.contains("short"):
				new_mat.albedo_color = Color(0.20, 0.20, 0.22, 1.0) # Dark Charcoal
				
	sk_mesh.set_surface_override_material(s_idx, new_mat)
```

---

## 4. Complete 12-Mission Enemy Roster & Contracts

### 4.1 Canonical Archetype Contracts
All tests (`test_enemy_variants.gd`, `stress_test_enemy_hierarchy_boss.gd`, `test_infected_dog_scene.gd`) enforce strict contract values:

| Archetype | HP | Speed (m/s) | Attack Range (m) | Attack Dmg | Attack Interval | Reward | Model Scene |
|---|---|---|---|---|---|---|---|
| **normal** | 50.0 | 1.4 | 1.7 | 6.0 | 1.2s | $10 | `zombie_normal.tscn` |
| **fast** | 30.0 | 2.8 | 1.7 | 5.0 | 1.0s | $15 | `zombie_fast.tscn` |
| **heavy** | 160.0 | 0.8 | 2.2 | 14.0 | 1.8s | $25 | `zombie_heavy.tscn` |
| **special / spitter** | 40.0 | 1.2 | 14.0 | 8.0 | 2.5s | $20 | `zombie_normal.tscn` |
| **dog** | 50.0 | 4.5 | 2.0 | 12.0 | 1.8s | $15 | `InfectedDog.tscn` |
| **rat / rats** | 15.0 | 3.8 | 1.2 | 4.0 | 0.8s | $5 | Procedural / Mesh |
| **bat / bats** | 12.0 | 3.6 | 1.5 | 3.0 | 1.0s | $5 | Procedural / Mesh |
| **boss** | 500.0 | 1.1 | 2.5 | 22.0 | 2.0s | $100 | `BossZombie.tscn` |

### 4.2 Mission Distribution Matrix

| Mission | Display Name | Wave Count | Target Count | Archetype Weights | Dog Presence |
|---|---|---|---|---|---|
| **01** | First Contact | 3 | 15 | normal: 70%, fast: 30% | No |
| **02** | Feral Pack | 3 | 32 | dog: 100% | **YES (Exclusive)** |
| **03** | Crossfire | 3 | 22 | normal: 50%, dog: 50% | **YES (50%)** |
| **04** | Rat King | 3 | Dynamic | dog: 60%, fast: 40% | **YES (60%)** |
| **05** | Containment Breach | 3 | 30 | normal: 40%, fast: 30%, dog: 30% | **YES (30%)** |
| **06** | Patient Zero | 3 | 25 | normal: 40%, heavy: 30%, spitter: 30% | No |
| **07** | Dead Mall | 3 | 30 | normal: 30%, fast: 30%, dog: 40% | **YES (40%)** |
| **08** | Blackout | 3 | Dynamic | normal: 25%, fast: 25%, heavy: 25%, dog: 25% | **YES (25%)** |
| **09** | Fortified | 3 | 35 | heavy: 50%, dog: 50% | **YES (50%)** |
| **10** | Mutation | 3 | 30 | normal: 30%, heavy: 40%, spitter: 30% | No |
| **11** | Overrun | 3 | Dynamic | heavy: 30%, fast: 20%, dog: 20%, spitter: 30% | **YES (20%)** |
| **12** | Lockdown | 3 | Boss (1+) | normal: 20%, fast: 15%, heavy: 20%, dog: 15%, spitter: 15%, boss: 15% | **YES (15%)** |

---

## 5. Spawner Architecture & Integration

In `scripts/GameManager.gd`, `spawn_zombie()` should instantiate dedicated scenes based on archetype:
```gdscript
func spawn_zombie(specific_archetype: String = "", direction: String = ""):
	if spawn_points.is_empty() or not zombie_scene:
		return
		
	if not player_ref and get_tree():
		player_ref = get_tree().get_first_node_in_group("player")
	var player_pos = player_ref.global_position if player_ref else Vector3.ZERO
	
	# Select spawn point matching direction if provided
	var candidate_points: Array[Node3D] = []
	if direction != "":
		for sp in spawn_points:
			if sp and sp.name.to_lower().contains(direction.to_lower()):
				candidate_points.append(sp)
				
	if candidate_points.is_empty():
		for sp in spawn_points:
			if sp and sp.global_position.distance_to(player_pos) > 10.0:
				candidate_points.append(sp)
			
	var spawn_point = candidate_points.pick_random() if not candidate_points.is_empty() else spawn_points.pick_random()
	if not spawn_point:
		return
		
	var arch = specific_archetype if specific_archetype != "" else _pick_archetype()
	
	# Archetype-to-Prefab Dispatch
	var zombie: Node3D = null
	if arch == "dog":
		var dog_scene = load("res://scenes/zombies/InfectedDog.tscn")
		if dog_scene:
			zombie = dog_scene.instantiate()
	elif arch == "boss":
		var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
		if boss_scene:
			zombie = boss_scene.instantiate()
			
	if not zombie:
		zombie = zombie_scene.instantiate()
		zombie.archetype = arch
		
	add_child(zombie)
	if zombie.has_method("_apply_archetype"):
		zombie._apply_archetype()
	zombie.global_position = spawn_point.global_position
	
	zombies_alive += 1
	zombie.tree_exited.connect(_on_zombie_death)
```

---

## 6. Verification Scripts Blueprints

Three target verification scripts are referenced in `ORIGINAL_REQUEST.md`:

### 6.1 `test_m2_play.gd` (Headless Mission 2 Full Play-Test)
**Purpose:** Authenticate Mission 2 full loop under headless simulation.
- **Path:** `scripts/Tools/test_m2_play.gd` (or `test_m2_play.gd` in root).
- **Core Checks:**
  1. Load `scenes/environments/AirportServiceRoad.tscn`.
  2. Verify Player, GameManager, ImpactPool, AmbiencePlayer nodes.
  3. Load `resources/missions/mission_02.tres`, verify `spawn_config` specifies `"dog"`.
  4. Instantiate `InfectedDog.tscn`, verify:
     - Root is `CharacterBody3D`, in group `"zombies"`.
     - `Skeleton3D` contains 18 bones.
     - `AnimationPlayer` contains `run`, `attack`, `hit_head`, `hit_body`, `death`.
     - `HeadHitZone` at `(0, 0.52, -0.45)`, type HEAD, 2.5x multiplier.
     - `BodyHitZone` at `(0, 0.38, 0.05)`, type CHEST, 1.0x multiplier.
     - `SfxGrowl`, `SfxAttack`, `SfxDeath` audio players are wired with valid streams.
  5. Run combat physics simulation:
     - Headshot: 10 dmg -> 25 dmg applied; triggers `is_headshot = true` and `hit_head` reaction.
     - Bodyshot: 10 dmg -> 10 dmg applied; triggers `is_headshot = false`.
     - Fatal blow triggers death sequence, disables collision, plays `death` animation and `sfx_death`.
  6. Wave progression simulation: Advance waves 1 through 3 and verify victory signal.

### 6.2 `test_capture_mission2.gd` (Headless Visual Frame Capture)
**Purpose:** Capture a 1280x720 in-engine gameplay frame to verify visual fidelity against `/home/am/Music/real/`.
- **Path:** `scripts/Tools/test_capture_mission2.gd` (or `test_capture_mission2.gd` in root).
- **Core Checks:**
  1. Create a `SubViewport` at 1280x720 with MSAA/FXAA enabled.
  2. Instantiate `scenes/environments/AirportServiceRoad.tscn`.
  3. Spawn 4 `InfectedDog` instances charging towards camera.
  4. Spawn 2 humanoid zombies with Dead Target randomized outfits (Safety Orange Worker & Civilian Denim with glowing red eyes).
  5. Run 30 frames of rendering to settle lighting, materials, and skeletal poses.
  6. Retrieve `viewport.get_texture().get_image()` and save to `test_real_m2_capture.png`.
  7. Validate file creation and file size > 50KB.

### 6.3 `test_p_verify.gd` (Player, Weapons, & HUD Verification)
**Purpose:** Verify player first-person SWAT arms, weapon models, auto-reload, and HUD interactions.
- **Path:** `scripts/Tools/test_p_verify.gd` (or `test_p_verify.gd` in root).
- **Core Checks:**
  1. Instantiate `scenes/player/Player.tscn`.
  2. Verify camera has `FPSArms` child mesh/rig.
  3. Iterate across all 10 weapons: `usp45`, `m4a1`, `remington870`, `mp5`, `ak47`, `desert_eagle`, `spas12`, `awp`, `grenade_launcher`, `crossbow`. Switch active weapon and verify model instance exists and is visible.
  4. Fire weapon until magazine is empty; verify auto-reload triggers without weapon lockup.
  5. Check mobile HUD nodes: virtual joystick, fire button, reload button, switch button, grenade button.
  6. Verify mouse mode remains `Input.MOUSE_MODE_VISIBLE`.

---

## 7. Actionable Implementation Plan for Worker Agent

1. **Restore `InfectedDog.tscn`**:
   - Revert `scenes/zombies/InfectedDog.tscn` to the git `HEAD` state using `git checkout HEAD -- scenes/zombies/InfectedDog.tscn`.
   - Ensure the raw model scene remains at `scenes/zombies/models/infected_dog.tscn`.
2. **Revert and Polish `EnemyBase.gd`**:
   - Revert stats in `archetype_data` back to canonical contract (Dog: 50 HP, 4.5 speed, 12 damage, 2.0 range, 1.8 interval; Boss: 500 HP, 1.1 speed, 22 damage; Normal: 50 HP, 1.4 speed; Fast: 30 HP, 2.8 speed; Heavy: 160 HP, 0.8 speed).
   - Replace the integer-based material loop with the semantic name matching block described in Section 3.2.
   - Enable `emission` on eyes to produce glowing red zombie eyes.
3. **Update `GameManager.gd`**:
   - Update `spawn_zombie()` to instantiate `InfectedDog.tscn` when archetype is `"dog"` and `BossZombie.tscn` when archetype is `"boss"`.
4. **Deploy Verification Scripts**:
   - Implement `test_m2_play.gd`, `test_capture_mission2.gd`, and `test_p_verify.gd` based on Section 6 blueprints.
5. **Run Verification**:
   - Run `godot --headless -s scenes/test/TestRunner.gd` -> Verify all 53/53 tests pass.
   - Run `godot --headless -s tools/test_infected_dog_scene.gd` -> Verify 100% pass.
   - Run `godot --headless -s tools/test_enemy_variants.gd` -> Verify 100% pass.
   - Run `godot --headless -s tools/stress_test_enemy_hierarchy_boss.gd` -> Verify 100% pass.
   - Run `godot --headless -s test_m2_play.gd` -> Verify Mission 2 complete pass.

