using Godot;
using System;
using System.Collections.Generic;

namespace SectorZero.AI;

/// <summary>
/// C# High-Density Zombie Swarm Optimizer.
/// Built with .NET 8 to handle hundreds of active entities at 60 FPS without garbage collection stalls.
/// </summary>
public partial class ZombieSwarmOptimizer : Node
{
    public static ZombieSwarmOptimizer Instance { get; private set; }

    private readonly List<Node3D> _trackedZombies = new(128);
    private double _batchTimer = 0.0;
    private const double BatchInterval = 0.25; // 4Hz batch spatial distribution

    public override void _Ready()
    {
        Instance = this;
        GD.Print("[ZombieSwarmOptimizer C#] High-density horde simulation manager online.");
    }

    public void RegisterZombie(Node3D zombie)
    {
        if (zombie != null && !_trackedZombies.Contains(zombie))
        {
            _trackedZombies.Add(zombie);
        }
    }

    public void UnregisterZombie(Node3D zombie)
    {
        if (zombie != null)
        {
            _trackedZombies.Remove(zombie);
        }
    }

    public override void _Process(double delta)
    {
        _batchTimer += delta;
        if (_batchTimer < BatchInterval) return;
        _batchTimer = 0.0;

        // Clean dead/invalid references
        _trackedZombies.RemoveAll(z => z == null || !IsInstanceValid(z));

        // High-scale spatial distribution optimization
        // In high-density hordes, zombies outside 50m have their processing throttled to save CPU
        var player = GetTree().GetFirstNodeInGroup("player") as Node3D;
        if (player == null || !IsInstanceValid(player)) return;

        Vector3 playerPos = player.GlobalPosition;
        float farDistanceSq = 55.0f * 55.0f;

        for (int i = 0; i < _trackedZombies.Count; i++)
        {
            var zombie = _trackedZombies[i];
            float distSq = zombie.GlobalPosition.DistanceSquaredTo(playerPos);
            bool isFar = distSq > farDistanceSq;
            
            // Adjust processing priority based on distance
            zombie.SetProcess(!isFar || (i % 2 == 0));
        }
    }
}
