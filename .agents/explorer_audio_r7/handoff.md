# Handoff Report: Requirement R1 (Punchy Weapon & Combat Audio Integration)

**Author:** explorer_audio_r7  
**Date:** 2026-09-08T08:02:00Z  
**Project Root:** `/home/am/targetkill`  
**Working Directory:** `/home/am/targetkill/.agents/explorer_audio_r7`  
**Milestone:** Requirement R1 Exploration & Architecture Audit  

---

## 1. Observation

### 1.1 Weapon Firing Audio Handling (`scenes/weapons/Weapon.gd` & `resources/weapons/`)
- **Direct Code Inspection:** In `/home/am/targetkill/scenes/weapons/Weapon.gd` (lines 54–68):
  ```gdscript
  func _load_sound_set():
      if not weapon_data: return
      var snd = weapon_data.sound_set if weapon_data.sound_set != "" else weapon_data.weapon_id
      var w_id = weapon_data.weapon_id
      match w_id:
          "minigun":
              sfx_shoot.stream = load("res://audio/weapons/sfx_minigun_shoot.wav")
          "flatline":
              sfx_shoot.stream = load("res://audio/weapons/sfx_flatline_shoot.wav")
          "car_smg", "car":
              sfx_shoot.stream = load("res://audio/weapons/sfx_car_shoot.wav")
          "hawk_shotgun":
              sfx_shoot.stream = load("res://audio/weapons/sfx_hawk_shoot.wav")
          "sniper":
              sfx_shoot.stream = load("res://audio/weapons/sfx_sniper_shoot.wav")
  ```
- **Verbatim Engine Error on Mission / Test Load:** Running `godot --headless scenes/test/TestRunner.tscn` or `scenes/test/test_realistic_overhaul.tscn` produces the following verbatim errors whenever the player and weapons initialize:
  ```
  ERROR: No loader found for resource: res://audio/weapons/sfx_minigun_shoot.wav (expected type: )
     at: _load (core/io/resource_loader.cpp:291)
  ERROR: No loader found for resource: res://audio/weapons/sfx_flatline_shoot.wav (expected type: )
     at: _load (core/io/resource_loader.cpp:291)
  ERROR: No loader found for resource: res://audio/weapons/sfx_car_shoot.wav (expected type: )
     at: _load (core/io/resource_loader.cpp:291)
  ERROR: No loader found for resource: res://audio/weapons/sfx_sniper_shoot.wav (expected type: )
     at: _load (core/io/resource_loader.cpp:291)
  ERROR: No loader found for resource: res://audio/weapons/sfx_hawk_shoot.wav (expected type: )
     at: _load (core/io/resource_loader.cpp:291)
  ```
- **Weapon Resources Inspection (`resources/weapons/`):**
  - `resources/weapons/minigun.tres`: `weapon_id = "minigun"`, `sound_set = "rifle"`, `muzzle_fx = "rifle"`.
  - `resources/weapons/flatline.tres`: `weapon_id = "flatline"`, `sound_set = "rifle"`, `muzzle_fx = "rifle"`.
  - `resources/weapons/car_smg.tres`: `weapon_id = "car_smg"`, `sound_set = "rifle"`, `muzzle_fx = "rifle"`.
  - `resources/weapons/hawk_shotgun.tres`: `weapon_id = "hawk_shotgun"`, `sound_set = "shotgun"`, `muzzle_fx = "shotgun"`.
  - `resources/weapons/sniper.tres`: `weapon_id = "sniper"`, `sound_set = "rifle"`, `muzzle_fx = "rifle"`.
  - `scripts/WeaponData.gd` defines `@export var sound_set: String = "pistol"`. There is NO `@export var shoot_sound: AudioStream` or `@export var reload_sound: AudioStream` property on `WeaponData`. Audio binding is strictly resolved procedurally inside `Weapon.gd:_load_sound_set()`.

### 1.2 Mechanical Reload Audio (`Weapon.gd` & `Player.gd`)
- **Direct Code Inspection:** In `/home/am/targetkill/scenes/weapons/Weapon.gd` (lines 96–118):
  ```gdscript
  # Mechanical reload sounds per weapon archetype
  match w_id:
      "shotgun", "remington870", "hawk_shotgun", "spas12":
          if ResourceLoader.exists("res://audio/weapons/sfx_reload_shotgun.wav"):
              sfx_reload.stream = load("res://audio/weapons/sfx_reload_shotgun.wav")
          else:
              sfx_reload.stream = load("res://audio/weapons/sfx_reload.wav")
      "sniper", "awp", "svd":
          if ResourceLoader.exists("res://audio/weapons/sfx_reload_bolt.wav"):
              sfx_reload.stream = load("res://audio/weapons/sfx_reload_bolt.wav")
          else:
              sfx_reload.stream = load("res://audio/weapons/sfx_reload.wav")
      "pistol", "usp45", "deagle", "desert_eagle":
          if ResourceLoader.exists("res://audio/weapons/sfx_reload_slide.wav"):
              sfx_reload.stream = load("res://audio/weapons/sfx_reload_slide.wav")
          else:
              sfx_reload.stream = load("res://audio/weapons/sfx_reload.wav")
      _:
          if ResourceLoader.exists("res://audio/weapons/sfx_reload_mag.wav"):
              sfx_reload.stream = load("res://audio/weapons/sfx_reload_mag.wav")
          else:
              sfx_reload.stream = load("res://audio/weapons/sfx_reload.wav")
  ```
- **Silent Fallback Glitch:** `sfx_reload_shotgun.wav`, `sfx_reload_bolt.wav`, `sfx_reload_slide.wav`, and `sfx_reload_mag.wav` exist on disk in `audio/weapons/`, but NONE of them have an accompanying `.import` file. In Godot 4, `ResourceLoader.exists()` returns `false` for unimported resources. Therefore, all weapon classes silently execute the `else` branch and load the generic fallback `res://audio/weapons/sfx_reload.wav`.
- **Reload Trigger Execution:**
  - `scenes/player/Player.gd` line 316: `_trigger_reload()` invokes `weapon.reload()` and coordinates first-person arm tweens via `_reload_arms(r_time)`.
  - `scenes/weapons/Weapon.gd` line 317: `reload()` calls `sfx_reload.play()` and emits `weapon_reload_started.emit(reload_time)`.
  - Empty-mag auto-reload is wired in `Weapon.gd` line 161 & 170 and `Player.gd` line 309.

### 1.3 Headshot Audio Handling (`scripts/Zombies/EnemyBase.gd` & `scripts/Combat/HitZone.gd`)
- **Direct Code Inspection:** In `/home/am/targetkill/scripts/Zombies/EnemyBase.gd` (lines 366–387):
  ```gdscript
  func take_damage(amount: float, is_headshot: bool = false, hit_dir: Vector3 = Vector3.ZERO):
      if is_dead:
          return
      last_hit_was_headshot = is_headshot
      if health_component:
          health_component.take_damage(amount)
      if is_dead:
          return
      # Hurt reactions
      if is_headshot:
          if active_anim_player and active_anim_player.has_animation("headshot_reaction"):
              _play_anim("headshot_reaction")
  ```
- **Absence of Headshot Sound:** In `EnemyBase.gd`, only three sound players exist: `sfx_growl` (`SfxGrowl`), `sfx_attack` (`SfxAttack`), and `sfx_death` (`SfxDeath`). There is ZERO reference to `res://audio/impacts/sfx_headshot_crunch.wav` (or `.ogg`) or `sfx_bone_break.wav` in `EnemyBase.gd`, `Zombie.gd`, or `Zombie.tscn`. When a critical headshot occurs (`zone_type == ZoneType.HEAD == 0` or raycast top hit), no skull/bone crunch sound is played.

### 1.4 Background Horror Drone Ambience (`audio/ambience/sfx_horror_drone.wav`)
- **Direct File Inspection:** `audio/ambience/sfx_horror_drone.wav` exists on disk (1,226,118 bytes, 24-bit stereo 44.1 kHz).
- **Zero In-Game Reference:** Grep searches for `sfx_horror_drone` across `scenes/` and `scripts/` returned 0 matches.
- **Current Ambience Pipeline:**
  - Environment scenes (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`, `FinalLockdown.tscn`, `AirportTerminal.tscn`) contain an `AmbiencePlayer: AudioStreamPlayer` node hardcoded to `res://audio/ambience/sfx_ambience_airport.wav` with `volume_db = -6.0` and `autoplay = true`.
  - `RailwayStation.tscn` and `AbandonedTrain.tscn` hardcode `res://audio/ambience/sfx_ambience_metro.wav`.
  - `AudioManager.gd` only has entries for `"ambience_airport"` and `"ambience_metro"` in `ambience_paths`. The dark horror drone ambience is completely absent from mission gameplay.

### 1.5 Audio Directory & Import Inventory
| File Path | Format & Channels | Size | Import File (.import) | Runtime Load Status |
|---|---|---|---|---|
| `audio/weapons/sfx_minigun_shoot.wav` | 16-bit PCM Stereo 44.1kHz | 91,982 B | Missing | **FAILS** (No loader found) |
| `audio/weapons/sfx_flatline_shoot.wav` | 16-bit PCM Stereo 44.1kHz | 474,958 B | Missing | **FAILS** (No loader found) |
| `audio/weapons/sfx_car_shoot.wav` | 16-bit PCM Stereo 44.1kHz | 463,182 B | Missing | **FAILS** (No loader found) |
| `audio/weapons/sfx_hawk_shoot.wav` | 16-bit PCM Stereo 44.1kHz | 415,566 B | Missing | **FAILS** (No loader found) |
| `audio/weapons/sfx_sniper_shoot.wav` | 16-bit PCM Stereo 44.1kHz | 449,358 B | Missing | **FAILS** (No loader found) |
| `audio/weapons/sfx_reload_shotgun.wav` | 16-bit PCM Stereo 44.1kHz | 768,354 B | Missing | Falls back to generic reload |
| `audio/weapons/sfx_reload_bolt.wav` | 16-bit PCM Stereo 44.1kHz | 1,193,150 B | Missing | Falls back to generic reload |
| `audio/weapons/sfx_reload_slide.wav` | 16-bit PCM Stereo 44.1kHz | 1,787,590 B | Missing | Falls back to generic reload |
| `audio/weapons/sfx_reload_mag.wav` | 16-bit PCM Stereo 44.1kHz | 1,429,482 B | Missing | Falls back to generic reload |
| `audio/impacts/sfx_headshot_crunch.wav` | 16-bit PCM Stereo 44.1kHz | 260,942 B | Missing | Unreferenced in code |
| `audio/impacts/sfx_bone_break.wav` | 16-bit PCM Stereo 44.1kHz | 196,430 B | Missing | Unreferenced in code |
| `audio/ambience/sfx_horror_drone.wav` | 24-bit PCM Stereo 44.1kHz | 1,226,118 B | Missing | Unreferenced in code |
| `audio/zombies/sfx_dog_bark.tres` | Godot Native AudioStreamWAV | 76,535 B | N/A (Native) | **PASSES** cleanly |
| `audio/zombies/sfx_dog_attack.tres` | Godot Native AudioStreamWAV | 58,895 B | N/A (Native) | **PASSES** cleanly |
| `audio/zombies/sfx_dog_death.tres` | Godot Native AudioStreamWAV | 129,435 B | N/A (Native) | **PASSES** cleanly |

---

## 2. Logic Chain

1. **Premise 1:** In Godot 4 headless execution mode, the engine does not dynamically import raw audio files unless `.import` metadata exists and corresponding sample binaries are stored in `.godot/imported/`.
2. **Premise 2:** `scenes/weapons/Weapon.gd` lines 60–68 execute `load("res://audio/weapons/sfx_minigun_shoot.wav")`, etc.
3. **Deduction 1:** Because `sfx_minigun_shoot.wav`, `sfx_flatline_shoot.wav`, `sfx_car_shoot.wav`, `sfx_hawk_shoot.wav`, and `sfx_sniper_shoot.wav` lack `.import` files, Godot fails with `ERROR: No loader found for resource`. The function `load()` returns `null`, leaving `sfx_shoot.stream = null`. Firing these weapons produces silence.
4. **Premise 3:** `scenes/weapons/Weapon.gd` lines 98–118 guard mechanical reload sounds with `if ResourceLoader.exists(...)`.
5. **Deduction 2:** Since `ResourceLoader.exists()` returns `false` for unimported assets, every weapon class defaults to the `else` branch, loading `res://audio/weapons/sfx_reload.wav`. Consequently, mechanical reload sounds are never heard.
6. **Premise 4:** In `scripts/Zombies/EnemyBase.gd`, `take_damage(amount, is_headshot, hit_dir)` processes hit reactions when `is_headshot == true`, but neither creates nor references any audio player for headshot audio.
7. **Deduction 3:** Headshots cause damage and visual reactions, but produce zero skull crunch sound feedback.
8. **Premise 5:** `audio/ambience/sfx_horror_drone.wav` is an orphaned asset on disk. No level scene or manager loads it.
9. **Deduction 4:** The requirement to play dark horror drone ambience during mission gameplay is currently unfulfilled.
10. **Premise 6:** In `scenes/test/TestRunner.gd` line 263, the test `record_test("Audio", true, ...)` unconditionally returns `true` without asserting that weapon, reload, or headshot audio streams are non-null and valid.
11. **Deduction 5:** The regression test suites currently pass 54/54 and 88/88 despite complete failure of the new weapon audio pipeline.

---

## 3. Caveats

- **Audio Extension Discrepancy:** The prompt and `ORIGINAL_REQUEST.md` mention both `.ogg` (e.g. `sfx_minigun_shoot.ogg`, `sfx_headshot_crunch.ogg`) and `.wav`. The repository previously had `.ogg` files in `audio/weapons/` which were converted/renamed to `.wav` (e.g. `sfx_minigun_shoot.wav`). The actual files currently residing on disk are `.wav`.
- **Godot Resource Loading Alternatives:** In Godot 4, there are two ways to eliminate the missing-loader error:
  - *Approach A (Standard):* Create valid `.import` files with `importer="wav"` and generate the `.sample` cache in `.godot/imported/`.
  - *Approach B (Bulletproof Native Tres):* Package the WAV data into `.tres` resources (exactly like `sfx_dog_bark.tres` was done in `audio/zombies/`). `.tres` files load natively in Godot 4 headless mode without requiring editor import passes.
  - *Approach C (Runtime WAV Parser):* A GDScript utility can read the WAV bytes using `FileAccess` and populate an `AudioStreamWAV` instance dynamically.
- **Volume Balancing:** `sfx_horror_drone.wav` has high dynamic range. If played at default volume (`0.0 dB`), it could mask zombie cues. It must be played at `-12.0 dB` to `-14.0 dB`.

---

## 4. Conclusion & Concrete Implementation Blueprint

### 4.1 Weapon Shoot Audio Integration (`scenes/weapons/Weapon.gd`)
- In `_load_sound_set()`, support both `.tres` and `.wav` with bulletproof fallback:
  ```gdscript
  match w_id:
      "minigun", "heavy_m134":
          sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_minigun_shoot", "res://audio/weapons/sfx_rifle_shoot.wav")
      "flatline":
          sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_flatline_shoot", "res://audio/weapons/sfx_rifle_shoot.wav")
      "car_smg", "car":
          sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_car_shoot", "res://audio/weapons/sfx_rifle_shoot.wav")
      "hawk_shotgun":
          sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_hawk_shoot", "res://audio/weapons/sfx_shotgun_shoot.wav")
      "sniper", "awp", "svd":
          sfx_shoot.stream = _load_audio("res://audio/weapons/sfx_sniper_shoot", "res://audio/weapons/sfx_awp_shoot.wav")
  ```

### 4.2 Mechanical Reload Audio Integration (`scenes/weapons/Weapon.gd`)
- Implement distinct mechanical reload sounds by weapon class with bulletproof fallback:
  ```gdscript
  match w_id:
      "shotgun", "remington870", "hawk_shotgun", "spas12":
          sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_shotgun", "res://audio/weapons/sfx_reload.wav")
      "sniper", "awp", "svd":
          sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_bolt", "res://audio/weapons/sfx_reload.wav")
      "pistol", "usp45", "deagle", "desert_eagle":
          sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_slide", "res://audio/weapons/sfx_reload.wav")
      _:
          sfx_reload.stream = _load_audio("res://audio/weapons/sfx_reload_mag", "res://audio/weapons/sfx_reload.wav")
  ```

### 4.3 Visceral Headshot Crunch Integration (`scripts/Zombies/EnemyBase.gd`)
- In `scripts/Zombies/EnemyBase.gd`:
  1. Add audio stream player variable: `var sfx_headshot: AudioStreamPlayer3D = null`.
  2. In `_ready()`, dynamically create or locate `sfx_headshot`:
     ```gdscript
     sfx_headshot = get_node_or_null("SfxHeadshot")
     if not sfx_headshot:
         sfx_headshot = AudioStreamPlayer3D.new()
         sfx_headshot.name = "SfxHeadshot"
         sfx_headshot.max_distance = 18.0
         sfx_headshot.bus = "SFX"
         add_child(sfx_headshot)
     var hs_stream = _load_audio("res://audio/impacts/sfx_headshot_crunch")
     if not hs_stream:
         hs_stream = _load_audio("res://audio/impacts/sfx_bone_break")
     if hs_stream:
         sfx_headshot.stream = hs_stream
     ```
  3. In `take_damage()`:
     ```gdscript
     if is_headshot:
         if sfx_headshot and sfx_headshot.stream:
             sfx_headshot.play()
     ```

### 4.4 Background Horror Drone Ambience Integration
- In `scripts/AudioManager.gd`:
  - Add `"horror_drone": "res://audio/ambience/sfx_horror_drone.wav"` to `ambience_paths`.
  - Add method `play_horror_drone(volume_db: float = -12.0)`.
- In level root scenes (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`, etc.):
  - Add or configure `HorrorDronePlayer: AudioStreamPlayer` with `volume_db = -12.0`, `autoplay = true`, and loop enabled so it continuously plays in the background without masking gunfire or zombie groans.

### 4.5 Asset Import / Package Fix
- To prevent Godot headless errors, either:
  1. Generate corresponding `.import` files and sample caches for all 12 WAV files, OR
  2. Provide native `.tres` counterparts (like `sfx_dog_bark.tres`), OR
  3. Include a robust WAV-loader helper that creates `AudioStreamWAV` from file bytes.

---

## 5. Verification Method

### Test Commands
1. **Headless Audio Verification Runner:**
   Execute:
   ```bash
   godot --headless scenes/test/TestRunner.tscn
   godot --headless scenes/test/test_realistic_overhaul.tscn
   ```
2. **Specific Assertions to Add to Test Suites:**
   - Verify `Weapon._load_sound_set()` sets `sfx_shoot.stream != null` for `minigun`, `flatline`, `car_smg`, `hawk_shotgun`, `sniper`.
   - Verify `Weapon.sfx_reload.stream != null` and is different from default `sfx_reload.wav` for `shotgun`, `sniper`, and `pistol`.
   - Verify `EnemyBase.take_damage(20.0, true)` triggers headshot sound player.
   - Verify `sfx_horror_drone` is playing in mission scenes with `volume_db <= -10.0`.
3. **Invalidation Conditions:**
   - Any `ERROR: No loader found for resource` in stdout/stderr.
   - Any weapon firing with `sfx_shoot.stream == null`.
   - Headshots occurring without triggering `sfx_headshot`.
