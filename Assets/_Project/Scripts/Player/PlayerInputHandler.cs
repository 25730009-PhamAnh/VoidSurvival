using UnityEngine;
using UnityEngine.InputSystem;

/// <summary>
/// Routes input from Input System to ship components.
/// Central input handler for the player ship.
/// </summary>
public class PlayerInputHandler : MonoBehaviour
{
    #region Private Fields
    private ShipMovement m_Movement;
    private ShipWeapon m_Weapon;

    private PlayerInput m_PlayerInput;
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        m_Movement = GetComponent<ShipMovement>();
        m_Weapon = GetComponent<ShipWeapon>();

        m_PlayerInput = GetComponent<PlayerInput>();
    }
    #endregion

    #region Input Callbacks
    public void OnMove(InputAction.CallbackContext context)
    {
        if (m_Movement != null)
            m_Movement.OnMove(context);
    }

    public void OnAttack(InputAction.CallbackContext context)
    {
        // Fire when button pressed
        if (context.performed && m_Weapon != null)
        {
            m_Weapon.Fire();
        }
    }
    #endregion
}
