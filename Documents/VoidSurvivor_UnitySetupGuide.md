# Void Survivor - Unity Setup Guide

## Overview

All C# scripts have been created. This guide walks you through setting up the Unity scene, prefabs, and ScriptableObject assets to complete the Week 1 prototype.

---

## Step 1: Open Unity Project

1. Open Unity Hub
2. Select the Void Survival project
3. Wait for Unity to compile the new scripts (check bottom-right progress bar)
4. Verify no compilation errors in the Console window

---

## Step 2: Create MainGame Scene

### 2.1 Create New Scene
1. In Project window, navigate to `Assets/_Project/Scenes/`
2. Right-click → Create → Scene
3. Name it `MainGame`
4. Double-click to open it

### 2.2 Configure Main Camera
1. Select "Main Camera" in Hierarchy
2. In Inspector, set:
   - **Projection:** Orthographic
   - **Size:** 10
   - **Position:** (0, 0, -10)
   - **Clear Flags:** Solid Color
   - **Background:** Black (#000000)

### 2.3 Create GameObject Hierarchy
Right-click in Hierarchy and create Empty GameObjects:

1. **GameManager** (empty GameObject at 0,0,0)
   - Add Component: `GameManager` script
   - Add Component: `ScoreManager` script

2. **Player** (empty GameObject at 0,0,0)

3. **Hazards** (empty GameObject at 0,0,0)
   - Add Component: `AsteroidSpawner` script

4. **Projectiles** (empty GameObject at 0,0,0)
   - Add Component: `ProjectilePool` script

5. **EventSystem**
   - Right-click Hierarchy → UI → Event System (this auto-creates it)

Your Hierarchy should look like:
```
- Main Camera
- GameManager
- Player
- Hazards
- Projectiles
- EventSystem
```

### 2.4 Wire Up GameManager References
1. Select **GameManager** in Hierarchy
2. In Inspector, find the `GameManager` script component
3. Drag **Hazards** GameObject to `m_HazardsParent` field
4. Drag **Projectiles** GameObject to `m_ProjectilesParent` field

---

## Step 3: Create ScriptableObject Assets

### 3.1 Create Asteroid Data Assets
1. In Project window, navigate to `Assets/_Project/ScriptableObjects/Asteroids/`

2. **Create AsteroidLarge:**
   - Right-click → Create → Game → Hazards → Asteroid Data
   - Name: `AsteroidLarge`
   - Configure in Inspector:
     - **Asteroid Name:** "Large Asteroid"
     - **Size:** Large
     - **Sprite Scale:** (1.5, 1.5)
     - **Color:** Gray (#808080)
     - **Collider Radius:** 0.7
     - **Mass:** 2
     - **Min Speed:** 1
     - **Max Speed:** 2
     - **Health:** 30
     - **Score Value:** 10
     - **Can Fragment:** ✓
     - **Fragment Count:** 3
     - **Fragment Data:** (leave empty for now)

3. **Create AsteroidMedium:**
   - Right-click → Create → Game → Hazards → Asteroid Data
   - Name: `AsteroidMedium`
   - Configure:
     - **Asteroid Name:** "Medium Asteroid"
     - **Size:** Medium
     - **Sprite Scale:** (1.0, 1.0)
     - **Color:** Gray (#808080)
     - **Collider Radius:** 0.5
     - **Mass:** 1
     - **Min Speed:** 2
     - **Max Speed:** 3.5
     - **Health:** 20
     - **Score Value:** 5
     - **Can Fragment:** ✓
     - **Fragment Count:** 3
     - **Fragment Data:** (leave empty for now)

4. **Create AsteroidSmall:**
   - Right-click → Create → Game → Hazards → Asteroid Data
   - Name: `AsteroidSmall`
   - Configure:
     - **Asteroid Name:** "Small Asteroid"
     - **Size:** Small
     - **Sprite Scale:** (0.5, 0.5)
     - **Color:** Gray (#808080)
     - **Collider Radius:** 0.3
     - **Mass:** 0.5
     - **Min Speed:** 3
     - **Max Speed:** 5
     - **Health:** 10
     - **Score Value:** 2
     - **Can Fragment:** ✗ (uncheck)
     - **Fragment Count:** 0

5. **Link Fragment References:**
   - Select `AsteroidLarge`
   - Drag `AsteroidMedium` to **Fragment Data** field
   - Select `AsteroidMedium`
   - Drag `AsteroidSmall` to **Fragment Data** field

---

## Step 4: Create Sprites

### 4.1 Create Simple Sprites (Using Unity's Built-in Shapes)

For the prototype, we'll use Unity's built-in sprites:

1. **Ship Sprite:**
   - We'll use a built-in sprite: `UI/Skin/Knob` (or create a simple triangle in Sprites folder)
   - Alternatively, create a simple white triangle texture

2. **Asteroid Sprite:**
   - Use built-in sprite: `Knob` or `Circle`
   - We'll tint it gray in the prefab

3. **Projectile:**
   - Will use LineRenderer (no sprite needed)

**Quick Alternative - Create Simple Colored Sprites:**
1. Right-click `Assets/_Project/Sprites/`
2. Create → Sprites → Square (or Circle)
3. Name appropriately

---

## Step 5: Create Projectile Prefab

### 5.1 Create Projectile GameObject
1. In Hierarchy, right-click → Create Empty
2. Name it `Projectile`
3. Position at (0, 0, 0)

### 5.2 Add Components to Projectile
1. Add Component: `Projectile` script
2. Add Component: `Rigidbody2D`
   - **Body Type:** Kinematic
   - **Gravity Scale:** 0
3. Add Component: `Circle Collider 2D`
   - **Is Trigger:** ✓
   - **Radius:** 0.1
4. Add Component: `Line Renderer`
   - **Positions:** Size = 2
   - **Width:** 0.05
   - **Color:** White
   - **Material:** Default-Line (or Sprites/Default)

### 5.3 Save as Prefab
1. In Project window, navigate to `Assets/_Project/Prefabs/Projectiles/`
2. Drag the Projectile GameObject from Hierarchy into this folder
3. Delete the Projectile from Hierarchy (we only need the prefab)

---

## Step 6: Create Asteroid Prefab

### 6.1 Create Asteroid GameObject
1. In Hierarchy, right-click → Create Empty
2. Name it `Asteroid`
3. Position at (0, 0, 0)

### 6.2 Add Components to Asteroid
1. Add Component: `Sprite Renderer`
   - **Sprite:** Circle (or any built-in sprite)
   - **Color:** Gray (#808080)
2. Add Component: `Rigidbody2D`
   - **Body Type:** Dynamic
   - **Gravity Scale:** 0
   - **Collision Detection:** Continuous
3. Add Component: `Circle Collider 2D`
   - **Is Trigger:** ✓
   - **Radius:** 0.5
4. Add Component: `Asteroid` script

### 6.3 Save as Prefab
1. Navigate to `Assets/_Project/Prefabs/Hazards/`
2. Drag Asteroid from Hierarchy into this folder
3. Delete Asteroid from Hierarchy

---

## Step 7: Create Player Ship Prefab

### 7.1 Create Ship GameObject
1. In Hierarchy, right-click → Create Empty
2. Name it `PlayerShip`
3. Position at (0, 0, 0)

### 7.2 Add Visual (Simple Triangle)
For now, use a simple sprite:
1. Add Component: `Sprite Renderer`
   - **Sprite:** Knob or any sprite (rotate to point up)
   - **Color:** White (#FFFFFF)
2. Set **Rotation:** (0, 0, 0) - ensure ship points UP (default Unity orientation)

### 7.3 Add Physics Components
1. Add Component: `Rigidbody2D`
   - **Body Type:** Dynamic
   - **Gravity Scale:** 0 (will be set by script)
   - **Drag:** 0.5 (will be set by script)
   - **Angular Drag:** 1
   - **Collision Detection:** Continuous
2. Add Component: `Circle Collider 2D`
   - **Radius:** 0.4

### 7.4 Add Input System Component
1. Add Component: `Player Input`
2. In Inspector:
   - **Actions:** Drag `Assets/InputSystem_Actions` asset here
   - **Default Map:** Player
   - **Behavior:** Send Messages

### 7.5 Add Ship Scripts
1. Add Component: `PlayerInputHandler` script
2. Add Component: `ShipMovement` script
3. Add Component: `ShipWeapon` script

### 7.6 Save as Prefab
1. Navigate to `Assets/_Project/Prefabs/Player/`
2. Drag PlayerShip from Hierarchy into this folder
3. **DO NOT DELETE from Hierarchy** - we want an instance in the scene

---

## Step 8: Wire Up References

### 8.1 Wire Up AsteroidSpawner (Hazards GameObject)
1. Select **Hazards** in Hierarchy
2. Find `AsteroidSpawner` component
3. Set:
   - **m_AsteroidPrefab:** Drag `Asteroid` prefab from `Prefabs/Hazards/`
   - **m_LargeAsteroidData:** Drag `AsteroidLarge` asset from `ScriptableObjects/Asteroids/`
   - **m_SpawnInterval:** 2
   - **m_ScreenBounds:** (10, 10)
   - **m_IsSpawning:** ✓ (check to start spawning immediately)

### 8.2 Wire Up ProjectilePool (Projectiles GameObject)
1. Select **Projectiles** in Hierarchy
2. Find `ProjectilePool` component
3. Set:
   - **m_ProjectilePrefab:** Drag `Projectile` prefab from `Prefabs/Projectiles/`
   - **m_InitialPoolSize:** 20

### 8.3 Verify Player References
1. Select **PlayerShip** in Hierarchy
2. The `ShipWeapon` component should auto-create a FirePoint child
3. Verify `PlayerInput` has `InputSystem_Actions` assigned

---

## Step 9: Configure Input System

### 9.1 Check Input Actions
1. Double-click `Assets/InputSystem_Actions` in Project window
2. Verify these actions exist:
   - **Move** (Vector2) - bound to WASD/Arrow keys
   - **Attack** (Button) - bound to Space/Left Click

If not configured:
1. Select "Player" action map
2. Add **Move** action:
   - Action Type: Value
   - Control Type: Vector2
   - Add Binding: Keyboard → WASD
   - Add Binding: Keyboard → Arrows
3. Add **Attack** action:
   - Action Type: Button
   - Add Binding: Keyboard → Space
   - Add Binding: Mouse → Left Button
4. Click "Save Asset"

---

## Step 10: Test the Game

### 10.1 Initial Test
1. Save the scene (Ctrl+S / Cmd+S)
2. Press Play ▶️
3. Check Console for initialization messages:
   - "GameManager initialized"
   - "Projectile pool initialized with 20 projectiles"

### 10.2 Test Player Movement
1. Use **WASD** or **Arrow Keys** to move the ship
   - W/Up = thrust forward
   - S/Down = thrust backward
   - A/Left = rotate left
   - D/Right = rotate right
2. Ship should:
   - Have inertia (keeps moving when you stop pressing)
   - Wrap around screen edges
   - Have velocity capped

### 10.3 Test Shooting
1. Press **Space** or **Left Click** to fire
2. White line projectiles should shoot from ship
3. Projectiles should despawn after 2 seconds

### 10.4 Test Asteroids
1. Asteroids should spawn at screen edges every 2 seconds
2. Asteroids should move toward center
3. Shoot asteroids:
   - Large asteroids split into 3 medium
   - Medium asteroids split into 3 small
   - Small asteroids don't split
4. Score should increase when destroying asteroids

### 10.5 Expected Behavior
- Ship moves with satisfying inertia
- Shooting feels responsive
- Asteroids spawn continuously
- Fragmentation creates escalating challenge
- Score displays in top-left corner
- FPS counter shows ~60 FPS

---

## Step 11: Tuning and Balancing

If anything feels off, adjust these values in Inspector:

### Ship Feel
- **ShipMovement** component:
  - `m_RotationSpeed` - if rotation too slow/fast
  - `m_ThrustForce` - if acceleration too weak/strong
  - `m_MaxVelocity` - if ship too slow/fast
  - `m_Drag` - if ship too floaty/sticky

### Combat Feel
- **ShipWeapon** component:
  - `m_FireRate` - shots per second
  - `m_ProjectileSpeed` - bullet speed
  - `m_Damage` - damage per shot

### Difficulty
- **AsteroidSpawner** component:
  - `m_SpawnInterval` - time between spawns (lower = harder)
- **AsteroidData** assets:
  - Adjust health, speed, score values

---

## Troubleshooting

### Scripts Don't Appear in Add Component Menu
- Wait for Unity to finish compiling (check bottom-right)
- Check Console for compilation errors
- Try Assets → Reimport All

### Player Doesn't Move
- Check `PlayerInput` has `InputSystem_Actions` assigned
- Verify Input Actions are enabled
- Check Console for input-related errors

### Projectiles Don't Fire
- Verify `ProjectilePool` has prefab assigned
- Check Console for NullReferenceException
- Ensure Projectile prefab has all components

### Asteroids Don't Spawn
- Verify `m_IsSpawning` is checked on `AsteroidSpawner`
- Check `m_AsteroidPrefab` and `m_LargeAsteroidData` are assigned
- Look for errors in Console

### Collisions Don't Work
- Verify all colliders have `Is Trigger` checked
- Check Physics2D settings (Edit → Project Settings → Physics 2D)
- Ensure layers are set up correctly (should use Default layer for now)

### Performance Issues
- Check Profiler (Window → Analysis → Profiler)
- Reduce `m_InitialPoolSize` if too many projectiles
- Slow down `m_SpawnInterval` if too many asteroids

---

## Next Steps After Week 1

Once you have a playable Week 1 prototype:

1. **Playtest extensively** - adjust values based on feel
2. **Document issues** - note what needs improvement
3. **Week 2 Planning** - prepare for shield system, game over, upgrades
4. **Gather feedback** - show to friends/testers

---

## Summary Checklist

- [ ] MainGame scene created with proper camera setup
- [ ] GameObjects hierarchy set up (GameManager, Player, Hazards, Projectiles)
- [ ] 3 Asteroid data assets created (Large, Medium, Small)
- [ ] Fragment references linked correctly
- [ ] Projectile prefab created with LineRenderer
- [ ] Asteroid prefab created with SpriteRenderer
- [ ] PlayerShip prefab created with all components
- [ ] All references wired up in Inspector
- [ ] Input System configured
- [ ] Game runs without errors
- [ ] Player movement feels good
- [ ] Shooting works correctly
- [ ] Asteroids spawn and fragment
- [ ] Score increases on destruction
- [ ] 60 FPS maintained

---

**Congratulations!** You now have a working Week 1 prototype! 🎮
