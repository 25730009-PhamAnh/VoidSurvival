# Void Survivor - Prototype Step-by-Step Implementation Guide
**Version:** 1.0  
**Date:** January 3, 2026  
**Companion Document:** VoidSurvivor_PrototypePlan.md

---

## How to Use This Guide

This document provides **detailed, actionable steps** for implementing the Void Survivor prototype. Each task from the Prototype Plan is broken down into specific actions you can follow.

**Format:**
- 📋 **Task**: High-level goal
- 🔧 **Steps**: Detailed implementation instructions
- ✅ **Verification**: How to test it works
- 💡 **Tips**: Common pitfalls and best practices

---

# Week 1: Foundation

## Day 1-2: Project Setup

### 📋 Task 1.1: Create Unity 6.3 LTS Project

🔧 **Steps:**
1. Launch Unity Hub
2. Click "New Project"
3. Select "2D (URP)" template
4. Set project name: "VoidSurvivor_Prototype"
5. Set location: Choose your preferred directory
6. Unity version: Select "6.3 LTS"
7. Click "Create Project"
8. Wait for Unity to initialize

✅ **Verification:**
- Unity Editor opens
- Default scene loaded
- 2D mode enabled (Scene view shows 2D)

💡 **Tips:**
- 2D URP template includes necessary packages for 2D rendering
- If 6.3 LTS not available, download from Unity Hub

---

### 📋 Task 1.2: Set Up Project Folder Structure

🔧 **Steps:**

1. In Unity Project window, create folder structure:
   ```
   Assets/
   ├── _Project/
   │   ├── Scenes/
   │   ├── Scripts/
   │   │   ├── Player/
   │   │   ├── Enemies/
   │   │   ├── Managers/
   │   │   ├── UI/
   │   │   └── Utilities/
   │   ├── Prefabs/
   │   │   ├── Player/
   │   │   ├── Enemies/
   │   │   └── Projectiles/
   │   ├── Materials/
   │   └── Audio/
   ```

2. Right-click in Project window → Create → Folder
3. Name it "_Project" (underscore keeps it at top)
4. Create subfolders as shown above

✅ **Verification:**
- Folder structure matches layout
- All folders visible in Project window

💡 **Tips:**
- Use "_Project" to separate game assets from Unity packages
- Keep Scripts organized by category from the start

---

### 📋 Task 1.3: Create Basic Scene

🔧 **Steps:**

1. Save current scene:
   - File → Save As
   - Navigate to `Assets/_Project/Scenes/`
   - Name: "GameScene"
   - Click Save

2. Configure Main Camera:
   - Select "Main Camera" in Hierarchy
   - Set Background: Color → Black (R:0, G:0, B:0)
   - Set Size: 10 (in Camera component)
   - Position: (0, 0, -10)

3. Set up 2D Physics:
   - Edit → Project Settings → Physics 2D
   - Gravity: Set to (0, 0) - no gravity in space!

4. Configure Game View:
   - Click Game tab
   - Set Aspect Ratio: 16:9 (or Free Aspect for testing)

✅ **Verification:**
- Scene shows black background
- Camera is at (0, 0, -10)
- Physics 2D gravity is (0, 0)

💡 **Tips:**
- Black background immediately gives "space" feel
- Zero gravity is crucial for proper inertia-based movement

---

### 📋 Task 1.4: Set Up Version Control (Git)

🔧 **Steps:**

1. Initialize Git repository:
   - Open Terminal/Command Prompt
   - Navigate to project folder:
     ```bash
     cd /path/to/VoidSurvivor_Prototype
     ```
   - Initialize Git:
     ```bash
     git init
     ```

2. Create .gitignore file:
   - In project root, create file named `.gitignore`
   - Add Unity-specific ignores:
     ```
     # Unity
     [Ll]ibrary/
     [Tt]emp/
     [Oo]bj/
     [Bb]uild/
     [Bb]uilds/
     [Ll]ogs/
     [Uu]ser[Ss]ettings/
     
     # Visual Studio
     .vs/
     *.csproj
     *.sln
     
     # Rider
     .idea/
     
     # OS
     .DS_Store
     Thumbs.db
     ```

3. Make initial commit:
   ```bash
   git add .
   git commit -m "Initial project setup"
   ```

4. Create GitHub repository (optional):
   - Go to github.com
   - Create new repository: "VoidSurvivor_Prototype"
   - Copy repository URL
   - Link local repo:
     ```bash
     git remote add origin <repository-url>
     git branch -M main
     git push -u origin main
     ```

✅ **Verification:**
- `.git` folder exists in project root
- First commit created
- (Optional) GitHub shows initial commit

💡 **Tips:**
- Commit early and often
- Use descriptive commit messages
- Push to GitHub for backup

---

### 📋 Task 1.5: Create Initial GameObject Structure

🔧 **Steps:**

1. Create empty GameObjects for organization:
   - Right-click in Hierarchy → Create Empty
   - Name: "--- GAME ---"
   - Position: (0, 0, 0)

2. Create more organizational objects:
   ```
   Hierarchy:
   - Main Camera
   - --- GAME ---
   - --- MANAGERS ---
   - --- DYNAMIC --- (for spawned objects)
   ```

3. For each object:
   - Right-click Hierarchy → Create Empty
   - Rename as shown
   - Set Position to (0, 0, 0)

✅ **Verification:**
- Hierarchy shows organized structure
- All GameObjects at (0, 0, 0)

💡 **Tips:**
- Use "---" prefix for separator objects
- This keeps Hierarchy clean as objects spawn
- Dynamic objects will be children of "--- DYNAMIC ---"

---

## Day 3-4: Player Ship Movement

### 📋 Task 2.1: Create Player Ship Visual

🔧 **Steps:**

1. Create Player GameObject:
   - Right-click "--- GAME ---" → Create Empty
   - Name: "Player"
   - Position: (0, 0, 0)

2. Add SpriteRenderer:
   - Select Player
   - Add Component → Rendering → Sprite Renderer
   - Sprite: None (we'll create a triangle)
   - Color: White

3. Create triangle sprite:
   - **Option A - Quick (using built-in):**
     - Assets → Create → Sprites → Triangle
     - Drag to Player's Sprite Renderer
   
   - **Option B - Custom (better control):**
     - Create a white triangle in external tool (16x16 pixels)
     - Import to `Assets/_Project/Materials/`
     - Set Texture Type: Sprite (2D and UI)
     - Drag to Sprite Renderer

4. Scale the ship:
   - Select Player
   - Scale: (0.5, 0.5, 1) or adjust to preference

5. Rotate to point upward:
   - Rotation: (0, 0, 0) - should point up by default
   - If pointing wrong way, adjust Z rotation

✅ **Verification:**
- White triangle visible in Game view
- Ship centered at (0, 0)
- Points upward

💡 **Tips:**
- Keep ship small (about 0.5-1 unit size)
- White color allows easy tinting later
- Triangle is iconic for space games (Asteroids style)

---

### 📋 Task 2.2: Add Physics Components

🔧 **Steps:**

1. Add Rigidbody2D:
   - Select Player
   - Add Component → Physics 2D → Rigidbody 2D
   - Configure:
     - Body Type: Dynamic
     - Gravity Scale: 0 (no gravity in space!)
     - Linear Drag: 0.5 (adds slight friction)
     - Angular Drag: 1 (dampens rotation)
     - Constraints: Freeze Rotation Z (we'll rotate manually)

2. Add Collider:
   - Add Component → Physics 2D → Polygon Collider 2D
   - Click "Edit Collider" button
   - Adjust points to match triangle shape closely

✅ **Verification:**
- Rigidbody2D component attached
- Gravity Scale is 0
- Collider matches ship shape (green outline in Scene view)

💡 **Tips:**
- Linear Drag prevents ship from drifting forever
- Freeze Rotation prevents physics from spinning ship
- Polygon Collider fits triangle better than Circle

---

### 📋 Task 2.3: Create Player Movement Script

🔧 **Steps:**

1. Create script:
   - Navigate to `Assets/_Project/Scripts/Player/`
   - Right-click → Create → C# Script
   - Name: "PlayerMovement"

2. Write the script:

```csharp
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement Settings")]
    [SerializeField] private float thrustForce = 5f;
    [SerializeField] private float rotationSpeed = 200f;
    [SerializeField] private float maxSpeed = 10f;
    
    private Rigidbody2D rb;
    private float rotationInput;
    private float thrustInput;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
    }
    
    private void Update()
    {
        // Get input
        rotationInput = -Input.GetAxis("Horizontal"); // A/D or Left/Right arrows
        thrustInput = Input.GetAxis("Vertical"); // W/S or Up/Down arrows
        
        // Mobile touch input (simple version)
        if (Input.touchCount > 0)
        {
            Touch touch = Input.GetTouch(0);
            Vector2 touchPos = Camera.main.ScreenToWorldPoint(touch.position);
            
            // Simple: touch left half = rotate left, right half = rotate right
            // Touch anywhere = thrust forward
            if (touchPos.x < 0)
                rotationInput = 1f;
            else if (touchPos.x > 0)
                rotationInput = -1f;
            
            thrustInput = 1f;
        }
    }
    
    private void FixedUpdate()
    {
        // Rotation
        float rotation = rotationInput * rotationSpeed * Time.fixedDeltaTime;
        rb.rotation += rotation;
        
        // Thrust
        if (thrustInput > 0)
        {
            Vector2 thrustDirection = transform.up; // Ship's forward direction
            rb.AddForce(thrustDirection * thrustForce * thrustInput);
        }
        
        // Clamp velocity to max speed
        if (rb.velocity.magnitude > maxSpeed)
        {
            rb.velocity = rb.velocity.normalized * maxSpeed;
        }
    }
}
```

3. Attach script to Player:
   - Drag PlayerMovement script onto Player GameObject
   - Or: Select Player → Add Component → search "PlayerMovement"

4. Configure in Inspector:
   - Thrust Force: 5
   - Rotation Speed: 200
   - Max Speed: 10

✅ **Verification:**
- Press Play
- Arrow keys/WASD rotates and moves ship
- Ship accelerates when thrusting
- Ship has inertia (keeps moving when you stop input)

💡 **Tips:**
- Use FixedUpdate for physics operations
- transform.up is ship's forward direction (points where triangle points)
- Max speed prevents infinite acceleration
- Adjust values until movement feels good!

---

### 📋 Task 2.4: Implement Screen Wrap-Around

🔧 **Steps:**

1. Create new script:
   - `Assets/_Project/Scripts/Player/ScreenWrapper.cs`

2. Write the script:

```csharp
using UnityEngine;

public class ScreenWrapper : MonoBehaviour
{
    private Camera mainCamera;
    private Vector2 screenBounds;
    
    private void Start()
    {
        mainCamera = Camera.main;
        UpdateScreenBounds();
    }
    
    private void UpdateScreenBounds()
    {
        // Calculate screen bounds in world coordinates
        screenBounds = mainCamera.ScreenToWorldPoint(
            new Vector3(Screen.width, Screen.height, 0)
        );
    }
    
    private void LateUpdate()
    {
        Vector3 pos = transform.position;
        
        // Wrap horizontally
        if (pos.x > screenBounds.x)
        {
            pos.x = -screenBounds.x;
        }
        else if (pos.x < -screenBounds.x)
        {
            pos.x = screenBounds.x;
        }
        
        // Wrap vertically
        if (pos.y > screenBounds.y)
        {
            pos.y = -screenBounds.y;
        }
        else if (pos.y < -screenBounds.y)
        {
            pos.y = screenBounds.y;
        }
        
        transform.position = pos;
    }
}
```

3. Attach to Player:
   - Add Component → ScreenWrapper

✅ **Verification:**
- Press Play
- Fly off screen edge
- Ship appears on opposite side
- Works for all four edges

💡 **Tips:**
- Use LateUpdate to run after physics
- This is classic Asteroids behavior
- Makes game area feel infinite

---

### 📋 Task 2.5: Test and Tune Movement Feel

🔧 **Steps:**

1. Create test checklist:
   - [ ] Ship rotates smoothly
   - [ ] Thrust feels responsive
   - [ ] Inertia feels natural (not too floaty, not too stiff)
   - [ ] Screen wrap works on all edges
   - [ ] Can navigate easily

2. Tune PlayerMovement values:
   - **Too floaty?** Increase Linear Drag on Rigidbody2D
   - **Too stiff?** Decrease Linear Drag
   - **Rotates too slow?** Increase Rotation Speed
   - **Accelerates too slow?** Increase Thrust Force
   - **Max speed too high?** Decrease Max Speed

3. Recommended starting values:
   ```
   Rigidbody2D:
   - Linear Drag: 0.5
   - Angular Drag: 1
   
   PlayerMovement:
   - Thrust Force: 5
   - Rotation Speed: 200
   - Max Speed: 10
   ```

4. Test extensively:
   - Play for 2-3 minutes
   - Try different maneuvers
   - Can you navigate precisely?
   - Does it feel fun?

✅ **Verification:**
- Movement feels good to you
- Can easily navigate around screen
- Inertia is noticeable but not frustrating

💡 **Tips:**
- "Feel" is subjective - trust your gut
- Get someone else to try if possible
- Save these values - you'll iterate later

**🎯 Day 3-4 Milestone Achieved: Playable ship with good feel**

---

## Day 5-7: Basic Shooting & Asteroids

### 📋 Task 3.1: Create Projectile System

🔧 **Steps:**

1. Create Projectile GameObject:
   - Hierarchy → Create → 2D Object → Sprite → Circle
   - Name: "Projectile"
   - Position: (0, 0, 0)
   - Move under `Assets/_Project/Prefabs/Projectiles/`

2. Configure visual:
   - Scale: (0.1, 0.3, 1) - make it a thin line
   - Sprite Renderer → Color: White
   - Or create line sprite for better look

3. Add physics:
   - Add Component → Rigidbody2D
     - Body Type: Dynamic
     - Gravity Scale: 0
     - Collision Detection: Continuous (for fast-moving objects)
   - Add Component → Circle Collider 2D
     - Radius: 0.1
     - Is Trigger: ✓ (checked)

4. Create Projectile script:
   - `Scripts/Player/Projectile.cs`

```csharp
using UnityEngine;

public class Projectile : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private float speed = 15f;
    [SerializeField] private float lifetime = 3f;
    
    private Rigidbody2D rb;
    
    public void Initialize(Vector2 direction)
    {
        rb = GetComponent<Rigidbody2D>();
        rb.velocity = direction * speed;
        
        // Rotate to face direction
        float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg - 90f;
        transform.rotation = Quaternion.Euler(0, 0, angle);
        
        // Destroy after lifetime
        Destroy(gameObject, lifetime);
    }
    
    private void OnTriggerEnter2D(Collider2D collision)
    {
        // Check if hit asteroid or enemy
        if (collision.CompareTag("Asteroid") || collision.CompareTag("Enemy"))
        {
            // Damage logic will go here
            Destroy(gameObject);
        }
    }
}
```

5. Add ScreenWrapper component to Projectile
   - Same wrap behavior as player

6. Create Prefab:
   - Drag Projectile from Hierarchy to `Prefabs/Projectiles/` folder
   - Delete from Hierarchy (we'll spawn it)

✅ **Verification:**
- Projectile prefab created
- Script attached
- Collider set to trigger

💡 **Tips:**
- Continuous collision detection prevents bullets tunneling through objects
- Is Trigger allows us to detect hits without physics push
- Auto-destroy prevents memory leaks

---

### 📋 Task 3.2: Implement Shooting Mechanic

🔧 **Steps:**

1. Create ShipWeapon script:
   - `Scripts/Player/ShipWeapon.cs`

```csharp
using UnityEngine;

public class ShipWeapon : MonoBehaviour
{
    [Header("Weapon Settings")]
    [SerializeField] private GameObject projectilePrefab;
    [SerializeField] private Transform firePoint;
    [SerializeField] private float fireRate = 0.5f; // Time between shots
    
    private float nextFireTime;
    
    private void Update()
    {
        // Check for fire input
        bool wantsToFire = Input.GetButton("Fire1") || Input.GetKey(KeyCode.Space);
        
        // Mobile: any touch fires
        if (Input.touchCount > 0)
        {
            wantsToFire = true;
        }
        
        // Fire if cooldown ready
        if (wantsToFire && Time.time >= nextFireTime)
        {
            Fire();
            nextFireTime = Time.time + fireRate;
        }
    }
    
    private void Fire()
    {
        // Spawn projectile
        GameObject projectile = Instantiate(
            projectilePrefab, 
            firePoint.position, 
            firePoint.rotation,
            GameObject.Find("--- DYNAMIC ---").transform
        );
        
        // Initialize with direction
        Projectile proj = projectile.GetComponent<Projectile>();
        proj.Initialize(transform.up); // Ship's forward direction
    }
}
```

2. Set up fire point on Player:
   - Select Player
   - Right-click → Create Empty Child
   - Name: "FirePoint"
   - Position: (0, 0.5, 0) - just in front of ship

3. Attach ShipWeapon to Player:
   - Add Component → ShipWeapon
   - Drag Projectile prefab to "Projectile Prefab" field
   - Drag FirePoint GameObject to "Fire Point" field
   - Fire Rate: 0.5

✅ **Verification:**
- Press Play
- Press Spacebar or click mouse
- White projectile shoots forward from ship
- Projectiles spawn every 0.5 seconds when holding fire
- Projectiles destroy after 3 seconds

💡 **Tips:**
- FirePoint offset prevents shooting yourself
- Fire rate prevents spam
- Parent projectiles to DYNAMIC for organization

---

### 📋 Task 3.3: Create Asteroid Prefab

🔧 **Steps:**

1. Create Asteroid GameObject:
   - Hierarchy → Create Empty
   - Name: "Asteroid"
   - Position: (0, 0, 0)

2. Add visual:
   - Add Component → Sprite Renderer
   - Sprite: Create or use hexagon/octagon
   - Color: Gray (R:0.5, G:0.5, B:0.5)
   - Scale: (1, 1, 1)

3. Add physics:
   - Add Component → Rigidbody2D
     - Body Type: Dynamic
     - Gravity Scale: 0
     - Linear Drag: 0
     - Angular Drag: 0
   - Add Component → Polygon Collider 2D

4. Create Asteroid script:
   - `Scripts/Enemies/Asteroid.cs`

```csharp
using UnityEngine;

public class Asteroid : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private int size = 3; // 3 = large, 2 = medium, 1 = small
    [SerializeField] private float minSpeed = 1f;
    [SerializeField] private float maxSpeed = 3f;
    [SerializeField] private int scoreValue = 10;
    
    [Header("Fragmentation")]
    [SerializeField] private GameObject asteroidPrefab;
    [SerializeField] private int fragmentCount = 3;
    
    private Rigidbody2D rb;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        gameObject.tag = "Asteroid";
    }
    
    public void Initialize(int asteroidSize)
    {
        size = asteroidSize;
        
        // Scale based on size
        float scale = size * 0.33f;
        transform.localScale = Vector3.one * scale;
        
        // Random velocity
        Vector2 randomDirection = Random.insideUnitCircle.normalized;
        float speed = Random.Range(minSpeed, maxSpeed);
        rb.velocity = randomDirection * speed;
        
        // Random rotation
        rb.angularVelocity = Random.Range(-50f, 50f);
    }
    
    public void TakeDamage()
    {
        // Award score
        GameManager.Instance.AddScore(scoreValue * size);
        
        // Fragment if not smallest size
        if (size > 1)
        {
            SpawnFragments();
        }
        
        Destroy(gameObject);
    }
    
    private void SpawnFragments()
    {
        for (int i = 0; i < fragmentCount; i++)
        {
            GameObject fragment = Instantiate(
                asteroidPrefab, 
                transform.position, 
                Quaternion.identity,
                GameObject.Find("--- DYNAMIC ---").transform
            );
            
            Asteroid ast = fragment.GetComponent<Asteroid>();
            ast.Initialize(size - 1);
        }
    }
    
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Projectile"))
        {
            TakeDamage();
        }
    }
}
```

5. Add ScreenWrapper component to Asteroid

6. Create Tag:
   - Top menu → Edit → Project Settings → Tags and Layers
   - Click "+" under Tags
   - Add tag: "Asteroid"
   - Close settings

7. Create Prefab:
   - Drag Asteroid to `Prefabs/Enemies/`
   - Set tag to "Asteroid"
   - Assign asteroidPrefab to itself (self-reference for spawning fragments)
   - Delete from Hierarchy

✅ **Verification:**
- Asteroid prefab created
- Script attached
- Tag set to "Asteroid"
- Self-reference set

💡 **Tips:**
- Polygon Collider auto-fits to sprite shape
- Self-reference lets asteroids spawn smaller versions
- Size determines scale and score value

---

### 📋 Task 3.4: Create Simple GameManager

🔧 **Steps:**

1. Create GameManager script:
   - `Scripts/Managers/GameManager.cs`

```csharp
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    [Header("Game State")]
    [SerializeField] private int currentScore = 0;
    
    private void Awake()
    {
        // Singleton pattern
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }
    
    public void AddScore(int points)
    {
        currentScore += points;
        Debug.Log($"Score: {currentScore}");
    }
    
    public int GetScore()
    {
        return currentScore;
    }
}
```

2. Create GameManager GameObject:
   - Hierarchy → Right-click "--- MANAGERS ---" → Create Empty
   - Name: "GameManager"
   - Add Component → GameManager script

✅ **Verification:**
- GameManager exists in scene under MANAGERS
- Script attached
- Singleton pattern working (only one instance)

💡 **Tips:**
- Singleton ensures only one GameManager exists
- We'll expand this later with more functionality
- Debug.Log helps verify scoring works

---

### 📋 Task 3.5: Implement Asteroid Spawning

🔧 **Steps:**

1. Create SpawnManager script:
   - `Scripts/Managers/SpawnManager.cs`

```csharp
using UnityEngine;

public class SpawnManager : MonoBehaviour
{
    [Header("Spawn Settings")]
    [SerializeField] private GameObject asteroidPrefab;
    [SerializeField] private float spawnInterval = 2f;
    [SerializeField] private float spawnDistance = 12f;
    
    private float nextSpawnTime;
    private Camera mainCamera;
    
    private void Start()
    {
        mainCamera = Camera.main;
        nextSpawnTime = Time.time + spawnInterval;
    }
    
    private void Update()
    {
        if (Time.time >= nextSpawnTime)
        {
            SpawnAsteroid();
            nextSpawnTime = Time.time + spawnInterval;
        }
    }
    
    private void SpawnAsteroid()
    {
        // Random position outside screen
        Vector2 spawnPos = GetRandomSpawnPosition();
        
        // Spawn asteroid
        GameObject asteroid = Instantiate(
            asteroidPrefab,
            spawnPos,
            Quaternion.identity,
            GameObject.Find("--- DYNAMIC ---").transform
        );
        
        // Initialize as large asteroid
        Asteroid ast = asteroid.GetComponent<Asteroid>();
        ast.Initialize(3); // Size 3 = large
    }
    
    private Vector2 GetRandomSpawnPosition()
    {
        // Get screen bounds
        Vector2 screenBounds = mainCamera.ScreenToWorldPoint(
            new Vector3(Screen.width, Screen.height, 0)
        );
        
        // Random angle
        float angle = Random.Range(0f, 360f) * Mathf.Deg2Rad;
        
        // Position outside screen
        Vector2 spawnPos = new Vector2(
            Mathf.Cos(angle) * spawnDistance,
            Mathf.Sin(angle) * spawnDistance
        );
        
        return spawnPos;
    }
}
```

2. Create SpawnManager GameObject:
   - Right-click "--- MANAGERS ---" → Create Empty
   - Name: "SpawnManager"
   - Add Component → SpawnManager
   - Drag Asteroid prefab to "Asteroid Prefab" field
   - Spawn Interval: 2
   - Spawn Distance: 12

✅ **Verification:**
- Press Play
- Asteroid spawns every 2 seconds
- Asteroids appear outside screen edges
- Asteroids drift into view

💡 **Tips:**
- Spawn distance should be beyond camera view
- Circular spawning creates unpredictable patterns
- Adjust spawn interval for difficulty

---

### 📋 Task 3.6: Test Shooting & Fragmentation

🔧 **Steps:**

1. Press Play and test:
   - [ ] Can shoot projectiles
   - [ ] Projectiles hit asteroids
   - [ ] Large asteroids break into 3 medium
   - [ ] Medium asteroids break into 3 small
   - [ ] Small asteroids just destroy
   - [ ] Score increases on asteroid destruction
   - [ ] Fragments drift in different directions

2. Check Console for score:
   - Should see "Score: 10", "Score: 20", etc.

3. Adjust values if needed:
   - **Too many asteroids?** Increase spawn interval
   - **Too few?** Decrease spawn interval
   - **Asteroids too slow?** Increase maxSpeed in Asteroid
   - **Too fast?** Decrease maxSpeed

✅ **Verification:**
- Complete asteroid lifecycle works
- Fragmentation creates smaller asteroids
- Scoring works
- Gameplay feels balanced

💡 **Tips:**
- Watch for fragment overlaps (some may collide immediately)
- If fragments spawn inside each other, add small random offset
- Scoring should feel rewarding

**🎯 Day 5-7 Milestone Achieved: Ship can shoot and destroy asteroids**

---

**COMMIT YOUR WORK:**
```bash
git add .
git commit -m "Week 1 complete: Player movement and asteroid shooting implemented"
git push
```

---

# Week 2: Core Loop

## Day 8-9: Shield System

### 📋 Task 4.1: Create Shield Component

🔧 **Steps:**

1. Create ShipShield script:
   - `Scripts/Player/ShipShield.cs`

```csharp
using UnityEngine;
using System.Collections;

public class ShipShield : MonoBehaviour
{
    [Header("Shield Settings")]
    [SerializeField] private float maxShield = 100f;
    [SerializeField] private float shieldRegenRate = 5f; // Per second
    [SerializeField] private float regenDelay = 3f; // Seconds before regen starts
    
    private float currentShield;
    private float lastDamageTime;
    private bool isDead = false;
    
    public float CurrentShield => currentShield;
    public float MaxShield => maxShield;
    public float ShieldPercent => currentShield / maxShield;
    
    private void Start()
    {
        currentShield = maxShield;
    }
    
    private void Update()
    {
        // Regenerate shield after delay
        if (Time.time - lastDamageTime > regenDelay && currentShield < maxShield)
        {
            currentShield += shieldRegenRate * Time.deltaTime;
            currentShield = Mathf.Min(currentShield, maxShield);
        }
    }
    
    public void TakeDamage(float damage)
    {
        if (isDead) return;
        
        currentShield -= damage;
        lastDamageTime = Time.time;
        
        Debug.Log($"Shield: {currentShield}/{maxShield}");
        
        if (currentShield <= 0)
        {
            Die();
        }
    }
    
    private void Die()
    {
        isDead = true;
        Debug.Log("Player died!");
        
        // Trigger game over
        GameManager.Instance.GameOver();
        
        // Disable player (or destroy)
        gameObject.SetActive(false);
    }
    
    private void OnCollisionEnter2D(Collision2D collision)
    {
        // Take damage from asteroids
        if (collision.gameObject.CompareTag("Asteroid"))
        {
            TakeDamage(20f);
        }
    }
}
```

2. Attach to Player:
   - Select Player
   - Add Component → ShipShield

3. Update Player's Collider:
   - Change Polygon Collider 2D to:
     - Is Trigger: ✗ (unchecked) - needs collision for damage
   - On Rigidbody2D:
     - Remove Freeze Rotation Z constraint (we handle rotation in code)

✅ **Verification:**
- Shield script attached
- Player takes damage on asteroid collision
- Console shows shield decreasing

💡 **Tips:**
- Collision (not trigger) needed for actual physics impact
- Shield regen creates recovery mechanic
- Damage values can be tuned later

---

### 📋 Task 4.2: Create Shield UI Bar

🔧 **Steps:**

1. Create UI Canvas:
   - Hierarchy → Right-click → UI → Canvas
   - Canvas automatically creates EventSystem (leave it)
   - Canvas settings:
     - Render Mode: Screen Space - Overlay
     - UI Scale Mode: Scale With Screen Size
     - Reference Resolution: 1920x1080

2. Create Shield Bar:
   - Right-click Canvas → UI → Slider
   - Name: "ShieldBar"
   - RectTransform:
     - Anchor: Bottom-left
     - Position: X: 150, Y: 50
     - Width: 250, Height: 30

3. Configure Slider:
   - Slider component:
     - Min Value: 0
     - Max Value: 100
     - Value: 100
     - Interactable: ✗ (unchecked)

4. Customize appearance:
   - Delete "Handle Slide Area" (we don't need it)
   - Select "Fill" under Fill Area:
     - Color: Cyan/Blue (R:0, G:0.7, B:1)
   - Select "Background":
     - Color: Dark Gray (R:0.2, G:0.2, B:0.2)

5. Create ShieldUI script:
   - `Scripts/UI/ShieldUI.cs`

```csharp
using UnityEngine;
using UnityEngine.UI;

public class ShieldUI : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Slider shieldSlider;
    [SerializeField] private ShipShield playerShield;
    [SerializeField] private Image fillImage;
    
    [Header("Colors")]
    [SerializeField] private Color fullColor = Color.cyan;
    [SerializeField] private Color lowColor = Color.red;
    [SerializeField] private float lowThreshold = 0.3f;
    
    private void Update()
    {
        if (playerShield == null) return;
        
        // Update slider value
        shieldSlider.value = playerShield.CurrentShield;
        shieldSlider.maxValue = playerShield.MaxShield;
        
        // Change color based on shield level
        float percent = playerShield.ShieldPercent;
        if (percent < lowThreshold)
        {
            fillImage.color = Color.Lerp(lowColor, fullColor, percent / lowThreshold);
        }
        else
        {
            fillImage.color = fullColor;
        }
    }
}
```

6. Attach script to Canvas:
   - Add Component → ShieldUI
   - Drag ShieldBar to "Shield Slider"
   - Drag Player to "Player Shield"
   - Find ShieldBar → Fill Area → Fill, drag to "Fill Image"

✅ **Verification:**
- Press Play
- Blue bar at bottom-left shows full shield
- Hit asteroid - bar decreases
- Bar turns red when low
- Shield regenerates after delay

💡 **Tips:**
- Color change provides visual warning
- Anchor to bottom-left keeps UI consistent across resolutions
- Slider component perfect for health/shield bars

---

### 📋 Task 4.3: Update GameManager with Game Over

🔧 **Steps:**

1. Update GameManager.cs:

```csharp
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    [Header("Game State")]
    [SerializeField] private int currentScore = 0;
    [SerializeField] private float survivalTime = 0f;
    [SerializeField] private bool isGameOver = false;
    
    public bool IsGameOver => isGameOver;
    
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
    
    private void Update()
    {
        if (!isGameOver)
        {
            survivalTime += Time.deltaTime;
        }
    }
    
    public void AddScore(int points)
    {
        currentScore += points;
    }
    
    public int GetScore()
    {
        return currentScore;
    }
    
    public float GetSurvivalTime()
    {
        return survivalTime;
    }
    
    public void GameOver()
    {
        if (isGameOver) return;
        
        isGameOver = true;
        Debug.Log($"Game Over! Score: {currentScore}, Time: {survivalTime:F1}s");
        
        // Stop spawning
        SpawnManager spawner = FindObjectOfType<SpawnManager>();
        if (spawner != null)
            spawner.enabled = false;
        
        // Show game over UI
        GameOverUI gameOverUI = FindObjectOfType<GameOverUI>();
        if (gameOverUI != null)
            gameOverUI.ShowGameOver(currentScore, survivalTime);
    }
    
    public void RestartGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
```

✅ **Verification:**
- GameManager updated with game over logic
- Tracks survival time
- Can restart game

---

### 📋 Task 4.4: Create Game Over Screen

🔧 **Steps:**

1. Create Game Over Panel:
   - Right-click Canvas → UI → Panel
   - Name: "GameOverPanel"
   - RectTransform: Stretch to full screen (set all anchors to 0,0,1,1)
   - Color: Black with 70% alpha (R:0, G:0, B:0, A:0.7)

2. Add Text - Game Over:
   - Right-click GameOverPanel → UI → Text - TextMeshPro
     - (If prompted, import TMP Essentials)
   - Name: "GameOverText"
   - Text: "GAME OVER"
   - Font Size: 72
   - Alignment: Center
   - Color: Red
   - Position: Center-top

3. Add Score Text:
   - Right-click GameOverPanel → UI → Text - TextMeshPro
   - Name: "ScoreText"
   - Text: "Score: 0"
   - Font Size: 48
   - Alignment: Center
   - Position: Below GameOverText

4. Add Time Text:
   - Right-click GameOverPanel → UI → Text - TextMeshPro
   - Name: "TimeText"
   - Text: "Time: 0s"
   - Font Size: 36
   - Position: Below ScoreText

5. Add Restart Button:
   - Right-click GameOverPanel → UI → Button - TextMeshPro
   - Name: "RestartButton"
   - Text (child): "RESTART"
   - Position: Center-bottom
   - Size: 200x60

6. Create GameOverUI script:
   - `Scripts/UI/GameOverUI.cs`

```csharp
using UnityEngine;
using TMPro;

public class GameOverUI : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private GameObject gameOverPanel;
    [SerializeField] private TextMeshProUGUI scoreText;
    [SerializeField] private TextMeshProUGUI timeText;
    
    private void Start()
    {
        // Hide panel at start
        gameOverPanel.SetActive(false);
    }
    
    public void ShowGameOver(int finalScore, float survivalTime)
    {
        gameOverPanel.SetActive(true);
        scoreText.text = $"Score: {finalScore}";
        timeText.text = $"Time: {survivalTime:F1}s";
        
        // Pause game (optional)
        Time.timeScale = 0f;
    }
    
    public void OnRestartClicked()
    {
        // Unpause
        Time.timeScale = 1f;
        
        // Restart game
        GameManager.Instance.RestartGame();
    }
}
```

7. Wire up UI:
   - Add GameOverUI script to Canvas
   - Drag GameOverPanel to "Game Over Panel"
   - Drag ScoreText to "Score Text"
   - Drag TimeText to "Time Text"
   - Select RestartButton → Inspector → Button component
   - Click "+" under OnClick()
   - Drag Canvas to object field
   - Function: GameOverUI → OnRestartClicked()

✅ **Verification:**
- Press Play
- Die (hit asteroids until shield depletes)
- Game Over screen appears
- Shows score and time
- Restart button works

💡 **Tips:**
- Time.timeScale = 0 pauses game
- Remember to unpause on restart!
- Black overlay makes text readable

**🎯 Day 8-9 Milestone Achieved: Complete life/death cycle**

---

## Day 10-11: Spawn System & Difficulty

### 📋 Task 5.1: Create Difficulty Scaling

🔧 **Steps:**

1. Update SpawnManager.cs:

```csharp
using UnityEngine;

public class SpawnManager : MonoBehaviour
{
    [Header("Spawn Settings")]
    [SerializeField] private GameObject asteroidPrefab;
    [SerializeField] private float baseSpawnInterval = 2f;
    [SerializeField] private float minSpawnInterval = 0.5f;
    [SerializeField] private float spawnDistance = 12f;
    
    [Header("Difficulty")]
    [SerializeField] private float difficultyIncreaseRate = 0.1f; // Decrease interval per minute
    [SerializeField] private float asteroidSpeedIncrease = 0.05f; // Speed mult per minute
    
    private float nextSpawnTime;
    private float currentSpawnInterval;
    private float gameTime;
    private float difficultyMultiplier = 1f;
    private Camera mainCamera;
    
    private void Start()
    {
        mainCamera = Camera.main;
        currentSpawnInterval = baseSpawnInterval;
        nextSpawnTime = Time.time + currentSpawnInterval;
    }
    
    private void Update()
    {
        if (GameManager.Instance.IsGameOver) return;
        
        // Track game time
        gameTime += Time.deltaTime;
        
        // Update difficulty every second
        UpdateDifficulty();
        
        // Spawn asteroids
        if (Time.time >= nextSpawnTime)
        {
            SpawnAsteroid();
            nextSpawnTime = Time.time + currentSpawnInterval;
        }
    }
    
    private void UpdateDifficulty()
    {
        float minutes = gameTime / 60f;
        
        // Decrease spawn interval (spawn faster)
        currentSpawnInterval = baseSpawnInterval - (minutes * difficultyIncreaseRate);
        currentSpawnInterval = Mathf.Max(currentSpawnInterval, minSpawnInterval);
        
        // Increase asteroid speed
        difficultyMultiplier = 1f + (minutes * asteroidSpeedIncrease);
    }
    
    private void SpawnAsteroid()
    {
        Vector2 spawnPos = GetRandomSpawnPosition();
        
        GameObject asteroid = Instantiate(
            asteroidPrefab,
            spawnPos,
            Quaternion.identity,
            GameObject.Find("--- DYNAMIC ---").transform
        );
        
        Asteroid ast = asteroid.GetComponent<Asteroid>();
        ast.Initialize(3, difficultyMultiplier);
    }
    
    private Vector2 GetRandomSpawnPosition()
    {
        Vector2 screenBounds = mainCamera.ScreenToWorldPoint(
            new Vector3(Screen.width, Screen.height, 0)
        );
        
        float angle = Random.Range(0f, 360f) * Mathf.Deg2Rad;
        Vector2 spawnPos = new Vector2(
            Mathf.Cos(angle) * spawnDistance,
            Mathf.Sin(angle) * spawnDistance
        );
        
        return spawnPos;
    }
}
```

2. Update Asteroid.cs to accept difficulty:

```csharp
// In Asteroid.cs, update Initialize method:
public void Initialize(int asteroidSize, float speedMultiplier = 1f)
{
    size = asteroidSize;
    
    float scale = size * 0.33f;
    transform.localScale = Vector3.one * scale;
    
    Vector2 randomDirection = Random.insideUnitCircle.normalized;
    float speed = Random.Range(minSpeed, maxSpeed) * speedMultiplier;
    rb.velocity = randomDirection * speed;
    
    rb.angularVelocity = Random.Range(-50f, 50f);
}
```

✅ **Verification:**
- Press Play
- Asteroids spawn faster over time
- Asteroids move faster over time
- Difficulty increases gradually

💡 **Tips:**
- Test for 2-3 minutes to see difficulty progression
- Adjust rates if too easy/hard
- Should feel challenging but fair

---

### 📋 Task 5.2: Add Score and Timer UI

🔧 **Steps:**

1. Create Score Text:
   - Right-click Canvas → UI → Text - TextMeshPro
   - Name: "ScoreText"
   - Anchor: Top-left
   - Position: X: 150, Y: -50
   - Text: "Score: 0"
   - Font Size: 36
   - Color: White

2. Create Timer Text:
   - Right-click Canvas → UI → Text - TextMeshPro
   - Name: "TimerText"
   - Anchor: Top-right
   - Position: X: -150, Y: -50
   - Text: "Time: 0:00"
   - Font Size: 36
   - Color: White

3. Create HUD script:
   - `Scripts/UI/HUDController.cs`

```csharp
using UnityEngine;
using TMPro;

public class HUDController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private TextMeshProUGUI scoreText;
    [SerializeField] private TextMeshProUGUI timerText;
    
    private GameManager gameManager;
    
    private void Start()
    {
        gameManager = GameManager.Instance;
    }
    
    private void Update()
    {
        if (gameManager == null) return;
        
        // Update score
        scoreText.text = $"Score: {gameManager.GetScore()}";
        
        // Update timer
        float time = gameManager.GetSurvivalTime();
        int minutes = Mathf.FloorToInt(time / 60f);
        int seconds = Mathf.FloorToInt(time % 60f);
        timerText.text = $"Time: {minutes}:{seconds:00}";
    }
}
```

4. Attach to Canvas:
   - Add Component → HUDController
   - Drag ScoreText to "Score Text"
   - Drag TimerText to "Timer Text"

✅ **Verification:**
- Score updates when destroying asteroids
- Timer counts up
- Both visible during gameplay

**🎯 Day 10-11 Milestone Achieved: Escalating challenge over time**

---

## Day 12-14: Basic Progression

### 📋 Task 6.1: Create ScriptableObject System

🔧 **Steps:**

1. Create UpgradeData ScriptableObject:
   - `Scripts/Progression/UpgradeData.cs`

```csharp
using UnityEngine;

[CreateAssetMenu(fileName = "New Upgrade", menuName = "Game/Upgrade")]
public class UpgradeData : ScriptableObject
{
    [Header("Info")]
    public string upgradeName;
    [TextArea]
    public string description;
    
    [Header("Cost")]
    public int baseCost;
    public int currentLevel = 0;
    public int maxLevel = 3;
    
    [Header("Effects")]
    public UpgradeType upgradeType;
    public float effectValue;
    public float effectPerLevel;
    
    public int GetCost()
    {
        // Cost increases per level
        return baseCost * (currentLevel + 1);
    }
    
    public float GetCurrentBonus()
    {
        return effectValue + (effectPerLevel * currentLevel);
    }
    
    public bool CanUpgrade()
    {
        return currentLevel < maxLevel;
    }
}

public enum UpgradeType
{
    MaxShield,
    FireRate,
    PiercingShots
}
```

2. Create 3 upgrade assets:
   - Right-click `Assets/_Project/ScriptableObjects/` → Create folder "Upgrades"
   - Right-click Upgrades → Create → Game → Upgrade
   
   **Energy Shield:**
   - Name: "Upgrade_EnergyShield"
   - Upgrade Name: "Energy Shield"
   - Description: "Increase maximum shield capacity"
   - Base Cost: 100
   - Upgrade Type: MaxShield
   - Effect Value: 25 (% increase)
   - Effect Per Level: 15

   **Rapid Fire:**
   - Name: "Upgrade_RapidFire"
   - Upgrade Name: "Rapid Fire"
   - Description: "Increase fire rate"
   - Base Cost: 150
   - Upgrade Type: FireRate
   - Effect Value: 20 (% increase)
   - Effect Per Level: 10

   **Piercing Rounds:**
   - Name: "Upgrade_PiercingRounds"
   - Upgrade Name: "Piercing Rounds"
   - Description: "Shots penetrate asteroids"
   - Base Cost: 200
   - Upgrade Type: PiercingShots
   - Effect Value: 1 (boolean, just check if owned)
   - Effect Per Level: 1

✅ **Verification:**
- 3 ScriptableObject assets created
- All fields filled in
- Assets in Upgrades folder

---

### 📋 Task 6.2: Create Upgrade Menu UI

🔧 **Steps:**

1. Create Upgrade Canvas:
   - Hierarchy → UI → Canvas
   - Name: "UpgradeCanvas"
   - Same settings as game Canvas

2. Create background panel:
   - Right-click UpgradeCanvas → UI → Panel
   - Name: "UpgradePanel"
   - Color: Dark gray semi-transparent

3. Create Title:
   - Add Text - TextMeshPro: "UPGRADES"
   - Top center, size 64

4. Create Upgrade Button Prefab:
   - Create → UI → Button - TextMeshPro
   - Name: "UpgradeButton"
   - Size: 400x120
   - Contains:
     - Name Text (TMP)
     - Description Text (TMP)
     - Cost Text (TMP)
     - Level Text (TMP)

5. Create UpgradeButton script:
   - `Scripts/UI/UpgradeButton.cs`

```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UpgradeButton : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private TextMeshProUGUI nameText;
    [SerializeField] private TextMeshProUGUI descText;
    [SerializeField] private TextMeshProUGUI costText;
    [SerializeField] private TextMeshProUGUI levelText;
    [SerializeField] private Button button;
    
    private UpgradeData upgradeData;
    private UpgradeManager upgradeManager;
    
    public void Initialize(UpgradeData data, UpgradeManager manager)
    {
        upgradeData = data;
        upgradeManager = manager;
        UpdateDisplay();
    }
    
    public void UpdateDisplay()
    {
        nameText.text = upgradeData.upgradeName;
        descText.text = upgradeData.description;
        costText.text = $"Cost: {upgradeData.GetCost()}";
        levelText.text = $"Level: {upgradeData.currentLevel}/{upgradeData.maxLevel}";
        
        // Check if can afford
        bool canAfford = upgradeManager.CanAfford(upgradeData.GetCost());
        bool canUpgrade = upgradeData.CanUpgrade();
        button.interactable = canAfford && canUpgrade;
    }
    
    public void OnPurchaseClicked()
    {
        upgradeManager.PurchaseUpgrade(upgradeData);
    }
}
```

6. Create 3 instances in Upgrade Panel:
   - Duplicate UpgradeButton 3 times
   - Arrange vertically
   - Attach UpgradeButton script to each

---

### 📋 Task 6.3: Create Upgrade Manager

🔧 **Steps:**

1. Create UpgradeManager script:
   - `Scripts/Managers/UpgradeManager.cs`

```csharp
using UnityEngine;
using System.Collections.Generic;

public class UpgradeManager : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private List<UpgradeData> availableUpgrades;
    [SerializeField] private int currentCredits = 0;
    
    [Header("UI")]
    [SerializeField] private List<UpgradeButton> upgradeButtons;
    [SerializeField] private GameObject upgradeCanvas;
    
    private void Start()
    {
        // Hide upgrade menu initially
        upgradeCanvas.SetActive(false);
        
        // Initialize buttons
        for (int i = 0; i < upgradeButtons.Count && i < availableUpgrades.Count; i++)
        {
            upgradeButtons[i].Initialize(availableUpgrades[i], this);
        }
    }
    
    public void ShowUpgradeMenu(int creditsEarned)
    {
        currentCredits = creditsEarned;
        upgradeCanvas.SetActive(true);
        UpdateAllButtons();
    }
    
    public void HideUpgradeMenu()
    {
        upgradeCanvas.SetActive(false);
    }
    
    public bool CanAfford(int cost)
    {
        return currentCredits >= cost;
    }
    
    public void PurchaseUpgrade(UpgradeData upgrade)
    {
        if (!CanAfford(upgrade.GetCost())) return;
        if (!upgrade.CanUpgrade()) return;
        
        currentCredits -= upgrade.GetCost();
        upgrade.currentLevel++;
        
        ApplyUpgrade(upgrade);
        UpdateAllButtons();
    }
    
    private void ApplyUpgrade(UpgradeData upgrade)
    {
        // Apply effects to player
        // (Will implement in next section)
        Debug.Log($"Purchased {upgrade.upgradeName} Level {upgrade.currentLevel}");
    }
    
    private void UpdateAllButtons()
    {
        foreach (var button in upgradeButtons)
        {
            button.UpdateDisplay();
        }
    }
    
    public void OnContinueClicked()
    {
        HideUpgradeMenu();
        GameManager.Instance.RestartGame();
    }
}
```

2. Add Continue button to Upgrade Panel

3. Wire everything up:
   - Create UpgradeManager GameObject under MANAGERS
   - Add UpgradeManager script
   - Drag 3 upgrade SOs to Available Upgrades
   - Drag 3 upgrade buttons to Upgrade Buttons
   - Drag UpgradeCanvas to Upgrade Canvas

---

### 📋 Task 6.4: Integrate Credits and Upgrades

🔧 **Steps:**

1. Update GameManager to calculate credits:

```csharp
// Add to GameManager.cs
private int creditsEarned = 0;

public void AddScore(int points)
{
    currentScore += points;
    creditsEarned += Mathf.RoundToInt(points * 0.1f); // 10% of score = credits
}

public void GameOver()
{
    if (isGameOver) return;
    isGameOver = true;
    
    // Calculate final credits
    int timeBonus = Mathf.RoundToInt(survivalTime);
    creditsEarned += timeBonus;
    
    // Stop spawning
    SpawnManager spawner = FindObjectOfType<SpawnManager>();
    if (spawner != null)
        spawner.enabled = false;
    
    // Show upgrade menu instead of game over
    UpgradeManager upgradeManager = FindObjectOfType<UpgradeManager>();
    if (upgradeManager != null)
        upgradeManager.ShowUpgradeMenu(creditsEarned);
}
```

2. Apply upgrades to player:
   - Update PlayerShip components to accept upgrades

```csharp
// Add to ShipShield.cs
public void ApplyMaxShieldUpgrade(float percentIncrease)
{
    maxShield = 100f * (1f + percentIncrease / 100f);
    currentShield = maxShield; // Heal to full
}

// Add to ShipWeapon.cs
public void ApplyFireRateUpgrade(float percentIncrease)
{
    fireRate = 0.5f / (1f + percentIncrease / 100f);
}

public void EnablePiercing()
{
    // Set flag for piercing shots
}
```

3. Update UpgradeManager.ApplyUpgrade():

```csharp
private void ApplyUpgrade(UpgradeData upgrade)
{
    // These will persist to next game via ScriptableObject
    Debug.Log($"Purchased {upgrade.upgradeName} Level {upgrade.currentLevel}");
}
```

✅ **Verification:**
- Press Play
- Earn score by destroying asteroids
- Die
- Upgrade menu appears with credits
- Can purchase upgrades
- Credits decrease
- Continue restarts game

**🎯 Day 12-14 Milestone Achieved: Working upgrade loop between runs**

---

**COMMIT YOUR WORK:**
```bash
git add .
git commit -m "Week 2 complete: Core loop functional with shield, upgrades, and progression"
git push
```

---

# Week 3 & 4 Implementation

*Due to length constraints, I'll provide a condensed version. Follow the same pattern:*

## Week 3: Content Expansion

### Day 15-16: Add UFO Enemy
- Create UFO prefab (red square)
- Add chase behavior script
- Add shooting mechanic
- Spawn based on difficulty

### Day 17-18: Pickups
- Create Crystal prefab
- Drop from destroyed objects
- Auto-collect system
- Create Speed Boost pickup

### Day 19-21: Dynamic Difficulty
- Track player shield %
- Adjust spawn rates dynamically
- Smooth transitions

## Week 4: Polish

### Day 22-23: Visual Effects
- Particle explosions
- Screen shake script
- Glow materials

### Day 24-25: Audio
- Find free SFX
- AudioManager script
- Play sounds on events

### Day 26-30: Test & Build
- Playtesting
- Bug fixes
- Balancing
- Build for PC/Android

---

## Daily Workflow Tips

**Each Day:**
1. ✅ Check off completed tasks
2. 🧪 Test thoroughly after each feature
3. 💾 Commit working code
4. 📝 Document issues/ideas

**Stay Focused:**
- Don't add features not in plan
- If stuck >30min, move on and come back
- Test often, even incomplete features
- Celebrate small wins!

---

## Troubleshooting Common Issues

**Movement feels floaty:**
- Increase Rigidbody2D Linear Drag

**Projectiles miss asteroids:**
- Check collision layers
- Enable Continuous collision detection

**UI not showing:**
- Check Canvas render mode
- Verify EventSystem exists

**Performance issues:**
- Limit objects on screen
- Use object pooling
- Profile with Unity Profiler

---

## Success! 🎉

By following these steps daily, you'll have a working prototype in 4 weeks. Remember:

- **Focus on fun first**
- **Iterate based on feel**
- **Test constantly**
- **Commit often**

Good luck building Void Survivor!
