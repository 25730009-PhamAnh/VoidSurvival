# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Void Survivor** is a 2D arcade-style space shooter/survival game built in Unity 6.3 LTS. It's an endless survival game inspired by Asteroids, featuring inertia-based movement, dynamic difficulty scaling, and an infinite progression system. The game is designed for mobile platforms (iOS/Android) with potential PC support.

## Unity Version

- **Engine**: Unity 6000.3.2f1 (a9779f353c9b)
- **Rendering**: Universal Render Pipeline (URP) 17.3.0
- **Input**: Unity Input System 1.17.0
- **2D Packages**: Animation 13.0.2, Sprite 1.0.0, Tilemap 1.0.0

## Architecture

The project follows a **data-driven, modular architecture** using Unity best practices:

### Design Patterns
- **MVC + ECS Hybrid**: Model (ScriptableObjects), View (MonoBehaviours), Controller (Managers)
- **Component-Based Design**: Entity behaviors built from reusable components
- **Event-Driven System**: Loosely coupled systems communicating via events
- **SOLID Principles**: Single responsibility, dependency injection, interface-based design

### Key Architectural Principles
- All game content (items, enemies, upgrades) defined as ScriptableObject data assets
- No hard-coded values - all parameters exposed in data files for easy balancing
- Manager pattern for core systems (GameManager, ProgressionManager, DifficultyManager, SpawnManager, etc.)
- Data-driven progression using mathematical formulas for infinite scaling

## Project Structure

```
Assets/
├── _Project/                    # Main project content (to be created)
│   ├── ScriptableObjects/       # All game data (items, enemies, configs)
│   │   ├── Items/               # Defensive, Offensive, Utility items
│   │   ├── Enemies/             # Enemy definitions
│   │   ├── Pickups/             # Resource pickup configs
│   │   ├── GameSettings/        # Core game configuration
│   │   └── DifficultyConfigs/   # Dynamic difficulty parameters
│   ├── Scripts/
│   │   ├── Core/                # Managers, Systems, Interfaces
│   │   ├── Entities/            # Ship, Enemies, Hazards
│   │   ├── Gameplay/            # Combat, Movement, Spawning
│   │   ├── Progression/         # Upgrades, Items, Difficulty
│   │   ├── UI/                  # User interface
│   │   └── Utilities/           # Helper classes
│   ├── Prefabs/
│   ├── Scenes/
│   ├── Materials/
│   └── Audio/
├── Scenes/                      # Currently: SampleScene.unity
├── Settings/                    # URP settings, renderer configs
└── InputSystem_Actions.inputactions  # Input action mappings
```

## Core Game Systems

### 1. Infinite Progression System
The game uses mathematical formulas to scale indefinitely without level caps:
- **Ship Parameters**: Base + (Level × Scaling) formulas for shields, damage, fire rate, etc.
- **Item Parameters**: Temporary pickups with exponential cost scaling
- **Enemy Parameters**: Difficulty scales infinitely to match player power

### 2. Dynamic Difficulty System
- Tracks player performance (survival time, accuracy, crystals collected)
- Scales up when player performs well (increased spawn rate, enemy speed)
- Scales down when player struggles (reduced spawn rate for breathing room)
- Smooth continuous adjustments over 15-30 second intervals
- No forced rest periods - difficulty flows naturally

### 3. Ship Mechanics
- **Physics**: Inertia-based movement using Unity Rigidbody2D
- **Controls**: Thrust forward/backward, rotate left/right, screen wrap-around
- **Combat**: Line-based laser projectiles
- **Shield System**: Auto-regenerating energy bar with upgrade paths

### 4. Hazards & Enemies
- **Asteroids**: Split into smaller fragments on hit, random trajectories
- **Black Holes**: Apply gravitational pull (AddForce) to all objects, despawn when overloaded
- **Enemies**: UFOs (shooting squares) and Comets (charging triangles)

## Input System

The project uses Unity's new Input System. Key player actions defined in `InputSystem_Actions.inputactions`:
- **Move**: Vector2 movement input
- **Look**: Vector2 aiming/rotation input
- **Attack**: Fire weapon
- **Interact**: Hold-to-interact (for future pickups/menus)
- **Crouch**: Reserved for future mechanics

## Design Documents

Critical design documentation in `Documents/`:
- **VoidSurvivor_GDD.md**: Complete game design document with mechanics, progression systems, and balance formulas
- **VoidSurvivor_TechnicalSpec.md**: Detailed technical architecture, system designs, and implementation guidelines
- **VoidSurvivor_PrototypePlan.md**: Prototype development roadmap
- **VoidSurvivor_PrototypeStepByStep.md**: Step-by-step implementation guide

**IMPORTANT**: Always reference these documents when implementing features to ensure alignment with the design vision and technical architecture.

## Development Commands

### Opening the Project
- Open Unity Hub and select this project folder
- Unity version 6000.3.2f1 is required

### Running the Game
- Open `Assets/Scenes/SampleScene.unity`
- Press Play in Unity Editor
- For builds: File > Build Settings > Build

### Testing
- Unity Test Framework 1.6.0 is installed
- Tests should be placed in `Assets/_Project/Tests/` (to be created)
- Run tests via Window > General > Test Runner

## Code Style Guidelines

When writing C# scripts for this project:

### Naming Conventions
- Classes/Interfaces: PascalCase (`GameManager`, `IPoolable`)
- Methods: PascalCase (`Initialize()`, `SpawnEnemy()`)
- Private fields: camelCase with underscore (`_playerShip`, `_currentDifficulty`)
- Public fields/properties: PascalCase (`MaxShield`, `CurrentScore`)
- ScriptableObject assets: PascalCase with descriptive suffix (`LaserGun_Item`, `UFO_Enemy`)

### Organization
- One class per file
- Group related scripts in appropriate subdirectories
- Use `#region` sparingly, prefer smaller focused classes
- Add XML documentation comments for public APIs
- Keep MonoBehaviour classes focused on Unity lifecycle events

### Unity-Specific
- Prefer `[SerializeField]` private fields over public fields
- Use `[Header]` and `[Tooltip]` attributes for Inspector organization
- Cache component references in `Awake()` or `Start()`
- Use object pooling for frequently spawned objects (projectiles, enemies, particles)

## Critical Implementation Notes

### Data-Driven Development
- Create ScriptableObjects for ALL game content before writing MonoBehaviour scripts
- Game balance should be tweakable in the Inspector without code changes
- Use ScriptableObject references, not string/enum lookups

### Performance Considerations
- Target: 60 FPS on mid-range mobile devices
- Use object pooling for projectiles, enemies, and particles
- Avoid `FindObjectOfType` and `GetComponent` in Update loops
- Utilize Unity's Job System and Burst Compiler for spawning/movement calculations if needed

### Manager System
All managers should:
- Follow singleton pattern (but avoid static dependencies)
- Initialize via `GameManager.Awake()`
- Implement dependency injection where possible
- Use events/delegates for cross-system communication

### Save System
- Player progression (upgrades, high scores, credits) must persist
- Use JSON serialization with Unity's `JsonUtility`
- Save location: `Application.persistentDataPath`
- Auto-save after each game session

## Common Patterns

### Creating New Enemies
1. Create ScriptableObject in `Assets/_Project/ScriptableObjects/Enemies/`
2. Define base stats using progression formulas from GDD
3. Create prefab with required components (Rigidbody2D, Collider2D, Enemy script)
4. Register with SpawnManager

### Adding New Items/Upgrades
1. Create ScriptableObject in appropriate Items subdirectory
2. Define effect parameters and cost scaling formula
3. Implement effect logic in item-specific component
4. Add to UpgradeManager's available items list

### Implementing UI Screens
1. Create prefab in `Assets/_Project/Prefabs/UI/`
2. Implement screen controller inheriting from base UI class
3. Register with UIManager for navigation
4. Use Unity's UI Toolkit or legacy uGUI (project to decide)

## Target Platforms

### Mobile (Primary)
- iOS: iPhone 8+ (iOS 14+)
- Android: API Level 24+ (Android 7.0+)
- Touch controls with virtual joystick
- Portrait or landscape orientation (to be determined)

### PC (Secondary)
- Keyboard/mouse or gamepad support
- Minimum: Windows 10, 4GB RAM, Intel HD Graphics 520


  
# Unity C# Expert Developer Prompt

You are an expert Unity C# developer with deep knowledge of game development best practices, performance optimization, and cross-platform considerations. When generating code or providing solutions:

1. Write clear, concise, well-documented C# code adhering to Unity best practices.
2. Prioritize performance, scalability, and maintainability in all code and architecture decisions.
3. Leverage Unity's built-in features and component-based architecture for modularity and efficiency.
4. Implement robust error handling, logging, and debugging practices.
5. Consider cross-platform deployment and optimize for various hardware capabilities.

## Code Style and Conventions
- Use PascalCase for public members, camelCase for private members.
- Utilize #regions to organize code sections.
- Wrap editor-only code with #if UNITY_EDITOR.
- Use [SerializeField] to expose private fields in the inspector.
- Implement Range attributes for float fields when appropriate.

## Best Practices
- Use TryGetComponent to avoid null reference exceptions.
- Prefer direct references or GetComponent() over GameObject.Find() or Transform.Find().
- Always use TextMeshPro for text rendering.
- Implement object pooling for frequently instantiated objects.
- Use ScriptableObjects for data-driven design and shared resources.
- Leverage Coroutines for time-based operations and the Job System for CPU-intensive tasks.
- Optimize draw calls through batching and atlasing.
- Implement LOD (Level of Detail) systems for complex 3D models.

## Nomenclature
- Variables: m_VariableName
- Constants: c_ConstantName
- Statics: s_StaticName
- Classes/Structs: ClassName
- Properties: PropertyName
- Methods: MethodName()
- Arguments: _argumentName
- Temporary variables: temporaryVariable

## Example Code Structure

public class ExampleClass : MonoBehaviour
{
    #region Constants
    private const int c_MaxItems = 100;
    #endregion

    #region Private Fields
    [SerializeField] private int m_ItemCount;
    [SerializeField, Range(0f, 1f)] private float m_SpawnChance;
    #endregion

    #region Public Properties
    public int ItemCount => m_ItemCount;
    #endregion

    #region Unity Lifecycle
    private void Awake()
    {
        InitializeComponents();
    }

    private void Update()
    {
        UpdateGameLogic();
    }
    #endregion

    #region Private Methods
    private void InitializeComponents()
    {
        // Initialization logic
    }

    private void UpdateGameLogic()
    {
        // Update logic
    }
    #endregion

    #region Public Methods
    public void AddItem(int _amount)
    {
        m_ItemCount = Mathf.Min(m_ItemCount + _amount, c_MaxItems);
    }
    #endregion

    #if UNITY_EDITOR
    [ContextMenu("Debug Info")]
    private void DebugInfo()
    {
        Debug.Log($"Current item count: {m_ItemCount}");
    }
    #endif
}
Refer to Unity documentation and C# programming guides for best practices in scripting, game architecture, and performance optimization.
When providing solutions, always consider the specific context, target platforms, and performance requirements. Offer multiple approaches when applicable, explaining the pros and cons of each.
  
  