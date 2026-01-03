using UnityEngine;

/// <summary>
/// Tracks score for Week 1 prototype.
/// </summary>
public class ScoreManager : MonoBehaviour
{
    #region Singleton
    public static ScoreManager Instance { get; private set; }
    #endregion

    #region Private Fields
    private int m_CurrentScore;
    #endregion

    #region Properties
    public int CurrentScore => m_CurrentScore;
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
    }

    private void OnGUI()
    {
        // Simple debug score display
        GUI.Label(new Rect(10, 50, 200, 20), $"Score: {m_CurrentScore}");
    }
    #endregion

    #region Public Methods
    public void AddScore(int points)
    {
        m_CurrentScore += points;
        Debug.Log($"Score: {m_CurrentScore} (+{points})");
    }

    public void ResetScore()
    {
        m_CurrentScore = 0;
    }
    #endregion
}
