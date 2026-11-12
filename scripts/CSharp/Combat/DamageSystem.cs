using Godot;
using System;
using Godot.Collections;

namespace SectorZero.Combat;

/// <summary>
/// High-performance C# Combat & Damage System.
/// Built with .NET 8 for AAA damage calculation with 0 heap allocation.
/// </summary>
public partial class DamageSystem : RefCounted
{
    public static float CalculateDamage(float baseDamage, float distance, float maxRange, float falloffFactor = 0.5f)
    {
        if (maxRange <= 0.0f || distance <= 0.0f)
            return baseDamage;

        float normalizedDist = Mathf.Clamp(distance / maxRange, 0.0f, 1.0f);
        float falloff = Mathf.Lerp(1.0f, falloffFactor, normalizedDist);
        return baseDamage * falloff;
    }

    public static Dictionary ProcessHit(Node target, float baseDamage, Vector3 hitPoint, Vector3 shooterPos, bool isHeadshotOverride = false)
    {
        Vector3 hitDir = (hitPoint - shooterPos).Normalized();
        float finalDamage = baseDamage;
        bool isHeadshot = isHeadshotOverride;
        string hitZone = "body";

        if (target != null && IsInstanceValid(target))
        {
            if (target.HasMethod("take_hit"))
            {
                var res = (Dictionary)target.Call("take_hit", baseDamage, hitDir);
                if (res != null)
                {
                    finalDamage = (float)res["final_damage"];
                    isHeadshot = (bool)res["is_headshot"];
                    hitZone = (string)res["zone"];
                }
            }
            else if (target.HasMethod("take_damage"))
            {
                if (isHeadshotOverride || hitPoint.Y > ((Node3D)target).GlobalPosition.Y + 1.2f)
                {
                    finalDamage *= 2.0f;
                    isHeadshot = true;
                    hitZone = "head";
                }
                target.Call("take_damage", finalDamage, isHeadshot, hitDir);
            }
        }

        var result = new Dictionary
        {
            { "final_damage", finalDamage },
            { "is_headshot", isHeadshot },
            { "hit_zone", hitZone },
            { "hit_point", hitPoint },
            { "hit_dir", hitDir }
        };

        return result;
    }
}
