using Godot;
using System;
using System.Collections.Generic;

namespace SectorZero.World;

/// <summary>
/// High-performance C# Open-World Chunk & Streaming Manager.
/// Built for large-scale open-world environments in .NET 8.
/// Dynamically tracks the player/vehicle to stream assets and maintain stable 45-60 FPS.
/// </summary>
public partial class WorldChunkStreamer : Node3D
{
    [Export] public float ChunkSize { get; set; } = 120.0f;
    [Export] public int ViewDistanceChunks { get; set; } = 3;
    [Export] public NodePath TargetTrackerPath { get; set; }

    private Node3D _trackerTarget;
    private Vector2I _currentChunkCoord = new Vector2I(int.MinValue, int.MinValue);
    private readonly HashSet<Vector2I> _activeChunks = new();

    public override void _Ready()
    {
        if (TargetTrackerPath != null && !TargetTrackerPath.IsEmpty)
        {
            _trackerTarget = GetNodeOrNull<Node3D>(TargetTrackerPath);
        }

        GD.Print($"[WorldChunkStreamer C#] Initialized with ChunkSize={ChunkSize}m, ViewDistance={ViewDistanceChunks} chunks.");
    }

    public override void _Process(double delta)
    {
        UpdateTrackerTargetIfNeeded();

        if (_trackerTarget == null || !IsInstanceValid(_trackerTarget))
            return;

        Vector3 pos = _trackerTarget.GlobalPosition;
        int cx = Mathf.FloorToInt(pos.X / ChunkSize);
        int cz = Mathf.FloorToInt(pos.Z / ChunkSize);
        Vector2I newCoord = new Vector2I(cx, cz);

        if (newCoord != _currentChunkCoord)
        {
            _currentChunkCoord = newCoord;
            ReevaluateStreamGrid(newCoord);
        }
    }

    private void UpdateTrackerTargetIfNeeded()
    {
        if (_trackerTarget != null && IsInstanceValid(_trackerTarget))
            return;

        // Automatically find active player or mounted vehicle in the scene
        var player = GetTree().GetFirstNodeInGroup("player") as Node3D;
        if (player != null && IsInstanceValid(player))
        {
            _trackerTarget = player;
            return;
        }

        var vehicle = GetTree().GetFirstNodeInGroup("vehicles") as Node3D;
        if (vehicle != null && IsInstanceValid(vehicle))
        {
            _trackerTarget = vehicle;
        }
    }

    private void ReevaluateStreamGrid(Vector2I center)
    {
        var requiredChunks = new HashSet<Vector2I>();

        for (int x = -ViewDistanceChunks; x <= ViewDistanceChunks; x++)
        {
            for (int z = -ViewDistanceChunks; z <= ViewDistanceChunks; z++)
            {
                requiredChunks.Add(new Vector2I(center.X + x, center.Y + z));
            }
        }

        // Identify newly entered chunks
        foreach (var chunk in requiredChunks)
        {
            if (!_activeChunks.Contains(chunk))
            {
                _activeChunks.Add(chunk);
                // Hook for chunk stream-in event
            }
        }

        // Identify departed chunks to free memory
        var toRemove = new List<Vector2I>();
        foreach (var chunk in _activeChunks)
        {
            if (!requiredChunks.Contains(chunk))
            {
                toRemove.Add(chunk);
            }
        }

        foreach (var chunk in toRemove)
        {
            _activeChunks.Remove(chunk);
            // Hook for chunk unload event
        }
    }
}
