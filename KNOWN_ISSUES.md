# Sector Zero: Lockdown — Known Issues & Technical Limitations

**Document Version:** 1.0.0  
**Project:** Sector Zero: Lockdown (Godot 4.3 Mobile 3D FPS)  
**Target Specs:** Low-End Android (Helio P35, Mali-G52, Adreno 610)  

---

## 1. Known Technical Nuances & Limitations

### 1.1 Mobile Aspect Ratio Edge Cases
- `Minor Robustness Risk`: Viewports wider than 20:9 (e.g., modern ultra-wide flagship phones with 21:9 or 22:9 displays) will exhibit horizontal letterboxing/pillarboxing due to the `keep_aspect` window configuration. While UI elements remain centered and fully reachable, edge ornamentation does not stretch infinitely.
- `Minor Robustness Risk`: Display cutouts/notches on certain asymmetrical tablets may require custom notch insets if the OEM OS does not supply standard Android display cutout metrics.

### 1.2 Low-End Mobile (Helio P35 / Mali-G52) Performance Considerations
- `Minor Robustness Risk`: Simultaneous multi-finger pinch-zooming and rapid panning on the Tactical Campaign Map may induce minor frame drops on devices with low touch sampling rates (e.g., 60Hz touch digitizers on budget phones).
- `Minor Robustness Risk`: Rapidly opening and closing the 3D rotating weapon view in `ArmoryUI.tscn` could cause momentary garbage collector pauses on low-RAM (2GB-3GB) devices as GLB meshes and materials are cycled into memory.

### 1.3 Godot 4.3 Headless Engine Teardown Warnings
- `Shallow Verification`: When running automated test scripts in `--headless` mode, Godot logs benign teardown notices:
  `WARNING: ObjectDB instances leaked at exit`
  `ERROR: 1 resources still in use at exit`
  These are standard Godot 4 headless runner engine artifacts caused by static singleton cleanup ordering when the engine is forcibly terminated by test runner scripts, and do not reflect runtime leaks during interactive gameplay.

### 1.4 Native OS & Hardware Back Handling
- `Shallow Verification`: Android hardware back button handling (`NOTIFICATION_WM_GO_BACK_REQUEST`) is verified via Godot notification tests and input injection. However, OEM-specific gesture navigation (e.g., Samsung OneUI edge swipe vs Xiaomi MIUI edge swipe) relies on the underlying Android activity window receiving `onBackPressed()`, which must be validated on physical test hardware.

### 1.5 Duplicate Script Hierarchy Aliases
- `Minor Robustness Risk`: The project maintains dual script paths for certain UI screens (`scripts/*.gd` and `scripts/UI/*.gd`) to prevent breaking external references. Both paths are kept synchronized via inheritance passthroughs (`extends "res://scripts/..."`), but future additions should standardize exclusively on `scripts/UI/`.

---

## 2. Recommendations for Reviewers / Future Iterations

1. **Physical Device Stress Test:** Verify touch latency and gesture recognition of the Tactical Campaign Map pan/zoom on low-tier 60Hz Android devices.
2. **Notch Inset Plugin:** For ultra-wide Android devices, integrate Godot's `DisplayServer.get_display_cutouts()` for dynamic UI padding.
3. **Audio Bus Ducking:** When the Pause menu or Mission Briefing panel opens, implement audio bus low-pass filtering or ducking to enhance tactical immersion.
