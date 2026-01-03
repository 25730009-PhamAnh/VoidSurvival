# Void Survivor - Week 1 Prototype Implementation Plan

## Overview

Implement Week 1 Foundation of the Void Survivor prototype following the step-by-step incremental approach. This creates a playable foundation with player movement, shooting, and asteroid destruction.

**Project State:**
- Unity 6000.3.2f1 with URP and Input System configured
- NO game code exists - completely fresh start
- Input actions already defined in `Assets/InputSystem_Actions.inputactions`

**Week 1 Goals:**
1. Project setup and folder structure
2. Player ship with inertia-based physics and screen wrap
3. Shooting system with object pooling
4. Asteroid spawning, fragmentation, and basic scoring

## Implementation Phases

### Phase 1: Project Setup (Days 1-2)

**Create Folder Structure:**
```
Assets/_Project/
├── Scenes/
├── Scripts/
│   ├── Core/           # GameManager, ScoreManager
│   ├── Player/         # ShipMovement, ShipWeapon, PlayerInputHandler
│   ├── Gameplay/       # AsteroidData, ProjectilePool, AsteroidSpawner
│   ├── Hazards/        # Asteroid, Projectile
│   └── Utilities/      # Future helpers
├── Prefabs/
│   ├── Player/
│   ├── Hazards/
│   └── Projectiles/
├── Materials/
├── ScriptableObjects/
│   └── Asteroids/      # Asteroid data assets
└── Sprites/
```

**Scene Setup:**
- Create `MainGame.unity` in `_Project/Scenes/`
- Configure Camera: Orthographic, Size 10, Black background, Position (0,0,-10)
- Create GameObject hierarchy:
  - Main Camera
  - GameManager (empty GameObject)
  - Player (will hold ship prefab)
  - Hazards (parent for spawned asteroids)
  - Projectiles (parent for pooled bullets)
  - EventSystem

**GameManager Script:**
- Location: `/Assets/_Project/Scripts/Core/GameManager.cs`
- Singleton pattern
- Holds references to Hazards and Projectiles parent transforms
- Debug info display (FPS counter)

---

### Phase 2: Player Ship Movement (Days 3-4)

**ShipMovement Script:**
- Location: `/Assets/_Project/Scripts/Player/ShipMovement.cs`
- Rigidbody2D-based inertia physics
- Rotation with A/D or Left/Right (300°/s)
- Thrust with W/S or Up/Down (force: 10)
- Max velocity cap (8 units/s)
- Drag for space friction (0.5)
- Screen wrap-around (bounds: ±10 units)
- All values exposed in Inspector for tuning

**PlayerInputHandler Script:**
- Location: `/Assets/_Project/Scripts/Player/PlayerInputHandler.cs`
- Routes Input System callbacks to ship components
- OnMove() → ShipMovement
- OnAttack() → ShipWeapon (future)

**Player Ship Prefab:**
- Location: `/Assets/_Project/Prefabs/Player/PlayerShip.prefab`
- Components:
  - SpriteRenderer (white triangle)
  - Rigidbody2D (configured by script)
  - CircleCollider2D (radius 0.4)
  - PlayerInput (reference InputSystem_Actions)
  - PlayerInputHandler script
  - ShipMovement script

**Testing Focus:**
- Movement feels responsive
- Inertia creates satisfying momentum
- Screen wrap works at all edges
- Velocity cap prevents runaway speed

---

### Phase 3A: Projectile System (Day 5 - First Half)

**Projectile Script:**
- Location: `/Assets/_Project/Scripts/Hazards/Projectile.cs`
- Rigidbody2D for movement
- LineRenderer for visual trail
- 2-second lifetime, then return to pool
- Trigger collision with asteroids
- Launch() method with position, direction, speed, damage

**ProjectilePool Script:**
- Location: `/Assets/_Project/Scripts/Gameplay/ProjectilePool.cs`
- Singleton pattern
- Initial pool size: 20 projectiles
- GetProjectile() / ReturnProjectile() methods
- Auto-expand if pool exhausted

**ShipWeapon Script:**
- Location: `/Assets/_Project/Scripts/Player/ShipWeapon.cs`
- Fire rate: 4 shots/second
- Projectile speed: 15 units/s
- Damage: 10 per shot
- FirePoint child transform (0.6 units ahead of ship)
- Cooldown-based firing

**Projectile Prefab:**
- Location: `/Assets/_Project/Prefabs/Projectiles/Projectile.prefab`
- LineRenderer (white, width 0.1)
- Rigidbody2D (kinematic, no gravity)
- CircleCollider2D (radius 0.1, trigger)
- Projectile script

---

### Phase 3B: Asteroid System (Days 5-6)

**AsteroidData ScriptableObject:**
- Location: `/Assets/_Project/Scripts/Gameplay/AsteroidData.cs`
- Defines asteroid properties: size, sprite, physics, movement, combat, fragmentation
- Create 3 data assets in `ScriptableObjects/Asteroids/`:
  - **AsteroidLarge**: Health 30, Speed 1-2, Fragments 3 → Medium
  - **AsteroidMedium**: Health 20, Speed 2-3.5, Fragments 3 → Small
  - **AsteroidSmall**: Health 10, Speed 3-5, No fragments

**Asteroid Script:**
- Location: `/Assets/_Project/Scripts/Hazards/Asteroid.cs`
- Initialize() method applies AsteroidData
- TakeDamage() reduces health, destroys when health <= 0
- CreateFragments() spawns smaller asteroids
- Screen wrap-around (same as ship)
- Random angular velocity for rotation

**AsteroidSpawner Script:**
- Location: `/Assets/_Project/Scripts/Gameplay/AsteroidSpawner.cs`
- Singleton pattern
- Spawn interval: 2 seconds
- Spawns large asteroids at random screen edges
- Velocity aimed toward center with randomness
- SpawnAsteroid() method for manual spawning (used by fragmentation)

**Asteroid Prefab:**
- Location: `/Assets/_Project/Prefabs/Hazards/Asteroid.prefab`
- SpriteRenderer (gray polygon)
- Rigidbody2D (dynamic, no gravity)
- CircleCollider2D (trigger)
- Asteroid script

---

### Phase 3C: Scoring & Integration (Day 7)

**ScoreManager Script:**
- Location: `/Assets/_Project/Scripts/Core/ScoreManager.cs`
- Singleton pattern
- AddScore() method
- Display current score in OnGUI()
- ResetScore() for future game over

**Scene Wiring:**
- Add AsteroidSpawner to Hazards GameObject
- Add ProjectilePool to Projectiles GameObject
- Add ScoreManager to GameManager GameObject
- Assign all references in Inspector
- Configure asteroid data assets

**Testing & Balancing:**
- Complete gameplay loop: spawn → shoot → destroy → fragment → score
- Tune spawn rate for appropriate challenge
- Adjust projectile damage/speed for satisfying combat
- Verify fragmentation chains work correctly
- Test with 15+ asteroids on screen (60 FPS target)

---

## Critical Files to Create

### Scripts (11 files)
1. `/Assets/_Project/Scripts/Core/GameManager.cs` - Game initialization and references
2. `/Assets/_Project/Scripts/Core/ScoreManager.cs` - Score tracking
3. `/Assets/_Project/Scripts/Player/ShipMovement.cs` - Ship physics and controls
4. `/Assets/_Project/Scripts/Player/ShipWeapon.cs` - Shooting mechanics
5. `/Assets/_Project/Scripts/Player/PlayerInputHandler.cs` - Input routing
6. `/Assets/_Project/Scripts/Hazards/Projectile.cs` - Bullet behavior
7. `/Assets/_Project/Scripts/Hazards/Asteroid.cs` - Asteroid entity
8. `/Assets/_Project/Scripts/Gameplay/ProjectilePool.cs` - Object pooling
9. `/Assets/_Project/Scripts/Gameplay/AsteroidSpawner.cs` - Spawn management
10. `/Assets/_Project/Scripts/Gameplay/AsteroidData.cs` - ScriptableObject definition
11. `/Assets/_Project/Scripts/Utilities/` (folder only for now)

### ScriptableObject Assets (3 files)
1. `/Assets/_Project/ScriptableObjects/Asteroids/AsteroidLarge.asset`
2. `/Assets/_Project/ScriptableObjects/Asteroids/AsteroidMedium.asset`
3. `/Assets/_Project/ScriptableObjects/Asteroids/AsteroidSmall.asset`

### Prefabs (3 files)
1. `/Assets/_Project/Prefabs/Player/PlayerShip.prefab`
2. `/Assets/_Project/Prefabs/Projectiles/Projectile.prefab`
3. `/Assets/_Project/Prefabs/Hazards/Asteroid.prefab`

### Scenes (1 file)
1. `/Assets/_Project/Scenes/MainGame.unity`

---

## Implementation Order

### Step 1: Folder Structure
Create all folders in `Assets/_Project/` before writing any code.

### Step 2: GameManager
Create GameManager script and add to scene - provides foundation for other systems.

### Step 3: Player Movement
Create ShipMovement, PlayerInputHandler, and PlayerShip prefab - establishes playable character.

### Step 4: Projectiles
Create Projectile, ProjectilePool, ShipWeapon - adds shooting capability.

### Step 5: Asteroids
Create AsteroidData, Asteroid, AsteroidSpawner, and asteroid data assets - adds targets and challenge.

### Step 6: Scoring
Create ScoreManager and wire up all systems in scene - completes gameplay loop.

### Step 7: Testing
Playtest and tune all parameters for satisfying gameplay feel.

---

## Success Criteria

By end of Week 1:
- ✅ Ship movement feels responsive and fun
- ✅ Shooting is satisfying with good visual feedback
- ✅ Asteroids provide escalating challenge through fragmentation
- ✅ Score system motivates destruction
- ✅ 60 FPS with 15+ objects on screen
- ✅ Playable for 1+ minute without boredom
- ✅ Clean codebase ready for Week 2 expansion

---

## Key Design Decisions

**Data-Driven Approach:**
- Use ScriptableObjects for asteroid data (needs tuning)
- Hard-code ship/weapon values initially (can extract later if needed)

**Simplicity First:**
- MonoBehaviour-based, no complex patterns
- Direct references, no event bus
- Simple spawning algorithm (time-based)

**Performance:**
- Object pooling for projectiles (spawned frequently)
- NO pooling for asteroids yet (destroyed often, less benefit)
- Can add later if needed

**Testing Strategy:**
- Build incrementally - test each phase before moving on
- Use Inspector to tune values without code changes
- Debug display for FPS and score monitoring
