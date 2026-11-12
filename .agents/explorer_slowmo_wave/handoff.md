# Handoff Report: Requirement R3 & R4 — Cinematic Last-Kill Slow-Motion Cam & Performance/Verification Targets

## Core Summary
This investigation covers Requirement R3 (Cinematic Last-Kill Slow-Motion Cam upon elimination of the final zombie in Wave 3 or Giant Butcher Boss defeat: 0.2x time scale for 1.8 real seconds with audio pitch/bass dip before restoring normal speed for ResultUI) and Requirement R4 (Mobile gl_compatibility performance budgets, 30 FPS target, zero memory growth <1MB across 3 cycles, and headless verification suites).

---

## 1. Observation

### 1.1 Codebase Structure & File Paths
- **Spawners & Waves**:
  - `res://scripts/GameManager.gd` is attached to `ZombieSpawner` in all 9 environment scenes (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`, `RailwayStation.tscn`, `AbandonedTrain.tscn`, `DarkIndustrial.tscn`, `ApartmentComplex.tscn`, `NightCityStreet.tscn`, `AirportTerminal.tscn`, `FinalLockdown.tscn`).
  - `scripts/Gameplay/GameManager.gd` is an older deprecated prototype script not referenced by any `.tscn` file.
  - `res://scripts/Zombies/ZombieDirector.gd` exists as an alternative wave director used in earlier prototypes and stress tests (`tools/stress_test_enemy_hierarchy_boss.gd`), but is not active in live mission scenes.
- **Mission Autoload**:
  - `res://scripts/MissionManager.gd` is configured as singleton autoload `/root/MissionManager` in `project.godot` (line 25).
- **Audio Autoload**:
  - `res://scripts/AudioManager.gd` is configured as singleton autoload `/root/AudioManager` in `project.godot` (line 26).
- **Result UI**:
  - `res://scenes/UI/ResultUI.tscn` uses `res://scripts/ResultUI.gd` and is instanced as a direct child under the root of every environment scene.

### 1.2 Wave Tracking & Completion Logic in `GameManager.gd`
- In `scripts/GameManager.gd`:
  - Lines 9-12:
    ```gdscript
    var current_wave: int = 0
    var zombies_to_spawn: int = 0
    var zombies_alive: int = 0
    var is_spawning_wave: bool = false
    ```
  - Lines 34-43:
    ```gdscript
    func start_next_wave():
        current_wave += 1
        var total_waves = mission.wave_count if mission else 3
        if is_endless_mode:
            total_waves = 0  # Signal infinite mode to HUD
        
        var event_bus = get_node_or_null("/root/EventBus")
        if event_bus:
            event_bus.wave_started.emit(current_wave, total_waves)
    ```
  - Lines 182-183:
    ```gdscript
    zombies_alive += 1
    zombie.tree_exited.connect(_on_zombie_death)
    ```
  - Lines 221-226:
    ```gdscript
    func _on_zombie_death():
        zombies_alive = max(0, zombies_alive - 1)
        if not is_inside_tree() or not get_tree():
            return
        if not is_spawning_wave and zombies_alive <= 0:
            _check_wave_end()
    ```
  - Lines 228-237:
    ```gdscript
    func _check_wave_end():
        if not is_inside_tree() or not get_tree():
            return
        var mission_mgr = get_node_or_null("/root/MissionManager")
        if mission_mgr:
            mission_mgr.on_wave_completed()
        var event_bus = get_node_or_null("/root/EventBus")
        if event_bus:
            event_bus.wave_completed.emit(current_wave)
    ```

### 1.3 Enemy Death & Tree Exit Timing in `EnemyBase.gd` and `BossZombie.gd`
- In `scripts/Zombies/EnemyBase.gd` (lines 610-645):
  ```gdscript
  func _on_died():
      if is_dead: return
      is_dead = true
      ai_state = AIState.DEAD
      
      if collision_shape:
          collision_shape.set_deferred("disabled", true)
      velocity = Vector3.ZERO
      
      _play_anim("death")
      if model_instance and archetype != "dog":
          var tw = create_tween()
          tw.tween_property(model_instance, "position:y", -0.4, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
          tw.parallel().tween_property(model_instance, "rotation:x", deg_to_rad(75.0), 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
      if sfx_death and is_inside_tree():
          sfx_death.play()
          
      var event_bus = get_node_or_null("/root/EventBus")
      if event_bus:
          event_bus.enemy_killed.emit(archetype, last_hit_was_headshot, global_position)
          
      var save_mgr = get_node_or_null("/root/SaveManager")
      if save_mgr:
          save_mgr.add_cash(reward_on_kill)
          
      var mission_mgr = get_node_or_null("/root/MissionManager")
      if mission_mgr:
          if archetype == "boss":
              mission_mgr.on_boss_killed()
          else:
              mission_mgr.on_zombie_killed()
              
      if get_tree():
          await get_tree().create_timer(2.2).timeout
      queue_free()
  ```
- In `scenes/zombies/BossZombie.gd` (lines 152-190):
  ```gdscript
  func _on_died():
      if is_dead: return
      is_dead = true
      ai_state = AIState.DEAD
      ...
      var mission_mgr = get_node_or_null("/root/MissionManager")
      if mission_mgr:
          mission_mgr.on_boss_killed()
          
      await get_tree().create_timer(3.5).timeout
      queue_free()
  ```

### 1.4 Immediate Victory Flow in `MissionManager.gd` and `ResultUI.gd`
- In `scripts/MissionManager.gd`:
  - Lines 100-108:
    ```gdscript
    func on_boss_killed():
        boss_kill_count += 1
        _notify_objective()
        check_objective()

    func on_wave_completed():
        wave_count += 1
        _notify_objective()
        check_objective()
    ```
  - Lines 129-146:
    ```gdscript
    func check_objective():
        if not current_mission: return
        var completed = false
        match current_mission.objective_type:
            MissionData.ObjectiveType.KILL_COUNT:
                if wave_count >= current_mission.wave_count and kill_count >= current_mission.target_count:
                    completed = true
            MissionData.ObjectiveType.SURVIVE_WAVES:
                if not current_mission.is_endless and wave_count >= current_mission.wave_count:
                    completed = true
            MissionData.ObjectiveType.BOSS_KILL:
                if wave_count >= current_mission.wave_count and boss_kill_count >= current_mission.target_count:
                    completed = true
        
        if completed:
            finish_mission(true)
    ```
  - Line 217:
    ```gdscript
    mission_completed.emit(current_mission)
    ```
- In `scripts/ResultUI.gd`:
  - Lines 18-19:
    ```gdscript
    if not mission_mgr.mission_completed.is_connected(_on_mission_completed):
        mission_mgr.mission_completed.connect(_on_mission_completed)
    ```
  - Lines 78-85:
    ```gdscript
    modulate.a = 0.0
    scale = Vector2(0.96, 0.96)
    pivot_offset = size / 2.0
    show()
    var in_tween = create_tween().set_parallel(true)
    in_tween.tween_property(self, "modulate:a", 1.0, 0.22)
    in_tween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    ```

### 1.5 Engine & Audio API Capabilities in Godot 4.3.stable
- `Engine.time_scale`: controls delta step across physics, processing, and standard timers.
- `SceneTree.create_timer(time_sec, process_always, process_in_physics, ignore_time_scale)`:
  - Signature verified via Godot 4.3 extension API:
    `create_timer(time_sec: float, process_always: bool = true, process_in_physics: bool = false, ignore_time_scale: bool = false) -> SceneTreeTimer`
  - Parameter 4 `ignore_time_scale`: when `true`, timer operates in unscaled wall-clock seconds.
- `AudioServer.playback_speed_scale`:
  - Verified present in Godot 4.3 `AudioServer` class properties (`Property: playback_speed_scale float`).
  - Methods: `set_playback_speed_scale(scale: float)` / `get_playback_speed_scale() -> float`.
  - Built-in global playback speed & pitch scaling across all streams.
- `AudioEffectLowPassFilter`:
  - Class verified present in Godot 4.3 (`AudioEffectLowPassFilter` inherits `AudioEffectFilter`).
  - Properties: `cutoff_hz: float` (range 20 to 20500 Hz), `resonance: float` (0.1 to 1.0), `db: int`.
- Audio buses:
  - Currently `AudioServer.get_bus_count() == 1` ("Master").
  - `AudioManager.gd` (line 46) sends streams to "Master".

### 1.6 Verification Suite Baselines Observed via Direct Execution
1. `tools/validate_all_missions.gd`:
   - Command: `godot --headless --script tools/validate_all_missions.gd`
   - Output: `🎉 ALL 12 MISSIONS + ENDLESS PASSED 100% VALIDATION!`
   - Result: Exit code 0, 13/13 missions pass (Player, ZombieSpawner points >= 4, Ground Collision, ResultUI, ImpactPool, AmbiencePlayer, HorrorDronePlayer).
2. `scenes/test/test_realistic_overhaul.tscn`:
   - Command: `godot --headless scenes/test/test_realistic_overhaul.tscn`
   - Output: `TOTAL VERIFIED: 88 / 88 PASSED (0 FAILED)`
   - Result: Exit code 0 across Tier 1, Tier 2, Tier 3, Tier 4.
   - Specific checks:
     - TC-M01 (Dynamic light budget <= 3): PASS (found 2 dynamic lights).
     - TC-M02 (30 FPS lock, 60 Hz physics ticks): PASS.
     - TC-M03 (ASTC/ETC2 VRAM compression): PASS.
     - TC-M04 (Headless execution): PASS.
     - TC-M05 (3-cycle load/unload memory growth): PASS (`0.01 MB`, well under 2.0 MB / 1.0 MB limits).
3. `scripts/Tools/test_memory_lifecycle.gd`:
   - Command: `godot --headless --script scripts/Tools/test_memory_lifecycle.gd`
   - Output: `Memory growth between Cycle 2 and Cycle 5: +0.01 MB`
   - Result: Exit code 0, `ALL MEMORY LIFECYCLE TESTS PASSED CLEANLY!`.

---

## 2. Logic Chain

### 2.1 The Death Timing vs `tree_exited` Problem
1. In `EnemyBase.gd:643`, when a zombie dies, `_on_died()` starts its death animation and then executes `await get_tree().create_timer(2.2).timeout` before calling `queue_free()`.
2. In `GameManager.gd:183`, `zombie.tree_exited.connect(_on_zombie_death)` decrements `zombies_alive` only when `queue_free()` executes.
3. Therefore, `zombies_alive` remains non-zero for 2.2 seconds after the enemy is already killed.
4. If the slow-motion cam triggers on `_check_wave_end()` (via `_on_zombie_death`), the slow-motion would begin 2.2 seconds *after* the final kill has already happened. The corpse would already be freed and deleted from the tree.
5. **Inference**: Detection of the final kill must occur inside `_on_died()` (or when fatal damage drops health <= 0), NOT on `tree_exited`. When lethal damage is dealt to the final enemy of Wave 3 (or the Boss), the slow-motion cam must activate immediately at t=0 so the player witnesses the fatal hit, blood spray, decapitation, and collapse in slow-motion.

### 2.2 Time Scale and Real-Time Duration (0.2x for 1.8s)
1. Setting `Engine.time_scale = 0.2` reduces physics and process time by 80%.
2. A standard `SceneTree.create_timer(1.8)` uses default `ignore_time_scale = false`. At 0.2x speed, an unhandled 1.8s timer takes `1.8 / 0.2 = 9.0` real wall-clock seconds.
3. In Godot 4.3, `SceneTree.create_timer(1.8, true, false, true)` explicitly sets `ignore_time_scale = true`.
4. Therefore, `await get_tree().create_timer(1.8, true, false, true).timeout` guarantees the slow-motion cam lasts exactly 1.8 real seconds, during which `1.8 * 0.2 = 0.36` seconds of in-game simulation time elapse.
5. In addition, standard node `Timer` instances lack an `ignore_time_scale` property and should not be used for real-time slow-mo duration. `SceneTreeTimer` with `ignore_time_scale = true` or tracking `Time.get_ticks_msec()` in a process loop with `PROCESS_MODE_ALWAYS` is required.

### 2.3 Audio Pitch and Bass Dip
1. `Engine.time_scale` in Godot 4 only affects process and physics loops; it does not alter audio stream playback speed or pitch.
2. In Godot 4.3, `AudioServer` exposes `playback_speed_scale` (default 1.0). Setting `AudioServer.playback_speed_scale = 0.5` or `0.4` lowers the playback pitch and speed of all active audio channels uniformly with zero CPU overhead and zero memory allocation.
3. To deliver the cinematic "bass dip" (muffled underwater rumble), adding an `AudioEffectLowPassFilter` on the Master bus (bus 0) and lowering `cutoff_hz` from 20,500 Hz down to 400–600 Hz creates the dramatic low-frequency isolation.
4. When the 1.8s duration completes:
   - `AudioServer.playback_speed_scale` is restored to `1.0`.
   - `AudioEffectLowPassFilter` is disabled (`AudioServer.set_bus_effect_enabled(0, lpf_idx, false)`) or its cutoff returned to 20,500 Hz.
   - `Engine.time_scale` is restored to `1.0`.
   - Zero orphaned effects or memory leaks occur.

### 2.4 Victory / Result UI Sequence Coordination
1. In `MissionManager.gd:145`, `check_objective()` calls `finish_mission(true)`, which immediately emits `mission_completed` and opens `ResultUI`.
2. In `ResultUI.gd:78-85`, opening `ResultUI` immediately plays victory audio (`audio_mgr.play_victory()`) and begins tweening UI elements.
3. If `finish_mission(true)` is delayed until the 1.8s slow-motion duration completes:
   - Gameplay remains active during slowmo.
   - Enemy death animation and blood particles play at 0.2x speed.
   - Audio pitch and bass dip remain active.
   - When 1.8s expires, time and audio return to 1.0x.
   - Then `MissionManager.finish_mission(true)` fires, `ResultUI` appears at normal speed, and victory fanfare plays cleanly.

### 2.5 Node Cleanup, Mobile Rendering & Memory Stability
1. Godot 4.3's `gl_compatibility` renderer uses OpenGL ES 3.0 / WebGL 2.0. Dynamic light count must stay <= 3 (TC-M01 verified: 2 lights in UrbanStreet).
2. Particles: `ImpactPool.gd` uses pre-allocated pools (16 blood + 16 concrete). New particle systems or blood splatters during slowmo must either use `ImpactPool` or static pool allocation to avoid runtime node creation during slowmo.
3. In TC-M05 and `test_memory_lifecycle.gd`, memory growth across 3–5 reload cycles was measured at `0.01 MB` (well within the `<1MB` requirement).
4. Any tweens created for slowmo transitions must use `SceneTree.create_tween()` or be tied to an autoload with `PROCESS_MODE_ALWAYS`, ensuring they do not leak if a scene reloads mid-slowmo.

---

## 3. Caveats
1. **Endless Mode Exclusion**: Requirement R3 explicitly states: "Upon eliminating the final zombie in Wave 3 or defeating the Giant Butcher Boss". In Endless Mode (`is_endless_mode == true`), waves continue indefinitely past Wave 3. Slow-motion should only trigger on Boss defeat or when Wave 3 specifically completes in campaign mode, not on every wave transition in endless mode.
2. **Player Death Race Condition**: If the player dies at the exact same moment as the final zombie, player death (`mission_failed`) must take precedence over victory slow-motion. `Engine.time_scale` must always be reset to 1.0 in `mission_failed` to prevent the failure screen or menu from staying in slow-motion.
3. **Mid-Slowmo Scene Quits**: If the player opens pause menu and clicks "Exit to Menu" or "Restart" during the 1.8s slow-motion window, `Engine.time_scale` and `AudioServer.playback_speed_scale` must be reset to 1.0 inside `AudioManager` or `GameStateManager` on state exit.

---

## 4. Conclusion & Concrete Recommendations

### 4.1 Recommended Implementation Architecture

#### A. Trigger Detection in `scripts/GameManager.gd`
Add a dedicated alive tracking counter for non-dead zombies:
```gdscript
var active_living_zombies: Array[Node3D] = []
var is_slowmo_active: bool = false
```
When spawning a zombie:
```gdscript
active_living_zombies.append(zombie)
if zombie.has_signal("enemy_died"):
    zombie.enemy_died.connect(_on_enemy_eliminated.bind(zombie))
```
In `EnemyBase.gd`, add `signal enemy_died(entity)` emitted immediately at the start of `_on_died()`.

In `GameManager._on_enemy_eliminated(zombie)`:
```gdscript
if zombie in active_living_zombies:
    active_living_zombies.erase(zombie)

var is_boss = (zombie is BossZombie or zombie.get("archetype") == "boss")
var is_final_wave_last_kill = (
    not is_endless_mode 
    and current_wave >= (mission.wave_count if mission else 3) 
    and not is_spawning_wave 
    and active_living_zombies.is_empty()
)

if (is_final_wave_last_kill or is_boss) and not is_slowmo_active:
    is_slowmo_active = true
    _trigger_cinematic_last_kill_slowmo(zombie)
```

#### B. Slow-Motion Cam & Audio Dip Execution in `scripts/GameManager.gd` / `scripts/AudioManager.gd`
```gdscript
func _trigger_cinematic_last_kill_slowmo(target_zombie: Node3D = null):
    var audio_mgr = get_node_or_null("/root/AudioManager")
    if audio_mgr and audio_mgr.has_method("start_slowmo_audio_dip"):
        audio_mgr.start_slowmo_audio_dip()
    else:
        AudioServer.playback_speed_scale = 0.5

    Engine.time_scale = 0.2
    
    # Optional camera zoom punch towards target
    var player = get_tree().get_first_node_in_group("player")
    if player and player.get("camera"):
        var cam = player.camera
        var original_fov = cam.fov
        var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tw.tween_property(cam, "fov", original_fov - 8.0, 0.3)

    # EXACT 1.8 REAL-TIME SECONDS (ignore_time_scale = true)
    await get_tree().create_timer(1.8, true, false, true).timeout

    # Clean restore
    Engine.time_scale = 1.0
    if player and player.get("camera"):
        player.camera.fov = 75.0 # Or original_fov

    if audio_mgr and audio_mgr.has_method("restore_slowmo_audio_dip"):
        audio_mgr.restore_slowmo_audio_dip()
    else:
        AudioServer.playback_speed_scale = 1.0

    # Proceed to wave completion & ResultUI
    _check_wave_end()
```

#### C. Audio Manager Pitch & Bass Dip in `scripts/AudioManager.gd`
```gdscript
var slowmo_lpf: AudioEffectLowPassFilter = null
var slowmo_lpf_idx: int = -1

func _setup_slowmo_filter():
    slowmo_lpf = AudioEffectLowPassFilter.new()
    slowmo_lpf.cutoff_hz = 20500.0
    slowmo_lpf.resonance = 0.5
    AudioServer.add_bus_effect(0, slowmo_lpf)
    slowmo_lpf_idx = AudioServer.get_bus_effect_count(0) - 1
    AudioServer.set_bus_effect_enabled(0, slowmo_lpf_idx, false)

func start_slowmo_audio_dip():
    AudioServer.playback_speed_scale = 0.45
    if slowmo_lpf_idx >= 0:
        slowmo_lpf.cutoff_hz = 500.0
        AudioServer.set_bus_effect_enabled(0, slowmo_lpf_idx, true)

func restore_slowmo_audio_dip():
    AudioServer.playback_speed_scale = 1.0
    if slowmo_lpf_idx >= 0:
        AudioServer.set_bus_effect_enabled(0, slowmo_lpf_idx, false)
        slowmo_lpf.cutoff_hz = 20500.0
```

#### D. Reset Safeguards in `scripts/Core/GameStateManager.gd` & `MissionManager.gd`
Whenever state changes away from gameplay (e.g. `MISSION_COMPLETE`, `MISSION_FAILED`, `MAIN_MENU`):
```gdscript
Engine.time_scale = 1.0
AudioServer.playback_speed_scale = 1.0
var audio_mgr = get_node_or_null("/root/AudioManager")
if audio_mgr and audio_mgr.has_method("restore_slowmo_audio_dip"):
    audio_mgr.restore_slowmo_audio_dip()
```

---

## 5. Verification Method

To independently verify the implementation and safeguards:

1. **Automated E2E Suite Verification**:
   ```bash
   godot --headless scenes/test/test_realistic_overhaul.tscn
   ```
   *Expected outcome*: All 88 tests pass (100% PASS rate), TC-M01 to TC-M05 verified.
   *Invalidation condition*: Any failure in Tier 1–4, memory delta > 1.0 MB in TC-M05.

2. **Mission Consistency Validator**:
   ```bash
   godot --headless --script tools/validate_all_missions.gd
   ```
   *Expected outcome*: `🎉 ALL 12 MISSIONS + ENDLESS PASSED 100% VALIDATION!`.
   *Invalidation condition*: Any missing nodes or broken spawner configurations.

3. **Memory Lifecycle Audit**:
   ```bash
   godot --headless --script scripts/Tools/test_memory_lifecycle.gd
   ```
   *Expected outcome*: Memory growth between Cycle 2 and Cycle 5 is flat (<1.0 MB, baseline measured +0.01 MB).

4. **Slow-Motion Unit Test Assertion**:
   Create or extend unit test asserting:
   - When slow-mo triggers, `is_equal_approx(Engine.time_scale, 0.2)` is true.
   - After 1.8 real seconds, `is_equal_approx(Engine.time_scale, 1.0)` is true.
   - `AudioServer.playback_speed_scale` transitions 1.0 -> 0.45 -> 1.0.
   - `ResultUI` is not shown until after the 1.8s duration finishes.
