#!/bin/bash
# Zombie Night Highway Launcher
# High-FPS, cool-running photorealistic zombie survival highway
cd /home/am/targetkill
DISPLAY=:0 XAUTHORITY=/home/am/.Xauthority /home/am/apps/godot-mono/Godot_v4.7.2-stable_mono_linux_x86_64/Godot_v4.7.2-stable_mono_linux.x86_64 res://scenes/environments/ZombieNightHighway.tscn "$@"
