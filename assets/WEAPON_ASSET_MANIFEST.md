# Sector Zero: Lockdown — Weapon Asset Manifest

**Date:** 2026-09-18  
**Project:** Sector Zero: Lockdown  
**Standard:** 10-Weapon Dedicated Arsenal — Zero-Tolerance Copyright Policy  

---

## 1. Verified Active Arsenal (10 Dedicated Weapons)

The active Armory and gameplay pipeline exclusively utilizes these 10 verified, legal, commercial-safe 3D weapon assets:

| # | Weapon ID | Display Name | Source Path | Format | Textures / PBR | Intended Slot | License & Provenance | Commercial Safe |
| :-: | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :-: |
| **1** | `usp45` | USP-45 Tactical | `assets/3d/weapons/usp45.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Starter Sidearm (Pistol) | CC0 1.0 Universal / MIT | **YES** |
| **2** | `m4a1` | M4A1 Sentinel | `assets/3d/weapons/m4a1.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Tactical Assault Rifle | CC0 1.0 Universal / MIT | **YES** |
| **3** | `remington870` | Remington 870 | `assets/3d/weapons/remington870.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Close-Quarters Shotgun | CC0 1.0 Universal / MIT | **YES** |
| **4** | `ak47` | AK-47 Vanguard | `assets/3d/weapons/ak47.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Heavy Combat Rifle | CC0 1.0 Universal / MIT | **YES** |
| **5** | `desert_eagle` | Desert Eagle .50 AE | `assets/3d/weapons/desert_eagle.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Heavy Handgun | CC0 1.0 Universal / MIT | **YES** |
| **6** | `mp5` | MP5 Tactical | `assets/3d/weapons/mp5.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | High-RPM Submachine Gun | CC0 1.0 Universal / MIT | **YES** |
| **7** | `awp` | AWP Arctic Warfare | `assets/3d/weapons/awp.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Extreme-Range Sniper | CC0 1.0 Universal / MIT | **YES** |
| **8** | `combat_knife` | Combat Knife | `assets/3d/weapons/combat_knife.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Silent Melee Weapon | CC0 1.0 Universal / MIT | **YES** |
| **9** | `crossbow` | Silent Hunter Crossbow | `assets/3d/weapons/crossbow.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Tactical Special Weapon | CC0 1.0 Universal / MIT | **YES** |
| **10** | `grenade_launcher` | M79 Grenade Launcher | `assets/3d/weapons/grenade_launcher.glb` | glTF 2.0 | `tex_weapon_metal.png` PBR | Heavy Explosive Ordnance | CC0 1.0 Universal / MIT | **YES** |

---

## 2. Quarantined & Excluded External Assets

The following downloaded or external models originate from commercial video games or have unverified licensing. They are **strictly quarantined** in `quarantine_suspect_assets/` and **excluded** from the active Armory, active gameplay scenes, and all distribution export presets:

| Quarantined Asset | Apparent Origin / Source | Legal Risk | Armory Status | Export Status |
| :--- | :--- | :--- | :--- | :--- |
| `apex_legends_car_smg_brimstone.glb` | Respawn / EA (Apex Legends) | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |
| `apex_legends_car_smg_mythic_allfathers_fury.glb` | Respawn / EA (Apex Legends) | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |
| `apex_legends_vk-47_flatline_overheat.glb` | Respawn / EA (Apex Legends) | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |
| `apex_legends_weapon_vantage_ultimate_sniper.glb`| Respawn / EA (Apex Legends) | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |
| `serious_sam_3_minigun.glb` | Croteam / Devolver Digital | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |
| `gta_grove_street.glb` | Rockstar Games (GTA:SA) | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |
| `wardens-sword-halo-5-2015.zip` | 343 Industries / Microsoft | Proprietary Commercial IP | **EXCLUDED** | **FILTERED OUT** |

---

## 3. Weapon Model Reconnection Rules

1. Each of the 10 active weapons links directly to its verified 3D scene in `scenes/weapons/models/`:
   - `usp45` -> `scenes/weapons/models/usp45.tscn` (Mesh: `assets/3d/weapons/usp45.glb`)
   - `m4a1` -> `scenes/weapons/models/m4a1.tscn` (Mesh: `assets/3d/weapons/m4a1.glb`)
   - `remington870` -> `scenes/weapons/models/remington870.tscn` (Mesh: `assets/3d/weapons/remington870.glb`)
   - `ak47` -> `scenes/weapons/models/ak47.tscn` (Mesh: `assets/3d/weapons/ak47.glb`)
   - `desert_eagle` -> `scenes/weapons/models/desert_eagle.tscn` (Mesh: `assets/3d/weapons/desert_eagle.glb`)
   - `mp5` -> `scenes/weapons/models/mp5.tscn` (Mesh: `assets/3d/weapons/mp5.glb`)
   - `awp` -> `scenes/weapons/models/awp.tscn` (Mesh: `assets/3d/weapons/awp.glb`)
   - `combat_knife` -> `scenes/weapons/models/combat_knife.tscn` (Mesh: `assets/3d/weapons/combat_knife.glb`)
   - `crossbow` -> `scenes/weapons/models/crossbow.tscn` (Mesh: `assets/3d/weapons/crossbow.glb`)
   - `grenade_launcher` -> `scenes/weapons/models/grenade_launcher.tscn` (Mesh: `assets/3d/weapons/grenade_launcher.glb`)

2. Aliases `pistol`, `rifle`, and `shotgun` resolve cleanly to `usp45`, `m4a1`, and `remington870` respectively for backward save compatibility.
3. No raw unverified external weapon models appear in the player's hands or in the Armory 3D showroom.
