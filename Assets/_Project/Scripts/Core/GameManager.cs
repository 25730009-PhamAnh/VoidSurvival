using UnityEngine;

/// <summary>
/// Simple game manager for Week 1 prototype.
/// Handles basic game state and initialization.
/// </summary>
public class GameManager : MonoBehaviour
{
    #region Singleton
    public static GameManager Instance { get; private set; }
    #endregion

    #region Private Fields
    [Header("References")]
    [SerializeField] private Transform m_HazardsParent;
    [SerializeField] private Transform m_ProjectilesParent;

    [Header("Debug")]
    [SerializeField] private bool m_ShowDebugInfo = true;
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

        InitializeGame();
    }

    private void OnGUI()
    {
        if (m_ShowDebugInfo)
        {
            GUI.Label(new Rect(10, 10, 200, 20), "Void Survivor - Week 1");
            GUI.Label(new Rect(10, 30, 200, 20), $"FPS: {(int)(1f / Time.deltaTime)}");
        }
    }
    #endregion

    #region Private Methods
    private void InitializeGame()
    {
        // Find or create parent objects
        if (m_HazardsParent == null)
        {
            GameObject hazardsObj = GameObject.Find("Hazards");
            if (hazardsObj != null)
                m_HazardsParent = hazardsObj.transform;
        }

        if (m_ProjectilesParent == null)
        {
            GameObject projectilesObj = GameObject.Find("Projectiles");
            if (projectilesObj != null)
                m_ProjectilesParent = projectilesObj.transform;
        }

        Debug.Log("GameManager initialized");
    }
    #endregion

    #region Public Methods
    public Transform GetHazardsParent() => m_HazardsParent;
    public Transform GetProjectilesParent() => m_ProjectilesParent;
    #endregion
}
