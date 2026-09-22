# Sector Zero: Lockdown 🎮
**3D Mobile Zombie Survival Action Shooter**

Package ID: `com.targetzero.lockdown`

## Tech Stack & Highlights
- **Engine:** Godot 4.x with GDScript
- **Core Systems:** Custom collision loops, AI pathfinding, wave-based spawning
- **Target FPS:** Stable 60 FPS on mid-to-high tier Android devices
- **Optimization:** Dynamic asset streaming, strict memory management, audio pooling
- **Controls:** Low-latency touch input handling with virtual joystick & crosshair

## Game Features
- 🧟 **Realistic Scary Zombies** — Skeletal-animated enemies with glowing red eyes, 7 archetypes (Normal, Fast, Heavy, Boss, Spitter, Special, Realistic)
- 🔫 **7 Unique Weapons** — USP-45, M4A1 Sentinel, Remington 870, NG7 Heavy LMG, P90 Tactical, AK-74 Bayonet, AKX Cyber Carbine + grenades
- 🎯 **Centered Crosshair System** — All weapons calibrated for direct screen-center first-person alignment
- 🗺️ **Multiple Missions** — Airport Terminal, Urban Street with progressive difficulty
- 💰 **Progression System** — Earn coins, upgrade weapons, unlock new missions
- 📱 **Mobile Optimized** — Touch controls, AdMob integration, responsive HUD
- 🎓 **Interactive Tutorial** — 5-step onboarding for new players

## Performance Optimizations
- Zero disk I/O hitching (async save system)
- GPU texture throttling on health bars
- Memory leak elimination (CPUParticles3D cleanup)
- 8-channel audio reuse pool
- Inactive weapon process loop disabling

## Build
```bash
# Android APK (Signed Release)
./build_release.sh

# Output: build/SectorZero-Lockdown-release.apk
```

## Release Info
| Field | Value |
|---|---|
| Version | 1.0.0 |
| Min SDK | 24 (Android 7.0) |
| Target SDK | 34 (Android 14) |
| Keystore Validity | 100 years (until 2126) |

## License
All rights reserved © 2026 Mayank Studio
