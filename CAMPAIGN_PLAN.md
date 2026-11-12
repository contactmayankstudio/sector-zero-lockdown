# Long-Form Campaign Architecture & Progression Plan
**Sector Zero: Lockdown (Godot 4 Mobile FPS)**

## 1. Executive Summary & Runtime Contract

The game has graduated from a 12-mission prototype to a **long-form campaign architecture** matching premium mobile zombie shooters.

- **Total Chapters:** 12 Major Locations / Chapters.
- **Sub-Missions per Chapter:** Exactly 7 sub-missions.
- **Total Campaign Missions:** $12 \times 7 = 84$ playable campaign missions (`1-1` to `12-7`).
- **Combat Waves per Sub-Mission:** Exactly 3 substantial tactical combat waves.
- **Enemy Density:** 10–25+ enemies per wave with directional wave pacing (`front`, `left`, `right`, `back`).
- **Campaign Capstone:** Sub-mission `12-7` ("APEX ALPHA MUTANT FINAL BOSS").
- **Post-Campaign Unlock:** Beating `12-7` displays **"CAMPAIGN COMPLETE"** and permanently unlocks **ENDLESS SURVIVAL MODE**.
- **Stationary Combat Grounding:** All objectives are designed around stationary 360-degree aiming and target prioritization.

---

## 2. 12 Chapters Breakdown & Reusable Environment Mapping

| Chapter | Sector Name | Major Location | Reusable Environment Scene | Tactical Dressing & Lighting |
| :---: | :--- | :--- | :--- | :--- |
| **01** | Sector 01 | Airport Complex | `res://scenes/environments/AirportTerminal.tscn` | High-key concourse lighting, ticket counters, baggage barricades |
| **02** | Sector 02 | Airport Service Road | `res://scenes/environments/AirportServiceRoad.tscn` | Low sun tarmac, security perimeter fencing, supply vehicles |
| **03** | Sector 03 | Railway Station | `res://scenes/environments/RailwayStation.tscn` | Sodium vapor lighting, passenger platform benches, turnstiles |
| **04** | Sector 04 | Abandoned Train Yard | `res://scenes/environments/AbandonedTrain.tscn` | Dark rail yard, train carriage choke points, rusty tracks |
| **05** | Sector 05 | Industrial Zone | `res://scenes/environments/DarkIndustrial.tscn` | Heavy industrial dumpsters, sodium perimeter lamps, machinery |
| **06** | Sector 06 | Abandoned Hospital | `res://scenes/environments/ApartmentComplex.tscn` | Emergency red strobe, claustrophobic ward corridors |
| **07** | Sector 07 | Shopping District / Metro | `res://scenes/environments/RailwayStation.tscn` | Commercial galleria concourse, escalator descent, subway tunnel |
| **08** | Sector 08 | Night City Street | `res://scenes/environments/NightCityStreet.tscn` | Neon reflections, emergency police strobes, wet asphalt |
| **09** | Sector 09 | Military Checkpoint | `res://scenes/environments/AirportServiceRoad.tscn` | Razorwire barriers, sandbag emplacements, armored carriers |
| **10** | Sector 10 | Chemical Facility | `res://scenes/environments/DarkIndustrial.tscn` | Hazard amber lighting, high-pressure toxic pipe venting |
| **11** | Sector 11 | Factory / Construction | `res://scenes/environments/DarkIndustrial.tscn` | High-contrast industrial shadows, scaffolding, excavation pit |
| **12** | Sector 12 | Quarantine Zone Core | `res://scenes/environments/FinalLockdown.tscn` | Red emergency lockdown strobe, siren audio, Apex Boss arena |
| **Endless** | Outpost | Quarantine Perimeter | `res://scenes/environments/NightCityStreet.tscn` | Infinite escalation, dynamic night lighting |

---

## 3. Sub-Mission Pacing Arc (7-Mission Template Per Chapter)

Every chapter executes a consistent difficulty and tactical arc:

| Sub-Mission | Tactical Role | Objective Type | Enemies / Target | Waves | Pacing Description |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **X-1** | Patrol / First Contact | `KILL_COUNT` | 10–14 | 3 | Establishes chapter environment; Normal infected; Front/Back spawns. |
| **X-2** | Flank Incursion | `KILL_COUNT` | 12–16 | 3 | Introduces Fast runners; heavy Left and Right flanking pressure. |
| **X-3** | Defensive Holdout | `SURVIVE_WAVES` | 15–20 | 3 | Multi-directional assault; stationary 360° situational awareness test. |
| **X-4** | Armored Escalation | `KILL_COUNT` | 16–22 | 3 | Heavy soldier / armored brute infected introduced in wave 2 & 3. |
| **X-5** | Specialist Swarm | `KILL_COUNT` | 18–24 | 3 | Fast infected + Dogs or Acid Spitters introduced in mixed squads. |
| **X-6** | Pre-Boss Siege | `SURVIVE_WAVES` | 20–28 | 3 | High-density mixed elite composition; ammo conservation pressure. |
| **X-7** | Sector Apex Boss | `BOSS_KILL` | Boss + 10 | 3 | Chapter Boss (`BossZombie.tscn` / Mutant) + wave 3 clear required. |

---

## 4. Linear Progression & Unlocking Chain

```
[1-1] -> [1-2] -> [1-3] -> [1-4] -> [1-5] -> [1-6] -> [1-7: Apex Boss 1]
                                                            |
[2-1] <- [2-2] <- [2-3] <- [2-4] <- [2-5] <- [2-6] <- [2-7: Apex Boss 2]
  |
 ...
  |
[12-1] -> [12-2] -> [12-3] -> [12-4] -> [12-5] -> [12-6] -> [12-7: APEX ALPHA SPECIMEN]
                                                                     |
                                                          [CAMPAIGN COMPLETE]
                                                                     |
                                                          [UNLOCK ENDLESS SURVIVAL]
```

- **Within Chapter:** `X-S` unlocks after `X-(S-1)`.
- **Across Chapters:** `(X+1)-1` unlocks only after `X-7` (Chapter Boss) is defeated.
- **Endless Survival Mode:** Unlocks permanently only after `12-7` is completed.

---

## 5. CASH Economy & Single-Claim Policy

- **First-Time Clear Bounty:** $500 (Chapter 1) scaling up to $7,500 (Chapter 12).
- **Single-Claim Policy:** `SaveManager.claim_mission_reward()` guarantees that replaying a completed mission yields $0 first-time bounty, preventing inflation exploits.
- **Endless Survival Rewards:** Awards $+15$ CASH per kill directly through score and kill count.
- **Zero Real Currency:** Uses fictional `SECTOR CASH` exclusively.
