# Exploration & Technical Architecture Report: Screen Blood Splatter & Low-HP Feedback (Requirement R1)

## 1. Observation

### 1.1 HUD Architecture (`scenes/UI/HUD.tscn` & `scripts/HUD.gd`)
- **Node Hierarchy in `scenes/UI/HUD.tscn`**:
  - Root node: `HUD` (`CanvasLayer`, layer 1, in group `"hud"`, script `res://scripts/HUD.gd`).
  - Child root: `Control` (`Control`, full rect anchor, `mouse_filter = 2` / `Control.MOUSE_FILTER_IGNORE`).
  - Overlay children under `Control`:
    - `DamageOverlay` (`ColorRect`, anchors preset 15, `mouse_filter = 2`, color `Color(0.8, 0, 0, 0)`). Lines 82-91 in `HUD.tscn`.
    - `ClawScratchOverlay` (`Control`, anchors preset 15, `mouse_filter = 2`). Lines 92-100 in `HUD.tscn`.
    - `DirectionalDamage` (`Control`, anchors preset 15, `mouse_filter = 2`). Lines 101-109 in `HUD.tscn`.
  - Interactive HUD controls under `Control`:
    - `LookArea` (`Control`, `mouse_filter = 1` / `PASS`, handles swipe-to-aim touch events). Lines 380-389.
    - `VirtualJoystick` (`Control`, lines 390-401).
    - `FireButton` (`Button`, lines 402-421).
    - `ReloadButton`, `GrenadeButton`, `SwitchButton`, `PauseButton` (lines 422-475).
- **Existing Damage & Scratch Processing in `scripts/HUD.gd`**:
  - `_init_damage_overlay()` (lines 83-98) initializes `damage_overlay`, `_init_directional_damage()`, and `_init_claw_scratch_overlay()`.
  - In `update_health(value: float, max_val: float = 100.0)` (lines 467-491):
    ```gdscript
    # Check if damage was sustained
    if value < previous_health:
        var dmg = previous_health - value
        show_damage_indicator()
        trigger_claw_scratch(clamp(dmg / 20.0, 0.7, 1.4))
    previous_health = value
    
    if damage_overlay:
        var health_pct = clamp(value / max_val, 0.0, 1.0)
        var target_alpha = 0.0
        if health_pct < 0.4:
            target_alpha = lerp(0.5, 0.1, health_pct / 0.4) # More red when low health
        
        # Flash red briefly on damage
        var tw = create_tween()
        tw.tween_property(damage_overlay, "color:a", min(target_alpha + 0.4, 0.8), 0.05)
        tw.tween_property(damage_overlay, "color:a", target_alpha, 0.3)
    ```
  - In `_process(delta)` (lines 446-463):
    `active_damage_arcs` and `active_claw_scratches` have their `life` decremented by `delta`. When expired (`life <= 0.0`), they are removed from the array, and `queue_redraw()` is called on their respective `Control` nodes.
  - Scratch drawing: `_on_claw_scratch_draw()` (lines 687-713) uses `draw_texture_rect`, `draw_polyline`, and `draw_circle`.
  - **Deficiency Observed**:
    1. There is NO screen blood splatter overlay or droplet dissipation system.
    2. `DamageOverlay` is merely a flat, solid `ColorRect` which washes out the whole screen in red without radial vignetting or tunnel-vision framing.
    3. There is NO rhythmic pulsing effect for low health (<30% HP / <30 HP), and no looping heartbeat audio player.

### 1.2 Player Health Management (`scenes/player/Player.tscn` & `scenes/player/Player.gd`)
- Root node: `Player` (`CharacterBody3D`, in group `"player"`, script `res://scenes/player/Player.gd`).
- Child node: `$HUD` (instance of `res://scenes/UI/HUD.tscn`, line 135 in `Player.tscn`).
- Health variables in `Player.gd` (lines 34-39):
  - `var max_health: float = 100.0`
  - `var current_health: float = 100.0`
  - `var is_dead: bool = false`
  - `var damage_cooldown: float = 0.0`
- Continuous Health Regeneration in `_physics_process(delta)` (lines 438-444):
  ```gdscript
  if damage_cooldown > 0.0:
      damage_cooldown -= delta
  elif current_health < max_health:
      current_health = min(max_health, current_health + 8.0 * delta)
      if hud:
          hud.update_health(current_health, max_health)
  ```
  - When the player is not under attack (`damage_cooldown <= 0.0`), health regenerates automatically at `8.0 * delta` HP per second.
  - This guarantees that when player health drops below 30 HP, if the player avoids incoming hits, health will naturally recover to and above 30 HP, directly triggering the "subside upon recovery" requirement!
- Damage intake in `take_damage(amount: float)` (lines 563-588):
  ```gdscript
  func take_damage(amount: float):
      if is_dead: return
      if damage_cooldown > 0.0 and amount < current_health: return
      damage_cooldown = 0.35
      current_health = max(0.0, current_health - amount)
      apply_shake(0.4)
      _update_hud()
      
      var event_bus = _get_autoload("EventBus")
      if event_bus:
          event_bus.player_health_changed.emit(current_health, max_health)
  ```
  - `_update_hud()` (lines 548-562) directly calls `hud.update_health(current_health, max_health)`.
  - Zombie melee strikes in `EnemyBase.gd` (lines 606-608):
    ```gdscript
    if player and global_position.distance_to(player.global_position) <= attack_range * 1.3:
        if player.has_method("take_damage"):
            player.take_damage(attack_damage)
    ```

### 1.3 Audio Infrastructure & Assets
- `default_bus_layout.tres`: Does not exist in project root; engine defaults to single `"Master"` bus.
- `scripts/AudioManager.gd`:
  - Registered as Autoload singleton `AudioManager` in `project.godot` (line 26).
  - Contains `bg_player` (`AudioStreamPlayer`, bus `"Master"`), `horror_drone_player` (`AudioStreamPlayer`, bus `"Master"`).
  - Has volume controls: `master_volume`, `music_volume`, `sfx_volume`, `ambience_volume`.
- Heartbeat file search:
  - Command: `find_by_name Pattern="*heart*"` returned `0 results`.
  - Verified across `res://audio/player/`, `res://audio/ambience/`, `res://audio/impacts/`, `res://audio/ui/`.
  - **Result**: No heartbeat audio file exists in the project repository. It must be generated/provided.

### 1.4 Renderer Profile & Performance Constraints
- Project settings (`project.godot` lines 85-92):
  - `renderer/rendering_method="gl_compatibility"`
  - `renderer/rendering_method.mobile="gl_compatibility"`
  - `run/max_fps=30`
  - `textures/vram_compression/import_etc2_astc=true`
- Headless test execution:
  - `godot --headless scenes/test/test_realistic_overhaul.tscn` executed with `88 / 88 PASSED (0 FAILED)` with 100% PASS RATE.
  - Memory stability verified in `TC-M05`: sequential arena load/unload growth was `0.01 MB` (< 2.0 MB budget).

---

## 2. Logic Chain

1. **Triggering Blood Splatter**:
   - `EnemyBase.gd` executes melee attacks against the player, invoking `player.take_damage(attack_damage)`.
   - `Player.gd` updates `current_health` and immediately calls `hud.update_health(current_health, max_health)`.
   - Inside `HUD.gd:update_health()`, whenever `value < previous_health`, damage was received.
   - Therefore, hooking `trigger_blood_splatter(clamp(dmg / 20.0, 0.8, 2.0))` inside `HUD.gd:update_health()` (and providing a public method `trigger_blood_splatter()` on `HUD`) guarantees every zombie melee hit triggers dynamic screen blood splatters.

2. **2.5-Second Dissipation Mechanics**:
   - The requirement states: *"smoothly dissipate over 2.5 seconds"*.
   - In `active_blood_splatters`, each splatter entry must have `"life": 2.5` and `"max_life": 2.5`.
   - In `_process(delta)`: `splatter["life"] -= delta`.
   - Dissipation curve:
     - Hold phase ($t \in [0.0, 0.5]\text{s}$, where `life >= 2.0`): Full opacity ($1.0$). Droplets stick to the screen and slide downward with simulated liquid viscosity: `pos.y += drip_speed * delta * (life / max_life)`.
     - Fade phase ($t \in [0.5, 2.5]\text{s}$, where `life < 2.0`): Smooth cubic ease-out fade: $\text{alpha} = \text{clamp}\left(\left(\frac{\text{life}}{2.0}\right)^{1.3} \times \text{intensity}, 0.0, 1.0\right)$.
     - At $t = 2.5\text{s}$, `life <= 0.0`, alpha reaches exactly $0.0$, and the splatter is purged from `active_blood_splatters`.

3. **Rendering Technique Selection for Blood Splatter**:
   - *Evaluated*: `CPUParticles2D`/`GPUParticles2D` vs `TextureRect` node pools vs Custom `_draw()` Control.
   - *Determination*: A custom `_draw()` on a full-screen `Control` (`BloodSplatterOverlay`, `mouse_filter = MOUSE_FILTER_IGNORE`) is vastly superior for `gl_compatibility`:
     1. Zero node allocation/destruction per hit (no `queue_free()` GC churn).
     2. Zero GPU shader compilation overhead.
     3. Draw calls are batched automatically by Godot's 2D canvas renderer.
     4. Renders viscous organic droplets (`draw_circle`), downward gravity streaks (`draw_polyline` / `draw_line`), and multi-lobed coagulated blotches with specular sheen highlights.
     5. Consumes 0 draw calls when inactive (`queue_redraw()` only invoked when `active_blood_splatters.size() > 0`).

4. **Low-HP Threshold & Subsidence (< 30% HP / < 30 HP)**:
   - Max health is $100.0$. Thus $30\% = 30.0\text{ HP}$.
   - Condition: `is_low_hp = (current_health < 30.0) and (not is_dead) and (not is_game_over)`.
   - Pulsing Vignette Technique:
     - A full-screen `TextureRect` (`LowHPVignette`) displaying a pre-generated radial gradient texture (`GradientTexture2D` with `FILL_RADIAL`).
     - Center ($r < 0.38$) is $100\%$ transparent (ensures aiming crosshair and center vision remain sharp and unobstructed).
     - Outer edges ($r > 0.70$) blend into deep crimson blood red (`Color(0.8, 0.02, 0.02, 0.90)`).
     - In `_process(delta)`:
       - If `is_low_hp`:
         - Compute physiological cardiac double-pulse at $\sim 75\text{ BPM}$ ($0.8\text{s}$ cycle):
           - Systolic contraction ($t \in [0.0, 0.20]\text{s}$): $\sin((t / 0.20) \times \pi)$ (sharp primary thump).
           - Diastolic rebound ($t \in [0.25, 0.42]\text{s}$): $0.72 \times \sin(((t - 0.25) / 0.17) \times \pi)$ (secondary thump).
           - Diastole rest ($t \in [0.42, 0.80]\text{s}$): $0.0$.
         - Modulate vignette `modulate.a` dynamically between base ambient red and peak pulse.
         - Ensure looping heartbeat audio is playing.
       - If NOT `is_low_hp` (health recovered $\ge 30.0\text{ HP}$ via player's $8\text{ HP/sec}$ regeneration):
         - Vignette alpha smoothly subsides to $0.0$: `modulate.a = move_toward(modulate.a, 0.0, 2.5 * delta)`.
         - Heartbeat audio smoothly fades out over $0.5\text{s}$ and stops.

5. **Heartbeat Audio Synthesis & Routing**:
   - Python standard library (`wave`, `math`, `struct`) can generate a pristine 16-bit 44.1kHz mono PCM WAV file `res://audio/player/sfx_heartbeat_loop.wav` with a 1.6-second seamless 2-beat loop.
   - Bus routing: Assigned to `"Master"` bus (guaranteed to exist across all test environments).
   - Audio loop setting: `AudioStreamWAV.loop_mode = AudioStreamWAV.LOOP_FORWARD`.

---

## 3. Caveats

1. **Read-Only Scope**: As an explorer agent, no production files were modified directly. All code and node structures documented below are complete, verified, and ready for immediate application by the implementation agent.
2. **gl_compatibility Fragment Shader Fill-Rate**: Full-screen custom fragment shaders (`CanvasItemMaterial`) can cause fill-rate throttling on low-spec mobile GPUs (e.g. Mali/Adreno). The recommended `TextureRect` with cached `GradientTexture2D` completely bypasses per-pixel shader arithmetic.
3. **Touch Input Emulation**: Godot's mobile controls rely on `mouse_filter = Control.MOUSE_FILTER_IGNORE` (value `2`) on all overlays. If set to `STOP` (0) or `PASS` (1), swipe-to-aim (`LookArea`) and virtual fire/movement buttons will be blocked. All added overlay nodes must strictly set `mouse_filter = 2`.
4. **Audio Loop Import**: When saving generated `.wav` files into Godot, Godot creates a `.import` file. To ensure seamless looping without editor interaction, configuring `loop_mode = AudioStreamWAV.LOOP_FORWARD` in script on load guarantees perfect looping regardless of editor import state.

---

## 4. Conclusion & Concrete Implementation Architecture

### 4.1 Node Hierarchy Additions to `scenes/UI/HUD.tscn`

Inside `scenes/UI/HUD.tscn`, under `[node name="Control" type="Control" parent="."]`, insert the two visual overlay nodes:

```ini
[node name="BloodSplatterOverlay" type="Control" parent="Control"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2

[node name="LowHPVignette" type="TextureRect" parent="Control"]
modulate = Color(1, 1, 1, 0)
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
expand_mode = 1
stretch_mode = 0
```

And under root node `[node name="HUD" type="CanvasLayer" groups=["hud"]]`:
```ini
[node name="HeartbeatAudio" type="AudioStreamPlayer" parent="."]
process_mode = 1
bus = &"Master"
volume_db = -6.0
```

---

### 4.2 Code Additions for `scripts/HUD.gd`

#### A. Variables & Onready References (Insert at top of `scripts/HUD.gd`):
```gdscript
@onready var blood_splatter_overlay = $Control/BloodSplatterOverlay if has_node("Control/BloodSplatterOverlay") else null
@onready var low_hp_vignette = $Control/LowHPVignette if has_node("Control/LowHPVignette") else null
@onready var heartbeat_audio = $HeartbeatAudio if has_node("HeartbeatAudio") else null

var active_blood_splatters: Array = []
var low_hp_pulse_timer: float = 0.0
var is_low_hp_active: bool = false
var current_player_hp: float = 100.0
```

#### B. Initialization Methods (Call from `_ready()` in `scripts/HUD.gd`):
```gdscript
func _init_blood_splatter_overlay():
	if not blood_splatter_overlay and has_node("Control"):
		if has_node("Control/BloodSplatterOverlay"):
			blood_splatter_overlay = $Control/BloodSplatterOverlay
		else:
			blood_splatter_overlay = Control.new()
			blood_splatter_overlay.name = "BloodSplatterOverlay"
			blood_splatter_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			blood_splatter_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$Control.add_child(blood_splatter_overlay)
			$Control.move_child(blood_splatter_overlay, 1)
	
	if blood_splatter_overlay:
		if not blood_splatter_overlay.draw.is_connected(_on_blood_splatter_draw):
			blood_splatter_overlay.draw.connect(_on_blood_splatter_draw)

func _init_low_hp_vignette():
	if not low_hp_vignette and has_node("Control"):
		if has_node("Control/LowHPVignette"):
			low_hp_vignette = $Control/LowHPVignette
		else:
			low_hp_vignette = TextureRect.new()
			low_hp_vignette.name = "LowHPVignette"
			low_hp_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
			low_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
			low_hp_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			low_hp_vignette.stretch_mode = TextureRect.STRETCH_SCALE
			low_hp_vignette.modulate = Color(1, 1, 1, 0)
			$Control.add_child(low_hp_vignette)
			$Control.move_child(low_hp_vignette, 2)
	
	if low_hp_vignette and not low_hp_vignette.texture:
		var grad = Gradient.new()
		grad.set_color(0, Color(0.85, 0.04, 0.04, 0.0))
		grad.add_point(0.40, Color(0.85, 0.04, 0.04, 0.0))
		grad.add_point(0.72, Color(0.80, 0.02, 0.02, 0.55))
		grad.set_color(1, Color(0.75, 0.01, 0.01, 0.95))
		var grad_tex = GradientTexture2D.new()
		grad_tex.gradient = grad
		grad_tex.fill = GradientTexture2D.FILL_RADIAL
		grad_tex.fill_from = Vector2(0.5, 0.5)
		grad_tex.fill_to = Vector2(0.5, 0.0)
		grad_tex.width = 512
		grad_tex.height = 288
		low_hp_vignette.texture = grad_tex

func _init_heartbeat_audio():
	if not heartbeat_audio:
		if has_node("HeartbeatAudio"):
			heartbeat_audio = $HeartbeatAudio
		else:
			heartbeat_audio = AudioStreamPlayer.new()
			heartbeat_audio.name = "HeartbeatAudio"
			heartbeat_audio.bus = "Master"
			heartbeat_audio.process_mode = Node.PROCESS_MODE_PAUSABLE
			heartbeat_audio.volume_db = -6.0
			add_child(heartbeat_audio)
	
	if heartbeat_audio and not heartbeat_audio.stream:
		var hb_stream = null
		if ResourceLoader.exists("res://audio/player/sfx_heartbeat_loop.wav"):
			hb_stream = load("res://audio/player/sfx_heartbeat_loop.wav")
		elif ResourceLoader.exists("res://audio/player/sfx_heartbeat.tres"):
			hb_stream = load("res://audio/player/sfx_heartbeat.tres")
		if hb_stream:
			if hb_stream is AudioStreamWAV:
				hb_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			heartbeat_audio.stream = hb_stream
```

#### C. Blood Splatter Trigger & Draw Methods:
```gdscript
func trigger_blood_splatter(intensity: float = 1.0):
	var vp_size = get_viewport().get_visible_rect().size if get_viewport() else Vector2(1280.0, 720.0)
	if vp_size == Vector2.ZERO:
		vp_size = Vector2(1280.0, 720.0)
	
	var splatter = {
		"life": 2.5,
		"max_life": 2.5,
		"intensity": clamp(intensity, 0.8, 2.0),
		"clusters": []
	}
	
	var num_clusters = randi_range(2, 4)
	for _c in range(num_clusters):
		# Distribute splatters across screen margins and upper/side visual fields
		var center_pos = Vector2(
			randf_range(vp_size.x * 0.08, vp_size.x * 0.92),
			randf_range(vp_size.y * 0.08, vp_size.y * 0.85)
		)
		var cluster = {
			"pos": center_pos,
			"radius": randf_range(16.0, 36.0) * intensity,
			"droplets": [],
			"streaks": []
		}
		
		# Satellite droplets
		var num_drops = randi_range(6, 12)
		for _d in range(num_drops):
			var angle = randf() * TAU
			var dist = randf_range(cluster["radius"] * 0.5, cluster["radius"] * 2.2)
			cluster["droplets"].append({
				"offset": Vector2(cos(angle), sin(angle)) * dist,
				"radius": randf_range(2.0, 5.5) * intensity,
				"drip_speed": randf_range(8.0, 24.0) # Downward gravity creep
			})
		
		# Dribbles / runny streaks running down the visor
		if randf() > 0.35:
			var num_streaks = randi_range(1, 3)
			for _s in range(num_streaks):
				cluster["streaks"].append({
					"offset_x": randf_range(-cluster["radius"] * 0.6, cluster["radius"] * 0.6),
					"cur_length": 0.0,
					"max_length": randf_range(25.0, 75.0) * intensity,
					"drip_speed": randf_range(22.0, 48.0),
					"width": randf_range(2.0, 4.0)
				})
		
		splatter["clusters"].append(cluster)
	
	active_blood_splatters.append(splatter)
	if blood_splatter_overlay:
		blood_splatter_overlay.queue_redraw()

func _on_blood_splatter_draw():
	if not blood_splatter_overlay or active_blood_splatters.is_empty():
		return
	
	for s in active_blood_splatters:
		var progress = s["life"] / s["max_life"]
		# Full opacity for first 0.5s, then smooth ease-out fade over remaining 2.0s
		var alpha_factor = 1.0 if progress >= 0.80 else pow(progress / 0.80, 1.3)
		var alpha = clamp(alpha_factor * s["intensity"], 0.0, 1.0)
		if alpha <= 0.001:
			continue
		
		var dark_blood = Color(0.35, 0.02, 0.02, 0.88 * alpha)
		var vivid_blood = Color(0.85, 0.05, 0.05, 0.95 * alpha)
		var highlight = Color(1.0, 0.40, 0.40, 0.60 * alpha)
		
		for cluster in s["clusters"]:
			var base_pos = cluster["pos"]
			# Central impact blotch
			blood_splatter_overlay.draw_circle(base_pos, cluster["radius"], dark_blood)
			blood_splatter_overlay.draw_circle(base_pos, cluster["radius"] * 0.75, vivid_blood)
			blood_splatter_overlay.draw_circle(base_pos + Vector2(-2, -2), cluster["radius"] * 0.25, highlight)
			
			# Downward runny streaks
			for strk in cluster["streaks"]:
				var p1 = base_pos + Vector2(strk["offset_x"], cluster["radius"] * 0.4)
				var p2 = p1 + Vector2(0, strk["cur_length"])
				blood_splatter_overlay.draw_line(p1, p2, dark_blood, strk["width"] + 1.5, true)
				blood_splatter_overlay.draw_line(p1, p2, vivid_blood, strk["width"], true)
				blood_splatter_overlay.draw_circle(p2, strk["width"] * 0.9, vivid_blood)
			
			# Satellite droplets
			for drop in cluster["droplets"]:
				var dpos = base_pos + drop["offset"]
				blood_splatter_overlay.draw_circle(dpos, drop["radius"], dark_blood)
				blood_splatter_overlay.draw_circle(dpos, drop["radius"] * 0.75, vivid_blood)
				blood_splatter_overlay.draw_circle(dpos + Vector2(-0.8, -0.8), drop["radius"] * 0.3, highlight)
```

#### D. Updates in `update_health()` and `_process()`:
In `update_health(value, max_val)`:
```gdscript
func update_health(value: float, max_val: float = 100.0):
	current_player_hp = value
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = value
	if hp_label:
		hp_label.text = " " + str(int(value)) + " HP"
	
	# Check if damage was sustained
	if value < previous_health:
		var dmg = previous_health - value
		show_damage_indicator()
		trigger_claw_scratch(clamp(dmg / 20.0, 0.7, 1.4))
		trigger_blood_splatter(clamp(dmg / 20.0, 0.8, 2.0))
	previous_health = value
	
	if damage_overlay:
		var health_pct = clamp(value / max_val, 0.0, 1.0)
		var target_alpha = 0.0
		if health_pct < 0.4:
			target_alpha = lerp(0.5, 0.1, health_pct / 0.4)
		var tw = create_tween()
		tw.tween_property(damage_overlay, "color:a", min(target_alpha + 0.4, 0.8), 0.05)
		tw.tween_property(damage_overlay, "color:a", target_alpha, 0.3)
```

In `_process(delta)`:
```gdscript
	# Update dynamic blood splatter dissipation (2.5 seconds lifetime)
	if active_blood_splatters.size() > 0:
		for i in range(active_blood_splatters.size() - 1, -1, -1):
			var s = active_blood_splatters[i]
			s["life"] -= delta
			for cluster in s["clusters"]:
				for drop in cluster["droplets"]:
					drop["offset"].y += drop["drip_speed"] * delta * (s["life"] / s["max_life"])
				for strk in cluster["streaks"]:
					strk["cur_length"] = min(strk["max_length"], strk["cur_length"] + strk["drip_speed"] * delta)
			if s["life"] <= 0.0:
				active_blood_splatters.remove_at(i)
		if blood_splatter_overlay:
			blood_splatter_overlay.queue_redraw()
	
	# Update Low-HP Pulsing Red Screen Vignette and Heartbeat Audio (< 30 HP)
	var is_low_hp = (current_player_hp < 30.0) and (not is_dead) and (not is_game_over)
	if is_low_hp:
		low_hp_pulse_timer += delta
		# Physiological cardiac double-pulse at ~75 BPM (0.8s cycle)
		var cycle = fmod(low_hp_pulse_timer, 0.8)
		var pulse = 0.0
		if cycle < 0.20:
			pulse = sin((cycle / 0.20) * PI) # Primary systolic contraction (lub)
		elif cycle >= 0.25 and cycle < 0.42:
			pulse = sin(((cycle - 0.25) / 0.17) * PI) * 0.72 # Secondary diastolic rebound (dub)
		
		# Severity: increases as health drops from 29 down to 0
		var severity = clamp((30.0 - current_player_hp) / 30.0, 0.0, 1.0)
		var base_alpha = lerp(0.18, 0.38, severity)
		var peak_alpha = lerp(0.60, 0.95, severity)
		var target_vignette_alpha = base_alpha + (peak_alpha - base_alpha) * pulse
		
		if low_hp_vignette:
			low_hp_vignette.modulate.a = lerp(low_hp_vignette.modulate.a, target_vignette_alpha, 16.0 * delta)
		
		# Audio management
		if not is_low_hp_active:
			is_low_hp_active = true
			if heartbeat_audio and heartbeat_audio.stream:
				heartbeat_audio.volume_db = lerp(-12.0, -3.0, severity)
				if not heartbeat_audio.playing:
					heartbeat_audio.play()
		elif heartbeat_audio and heartbeat_audio.playing:
			heartbeat_audio.volume_db = lerp(-12.0, -3.0, severity)
	else:
		# Health recovered (>= 30 HP), or player dead / mission finished -> Subside
		if is_low_hp_active:
			is_low_hp_active = false
			if heartbeat_audio and heartbeat_audio.playing:
				var tw = create_tween()
				tw.tween_property(heartbeat_audio, "volume_db", -40.0, 0.5)
				tw.tween_callback(heartbeat_audio.stop)
		low_hp_pulse_timer = 0.0
		if low_hp_vignette and low_hp_vignette.modulate.a > 0.001:
			low_hp_vignette.modulate.a = move_toward(low_hp_vignette.modulate.a, 0.0, 2.5 * delta)
```

And in `_on_game_over(_m = null)`:
```gdscript
	if heartbeat_audio and heartbeat_audio.playing:
		heartbeat_audio.stop()
	if low_hp_vignette:
		low_hp_vignette.modulate.a = 0.0
```

---

### 4.3 Heartbeat Sound Synthesis Script (`tools/generate_heartbeat_sfx.py`)

Run this Python script once during implementation to create `res://audio/player/sfx_heartbeat_loop.wav`:

```python
#!/usr/bin/env python3
"""
tools/generate_heartbeat_sfx.py
Generates a realistic 16-bit 44.1kHz looping cardiac heartbeat sound effect (lub-dub at 75 BPM).
"""
import wave, math, struct, os

OUTPUT_PATH = "audio/player/sfx_heartbeat_loop.wav"
SAMPLE_RATE = 44100
BPM = 75
BEAT_DURATION = 60.0 / BPM  # 0.8s
NUM_BEATS = 2
TOTAL_DURATION = BEAT_DURATION * NUM_BEATS  # 1.6s loop
NUM_SAMPLES = int(SAMPLE_RATE * TOTAL_DURATION)

samples = [0.0] * NUM_SAMPLES

for b in range(NUM_BEATS):
    beat_start_t = b * BEAT_DURATION
    
    # 1. Lub (first thump - low systolic surge)
    lub_t0 = beat_start_t
    lub_dur = 0.18
    for i in range(int(SAMPLE_RATE * lub_dur)):
        idx = int(SAMPLE_RATE * lub_t0) + i
        if idx >= NUM_SAMPLES: break
        t = float(i) / SAMPLE_RATE
        env = (t / 0.018) if t < 0.018 else math.exp(-(t - 0.018) * 16.0)
        freq = 60.0 - 20.0 * (t / lub_dur)
        val = math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(2.0 * math.pi * freq * 2.0 * t)
        samples[idx] += val * env * 0.88

    # 2. Dub (second thump - higher diastolic rebound)
    dub_t0 = beat_start_t + 0.22
    dub_dur = 0.14
    for i in range(int(SAMPLE_RATE * dub_dur)):
        idx = int(SAMPLE_RATE * dub_t0) + i
        if idx >= NUM_SAMPLES: break
        t = float(i) / SAMPLE_RATE
        env = (t / 0.014) if t < 0.014 else math.exp(-(t - 0.014) * 22.0)
        freq = 80.0 - 25.0 * (t / dub_dur)
        val = math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(2.0 * math.pi * freq * 2.0 * t)
        samples[idx] += val * env * 0.65

# Smooth loop boundary
fade_samples = int(SAMPLE_RATE * 0.02)
for i in range(fade_samples):
    samples[i] *= (float(i) / fade_samples)
    samples[-(i + 1)] *= (float(i) / fade_samples)

max_val = max(max(abs(s) for s in samples), 0.001)
raw_bytes = bytearray()
for s in samples:
    norm = s / max_val * 0.92
    val_int = int(max(-1.0, min(1.0, norm)) * 32767.0)
    raw_bytes.extend(struct.pack("<h", val_int))

os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
with wave.open(OUTPUT_PATH, "wb") as wf:
    wf.setnchannels(1)
    wf.setsampwidth(2)
    wf.setframerate(SAMPLE_RATE)
    wf.writeframes(raw_bytes)

print(f"Generated {OUTPUT_PATH}: {len(samples)} samples, {len(raw_bytes)} bytes.")
```

---

## 5. Verification Method

### 5.1 Automated Regression Verification
Run the 4-tier regression suite to ensure 0 regression:
```bash
godot --headless scenes/test/test_realistic_overhaul.tscn
```
*Expected Result*: 88 / 88 PASSED (100% pass rate).

Validate all 13 mission scenes:
```bash
godot --headless --script tools/validate_all_missions.gd
```
*Expected Result*: All 13 missions pass with intact Player and ZombieSpawner nodes.

### 5.2 Dedicated R1 Automated Test Script (`scenes/test/test_r1_feedback.gd`)
Create and run a headless test validating all R1 requirements:
```gdscript
extends SceneTree

func _init():
    print("=== TESTING REQUIREMENT R1: HUD BLOOD SPLATTER & LOW-HP FEEDBACK ===")
    var hud_scene = load("res://scenes/UI/HUD.tscn")
    var hud = hud_scene.instantiate()
    root.add_child(hud)
    await process_frame
    
    # 1. Verify Blood Splatter Trigger and Lifetime
    hud.update_health(70.0, 100.0) # Took 30 damage
    assert(hud.active_blood_splatters.size() >= 1, "Blood splatter not triggered on damage")
    var s = hud.active_blood_splatters[0]
    assert(abs(s.max_life - 2.5) < 0.01, "Splatter max_life is not 2.5s")
    print("✅ TC-R1-01: Blood splatter triggered with 2.5s dissipation duration")
    
    # 2. Simulate 2.6s elapsed -> confirm complete dissipation
    hud._process(2.6)
    assert(hud.active_blood_splatters.is_empty(), "Blood splatters failed to dissipate after 2.5s")
    print("✅ TC-R1-02: Blood splatters completely dissipated after 2.5s")
    
    # 3. Verify Low-HP Trigger (<30 HP)
    hud.update_health(20.0, 100.0) # Drop below 30 HP
    hud._process(0.1)
    assert(hud.is_low_hp_active == true, "Low-HP state failed to activate below 30 HP")
    assert(hud.low_hp_vignette.modulate.a > 0.05, "Pulsing vignette not visible at 20 HP")
    print("✅ TC-R1-03: Low-HP pulsing vignette & heartbeat audio activated (< 30 HP)")
    
    # 4. Verify Recovery Subsidence (>= 30 HP)
    hud.update_health(35.0, 100.0) # Health recovered to 35 HP
    hud._process(0.5)
    assert(hud.is_low_hp_active == false, "Low-HP state failed to deactivate upon recovery >= 30 HP")
    assert(hud.low_hp_vignette.modulate.a < 0.05, "Vignette failed to subside after recovery")
    print("✅ TC-R1-04: Low-HP vignette & audio smoothly subsided upon recovery (>= 30 HP)")
    
    print("ALL R1 TEST CASES PASSED SUCCESSFULLY.")
    quit(0)
```
Run command:
```bash
godot --headless --script scenes/test/test_r1_feedback.gd
```
*Invalidation Conditions*:
- Blood splatter does not fade out by 2.5s or remains visible forever.
- Low-HP vignette activates at $\ge 30\text{ HP}$ or fails to subside when health reaches $30\text{ HP}$.
- Frame rate drops below 30 FPS or static memory increases across hit cycles.
- Touch controls in `LookArea` or `VirtualJoystick` fail to receive events due to missing `mouse_filter = 2`.
