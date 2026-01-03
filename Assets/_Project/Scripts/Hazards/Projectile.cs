using UnityEngine;

/// <summary>
/// Simple projectile with lifetime and pooling support.
/// </summary>
[RequireComponent(typeof(Rigidbody2D))]
public class Projectile : MonoBehaviour
{
    #region Private Fields
    private Rigidbody2D m_Rigidbody;
    private float m_Lifetime = 2f;
    private float m_SpawnTime;
    private int m_Damage = 10;

    [Header("Visual")]
    [SerializeField] private LineRenderer m_LineRenderer;
    [SerializeField] private float m_LineLength = 0.3f;
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        m_Rigidbody = GetComponent<Rigidbody2D>();
        m_Rigidbody.gravityScale = 0f;

        if (m_LineRenderer == null)
            m_LineRenderer = GetComponent<LineRenderer>();
    }

    private void Update()
    {
        // Despawn after lifetime
        if (Time.time - m_SpawnTime > m_Lifetime)
        {
            ReturnToPool();
        }

        // Update line renderer to show trail
        UpdateLineRenderer();
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        // Check if hit an asteroid
        Asteroid asteroid = collision.GetComponent<Asteroid>();
        if (asteroid != null)
        {
            asteroid.TakeDamage(m_Damage);
            ReturnToPool();
        }
    }
    #endregion

    #region Public Methods
    public void Launch(Vector2 position, Vector2 direction, float speed, int damage)
    {
        transform.position = position;
        m_Rigidbody.linearVelocity = direction.normalized * speed;
        m_Damage = damage;
        m_SpawnTime = Time.time;
        gameObject.SetActive(true);
    }

    public void ReturnToPool()
    {
        gameObject.SetActive(false);
        ProjectilePool.Instance.ReturnProjectile(this);
    }
    #endregion

    #region Private Methods
    private void UpdateLineRenderer()
    {
        if (m_LineRenderer != null)
        {
            Vector3 start = transform.position;
            Vector3 end = start - (Vector3)m_Rigidbody.linearVelocity.normalized * m_LineLength;

            m_LineRenderer.SetPosition(0, start);
            m_LineRenderer.SetPosition(1, end);
        }
    }
    #endregion
}
