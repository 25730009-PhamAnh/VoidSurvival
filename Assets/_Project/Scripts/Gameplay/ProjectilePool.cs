using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Object pool for projectiles to avoid instantiation overhead.
/// </summary>
public class ProjectilePool : MonoBehaviour
{
    #region Singleton
    public static ProjectilePool Instance { get; private set; }
    #endregion

    #region Private Fields
    [Header("Pooling")]
    [SerializeField] private GameObject m_ProjectilePrefab;
    [SerializeField] private int m_InitialPoolSize = 20;
    [SerializeField] private Transform m_PoolParent;

    private Queue<Projectile> m_AvailableProjectiles = new Queue<Projectile>();
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
            return;
        }

        InitializePool();
    }
    #endregion

    #region Public Methods
    public Projectile GetProjectile()
    {
        if (m_AvailableProjectiles.Count > 0)
        {
            return m_AvailableProjectiles.Dequeue();
        }
        else
        {
            // Pool exhausted, create new projectile
            return CreateProjectile();
        }
    }

    public void ReturnProjectile(Projectile projectile)
    {
        projectile.gameObject.SetActive(false);
        m_AvailableProjectiles.Enqueue(projectile);
    }
    #endregion

    #region Private Methods
    private void InitializePool()
    {
        if (m_PoolParent == null)
            m_PoolParent = GameManager.Instance.GetProjectilesParent();

        for (int i = 0; i < m_InitialPoolSize; i++)
        {
            Projectile proj = CreateProjectile();
            proj.gameObject.SetActive(false);
            m_AvailableProjectiles.Enqueue(proj);
        }

        Debug.Log($"Projectile pool initialized with {m_InitialPoolSize} projectiles");
    }

    private Projectile CreateProjectile()
    {
        GameObject obj = Instantiate(m_ProjectilePrefab, m_PoolParent);
        Projectile proj = obj.GetComponent<Projectile>();
        return proj;
    }
    #endregion
}
