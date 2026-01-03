using UnityEngine;
using UnityEngine.InputSystem;

/// <summary>
/// Handles ship physics-based movement with inertia.
/// Uses Rigidbody2D for authentic space physics feel.
/// </summary>
[RequireComponent(typeof(Rigidbody2D))]
public class ShipMovement : MonoBehaviour
{
    #region Constants
    private const float c_RotationSpeed = 300f;      // Degrees per second
    private const float c_ThrustForce = 10f;         // Forward thrust force
    private const float c_MaxVelocity = 8f;          // Speed cap
    private const float c_Drag = 0.5f;               // Space friction
    #endregion

    #region Private Fields
    private Rigidbody2D m_Rigidbody;
    private Vector2 m_MoveInput;

    [Header("Tuning")]
    [SerializeField, Range(100f, 500f)] private float m_RotationSpeed = c_RotationSpeed;
    [SerializeField, Range(5f, 20f)] private float m_ThrustForce = c_ThrustForce;
    [SerializeField, Range(3f, 15f)] private float m_MaxVelocity = c_MaxVelocity;
    [SerializeField, Range(0f, 2f)] private float m_Drag = c_Drag;

    [Header("Screen Wrap")]
    [SerializeField] private Vector2 m_ScreenBounds = new Vector2(10f, 10f);

    [Header("Debug")]
    [SerializeField] private bool m_ShowVelocity = true;
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        m_Rigidbody = GetComponent<Rigidbody2D>();
        ConfigureRigidbody();
    }

    private void FixedUpdate()
    {
        HandleRotation();
        HandleThrust();
        ClampVelocity();
        HandleScreenWrap();
    }

    private void OnDrawGizmos()
    {
        if (m_ShowVelocity && Application.isPlaying && m_Rigidbody != null)
        {
            Gizmos.color = Color.cyan;
            Gizmos.DrawLine(transform.position,
                transform.position + (Vector3)m_Rigidbody.linearVelocity);
        }
    }
    #endregion

    #region Input Handlers
    public void OnMove(InputAction.CallbackContext context)
    {
        m_MoveInput = context.ReadValue<Vector2>();
    }
    #endregion

    #region Private Methods
    private void ConfigureRigidbody()
    {
        m_Rigidbody.gravityScale = 0f;
        m_Rigidbody.linearDamping = m_Drag;
        m_Rigidbody.angularDamping = 1f;
        m_Rigidbody.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
    }

    private void HandleRotation()
    {
        // A/D or Left/Right rotates the ship
        float rotationInput = -m_MoveInput.x; // Negative for intuitive controls
        float rotationAmount = rotationInput * m_RotationSpeed * Time.fixedDeltaTime;
        m_Rigidbody.MoveRotation(m_Rigidbody.rotation + rotationAmount);
    }

    private void HandleThrust()
    {
        // W/S or Up/Down for forward/backward thrust
        float thrustInput = m_MoveInput.y;

        if (Mathf.Abs(thrustInput) > 0.1f)
        {
            Vector2 thrustDirection = transform.up; // Ship's forward direction
            Vector2 force = thrustDirection * (thrustInput * m_ThrustForce);
            m_Rigidbody.AddForce(force);
        }
    }

    private void ClampVelocity()
    {
        if (m_Rigidbody.linearVelocity.magnitude > m_MaxVelocity)
        {
            m_Rigidbody.linearVelocity = m_Rigidbody.linearVelocity.normalized * m_MaxVelocity;
        }
    }

    private void HandleScreenWrap()
    {
        Vector3 pos = transform.position;

        // Wrap X axis
        if (pos.x > m_ScreenBounds.x)
            pos.x = -m_ScreenBounds.x;
        else if (pos.x < -m_ScreenBounds.x)
            pos.x = m_ScreenBounds.x;

        // Wrap Y axis
        if (pos.y > m_ScreenBounds.y)
            pos.y = -m_ScreenBounds.y;
        else if (pos.y < -m_ScreenBounds.y)
            pos.y = m_ScreenBounds.y;

        transform.position = pos;
    }
    #endregion
}
