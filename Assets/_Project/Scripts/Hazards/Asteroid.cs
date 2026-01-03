using UnityEngine;

/// <summary>
/// Asteroid entity with movement, health, and fragmentation.
/// </summary>
[RequireComponent(typeof(Rigidbody2D), typeof(CircleCollider2D))]
public class Asteroid : MonoBehaviour
{
    #region Private Fields
    [Header("Data")]
    [SerializeField] private AsteroidData m_Data;

    private Rigidbody2D m_Rigidbody;
    private CircleCollider2D m_Collider;
    private SpriteRenderer m_SpriteRenderer;

    private int m_CurrentHealth;

    [Header("Screen Wrap")]
    [SerializeField] private Vector2 m_ScreenBounds = new Vector2(10f, 10f);
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        m_Rigidbody = GetComponent<Rigidbody2D>();
        m_Collider = GetComponent<CircleCollider2D>();
        m_SpriteRenderer = GetComponent<SpriteRenderer>();

        ConfigureComponents();
    }

    private void FixedUpdate()
    {
        HandleScreenWrap();
    }
    #endregion

    #region Public Methods
    public void Initialize(AsteroidData data, Vector2 position, Vector2 velocity)
    {
        m_Data = data;
        transform.position = position;

        m_CurrentHealth = m_Data.health;

        // Apply data to components
        m_SpriteRenderer.sprite = m_Data.sprite;
        m_SpriteRenderer.color = m_Data.color;
        transform.localScale = m_Data.spriteScale;

        m_Collider.radius = m_Data.colliderRadius;
        m_Rigidbody.mass = m_Data.mass;
        m_Rigidbody.linearVelocity = velocity;

        // Random rotation
        m_Rigidbody.angularVelocity = Random.Range(-50f, 50f);
    }

    public void TakeDamage(int damage)
    {
        m_CurrentHealth -= damage;

        if (m_CurrentHealth <= 0)
        {
            DestroyAsteroid();
        }
    }
    #endregion

    #region Private Methods
    private void ConfigureComponents()
    {
        m_Rigidbody.gravityScale = 0f;
        m_Rigidbody.collisionDetectionMode = CollisionDetectionMode2D.Continuous;

        m_Collider.isTrigger = true; // For projectile detection
    }

    private void DestroyAsteroid()
    {
        // Award score
        ScoreManager.Instance.AddScore(m_Data.scoreValue);

        // Fragment if applicable
        if (m_Data.canFragment && m_Data.fragmentData != null)
        {
            CreateFragments();
        }

        // TODO: Spawn particle effect
        // TODO: Play sound

        Destroy(gameObject);
    }

    private void CreateFragments()
    {
        for (int i = 0; i < m_Data.fragmentCount; i++)
        {
            Vector2 fragmentPosition = transform.position;

            // Random direction for fragment
            float angle = (360f / m_Data.fragmentCount) * i + Random.Range(-15f, 15f);
            Vector2 direction = Quaternion.Euler(0, 0, angle) * Vector2.up;

            float speed = Random.Range(m_Data.fragmentData.minSpeed,
                                      m_Data.fragmentData.maxSpeed);
            Vector2 fragmentVelocity = direction * speed;

            AsteroidSpawner.Instance.SpawnAsteroid(
                m_Data.fragmentData,
                fragmentPosition,
                fragmentVelocity
            );
        }
    }

    private void HandleScreenWrap()
    {
        Vector3 pos = transform.position;

        if (pos.x > m_ScreenBounds.x)
            pos.x = -m_ScreenBounds.x;
        else if (pos.x < -m_ScreenBounds.x)
            pos.x = m_ScreenBounds.x;

        if (pos.y > m_ScreenBounds.y)
            pos.y = -m_ScreenBounds.y;
        else if (pos.y < -m_ScreenBounds.y)
            pos.y = m_ScreenBounds.y;

        transform.position = pos;
    }
    #endregion
}
