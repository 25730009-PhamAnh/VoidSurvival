# Module 07: Black Hole Hazard System - Implementation Plan

**Status**: Ready for Implementation
**Priority**: Medium
**Dependencies**: None (uses existing component architecture)
**Estimated Duration**: 3-4 days

---

## Overview

Implement a dynamic black hole hazard system that applies gravitational forces to all objects in the game world (player, asteroids, enemies, projectiles). Black holes spawn periodically, pull objects toward their center, and **destroy everything that reaches the center** (including the player). Black holes can be "overloaded" and destroyed by consuming enough mass.

---

## Architecture Integration

### Core Systems Used
- **GameManager**: Spawn timing and game state coordination
- **SessionManager**: Track black hole-related stats (optional)
- **Component System**: New `GravitationalComponent` follows existing component patterns
- **Signal System**: Event-driven communication for black hole lifecycle

### New Components
1. **GravitationalComponent** (`scripts/components/gravitational_component.gd`)
2. **BlackHole** scene + script (`scenes/gameplay/hazards/black_hole.tscn`)
3. **BlackHoleSpawner** (`scripts/gameplay/spawners/black_hole_spawner.gd`)

---

## Implementation Steps

### Step 1: Gravitational Component (Reusable Physics Component)

**File**: `Src/void-survival/scripts/components/gravitational_component.gd`

**Purpose**: Apply gravitational force toward a center point to any physics body in range.

**Implementation Details**:

```gdscript
class_name GravitationalComponent
extends Area2D

## Reusable component for applying gravitational force to nearby objects

signal object_captured(body: Node2D)
signal mass_absorbed(amount: float)

@export var pull_strength: float = 10000.0
@export var detection_radius: float = 300.0
@export var capture_radius: float = 20.0  # INSTANT DEATH ZONE - Everything destroyed (including player)
@export var max_pull_distance: float = 500.0  # Beyond this, no pull
@export var affects_projectiles: bool = true
@export var affects_player: bool = true
@export var affects_asteroids: bool = true
@export var affects_enemies: bool = true

var _detected_bodies: Array[Node2D] = []

func _ready() -> void:
    # Set up Area2D for detection
    monitoring = true
    monitorable = false

    # Create collision shape
    var shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = detection_radius
    shape.shape = circle
    add_child(shape)

    # Connect signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    # Set up collision layers/masks
    collision_layer = 0  # Black hole doesn't collide
    collision_mask = 0b1111  # Detect all layers (player, asteroids, projectiles, enemies)

func _physics_process(delta: float) -> void:
    _apply_gravitational_forces(delta)

func _apply_gravitational_forces(delta: float) -> void:
    for body in _detected_bodies:
        if not is_instance_valid(body):
            continue

        # Filter by type
        if not _should_affect_body(body):
            continue

        var direction = global_position - body.global_position
        var distance = direction.length()

        # Check if object should be captured
        if distance < capture_radius:
            _capture_object(body)
            continue

        # Apply inverse square law: F = strength / distance^2
        # Clamp to avoid extreme forces at very close distances
        var safe_distance = max(distance, 50.0)
        var force_magnitude = pull_strength / (safe_distance * safe_distance)

        # Apply force based on body type
        if body is RigidBody2D:
            body.apply_central_force(direction.normalized() * force_magnitude)
        elif body is CharacterBody2D:
            # For CharacterBody2D (player), apply as velocity modification
            if body.has_method("apply_external_force"):
                body.apply_external_force(direction.normalized() * force_magnitude * delta)
            else:
                # Fallback: directly modify velocity
                body.velocity += direction.normalized() * force_magnitude * delta * 0.01

func _should_affect_body(body: Node2D) -> bool:
    if body.is_in_group("player"):
        return affects_player
    elif body.is_in_group("asteroid") or body.is_in_group("enemy"):
        return affects_asteroids or affects_enemies
    elif body.is_in_group("projectile"):
        return affects_projectiles
    return true

func _capture_object(body: Node2D) -> void:
    object_captured.emit(body)

    # Calculate mass absorbed (approximate based on body type)
    var mass: float = 1.0
    if body.is_in_group("asteroid"):
        mass = 10.0
    elif body.is_in_group("enemy"):
        mass = 15.0
    elif body.is_in_group("player"):
        mass = 20.0

    mass_absorbed.emit(mass)

    # EVERYTHING at the center is destroyed - no exceptions
    if body.is_in_group("player"):
        # Player dies instantly when captured by black hole
        if body.has_node("HealthComponent"):
            # Deal massive damage to trigger instant death
            body.get_node("HealthComponent").take_damage(999999.0)
        else:
            # Fallback: call died signal directly if available
            if body.has_signal("died"):
                body.emit_signal("died")
    else:
        # All other objects are destroyed immediately
        body.queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body is RigidBody2D or body is CharacterBody2D:
        _detected_bodies.append(body)

func _on_body_exited(body: Node2D) -> void:
    _detected_bodies.erase(body)

func set_pull_strength(strength: float) -> void:
    pull_strength = strength

func set_detection_radius(radius: float) -> void:
    detection_radius = radius
    # Update collision shape if already created
    if get_child_count() > 0:
        var shape = get_child(0) as CollisionShape2D
        if shape and shape.shape is CircleShape2D:
            shape.shape.radius = radius
```

**Key Features**:
- Inverse square law physics (realistic gravitational falloff)
- Configurable for different body types (player, asteroids, enemies, projectiles)
- **Instant destruction at center** - everything within capture radius is destroyed (no exceptions)
- Player dies instantly if pulled into the center
- Emits signals for mass absorption (used by overload mechanic)

**Testing Checkpoint**:
- [ ] Component applies force to RigidBody2D objects
- [ ] Force strength follows inverse square law
- [ ] Objects within capture radius are destroyed immediately
- [ ] **Player dies instantly when captured** (triggers game over)
- [ ] Can be toggled for different body types via exports

---

### Step 2: Black Hole Scene & Script

**File**: `Src/void-survival/scenes/gameplay/hazards/black_hole.tscn`
**Script**: `Src/void-survival/scenes/gameplay/hazards/black_hole.gd`

**Scene Structure**:
```
BlackHole (Node2D)
├── Sprite2D (visual - black circle with gradient)
├── GravitationalComponent
├── GPUParticles2D (swirling matter effect)
├── AnimationPlayer (pulsing animation)
└── LifetimeTimer (Timer)
```

**Script Implementation**:

```gdscript
class_name BlackHole
extends Node2D

## Black hole hazard with gravitational pull and overload mechanic

signal destroyed
signal overloaded

@export var lifetime: float = 60.0  # Seconds before auto-destruction
@export var overload_threshold: float = 100.0  # Mass required to overload
@export var initial_pull_strength: float = 10000.0
@export var pull_strength_growth: float = 500.0  # Increases as it absorbs mass

@onready var gravitational_component: GravitationalComponent = $GravitationalComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lifetime_timer: Timer = $LifetimeTimer

var _absorbed_mass: float = 0.0
var _is_overloaded: bool = false

func _ready() -> void:
    # Initialize gravitational component
    gravitational_component.pull_strength = initial_pull_strength
    gravitational_component.mass_absorbed.connect(_on_mass_absorbed)

    # Set up lifetime timer
    lifetime_timer.wait_time = lifetime
    lifetime_timer.one_shot = true
    lifetime_timer.timeout.connect(_on_lifetime_expired)
    lifetime_timer.start()

    # Start pulsing animation
    if animation_player and animation_player.has_animation("pulse"):
        animation_player.play("pulse")

func _process(delta: float) -> void:
    # Visual feedback for absorbed mass (scale grows)
    var mass_scale = 1.0 + (_absorbed_mass / overload_threshold) * 0.5
    sprite.scale = Vector2.ONE * mass_scale

    # Increase particle emission as mass grows
    if particles:
        particles.amount = int(20 + (_absorbed_mass / overload_threshold) * 30)

func _on_mass_absorbed(mass: float) -> void:
    _absorbed_mass += mass

    # Increase pull strength as mass is absorbed
    gravitational_component.pull_strength += pull_strength_growth

    # Check for overload
    if _absorbed_mass >= overload_threshold and not _is_overloaded:
        _trigger_overload()

func _trigger_overload() -> void:
    _is_overloaded = true
    overloaded.emit()

    # Play explosion animation (TODO: add VFX)
    # Award player for overloading (optional)
    if has_node("/root/SessionManager"):
        get_node("/root/SessionManager").add_score(500)

    # Destroy after brief delay
    await get_tree().create_timer(0.5).timeout
    _destroy()

func _on_lifetime_expired() -> void:
    # Natural expiration (no overload)
    _destroy()

func _destroy() -> void:
    destroyed.emit()
    queue_free()

func initialize(spawn_position: Vector2) -> void:
    global_position = spawn_position
```

**Visual Assets Needed** (placeholder for now):
- Sprite2D: Black circle with purple/blue gradient (128x128px)
- Particles: Small white/blue dots swirling inward

**Testing Checkpoint**:
- [ ] Black hole spawns at specified position
- [ ] Gravitational pull affects nearby objects
- [ ] Mass absorption increases pull strength and visual scale
- [ ] Overload mechanic triggers at threshold
- [ ] Auto-destructs after lifetime expires

---

### Step 3: Black Hole Spawner

**File**: `Src/void-survival/scripts/gameplay/spawners/black_hole_spawner.gd`

**Implementation**:

```gdscript
class_name BlackHoleSpawner
extends Node

## Manages black hole spawning based on difficulty and time

@export var black_hole_scene: PackedScene
@export var min_spawn_interval: float = 45.0
@export var max_spawn_interval: float = 90.0
@export var max_active_black_holes: int = 1  # Only 1 at a time initially
@export var late_game_max: int = 2  # Increase to 2 after 300 seconds
@export var late_game_threshold: float = 300.0  # 5 minutes
@export var safe_zone_radius: float = 150.0  # Don't spawn near player

var _spawn_timer: Timer
var _active_black_holes: Array[BlackHole] = []

func _ready() -> void:
    # Create spawn timer
    _spawn_timer = Timer.new()
    add_child(_spawn_timer)
    _spawn_timer.one_shot = false
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)

    # Start spawning
    _schedule_next_spawn()

func _on_spawn_timer_timeout() -> void:
    _try_spawn_black_hole()
    _schedule_next_spawn()

func _try_spawn_black_hole() -> void:
    # Check max active limit
    _clean_destroyed_black_holes()

    var max_allowed = max_active_black_holes
    if has_node("/root/GameManager"):
        var survival_time = get_node("/root/GameManager").survival_time
        if survival_time > late_game_threshold:
            max_allowed = late_game_max

    if _active_black_holes.size() >= max_allowed:
        return

    # Find safe spawn position (away from player)
    var spawn_pos = _get_safe_spawn_position()
    if spawn_pos == Vector2.ZERO:
        return  # No safe position found

    # Spawn black hole
    var black_hole = black_hole_scene.instantiate() as BlackHole
    get_tree().current_scene.add_child(black_hole)
    black_hole.initialize(spawn_pos)
    black_hole.destroyed.connect(_on_black_hole_destroyed.bind(black_hole))

    _active_black_holes.append(black_hole)

func _get_safe_spawn_position() -> Vector2:
    var screen_size = get_viewport_rect().size
    var player = get_tree().get_first_node_in_group("player")

    # Try up to 10 times to find a safe position
    for i in range(10):
        var pos = Vector2(
            randf_range(100, screen_size.x - 100),
            randf_range(100, screen_size.y - 100)
        )

        # Check distance from player
        if player:
            var distance_to_player = pos.distance_to(player.global_position)
            if distance_to_player < safe_zone_radius:
                continue

        return pos

    return Vector2.ZERO  # Failed to find safe position

func _schedule_next_spawn() -> void:
    var interval = randf_range(min_spawn_interval, max_spawn_interval)

    # Reduce interval based on difficulty (if GameManager exists)
    if has_node("/root/GameManager"):
        var survival_time = get_node("/root/GameManager").survival_time
        var difficulty_modifier = 1.0 - min(survival_time / 600.0, 0.4)  # Up to 40% reduction
        interval *= difficulty_modifier

    _spawn_timer.wait_time = max(interval, 20.0)  # Minimum 20 seconds
    _spawn_timer.start()

func _on_black_hole_destroyed(black_hole: BlackHole) -> void:
    _active_black_holes.erase(black_hole)

func _clean_destroyed_black_holes() -> void:
    _active_black_holes = _active_black_holes.filter(func(bh): return is_instance_valid(bh))

func stop_spawning() -> void:
    _spawn_timer.stop()

func resume_spawning() -> void:
    _schedule_next_spawn()
```

**Testing Checkpoint**:
- [ ] Black holes spawn at configured intervals
- [ ] Never spawn within safe zone radius of player
- [ ] Respects max active limit (1, then 2 late game)
- [ ] Spawn rate increases with difficulty/time
- [ ] Stops spawning on game over

---

### Step 4: Player Integration (External Force Application)

**Modification**: `Src/void-survival/scenes/prototype/player.gd`

**Add method to handle external forces from black holes**:

```gdscript
# Add this to player.gd

## Called by external systems (like GravitationalComponent) to apply forces
func apply_external_force(force: Vector2) -> void:
    # Apply force as velocity modification
    # This allows player to still control ship, but gravitational pull influences movement
    velocity += force
```

**Rationale**: CharacterBody2D doesn't have `apply_force()` like RigidBody2D, so we need a custom method.

**Testing Checkpoint**:
- [ ] Player is pulled toward black hole
- [ ] Player can still thrust away with enough power (before reaching capture radius)
- [ ] **Player dies instantly when captured by black hole center**

---

### Step 5: Integration with GameManager

**Modification**: `Src/void-survival/scenes/prototype/game.gd` (or wherever GameManager logic lives)

**Add BlackHoleSpawner to game scene**:

1. Open `game.tscn` in the editor
2. Add a new `Node` child named "BlackHoleSpawner"
3. Attach `black_hole_spawner.gd` script
4. Configure exports:
   - `black_hole_scene`: Assign `res://scenes/gameplay/hazards/black_hole.tscn`
   - `min_spawn_interval`: 45.0
   - `max_spawn_interval`: 90.0

**OR** instantiate programmatically in `game.gd`:

```gdscript
# In game.gd _ready()
var black_hole_spawner = BlackHoleSpawner.new()
black_hole_spawner.black_hole_scene = preload("res://scenes/gameplay/hazards/black_hole.tscn")
add_child(black_hole_spawner)
```

**Testing Checkpoint**:
- [ ] Black holes spawn during gameplay
- [ ] Black holes stop spawning on game over
- [ ] No errors in console during spawn/despawn

---

### Step 6: Visual Effects (Basic Implementation)

**Sprite Creation**:
1. Create a simple black hole sprite (128x128px):
   - Radial gradient: black center → purple → dark blue outer edge
   - Place in `Src/void-survival/assets/sprites/black_hole.png`

**Particle System**:
1. In `black_hole.tscn`, configure `GPUParticles2D`:
   - **Process Material**: New `ParticleProcessMaterial`
   - **Emission Shape**: Ring (radius ~100)
   - **Direction**: Toward center (requires custom shader or radial velocity)
   - **Lifetime**: 1.5 seconds
   - **Amount**: 30
   - **Color**: White → light blue gradient
   - **Scale**: 2.0 → 0.5 (shrink as particles approach center)

**Animation**:
1. Create `AnimationPlayer` animation named "pulse":
   - Animate `Sprite2D.scale` from 1.0 to 1.15 and back over 2 seconds
   - Loop enabled

**Advanced (Optional - Shader Distortion)**:
- Create distortion shader in `Src/void-survival/shaders/distortion.gdshader`
- Apply as CanvasItem shader on Sprite2D
- Warps space around black hole (low priority, can be added in Module 10)

**Testing Checkpoint**:
- [ ] Black hole has visible sprite
- [ ] Particles swirl toward center
- [ ] Pulsing animation plays smoothly
- [ ] Visuals scale with absorbed mass

---

### Step 7: Signal Flow Integration

**Signal Connections**:

```
BlackHole.mass_absorbed
→ Updates internal mass counter
→ Increases pull strength
→ Scales visual size

BlackHole.overloaded
→ Awards bonus score (500 points)
→ Triggers destruction VFX
→ Emits destroyed signal

BlackHole.destroyed
→ BlackHoleSpawner removes from active list
→ Cleans up scene

GravitationalComponent.object_captured
→ Destroys asteroid/enemy immediately
→ **Kills player instantly** (if player captured) - triggers game over
→ Emits mass_absorbed to parent BlackHole
```

**Testing Checkpoint**:
- [ ] All signals fire correctly
- [ ] No orphaned signal connections (memory leaks)
- [ ] Score updates when black hole overloads

---

## Testing Strategy

### Unit Tests
1. **GravitationalComponent**:
   - Force calculation follows inverse square law
   - Capture radius detection works
   - Body type filtering works correctly

2. **BlackHole**:
   - Mass accumulation triggers overload at threshold
   - Lifetime timer destroys black hole after duration
   - Pull strength increases with absorbed mass

3. **BlackHoleSpawner**:
   - Respects max active limit
   - Safe zone prevents spawning near player
   - Spawn interval scales with difficulty

### Integration Tests
1. **Player vs Black Hole**:
   - Player is pulled toward black hole
   - Player can escape with thrust (before reaching capture radius)
   - **Player dies instantly when captured** (triggers game over)
   - Player can destroy black hole via overload (by luring asteroids into it)

2. **Asteroids vs Black Hole**:
   - Asteroids are pulled and captured
   - Captured asteroids count toward overload meter
   - Multiple asteroids can overload black hole

3. **Enemies vs Black Hole**:
   - UFOs and Comets are affected by gravity
   - Enemies captured contribute to overload

4. **Projectiles vs Black Hole**:
   - Projectiles can be bent by gravity (if enabled)
   - Captured projectiles don't contribute much mass

### Performance Tests
1. **Physics Load**:
   - Monitor FPS with 1 black hole + 20 asteroids + 3 enemies
   - Monitor FPS with 2 black holes active simultaneously
   - Ensure no lag spikes during force calculations

2. **Memory**:
   - No memory leaks from signal connections
   - Black holes properly clean up when destroyed

---

## Success Criteria

### Functional Requirements
- ✅ Black holes spawn every 45-90 seconds (scales with difficulty)
- ✅ Gravitational pull affects player, asteroids, enemies, projectiles
- ✅ **Everything at the center is destroyed instantly** (including player)
- ✅ Player dies immediately when captured (triggers game over)
- ✅ Overload mechanic works (100 mass threshold)
- ✅ Player can escape with sufficient thrust (before reaching capture radius)
- ✅ Visual effects show gravity field and mass absorption
- ✅ Only 1 black hole active early game, 2 in late game

### Performance Requirements
- ✅ Maintains 60 FPS on target hardware with 2 black holes active
- ✅ No physics glitches or instability with high forces
- ✅ No memory leaks from spawning/destroying black holes

### User Experience
- ✅ Black hole is visually distinct and threatening
- ✅ Gravitational pull is noticeable but player can escape with thrust
- ✅ **Reaching the center means instant death** - creates high-stakes gameplay
- ✅ Overload mechanic is satisfying (visual + score reward)
- ✅ Adds strategic depth (risk vs reward of staying near black hole)

---

## Extensibility Hooks (Future Modules)

### Module 10: VFX & Polish
- Enhanced distortion shader around black hole
- Improved particle effects (swirling debris)
- Screen shake when black hole overloads
- Audio: ambient hum, overload explosion

### Potential Future Features (Post-Module 12)
- **Different Black Hole Types**:
  - Pulsing black holes (pull strength oscillates)
  - Moving black holes (drift across screen)
  - Paired wormholes (teleportation)
- **White Holes** (repulsion instead of attraction)
- **Black Hole Items**:
  - "Gravity Dampener" item (reduces pull strength by X%)
  - "Event Horizon Escape" item (teleport away when captured)

---

## Implementation Checklist

### Phase 1: Core Components (Day 1)
- [ ] Create `GravitationalComponent` script
- [ ] Test gravitational force on asteroids
- [ ] Verify inverse square law physics
- [ ] Test capture radius mechanic

### Phase 2: Black Hole Entity (Day 2)
- [ ] Create `black_hole.tscn` scene
- [ ] Create `black_hole.gd` script
- [ ] Implement mass absorption system
- [ ] Implement overload mechanic
- [ ] Add lifetime timer
- [ ] Create placeholder sprite

### Phase 3: Spawning System (Day 2)
- [ ] Create `BlackHoleSpawner` script
- [ ] Integrate with GameManager
- [ ] Test safe zone spawning
- [ ] Test max active limit
- [ ] Test late-game scaling (2 black holes)

### Phase 4: Player Integration (Day 3)
- [ ] Add `apply_external_force()` to player
- [ ] Test player gravitational pull
- [ ] Test player escape mechanics
- [ ] Test player damage when captured

### Phase 5: Visual Effects (Day 3)
- [ ] Create black hole sprite
- [ ] Set up particle system
- [ ] Create pulsing animation
- [ ] Test visual scaling with mass

### Phase 6: Polish & Testing (Day 4)
- [ ] Full gameplay test (10 minute run)
- [ ] Performance profiling
- [ ] Balance tuning (pull strength, spawn rate)
- [ ] Bug fixes
- [ ] Documentation update

---

## Files to Create

1. `Src/void-survival/scripts/components/gravitational_component.gd`
2. `Src/void-survival/scenes/gameplay/hazards/black_hole.tscn`
3. `Src/void-survival/scenes/gameplay/hazards/black_hole.gd`
4. `Src/void-survival/scripts/gameplay/spawners/black_hole_spawner.gd`
5. `Src/void-survival/assets/sprites/black_hole.png` (placeholder)

## Files to Modify

1. `Src/void-survival/scenes/prototype/player.gd` (add `apply_external_force()`)
2. `Src/void-survival/scenes/prototype/game.tscn` (add BlackHoleSpawner node)

---

## Risk Mitigation

### Risk: Physics instability with high forces
- **Mitigation**: Clamp force values, use safe distance in calculations, test with extreme scenarios

### Risk: Performance degradation with multiple black holes
- **Mitigation**: Start with max 1 black hole, profile before increasing to 2, optimize detection radius

### Risk: Black holes making game too difficult
- **Mitigation**: Extensive playtesting, tunable exports for all parameters, player can destroy via overload

### Risk: Complex integration with existing systems
- **Mitigation**: Use component pattern (matches existing architecture), signal-based decoupling, minimal changes to existing code

---

## Post-Implementation

### Archive This Plan
- Move to `Documents/archive/plans/` when complete
- Update `Documents/Development_Plan_Overview.md` status
- Create completion summary with lessons learned

### Next Module
- **Module 8**: Dynamic Difficulty System (builds on black hole spawning mechanics)

---

**End of Implementation Plan**
