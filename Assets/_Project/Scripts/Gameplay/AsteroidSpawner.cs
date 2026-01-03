using UnityEngine;

/// <summary>
/// Spawns asteroids at random screen edges.
/// Simple time-based spawning for Week 1.
/// </summary>
public class AsteroidSpawner : MonoBehaviour
{
    #region Singleton
    public static AsteroidSpawner Instance { get; private set; }
    #endregion

    #region Private Fields
    [Header("Spawn Settings")]
    [SerializeField] private GameObject m_AsteroidPrefab;
    [SerializeField] private AsteroidData m_LargeAsteroidData;

    [SerializeField] private float m_SpawnInterval = 2f;
    [SerializeField] private Vector2 m_ScreenBounds = new Vector2(10f, 10f);

    [Header("Spawn Control")]
    [SerializeField] private Transform m_HazardsParent;
    [SerializeField] private bool m_IsSpawning = false;

    private float m_LastSpawnTime;
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }

        if (m_HazardsParent == null)
            m_HazardsParent = GameManager.Instance.GetHazardsParent();
    }

    private void Update()
    {
        if (m_IsSpawning && Time.time - m_LastSpawnTime > m_SpawnInterval)
        {
            SpawnRandomAsteroid();
            m_LastSpawnTime = Time.time;
        }
    }
    #endregion

    #region Public Methods
    public void StartSpawning()
    {
        m_IsSpawning = true;
        m_LastSpawnTime = Time.time;
    }

    public void StopSpawning()
    {
        m_IsSpawning = false;
    }

    public void SpawnAsteroid(AsteroidData data, Vector2 position, Vector2 velocity)
    {
        GameObject asteroidObj = Instantiate(m_AsteroidPrefab, m_HazardsParent);
        Asteroid asteroid = asteroidObj.GetComponent<Asteroid>();
        asteroid.Initialize(data, position, velocity);
    }
    #endregion

    #region Private Methods
    private void SpawnRandomAsteroid()
    {
        // Random edge position
        Vector2 spawnPosition = GetRandomEdgePosition();

        // Velocity toward center with some randomness
        Vector2 toCenter = ((Vector2)Vector2.zero - spawnPosition).normalized;
        Vector2 randomOffset = Random.insideUnitCircle * 0.3f;
        Vector2 direction = (toCenter + randomOffset).normalized;

        float speed = Random.Range(m_LargeAsteroidData.minSpeed,
                                   m_LargeAsteroidData.maxSpeed);
        Vector2 velocity = direction * speed;

        SpawnAsteroid(m_LargeAsteroidData, spawnPosition, velocity);
    }

    private Vector2 GetRandomEdgePosition()
    {
        int edge = Random.Range(0, 4); // 0=top, 1=right, 2=bottom, 3=left

        return edge switch
        {
            0 => new Vector2(Random.Range(-m_ScreenBounds.x, m_ScreenBounds.x), m_ScreenBounds.y),
            1 => new Vector2(m_ScreenBounds.x, Random.Range(-m_ScreenBounds.y, m_ScreenBounds.y)),
            2 => new Vector2(Random.Range(-m_ScreenBounds.x, m_ScreenBounds.x), -m_ScreenBounds.y),
            3 => new Vector2(-m_ScreenBounds.x, Random.Range(-m_ScreenBounds.y, m_ScreenBounds.y)),
            _ => Vector2.zero
        };
    }
    #endregion
}
