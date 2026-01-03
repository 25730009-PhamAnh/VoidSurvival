using UnityEngine;

/// <summary>
/// ScriptableObject defining asteroid properties.
/// Allows easy balancing without code changes.
/// </summary>
[CreateAssetMenu(fileName = "AsteroidData", menuName = "Game/Hazards/Asteroid Data")]
public class AsteroidData : ScriptableObject
{
    [Header("Identity")]
    public string asteroidName;
    public AsteroidSize size;

    [Header("Visual")]
    public Sprite sprite;
    public Vector2 spriteScale = Vector2.one;
    public Color color = Color.gray;

    [Header("Physics")]
    [Range(0.1f, 5f)] public float colliderRadius = 0.5f;
    [Range(0.5f, 10f)] public float mass = 1f;

    [Header("Movement")]
    [Range(0.5f, 5f)] public float minSpeed = 1f;
    [Range(1f, 8f)] public float maxSpeed = 3f;

    [Header("Combat")]
    [Range(1, 100)] public int health = 30;
    [Range(1, 20)] public int scoreValue = 10;

    [Header("Fragmentation")]
    public bool canFragment = true;
    [Range(0, 5)] public int fragmentCount = 3;
    public AsteroidData fragmentData; // Reference to smaller asteroid data
}

public enum AsteroidSize
{
    Large,
    Medium,
    Small
}
