using Godot;
using System;

namespace SectorZero.Vehicles;

/// <summary>
/// High-speed C# Vehicle Physics & Incline Climbing Helper.
/// Built with .NET 8 for responsive 4x4 crawling and lean physics.
/// </summary>
[GlobalClass]
public partial class VehiclePhysicsHelper : RefCounted
{
    /// <summary>
    /// Calculates dynamic 4x4 hill-climbing crawl assist on mountain slopes.
    /// </summary>
    public static Vector3 CalculateInclineAssist(Vector3 linearVelocity, Vector3 forwardDir, float slopeAngleDeg, float baseForce)
    {
        if (slopeAngleDeg < 8.0f)
            return Vector3.Zero;

        // Scale crawl assist smoothly with slope incline (up to 45 degrees)
        float factor = Mathf.Clamp((slopeAngleDeg - 8.0f) / 37.0f, 0.0f, 1.0f);
        float boost = baseForce * factor;
        
        // Project forward direction slightly up the slope to prevent bumper stalling
        Vector3 assistDir = (forwardDir + Vector3.Up * 0.25f).Normalized();
        return assistDir * boost;
    }

    /// <summary>
    /// Instance method for GDScript interop.
    /// </summary>
    public Vector3 GetInclineAssist(Vector3 linearVelocity, Vector3 forwardDir, float slopeAngleDeg, float baseForce)
    {
        return CalculateInclineAssist(linearVelocity, forwardDir, slopeAngleDeg, baseForce);
    }

    /// <summary>
    /// Smoothly computes dynamic motorcycle roll/lean angle based on turn speed.
    /// </summary>
    public static float ComputeBikeLean(float currentLeanRad, float steerInput, float speedKmh, float maxLeanRad, float delta)
    {
        // Don't lean at standstill
        float speedFactor = Mathf.Clamp(speedKmh / 30.0f, 0.0f, 1.0f);
        float targetLean = -steerInput * maxLeanRad * speedFactor;
        return Mathf.Lerp(currentLeanRad, targetLean, delta * 9.0f);
    }

    /// <summary>
    /// Instance method for GDScript interop.
    /// </summary>
    public float GetBikeLean(float currentLeanRad, float steerInput, float speedKmh, float maxLeanRad, float delta)
    {
        return ComputeBikeLean(currentLeanRad, steerInput, speedKmh, maxLeanRad, delta);
    }
}
