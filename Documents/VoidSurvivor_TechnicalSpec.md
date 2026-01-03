# Technical Specification Document: Void Survivor
**Version:** 1.0  
**Date:** January 3, 2026  
**Engine:** Unity 6.3 LTS  
**Platform:** Mobile (iOS/Android), with PC support

---

## 1. Architecture Overview

### 1.1 Design Philosophy

The game follows a **data-driven, modular architecture** using Unity best practices:

- **Scriptable Objects**: All game content (items, enemies, upgrades) defined as data assets
- **Component-Based Design**: Entity behaviors built from reusable components
- **SOLID Principles**: Single responsibility, dependency injection, interface-based design
- **Event-Driven System**: Loosely coupled systems communicating via events/messages
- **No Hard-Coded Values**: All parameters exposed in data files for easy balancing

### 1.2 Core Architecture Pattern

```
MVC + ECS Hybrid Architecture:
- Model: ScriptableObjects (data)
- View: MonoBehaviours (presentation)
- Controller: Manager classes (logic)
- ECS: Entity components for gameplay objects
```

### 1.3 Project Structure

```
Assets/
├── _Project/
│   ├── ScriptableObjects/
│   │   ├── Items/
│   │   │   ├── Defensive/
│   │   │   ├── Offensive/
│   │   │   └── Utility/
│   │   ├── Enemies/
│   │   ├── Pickups/
│   │   ├── GameSettings/
│   │   └── DifficultyConfigs/
│   ├── Scripts/
│   │   ├── Core/
│   │   │   ├── Managers/
│   │   │   ├── Systems/
│   │   │   └── Interfaces/
│   │   ├── Entities/
│   │   │   ├── Ship/
│   │   │   ├── Enemies/
│   │   │   └── Hazards/
│   │   ├── Gameplay/
│   │   │   ├── Combat/
│   │   │   ├── Movement/
│   │   │   └── Spawning/
│   │   ├── Progression/
│   │   │   ├── UpgradeSystem/
│   │   │   ├── ItemSystem/
│   │   │   └── DifficultySystem/
│   │   ├── UI/
│   │   └── Utilities/
│   ├── Prefabs/
│   ├── Scenes/
│   ├── Materials/
│   ├── Audio/
│   └── Settings/
├── Plugins/
└── Resources/
```

---

## 2. Core Systems Architecture

### 2.1 Game Manager System

**Purpose**: Central orchestrator for game state and system initialization.

```csharp
// Core/Managers/GameManager.cs
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    [Header("System References")]
    [SerializeField] private GameSettings gameSettings;
    
    // System managers
    private ProgressionManager progressionManager;
    private DifficultyManager difficultyManager;
    private SpawnManager spawnManager;
    private UIManager uiManager;
    private SaveManager saveManager;
    
    public GameState CurrentState { get; private set; }
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            InitializeSystems();
        }
        else
        {
            Destroy(gameObject);
        }
    }
    
    private void InitializeSystems()
    {
        progressionManager = GetComponent<ProgressionManager>();
        difficultyManager = GetComponent<DifficultyManager>();
        spawnManager = GetComponent<SpawnManager>();
        uiManager = GetComponent<UIManager>();
        saveManager = GetComponent<SaveManager>();
        
        // Initialize all systems
        progressionManager.Initialize();
        difficultyManager.Initialize();
        saveManager.LoadPlayerData();
    }
    
    public void StartGame()
    {
        CurrentState = GameState.Playing;
        EventBus.Publish(new GameStartedEvent());
        spawnManager.StartSpawning();
        difficultyManager.ResetDifficulty();
    }
    
    public void EndGame()
    {
        CurrentState = GameState.GameOver;
        EventBus.Publish(new GameEndedEvent());
        spawnManager.StopSpawning();
        progressionManager.ProcessRunRewards();
    }
}

public enum GameState
{
    MainMenu,
    Playing,
    Paused,
    GameOver,
    Upgrading
}
```

### 2.2 Event Bus System

**Purpose**: Decoupled communication between systems.

```csharp
// Core/Systems/EventBus.cs
public static class EventBus
{
    private static Dictionary<Type, List<Delegate>> eventHandlers = new();
    
    public static void Subscribe<T>(Action<T> handler) where T : IGameEvent
    {
        Type eventType = typeof(T);
        if (!eventHandlers.ContainsKey(eventType))
        {
            eventHandlers[eventType] = new List<Delegate>();
        }
        eventHandlers[eventType].Add(handler);
    }
    
    public static void Unsubscribe<T>(Action<T> handler) where T : IGameEvent
    {
        Type eventType = typeof(T);
        if (eventHandlers.ContainsKey(eventType))
        {
            eventHandlers[eventType].Remove(handler);
        }
    }
    
    public static void Publish<T>(T eventData) where T : IGameEvent
    {
        Type eventType = typeof(T);
        if (eventHandlers.ContainsKey(eventType))
        {
            foreach (var handler in eventHandlers[eventType].ToList())
            {
                ((Action<T>)handler)?.Invoke(eventData);
            }
        }
    }
}

// Core/Interfaces/IGameEvent.cs
public interface IGameEvent { }

// Example Events
public struct GameStartedEvent : IGameEvent { }
public struct GameEndedEvent : IGameEvent { }
public struct PlayerDamagedEvent : IGameEvent 
{ 
    public float Damage;
    public float ShieldRemaining;
}
public struct EnemyDestroyedEvent : IGameEvent 
{ 
    public EnemyType Type;
    public int CreditsAwarded;
}
```

---

## 3. Infinite Progression System

### 3.1 Parameter System Architecture

**Purpose**: Data-driven stat calculation with infinite scaling.

```csharp
// ScriptableObjects/GameSettings/ParameterDefinition.cs
[CreateAssetMenu(fileName = "ParameterDefinition", menuName = "Game/Parameter Definition")]
public class ParameterDefinition : ScriptableObject
{
    [Header("Identification")]
    public string parameterId;
    public string displayName;
    public string description;
    
    [Header("Base Values")]
    public float baseValue;
    
    [Header("Scaling")]
    public ScalingType scalingType;
    public float linearScaling;    // Added per level
    public float multiplierScaling; // Multiplied per level
    
    [Header("Limits")]
    public bool hasMinValue;
    public float minValue;
    public bool hasMaxValue;
    public float maxValue;
    
    public float CalculateValue(int level)
    {
        float value = scalingType switch
        {
            ScalingType.Linear => baseValue + (level * linearScaling),
            ScalingType.Multiplicative => baseValue * (1f + level * multiplierScaling),
            ScalingType.Exponential => baseValue * Mathf.Pow(1f + multiplierScaling, level),
            ScalingType.Diminishing => baseValue + (linearScaling * level) / (1f + level * 0.01f),
            _ => baseValue
        };
        
        if (hasMinValue) value = Mathf.Max(value, minValue);
        if (hasMaxValue) value = Mathf.Min(value, maxValue);
        
        return value;
    }
}

public enum ScalingType
{
    Linear,          // base + (level × linear)
    Multiplicative,  // base × (1 + level × mult)
    Exponential,     // base × (1 + mult)^level
    Diminishing      // base + (linear × level) / (1 + level × 0.01)
}
```

### 3.2 Ship Stats System

```csharp
// Progression/ShipStats.cs
[System.Serializable]
public class ShipStats
{
    [Header("Stat Points")]
    public int defensivePoints;
    public int mobilityPoints;
    public int offensivePoints;
    public int utilityPoints;
    
    [Header("Parameter References")]
    [SerializeField] private ParameterDefinition maxShield;
    [SerializeField] private ParameterDefinition shieldRegen;
    [SerializeField] private ParameterDefinition moveSpeed;
    [SerializeField] private ParameterDefinition fireRate;
    [SerializeField] private ParameterDefinition damage;
    // ... other parameters
    
    private Dictionary<string, float> calculatedStats = new();
    
    public void RecalculateStats()
    {
        calculatedStats["MaxShield"] = maxShield.CalculateValue(defensivePoints);
        calculatedStats["ShieldRegen"] = shieldRegen.CalculateValue(defensivePoints);
        calculatedStats["MoveSpeed"] = moveSpeed.CalculateValue(mobilityPoints);
        calculatedStats["FireRate"] = fireRate.CalculateValue(offensivePoints);
        calculatedStats["Damage"] = damage.CalculateValue(offensivePoints);
        // ... calculate all stats
    }
    
    public float GetStat(string statName)
    {
        return calculatedStats.ContainsKey(statName) ? calculatedStats[statName] : 0f;
    }
    
    public int GetTotalPoints()
    {
        return defensivePoints + mobilityPoints + offensivePoints + utilityPoints;
    }
    
    public int CalculatePointCost(int nextPointNumber)
    {
        // Point Cost = 100 × (1.15 ^ Total_Points_Purchased)
        return Mathf.RoundToInt(100f * Mathf.Pow(1.15f, nextPointNumber));
    }
}
```

### 3.3 Item System (ScriptableObject-Based)

**Purpose**: Modular, data-driven items with zero code changes for new items.

```csharp
// ScriptableObjects/Items/ItemDefinition.cs
[CreateAssetMenu(fileName = "New Item", menuName = "Game/Items/Item Definition")]
public class ItemDefinition : ScriptableObject
{
    [Header("Identity")]
    public string itemId;
    public string displayName;
    [TextArea(3, 5)]
    public string description;
    public Sprite icon;
    
    [Header("Category")]
    public ItemCategory category;
    public ItemRarity rarity;
    
    [Header("Effects")]
    public List<ItemEffect> effects;
    
    [Header("Cost Scaling")]
    public int baseCost = 100;
    public float costMultiplier = 1.12f;
    
    [Header("Level Info")]
    [TextArea(2, 4)]
    public string levelUpDescription;
    
    public int CalculateCost(int currentLevel)
    {
        // Cost = baseCost × (costMultiplier ^ Level)
        return Mathf.RoundToInt(baseCost * Mathf.Pow(costMultiplier, currentLevel));
    }
    
    public string GetEffectDescription(int level)
    {
        StringBuilder sb = new StringBuilder();
        foreach (var effect in effects)
        {
            float value = effect.CalculateValue(level);
            sb.AppendLine($"{effect.effectType}: {value}{effect.displaySuffix}");
        }
        return sb.ToString();
    }
}

[System.Serializable]
public class ItemEffect
{
    public EffectType effectType;
    public string targetParameter; // References ParameterDefinition
    
    [Header("Scaling")]
    public float baseEffect;
    public float perLevelIncrease;
    public EffectScalingType scalingType;
    
    public string displaySuffix = "%";
    
    public float CalculateValue(int level)
    {
        return scalingType switch
        {
            EffectScalingType.Flat => baseEffect + (level * perLevelIncrease),
            EffectScalingType.Percentage => baseEffect + (level * perLevelIncrease),
            EffectScalingType.Exponential => baseEffect * Mathf.Pow(1f + perLevelIncrease, level),
            _ => baseEffect
        };
    }
}

public enum ItemCategory
{
    Defensive,
    Offensive,
    Utility
}

public enum ItemRarity
{
    Common,
    Rare,
    Epic,
    Legendary
}

public enum EffectType
{
    MaxShieldBonus,
    ShieldRegenBonus,
    DamageBonus,
    FireRateBonus,
    MoveSpeedBonus,
    CollectionRadiusBonus,
    CreditMultiplier,
    DamageReduction,
    // Add more as needed
}

public enum EffectScalingType
{
    Flat,
    Percentage,
    Exponential
}
```

### 3.4 Equipped Items Manager

```csharp
// Progression/EquippedItemsManager.cs
public class EquippedItemsManager : MonoBehaviour
{
    [System.Serializable]
    public class EquippedItem
    {
        public ItemDefinition definition;
        public int currentLevel;
        
        public EquippedItem(ItemDefinition def, int level = 1)
        {
            definition = def;
            currentLevel = level;
        }
    }
    
    [Header("Slot Configuration")]
    [SerializeField] private int maxSlots = 8;
    private int unlockedSlots = 4;
    
    private List<EquippedItem> equippedItems = new();
    private Dictionary<EffectType, float> aggregatedEffects = new();
    
    public bool CanEquipItem()
    {
        return equippedItems.Count < unlockedSlots;
    }
    
    public void EquipItem(ItemDefinition item)
    {
        if (!CanEquipItem()) return;
        
        equippedItems.Add(new EquippedItem(item, 1));
        RecalculateEffects();
        EventBus.Publish(new ItemEquippedEvent { Item = item });
    }
    
    public void UnequipItem(ItemDefinition item)
    {
        equippedItems.RemoveAll(e => e.definition == item);
        RecalculateEffects();
    }
    
    public void UpgradeItem(ItemDefinition item)
    {
        var equipped = equippedItems.FirstOrDefault(e => e.definition == item);
        if (equipped != null)
        {
            equipped.currentLevel++;
            RecalculateEffects();
        }
    }
    
    private void RecalculateEffects()
    {
        aggregatedEffects.Clear();
        
        foreach (var equipped in equippedItems)
        {
            foreach (var effect in equipped.definition.effects)
            {
                float value = effect.CalculateValue(equipped.currentLevel);
                
                if (!aggregatedEffects.ContainsKey(effect.effectType))
                {
                    aggregatedEffects[effect.effectType] = 0f;
                }
                
                aggregatedEffects[effect.effectType] += value;
            }
        }
        
        EventBus.Publish(new ItemEffectsRecalculatedEvent());
    }
    
    public float GetTotalEffect(EffectType type)
    {
        return aggregatedEffects.ContainsKey(type) ? aggregatedEffects[type] : 0f;
    }
    
    public List<EquippedItem> GetEquippedItems() => equippedItems;
    
    public void UnlockSlot()
    {
        if (unlockedSlots < maxSlots)
        {
            unlockedSlots++;
        }
    }
}
```

### 3.5 Progression Manager

```csharp
// Progression/ProgressionManager.cs
public class ProgressionManager : MonoBehaviour
{
    [Header("Player Data")]
    [SerializeField] private ShipStats shipStats;
    
    private EquippedItemsManager itemsManager;
    private int voidCredits;
    private int currentRunCredits;
    
    // Run statistics
    private float survivalTime;
    private int asteroidsDestroyed;
    private int enemiesDestroyed;
    private int crystalsCollected;
    
    public void Initialize()
    {
        itemsManager = GetComponent<EquippedItemsManager>();
        LoadPlayerProgression();
    }
    
    public bool CanAffordUpgradePoint()
    {
        int totalPoints = shipStats.GetTotalPoints();
        int cost = shipStats.CalculatePointCost(totalPoints + 1);
        return voidCredits >= cost;
    }
    
    public void PurchaseUpgradePoint(StatCategory category)
    {
        int totalPoints = shipStats.GetTotalPoints();
        int cost = shipStats.CalculatePointCost(totalPoints + 1);
        
        if (voidCredits >= cost)
        {
            voidCredits -= cost;
            
            switch (category)
            {
                case StatCategory.Defensive:
                    shipStats.defensivePoints++;
                    break;
                case StatCategory.Mobility:
                    shipStats.mobilityPoints++;
                    break;
                case StatCategory.Offensive:
                    shipStats.offensivePoints++;
                    break;
                case StatCategory.Utility:
                    shipStats.utilityPoints++;
                    break;
            }
            
            shipStats.RecalculateStats();
            EventBus.Publish(new StatPointPurchasedEvent { Category = category });
        }
    }
    
    public void ProcessRunRewards()
    {
        // Calculate credits earned
        currentRunCredits = CalculateRunCredits();
        voidCredits += currentRunCredits;
        
        EventBus.Publish(new RunCompletedEvent 
        { 
            CreditsEarned = currentRunCredits,
            SurvivalTime = survivalTime,
            TotalCredits = voidCredits
        });
        
        SavePlayerProgression();
    }
    
    private int CalculateRunCredits()
    {
        // Base: 1 credit per second survived
        int credits = Mathf.RoundToInt(survivalTime);
        
        // Bonuses
        credits += asteroidsDestroyed * 2;
        credits += enemiesDestroyed * 5;
        credits += crystalsCollected;
        
        // Apply luck multiplier from items
        float luckMultiplier = 1f + itemsManager.GetTotalEffect(EffectType.CreditMultiplier) / 100f;
        credits = Mathf.RoundToInt(credits * luckMultiplier);
        
        return credits;
    }
    
    public void RecordAsteroidDestroyed() => asteroidsDestroyed++;
    public void RecordEnemyDestroyed() => enemiesDestroyed++;
    public void RecordCrystalCollected() => crystalsCollected++;
    
    private void LoadPlayerProgression()
    {
        // Load from SaveManager
    }
    
    private void SavePlayerProgression()
    {
        // Save via SaveManager
    }
}

public enum StatCategory
{
    Defensive,
    Mobility,
    Offensive,
    Utility
}
```

---

## 4. Difficulty Scaling System

### 4.1 Difficulty Manager

```csharp
// Progression/DifficultySystem/DifficultyManager.cs
public class DifficultyManager : MonoBehaviour
{
    [Header("Configuration")]
    [SerializeField] private DifficultyConfig config;
    
    private float currentDifficultyLevel;
    private float survivalTime;
    private int playerPowerRating;
    
    // Dynamic difficulty metrics
    private float recentDamageRate;
    private float recentAccuracy;
    private float shieldPercentage;
    
    public float CurrentDifficulty => currentDifficultyLevel;
    
    public void Initialize()
    {
        currentDifficultyLevel = config.baseDifficulty;
        EventBus.Subscribe<PlayerDamagedEvent>(OnPlayerDamaged);
        EventBus.Subscribe<EnemyDestroyedEvent>(OnEnemyDestroyed);
    }
    
    private void Update()
    {
        if (GameManager.Instance.CurrentState == GameState.Playing)
        {
            survivalTime += Time.deltaTime;
            UpdateDifficulty();
        }
    }
    
    private void UpdateDifficulty()
    {
        // Calculate difficulty based on GDD formula
        float timeFactor = survivalTime / 60f * config.timeScaling; // minutes to difficulty
        float performanceFactor = CalculatePerformanceFactor();
        
        float targetDifficulty = config.baseDifficulty + timeFactor + performanceFactor;
        
        // Apply dynamic difficulty adjustments
        if (shieldPercentage < 0.3f) // Player struggling
        {
            targetDifficulty -= config.dynamicScalingDown;
        }
        else if (shieldPercentage > 0.7f && recentAccuracy > 0.6f) // Player dominating
        {
            targetDifficulty += config.dynamicScalingUp;
        }
        
        // Smooth transition
        currentDifficultyLevel = Mathf.Lerp(
            currentDifficultyLevel, 
            targetDifficulty, 
            Time.deltaTime * config.transitionSpeed
        );
        
        // Clamp to valid range
        currentDifficultyLevel = Mathf.Clamp(
            currentDifficultyLevel, 
            config.minDifficulty, 
            config.maxDifficulty
        );
    }
    
    private float CalculatePerformanceFactor()
    {
        playerPowerRating = CalculatePlayerPower();
        return (playerPowerRating / 100f) * config.powerScaling;
    }
    
    private int CalculatePlayerPower()
    {
        // Get power from progression manager
        var progression = GameManager.Instance.GetComponent<ProgressionManager>();
        // Implementation depends on how you track total points and item power
        return 50; // Placeholder
    }
    
    public EnemyScalingData GetEnemyScaling(EnemyType type)
    {
        return config.GetScalingForType(type, currentDifficultyLevel);
    }
    
    private void OnPlayerDamaged(PlayerDamagedEvent evt)
    {
        shieldPercentage = evt.ShieldRemaining;
    }
    
    private void OnEnemyDestroyed(EnemyDestroyedEvent evt)
    {
        // Track accuracy and performance
    }
    
    public void ResetDifficulty()
    {
        currentDifficultyLevel = config.baseDifficulty;
        survivalTime = 0f;
    }
}
```

### 4.2 Difficulty Configuration (ScriptableObject)

```csharp
// ScriptableObjects/DifficultyConfigs/DifficultyConfig.cs
[CreateAssetMenu(fileName = "DifficultyConfig", menuName = "Game/Difficulty Config")]
public class DifficultyConfig : ScriptableObject
{
    [Header("Base Settings")]
    public float baseDifficulty = 10f;
    public float minDifficulty = 5f;
    public float maxDifficulty = 200f;
    
    [Header("Scaling Factors")]
    [Tooltip("Difficulty added per minute survived")]
    public float timeScaling = 0.5f;
    
    [Tooltip("Multiplier for player power rating")]
    public float powerScaling = 10f;
    
    [Header("Dynamic Adjustments")]
    public float dynamicScalingUp = 5f;
    public float dynamicScalingDown = 10f;
    public float transitionSpeed = 0.1f;
    
    [Header("Enemy Scaling Curves")]
    public List<EnemyScalingCurve> enemyScalings;
    
    public EnemyScalingData GetScalingForType(EnemyType type, float difficulty)
    {
        var curve = enemyScalings.FirstOrDefault(c => c.enemyType == type);
        if (curve == null) return default;
        
        return new EnemyScalingData
        {
            Health = curve.baseHealth * (1f + difficulty * curve.healthScaling),
            Speed = curve.baseSpeed * (1f + difficulty * curve.speedScaling),
            Damage = curve.baseDamage * (1f + difficulty * curve.damageScaling),
            SpawnRate = curve.baseSpawnRate / Mathf.Max(1f, 1f + difficulty * curve.spawnRateScaling)
        };
    }
}

[System.Serializable]
public class EnemyScalingCurve
{
    public EnemyType enemyType;
    
    [Header("Base Stats")]
    public float baseHealth = 100f;
    public float baseSpeed = 3f;
    public float baseDamage = 20f;
    public float baseSpawnRate = 30f; // seconds between spawns
    
    [Header("Scaling Multipliers")]
    public float healthScaling = 0.15f;
    public float speedScaling = 0.06f;
    public float damageScaling = 0.12f;
    public float spawnRateScaling = 0.01f;
}

public struct EnemyScalingData
{
    public float Health;
    public float Speed;
    public float Damage;
    public float SpawnRate;
}

public enum EnemyType
{
    Asteroid,
    UFO,
    Comet,
    BlackHole
}
```

---

## 5. Entity System

### 5.1 Player Ship

```csharp
// Entities/Ship/PlayerShip.cs
public class PlayerShip : MonoBehaviour
{
    [Header("Components")]
    private Rigidbody2D rb;
    private ShipShield shield;
    private ShipWeapon weapon;
    private ShipMovement movement;
    
    [Header("Stats Reference")]
    [SerializeField] private ShipStats baseStats;
    
    private EquippedItemsManager itemsManager;
    private Dictionary<string, float> finalStats = new();
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        shield = GetComponent<ShipShield>();
        weapon = GetComponent<ShipWeapon>();
        movement = GetComponent<ShipMovement>();
        
        itemsManager = GameManager.Instance.GetComponent<EquippedItemsManager>();
    }
    
    private void Start()
    {
        RecalculateAllStats();
        InitializeComponents();
        
        EventBus.Subscribe<ItemEffectsRecalculatedEvent>(OnItemEffectsChanged);
    }
    
    private void RecalculateAllStats()
    {
        baseStats.RecalculateStats();
        
        // Apply item bonuses
        finalStats["MaxShield"] = ApplyItemBonus(
            baseStats.GetStat("MaxShield"), 
            EffectType.MaxShieldBonus
        );
        
        finalStats["ShieldRegen"] = ApplyItemBonus(
            baseStats.GetStat("ShieldRegen"), 
            EffectType.ShieldRegenBonus
        );
        
        finalStats["MoveSpeed"] = ApplyItemBonus(
            baseStats.GetStat("MoveSpeed"), 
            EffectType.MoveSpeedBonus
        );
        
        finalStats["Damage"] = ApplyItemBonus(
            baseStats.GetStat("Damage"), 
            EffectType.DamageBonus
        );
        
        finalStats["FireRate"] = ApplyItemBonus(
            baseStats.GetStat("FireRate"), 
            EffectType.FireRateBonus
        );
        
        // Apply to components
        shield.SetMaxShield(finalStats["MaxShield"]);
        shield.SetRegenRate(finalStats["ShieldRegen"]);
        movement.SetMoveSpeed(finalStats["MoveSpeed"]);
        weapon.SetDamage(finalStats["Damage"]);
        weapon.SetFireRate(finalStats["FireRate"]);
    }
    
    private float ApplyItemBonus(float baseValue, EffectType effectType)
    {
        float bonusPercent = itemsManager.GetTotalEffect(effectType);
        return baseValue * (1f + bonusPercent / 100f);
    }
    
    private void InitializeComponents()
    {
        shield.Initialize(finalStats["MaxShield"]);
    }
    
    private void OnItemEffectsChanged(ItemEffectsRecalculatedEvent evt)
    {
        RecalculateAllStats();
    }
    
    public void TakeDamage(float damage)
    {
        // Apply damage reduction from items
        float reduction = itemsManager.GetTotalEffect(EffectType.DamageReduction);
        float actualDamage = damage * (1f - reduction / 100f);
        
        shield.TakeDamage(actualDamage);
    }
    
    private void OnDestroy()
    {
        EventBus.Unsubscribe<ItemEffectsRecalculatedEvent>(OnItemEffectsChanged);
    }
}
```

### 5.2 Enemy System

```csharp
// ScriptableObjects/Enemies/EnemyDefinition.cs
[CreateAssetMenu(fileName = "New Enemy", menuName = "Game/Enemies/Enemy Definition")]
public class EnemyDefinition : ScriptableObject
{
    [Header("Identity")]
    public string enemyId;
    public string displayName;
    public EnemyType enemyType;
    
    [Header("Visuals")]
    public GameObject prefab;
    public Color color = Color.red;
    
    [Header("Base Stats")]
    public float baseHealth = 100f;
    public float baseSpeed = 3f;
    public float baseDamage = 20f;
    
    [Header("Behavior")]
    public EnemyBehaviorType behaviorType;
    public float detectionRange = 10f;
    public float attackRange = 5f;
    
    [Header("Rewards")]
    public int creditReward = 5;
    public float crystalDropChance = 0.3f;
    public int crystalDropAmount = 1;
    
    [Header("Difficulty Scaling")]
    public float healthScaling = 0.15f;
    public float speedScaling = 0.06f;
    public float damageScaling = 0.12f;
    
    public EnemyStats CalculateScaledStats(float difficultyLevel)
    {
        return new EnemyStats
        {
            Health = baseHealth * (1f + difficultyLevel * healthScaling),
            Speed = baseSpeed * (1f + difficultyLevel * speedScaling),
            Damage = baseDamage * (1f + difficultyLevel * damageScaling)
        };
    }
}

public struct EnemyStats
{
    public float Health;
    public float Speed;
    public float Damage;
}

public enum EnemyBehaviorType
{
    Passive,      // Like asteroids
    Aggressive,   // Chase player
    Shooter,      // Keep distance and shoot
    Charger      // Periodic charges
}
```

```csharp
// Entities/Enemies/Enemy.cs
public class Enemy : MonoBehaviour, IDamageable
{
    [Header("Configuration")]
    [SerializeField] private EnemyDefinition definition;
    
    private float currentHealth;
    private float maxHealth;
    private float moveSpeed;
    private float damage;
    
    private Transform player;
    private Rigidbody2D rb;
    
    public void Initialize(EnemyDefinition def, float difficultyLevel)
    {
        definition = def;
        
        var stats = definition.CalculateScaledStats(difficultyLevel);
        maxHealth = stats.Health;
        currentHealth = maxHealth;
        moveSpeed = stats.Speed;
        damage = stats.Damage;
        
        rb = GetComponent<Rigidbody2D>();
        player = GameObject.FindGameObjectWithTag("Player").transform;
        
        // Apply behavior component based on type
        ApplyBehavior();
    }
    
    private void ApplyBehavior()
    {
        switch (definition.behaviorType)
        {
            case EnemyBehaviorType.Aggressive:
                gameObject.AddComponent<AggressiveBehavior>();
                break;
            case EnemyBehaviorType.Shooter:
                gameObject.AddComponent<ShooterBehavior>();
                break;
            case EnemyBehaviorType.Charger:
                gameObject.AddComponent<ChargerBehavior>();
                break;
        }
    }
    
    public void TakeDamage(float damageAmount)
    {
        currentHealth -= damageAmount;
        
        if (currentHealth <= 0)
        {
            Die();
        }
    }
    
    private void Die()
    {
        // Drop rewards
        if (Random.value < definition.crystalDropChance)
        {
            SpawnCrystals();
        }
        
        EventBus.Publish(new EnemyDestroyedEvent 
        { 
            Type = definition.enemyType,
            CreditsAwarded = definition.creditReward
        });
        
        Destroy(gameObject);
    }
    
    private void SpawnCrystals()
    {
        // Spawn crystal pickups
    }
    
    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            var player = collision.gameObject.GetComponent<PlayerShip>();
            player?.TakeDamage(damage);
        }
    }
}

public interface IDamageable
{
    void TakeDamage(float damage);
}
```

---

## 6. Spawn System

### 6.1 Spawn Manager

```csharp
// Gameplay/Spawning/SpawnManager.cs
public class SpawnManager : MonoBehaviour
{
    [Header("Spawn Configuration")]
    [SerializeField] private List<SpawnableDefinition> spawnables;
    [SerializeField] private float spawnRadius = 15f;
    
    [Header("Bounds")]
    [SerializeField] private Vector2 spawnAreaMin;
    [SerializeField] private Vector2 spawnAreaMax;
    
    private DifficultyManager difficultyManager;
    private Dictionary<EnemyType, float> spawnTimers = new();
    private bool isSpawning;
    
    public void Initialize()
    {
        difficultyManager = GetComponent<DifficultyManager>();
    }
    
    public void StartSpawning()
    {
        isSpawning = true;
        InitializeTimers();
    }
    
    public void StopSpawning()
    {
        isSpawning = false;
    }
    
    private void InitializeTimers()
    {
        foreach (var spawnable in spawnables)
        {
            spawnTimers[spawnable.enemyType] = spawnable.GetSpawnInterval(0);
        }
    }
    
    private void Update()
    {
        if (!isSpawning) return;
        
        float difficulty = difficultyManager.CurrentDifficulty;
        
        foreach (var spawnable in spawnables)
        {
            if (!spawnTimers.ContainsKey(spawnable.enemyType))
                spawnTimers[spawnable.enemyType] = 0;
            
            spawnTimers[spawnable.enemyType] -= Time.deltaTime;
            
            if (spawnTimers[spawnable.enemyType] <= 0)
            {
                SpawnEnemy(spawnable, difficulty);
                spawnTimers[spawnable.enemyType] = spawnable.GetSpawnInterval(difficulty);
            }
        }
    }
    
    private void SpawnEnemy(SpawnableDefinition spawnable, float difficulty)
    {
        Vector2 spawnPos = GetRandomSpawnPosition();
        GameObject enemyObj = Instantiate(spawnable.enemyDefinition.prefab, spawnPos, Quaternion.identity);
        
        var enemy = enemyObj.GetComponent<Enemy>();
        enemy?.Initialize(spawnable.enemyDefinition, difficulty);
    }
    
    private Vector2 GetRandomSpawnPosition()
    {
        // Spawn outside player view
        Vector2 playerPos = Camera.main.transform.position;
        Vector2 direction = Random.insideUnitCircle.normalized;
        return playerPos + direction * spawnRadius;
    }
}

[System.Serializable]
public class SpawnableDefinition
{
    public EnemyType enemyType;
    public EnemyDefinition enemyDefinition;
    
    [Header("Spawn Rate")]
    public float baseSpawnInterval = 5f;
    public float minSpawnInterval = 1f;
    public float spawnIntervalScaling = 0.01f;
    
    public float GetSpawnInterval(float difficulty)
    {
        float interval = baseSpawnInterval / (1f + difficulty * spawnIntervalScaling);
        return Mathf.Max(interval, minSpawnInterval);
    }
}
```

---

## 7. Save System

### 7.1 Save Data Structure

```csharp
// Core/Systems/SaveSystem/PlayerData.cs
[System.Serializable]
public class PlayerData
{
    public int voidCredits;
    public int prestigePoints;
    
    // Ship stats
    public int defensivePoints;
    public int mobilityPoints;
    public int offensivePoints;
    public int utilityPoints;
    
    // Equipped items
    public List<EquippedItemData> equippedItems;
    public int unlockedSlots;
    
    // Statistics
    public int totalRunsCompleted;
    public float totalSurvivalTime;
    public float longestSurvival;
    public int totalEnemiesKilled;
    public float highestDifficulty;
    
    // Achievements
    public List<string> unlockedAchievements;
    
    // Settings
    public float masterVolume;
    public float sfxVolume;
    public float musicVolume;
}

[System.Serializable]
public class EquippedItemData
{
    public string itemId;
    public int level;
}
```

### 7.2 Save Manager

```csharp
// Core/Systems/SaveSystem/SaveManager.cs
public class SaveManager : MonoBehaviour
{
    private const string SAVE_KEY = "PlayerSaveData";
    
    public PlayerData LoadPlayerData()
    {
        string json = PlayerPrefs.GetString(SAVE_KEY, "");
        
        if (string.IsNullOrEmpty(json))
        {
            return CreateNewPlayerData();
        }
        
        return JsonUtility.FromJson<PlayerData>(json);
    }
    
    public void SavePlayerData(PlayerData data)
    {
        string json = JsonUtility.ToJson(data, true);
        PlayerPrefs.SetString(SAVE_KEY, json);
        PlayerPrefs.Save();
    }
    
    private PlayerData CreateNewPlayerData()
    {
        return new PlayerData
        {
            voidCredits = 0,
            prestigePoints = 0,
            unlockedSlots = 4,
            equippedItems = new List<EquippedItemData>(),
            unlockedAchievements = new List<string>(),
            masterVolume = 1f,
            sfxVolume = 1f,
            musicVolume = 1f
        };
    }
    
    public void AutoSave()
    {
        // Gather data from various managers
        var progression = GetComponent<ProgressionManager>();
        var items = GetComponent<EquippedItemsManager>();
        
        PlayerData data = new PlayerData();
        // Populate data...
        
        SavePlayerData(data);
    }
}
```

---

## 8. UI System

### 8.1 UI Architecture

```
UI Structure:
- Canvas (Screen Space - Overlay)
  ├── HUD Panel
  │   ├── Shield Bar
  │   ├── Score Display
  │   ├── Crystal Counter
  │   └── Active Buffs Display
  ├── Upgrade Menu
  │   ├── Stats Panel
  │   ├── Items Panel
  │   └── Slots Panel
  └── Game Over Screen
      ├── Stats Summary
      └── Continue Button
```

### 8.2 HUD Controller

```csharp
// UI/HUDController.cs
public class HUDController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Slider shieldBar;
    [SerializeField] private TextMeshProUGUI scoreText;
    [SerializeField] private TextMeshProUGUI crystalText;
    [SerializeField] private Transform activeBuffsContainer;
    
    private void Start()
    {
        EventBus.Subscribe<PlayerDamagedEvent>(OnPlayerDamaged);
        EventBus.Subscribe<CrystalCollectedEvent>(OnCrystalCollected);
    }
    
    private void OnPlayerDamaged(PlayerDamagedEvent evt)
    {
        shieldBar.value = evt.ShieldRemaining / shieldBar.maxValue;
    }
    
    private void OnCrystalCollected(CrystalCollectedEvent evt)
    {
        crystalText.text = evt.TotalCrystals.ToString();
    }
    
    private void Update()
    {
        // Update score display
    }
}
```

---

## 9. Performance Optimization

### 9.1 Object Pooling

```csharp
// Utilities/ObjectPool.cs
public class ObjectPool : MonoBehaviour
{
    [System.Serializable]
    public class Pool
    {
        public string tag;
        public GameObject prefab;
        public int size;
    }
    
    public List<Pool> pools;
    private Dictionary<string, Queue<GameObject>> poolDictionary;
    
    private void Start()
    {
        poolDictionary = new Dictionary<string, Queue<GameObject>>();
        
        foreach (Pool pool in pools)
        {
            Queue<GameObject> objectPool = new Queue<GameObject>();
            
            for (int i = 0; i < pool.size; i++)
            {
                GameObject obj = Instantiate(pool.prefab);
                obj.SetActive(false);
                objectPool.Enqueue(obj);
            }
            
            poolDictionary.Add(pool.tag, objectPool);
        }
    }
    
    public GameObject SpawnFromPool(string tag, Vector3 position, Quaternion rotation)
    {
        if (!poolDictionary.ContainsKey(tag))
        {
            Debug.LogWarning($"Pool with tag {tag} doesn't exist.");
            return null;
        }
        
        GameObject objectToSpawn = poolDictionary[tag].Dequeue();
        
        objectToSpawn.SetActive(true);
        objectToSpawn.transform.position = position;
        objectToSpawn.transform.rotation = rotation;
        
        poolDictionary[tag].Enqueue(objectToSpawn);
        
        return objectToSpawn;
    }
}
```

### 9.2 Performance Considerations

- **Fixed Update for Physics**: Use `FixedUpdate()` for all physics calculations
- **Caching**: Cache component references in `Awake()`/`Start()`
- **Object Pooling**: Pool projectiles, enemies, particles, VFX
- **Culling**: Deactivate off-screen objects
- **LOD**: Use simpler visuals for distant objects
- **Profiler Targets**:
  - Mobile: 60 FPS on mid-range devices
  - PC: 144 FPS on modern hardware

---

## 10. Testing Strategy

### 10.1 Unit Tests

```csharp
// Tests/ParameterSystemTests.cs
using NUnit.Framework;

public class ParameterSystemTests
{
    [Test]
    public void LinearScaling_CalculatesCorrectly()
    {
        var param = ScriptableObject.CreateInstance<ParameterDefinition>();
        param.baseValue = 100;
        param.linearScaling = 20;
        param.scalingType = ScalingType.Linear;
        
        Assert.AreEqual(100, param.CalculateValue(0));
        Assert.AreEqual(120, param.CalculateValue(1));
        Assert.AreEqual(300, param.CalculateValue(10));
    }
    
    [Test]
    public void ItemCost_ScalesExponentially()
    {
        var item = ScriptableObject.CreateInstance<ItemDefinition>();
        item.baseCost = 100;
        item.costMultiplier = 1.15f;
        
        Assert.AreEqual(100, item.CalculateCost(1));
        Assert.Greater(item.CalculateCost(10), 400);
    }
}
```

### 10.2 Integration Tests

- Test full upgrade flow: earn credits → purchase → apply stats
- Test difficulty scaling with different player power levels
- Test save/load cycle preserves all data

---

## 11. Build Configuration

### 11.1 Build Settings

**Mobile (iOS/Android)**
```
- Resolution: Adaptive (16:9, 18:9, 19.5:9)
- Target FPS: 60
- Graphics API: Vulkan (Android), Metal (iOS)
- Texture Compression: ASTC
- Scripting Backend: IL2CPP
- API Level: Android 8.0+ (API 26), iOS 12+
```

**PC**
```
- Resolution: 1920×1080 default, scalable
- Graphics API: DirectX 11/12, Vulkan
- Fullscreen modes: Fullscreen, Windowed, Borderless
```

### 11.2 Addressables Setup

Use Addressables for:
- Item definitions
- Enemy definitions
- Audio clips
- UI sprites

Benefits:
- Smaller initial build size
- On-demand loading
- Easy content updates

---

## 12. Development Milestones

### Phase 1: Core Systems (Weeks 1-2)
- [ ] Set up project structure
- [ ] Implement Event Bus
- [ ] Create Parameter System
- [ ] Build Ship Stats system
- [ ] Implement basic player movement

### Phase 2: Item System (Weeks 3-4)
- [ ] Create ItemDefinition ScriptableObjects
- [ ] Implement EquippedItemsManager
- [ ] Build ProgressionManager
- [ ] Create 10+ item definitions
- [ ] Build upgrade UI

### Phase 3: Combat & Enemies (Weeks 5-6)
- [ ] Create EnemyDefinition system
- [ ] Implement enemy behaviors
- [ ] Build spawn system
- [ ] Create 5+ enemy types
- [ ] Implement combat mechanics

### Phase 4: Difficulty System (Week 7)
- [ ] Implement DifficultyManager
- [ ] Create difficulty configurations
- [ ] Integrate with spawn system
- [ ] Balance and tune

### Phase 5: Polish & UI (Week 8-9)
- [ ] Complete HUD
- [ ] Build upgrade menus
- [ ] Implement save system
- [ ] Add audio/VFX
- [ ] Performance optimization

### Phase 6: Testing & Release (Week 10-12)
- [ ] Playtesting
- [ ] Bug fixing
- [ ] Balance tuning
- [ ] Build and deploy

---

## 13. Code Style Guidelines

### Naming Conventions
- Classes: `PascalCase`
- Methods: `PascalCase`
- Private fields: `camelCase`
- Serialized fields: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

### Code Organization
- One class per file
- Group using statements
- Region tags for large classes
- XML documentation for public APIs

### Unity-Specific
- Use `[SerializeField]` for private fields in inspector
- Cache component references
- Unsubscribe from events in `OnDestroy()`
- Use object pooling for frequently instantiated objects

---

## Conclusion

This technical specification provides a complete, modular architecture for Void Survivor that:

✅ **Data-Driven**: All content configured via ScriptableObjects  
✅ **Extensible**: Add new items/enemies without code changes  
✅ **Maintainable**: Clean separation of concerns, event-based communication  
✅ **Scalable**: Supports infinite progression with formula-based calculations  
✅ **Performant**: Object pooling, caching, optimized for mobile  
✅ **Testable**: Unit tests for core systems  

The architecture follows Unity best practices and SOLID principles, making it easy for developers to add, modify, and maintain game content throughout the development lifecycle.
