using UnityEngine;

/// <summary>
/// Handles ship firing mechanics.
/// </summary>
public class ShipWeapon : MonoBehaviour
{
    #region Constants
    private const float c_FireRate = 4f;           // Shots per second
    private const float c_ProjectileSpeed = 15f;   // Units per second
    private const int c_Damage = 10;
    #endregion

    #region Private Fields
    [Header("Weapon Stats")]
    [SerializeField] private float m_FireRate = c_FireRate;
    [SerializeField] private float m_ProjectileSpeed = c_ProjectileSpeed;
    [SerializeField] private int m_Damage = c_Damage;

    [Header("Spawn Point")]
    [SerializeField] private Transform m_FirePoint;

    private float m_LastFireTime;
    private float m_FireCooldown => 1f / m_FireRate;
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        if (m_FirePoint == null)
        {
            // Create fire point slightly ahead of ship
            GameObject firePointObj = new GameObject("FirePoint");
            firePointObj.transform.SetParent(transform);
            firePointObj.transform.localPosition = new Vector3(0, 0.6f, 0);
            m_FirePoint = firePointObj.transform;
        }
    }
    #endregion

    #region Public Methods
    public void Fire()
    {
        if (Time.time - m_LastFireTime < m_FireCooldown)
            return;

        Projectile proj = ProjectilePool.Instance.GetProjectile();

        Vector2 firePosition = m_FirePoint.position;
        Vector2 fireDirection = m_FirePoint.up;

        proj.Launch(firePosition, fireDirection, m_ProjectileSpeed, m_Damage);

        m_LastFireTime = Time.time;

        // TODO: Play sound effect
    }
    #endregion
}
