# Void Survivor - Minimal Prototype Plan (Godot 4)

## ✅ PROTOTYPE COMPLETED!

**Status**: All core systems implemented and playable
**Completion Date**: January 2026
**Result**: Core gameplay loop validated - ready for next iteration

## Prototype Goal

**Primary Objective**: Create a playable core loop to validate the game feel ✅ **ACHIEVED**
**Timeline**: 1-2 days
**Scope**: Minimal viable gameplay - no progression, no polish, just mechanics

---

## What We're Building

A single playable scene where:
- Player controls a ship with inertia-based movement
- Ship shoots projectiles to destroy asteroids
- Asteroids split into smaller pieces when hit
- Player has a shield that depletes on collision
- Game ends when shield reaches zero
- Simple score tracking

**NOT in Prototype**:
- ❌ Upgrade system
- ❌ Enemy UFOs/Comets
- ❌ Black holes
- ❌ Persistent progression
- ❌ Multiple game modes
- ❌ Polished UI
- ❌ Dynamic difficulty
- ❌ VFX/particles
- ❌ Sound/music

**BONUS FEATURES ADDED** (not originally planned):
- ✅ **Invincibility Timer**: 1 second of invincibility after taking damage
- ✅ **Knockback System**: Player bounces back when hitting asteroids

---

## Core Mechanics to Implement

### 1. Player Ship
**Features**:
- Inertia-based movement (thrust forward/backward)
- Rotation (left/right)
- Screen wrap-around
- Basic collision detection
- Shield with health bar

**Controls** (Input Map):
- `W` / `thrust_forward` - Thrust forward
- `A` / `rotate_left` - Rotate left
- `D` / `rotate_right` - Rotate right
- `Space` / `fire` - Shoot
- `R` / `restart` - Restart game

### 2. Shooting System
**Features**:
- Fire projectiles in facing direction
- Fixed fire rate (2 shots/second)
- Projectiles destroy on hit or off-screen
- Simple collision detection

### 3. Asteroids
**Features**:
- 3 sizes: Large → Medium → Small
- Random initial velocity
- Rotate slowly
- Split into 2-3 smaller asteroids when destroyed
- Small asteroids disappear when destroyed
- Each size has different health (Large: 30, Medium: 15, Small: 5)

### 4. Shield System
**Features**:
- Start with 100 shield
- Lose shield on asteroid collision (damage: Large -40, Medium -20, Small -10)
- NO regeneration in prototype (keep it simple)
- Game over when shield = 0

### 5. Spawning
**Features**:
- Spawn 1 large asteroid every 3 seconds
- Spawn at random screen edge
- Random initial direction toward screen center (with variance)
- Max 15 asteroids on screen at once

### 6. Basic HUD
**Features**:
- Shield bar (top-left)
- Score counter (top-right)
- "Game Over" text on death
- "Press R to Restart" message

### 7. Score System
**Simple scoring**:
- Large asteroid destroyed: +100
- Medium asteroid destroyed: +50
- Small asteroid destroyed: +25

---

## Implementation Checklist

### Phase 1: Project Setup (30 min) ✅ COMPLETE
- [x] Create Godot 4 project named "Void Survival"
- [x] Set up project structure:
  ```
  Src/
  ├── scenes/
  │   ├── prototype/
  │   │   ├── game.tscn          # Main game scene
  │   │   ├── player.tscn        # Player ship
  │   │   ├── projectile.tscn    # Bullet
  │   │   └── asteroid.tscn      # Asteroid (3 sizes)
  │   └── ui/
  │       └── prototype_hud.tscn # Simple HUD
  └── scripts/
      ├── player.gd
      ├── projectile.gd
      ├── asteroid.gd
      ├── spawner.gd
      ├── game_manager.gd
      └── prototype_hud.gd
  ```
- [x] Configure Input Map (Project Settings → Input Map):
  - `thrust_forward` → W
  - `rotate_left` → A
  - `rotate_right` → D
  - `fire` → Space
  - `restart` → R
- [x] Set project settings:
  - Window size: 1280x720
  - Stretch mode: viewport
  - Physics: Zero gravity, no damping
- [x] Configure physics layers:
  - Layer 1: Player
  - Layer 2: Asteroids
  - Layer 4: Projectiles

### Phase 2: Player Ship (1 hour) ✅ COMPLETE

**Scene Structure**: `Src/scenes/prototype/player.tscn`
```
Player (CharacterBody2D)
├── Sprite2D (white triangle)
│   └── Polygon2D (triangle points: [0,-20], [-15,15], [15,15])
├── CollisionPolygon2D (same triangle points)
└── ShootPoint (Marker2D at [0, -25] for projectile spawn)
```

**Script**: `Src/scripts/prototype/player.gd`
```gdscript
class_name Player
extends CharacterBody2D

signal died
signal shield_changed(current: float, maximum: float)

const ACCELERATION = 200.0
const MAX_SPEED = 300.0
const ROTATION_SPEED = 3.0
const FIRE_RATE = 0.5  # seconds between shots

@export var projectile_scene: PackedScene
@export var max_shield: float = 100.0

var current_shield: float
var _fire_timer: float = 0.0

@onready var shoot_point: Marker2D = $ShootPoint

func _ready() -> void:
	current_shield = max_shield
	shield_changed.emit(current_shield, max_shield)

func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_update_movement(delta)
	_wrap_around_screen()

func _handle_input(delta: float) -> void:
	# Rotation
	var rotation_input = Input.get_axis("rotate_left", "rotate_right")
	rotation += rotation_input * ROTATION_SPEED * delta

	# Thrust
	if Input.is_action_pressed("thrust_forward"):
		var direction = Vector2.UP.rotated(rotation)
		velocity += direction * ACCELERATION * delta
		velocity = velocity.limit_length(MAX_SPEED)

	# Shooting
	if _fire_timer > 0:
		_fire_timer -= delta

	if Input.is_action_pressed("fire") and _fire_timer <= 0:
		_fire()

func _update_movement(_delta: float) -> void:
	move_and_slide()

func _fire() -> void:
	_fire_timer = FIRE_RATE

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.global_rotation = global_rotation
	get_parent().add_child(projectile)

func _wrap_around_screen() -> void:
	var screen_size = get_viewport_rect().size
	var pos = global_position

	if pos.x < 0:
		pos.x = screen_size.x
	elif pos.x > screen_size.x:
		pos.x = 0

	if pos.y < 0:
		pos.y = screen_size.y
	elif pos.y > screen_size.y:
		pos.y = 0

	global_position = pos

func take_damage(amount: float) -> void:
	current_shield -= amount
	shield_changed.emit(current_shield, max_shield)

	if current_shield <= 0:
		died.emit()
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("asteroid"):
		var asteroid = body as Asteroid
		if asteroid:
			take_damage(asteroid.collision_damage)
```

**Physics Settings**:
- Motion Mode: Floating
- Collision Layer: 1 (player)
- Collision Mask: 2 (asteroids)

**Add player to group "player"** in the Node tab

**✅ Implementation Status**:
- Core movement: ✅ Implemented
- Shooting system: ✅ Implemented
- Shield system: ✅ Implemented
- **BONUS**: Invincibility timer added (1 second after damage)
- **BONUS**: Knockback/bounce on asteroid collision added

---

### Phase 3: Projectile System (45 min) ✅ COMPLETE

**Scene Structure**: `Src/scenes/prototype/projectile.tscn`
```
Projectile (Area2D)
├── Sprite2D (small white rectangle 4x10)
│   └── ColorRect (white, 4x10 pixels)
├── CollisionShape2D (RectangleShape2D 4x10)
└── VisibleOnScreenNotifier2D
```

**Script**: `Src/scripts/prototype/projectile.gd`
```gdscript
class_name Projectile
extends Area2D

const SPEED = 400.0
const DAMAGE = 10.0

var velocity: Vector2

func _ready() -> void:
	velocity = Vector2.UP.rotated(global_rotation) * SPEED
	area_entered.connect(_on_area_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("asteroid"):
		var asteroid = area as Asteroid
		if asteroid:
			asteroid.take_damage(DAMAGE)
			queue_free()

func _on_screen_exited() -> void:
	queue_free()
```

**Settings**:
- Collision Layer: 4 (projectiles)
- Collision Mask: 2 (asteroids)

**✅ Implementation Status**: Fully implemented with auto-destroy on screen exit

---

### Phase 4: Asteroid System (1.5 hours) ✅ COMPLETE

**Scene Structure**: `Src/scenes/prototype/asteroid.tscn`
```
Asteroid (RigidBody2D)
├── Polygon2D (gray irregular polygon)
├── CollisionPolygon2D (same points)
└── VisibleOnScreenNotifier2D
```

**Script**: `Src/scripts/prototype/asteroid.gd`
```gdscript
class_name Asteroid
extends RigidBody2D

signal destroyed(score_value: int)

enum Size {LARGE, MEDIUM, SMALL}

@export var size: Size = Size.LARGE

var health: float
var collision_damage: float
var score_value: int
var rotation_speed: float

func _ready() -> void:
	add_to_group("asteroid")
	_setup_size()
	rotation_speed = randf_range(-1.0, 1.0)
	body_entered.connect(_on_body_entered)

func _setup_size() -> void:
	match size:
		Size.LARGE:
			health = 30.0
			collision_damage = 40.0
			score_value = 100
			scale = Vector2.ONE * 1.0
		Size.MEDIUM:
			health = 15.0
			collision_damage = 20.0
			score_value = 50
			scale = Vector2.ONE * 0.6
		Size.SMALL:
			health = 5.0
			collision_damage = 10.0
			score_value = 25
			scale = Vector2.ONE * 0.35

func _physics_process(delta: float) -> void:
	rotate(rotation_speed * delta)
	_wrap_around_screen()

func _wrap_around_screen() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var pos = global_position

	if pos.x < -50:
		pos.x = screen_size.x + 50
	elif pos.x > screen_size.x + 50:
		pos.x = -50

	if pos.y < -50:
		pos.y = screen_size.y + 50
	elif pos.y > screen_size.y + 50:
		pos.y = -50

	global_position = pos

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_split()
		destroyed.emit(score_value)
		queue_free()

func _split() -> void:
	if size == Size.SMALL:
		return  # Don't split, just destroy

	var next_size = Size.MEDIUM if size == Size.LARGE else Size.SMALL
	var split_count = 3 if size == Size.LARGE else 2

	for i in split_count:
		var asteroid = duplicate()
		asteroid.size = next_size
		asteroid.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))

		# Random velocity for split pieces
		var angle = (TAU / split_count) * i + randf_range(-0.3, 0.3)
		var speed = randf_range(100, 200)
		asteroid.linear_velocity = Vector2.UP.rotated(angle) * speed

		get_parent().call_deferred("add_child", asteroid)

func _on_body_entered(body: Node) -> void:
	# Collision with player handled by player script
	pass
```

**Settings**:
- Body Type: Rigid
- Gravity Scale: 0
- Linear Damp: 0
- Angular Damp: 0
- Collision Layer: 2 (asteroids)
- Collision Mask: 1 (player)

**✅ Implementation Status**:
- 3 sizes with proper scaling: ✅ Implemented
- Split mechanics: ✅ Implemented (3 pieces for LARGE, 2 for MEDIUM)
- Screen wrapping: ✅ Implemented
- Health and damage system: ✅ Implemented

---

### Phase 5: Spawner System (45 min) ✅ COMPLETE

**Script**: `Src/scripts/prototype/spawner.gd`
```gdscript
class_name Spawner
extends Node

@export var asteroid_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var max_asteroids: int = 15

var _spawn_timer: float = 0.0
var _active_asteroids: int = 0

func _ready() -> void:
	_spawn_timer = spawn_interval

func _process(delta: float) -> void:
	_spawn_timer -= delta

	if _spawn_timer <= 0 and _active_asteroids < max_asteroids:
		_spawn_asteroid()
		_spawn_timer = spawn_interval

func _spawn_asteroid() -> void:
	var asteroid = asteroid_scene.instantiate() as Asteroid

	# Random edge position
	var spawn_pos = _get_random_edge_position()
	asteroid.global_position = spawn_pos

	# Velocity toward screen center with variance
	var screen_center = get_viewport().get_visible_rect().size / 2
	var direction = (screen_center - spawn_pos).normalized()
	var angle_variance = randf_range(-0.5, 0.5)
	direction = direction.rotated(angle_variance)
	var speed = randf_range(50, 100)

	asteroid.linear_velocity = direction * speed
	asteroid.destroyed.connect(_on_asteroid_destroyed)

	get_parent().add_child(asteroid)
	_active_asteroids += 1

func _get_random_edge_position() -> Vector2:
	var screen_size = get_viewport().get_visible_rect().size
	var edge = randi() % 4

	match edge:
		0:  # Top
			return Vector2(randf() * screen_size.x, -50)
		1:  # Right
			return Vector2(screen_size.x + 50, randf() * screen_size.y)
		2:  # Bottom
			return Vector2(randf() * screen_size.x, screen_size.y + 50)
		_:  # Left
			return Vector2(-50, randf() * screen_size.y)

func _on_asteroid_destroyed(_score: int) -> void:
	_active_asteroids = max(0, _active_asteroids - 1)
```

**✅ Implementation Status**:
- Edge spawning: ✅ Implemented
- Velocity toward center: ✅ Implemented
- Active asteroid tracking: ✅ Implemented
- Max asteroid limit: ✅ Implemented (15 max)

---

### Phase 6: Game Manager (1 hour) ✅ COMPLETE

**Script**: `Src/scripts/prototype/game_manager.gd`
```gdscript
class_name GameManager
extends Node

signal score_updated(new_score: int)
signal game_over

var current_score: int = 0
var is_playing: bool = true

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	if player:
		player.died.connect(_on_player_died)

	# Connect to all asteroids' destroyed signals
	get_tree().node_added.connect(_on_node_added)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not is_playing:
		get_tree().reload_current_scene()

func add_score(amount: int) -> void:
	current_score += amount
	score_updated.emit(current_score)

func _on_player_died() -> void:
	is_playing = false
	game_over.emit()

func _on_node_added(node: Node) -> void:
	if node is Asteroid:
		node.destroyed.connect(add_score)
```

**Scene Structure**: `Src/scenes/prototype/game.tscn`
```
Game (Node2D)
├── Camera2D (Position: [640, 360], Enabled: true)
├── ColorRect (Color: #000000, Size: 1280x720) - Background
├── GameManager (Node with game_manager.gd)
├── Spawner (Node with spawner.gd)
├── Player (instance of player.tscn at center)
└── HUD (instance of prototype_hud.tscn)
```

**✅ Implementation Status**:
- Score tracking: ✅ Implemented
- Player death detection: ✅ Implemented
- Auto-connect to asteroids: ✅ Implemented (via node_added signal)
- Restart functionality: ✅ Implemented (R key)
- Game state management: ✅ Implemented

---

### Phase 7: Basic HUD (45 min) ✅ COMPLETE

**Scene Structure**: `Src/scenes/ui/prototype_hud.tscn`
```
HUD (CanvasLayer)
└── Control (FullRect)
    ├── MarginContainer (Margin: 20)
    │   ├── TopBar (HBoxContainer)
    │   │   ├── ShieldBar (ProgressBar)
    │   │   │   └── Properties: Max Value: 100, Show Percentage: false
    │   │   └── ScoreLabel (Label)
    │   │       └── Text: "Score: 0"
    └── GameOverPanel (CenterContainer)
        └── VBoxContainer
            ├── GameOverLabel (Label)
            │   └── Text: "GAME OVER"
            └── RestartLabel (Label)
                └── Text: "Press R to Restart"
```

**Script**: `Src/scripts/prototype/prototype_hud.gd`
```gdscript
extends CanvasLayer

@onready var shield_bar: ProgressBar = %ShieldBar
@onready var score_label: Label = %ScoreLabel
@onready var game_over_panel: CenterContainer = %GameOverPanel

func _ready() -> void:
	game_over_panel.hide()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.shield_changed.connect(_on_shield_changed)
		player.died.connect(_on_player_died)

	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.score_updated.connect(_on_score_updated)

func _on_shield_changed(current: float, maximum: float) -> void:
	shield_bar.value = (current / maximum) * 100.0

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_player_died() -> void:
	game_over_panel.show()
```

**Add GameManager to group "game_manager"** in the Node tab

**✅ Implementation Status**:
- Shield bar with reactive updates: ✅ Implemented
- Score display: ✅ Implemented
- Game Over screen: ✅ Implemented
- Signal-based UI updates: ✅ Implemented
- Unique name references (%): ✅ Implemented

---

### Phase 8: Integration & Testing (1 hour) ✅ COMPLETE

**Checklist**:
- [x] Wire up all scene references:
  - Player → Projectile scene reference
  - Spawner → Asteroid scene reference
- [x] Test player movement (ACCELERATION: 200, MAX_SPEED: 300) ✅
- [x] Test shooting (FIRE_RATE: 0.5 seconds) ✅
- [x] Test asteroid splitting ✅
- [x] Test collision damage ✅
- [x] Test spawning (3 second interval, max 15) ✅
- [x] Test game over flow (death → restart) ✅
- [x] Balance pass completed ✅
- [x] All systems working together ✅

---

## Visual Style (Prototype)

**Ultra-minimalist placeholders**:
- **Player**: White triangle (Polygon2D: points [0,-20], [-15,15], [15,15])
- **Asteroids**: Gray irregular polygons (create 3 variants with different point arrays)
- **Projectiles**: White rectangle (4x10 pixels)
- **Background**: Pure black (#000000)
- **UI**: Default Godot theme, white text on dark background

**No custom art needed** - use built-in Godot nodes (Polygon2D, ColorRect).

---

## Success Criteria ✅ ALL ACHIEVED

The prototype is "done" when:
- ✅ Player can fly around with satisfying inertia **DONE**
- ✅ Shooting feels responsive and accurate **DONE**
- ✅ Asteroids split in a satisfying way **DONE**
- ✅ Getting hit by asteroids feels dangerous **DONE**
- ✅ Game loop is clear: shoot → survive → score **DONE**
- ✅ Can play for 2-3 minutes before death **DONE**
- ✅ Core gameplay "feel" is fun **DONE**

**BONUS ACHIEVEMENTS**:
- ✅ Invincibility system prevents damage spam
- ✅ Knockback adds tactile feedback to collisions

---

## Testing Questions

After building the prototype, answer these:

1. **Movement Feel**
   - Does the ship feel too floaty? Too stiff?
   - Is rotation speed right?
   - Does screen wrap feel natural?

2. **Combat Feel**
   - Are asteroids satisfying to destroy?
   - Is the fire rate too slow/fast?
   - Do projectiles feel impactful?

3. **Difficulty**
   - How long can you survive on first try?
   - Does it ramp up naturally as asteroids multiply?
   - Is it too punishing or too easy?

4. **Core Loop**
   - Is it fun for 5 minutes without upgrades?
   - Do you want to restart after dying?
   - Can you see the potential with progression added?

---

## Next Steps After Prototype

If the prototype feels good:
1. Add basic shield regeneration (test auto-heal mechanic)
2. Add ONE enemy type (UFO) to test combat variety
3. Add temporary pickup (Speed Boost) to test buff system
4. Add simple difficulty scaling (spawn rate increases over time)

Then move to full implementation with progression systems from the Technical Spec.

---

## Time Estimate

| Phase | Time | Cumulative |
|-------|------|------------|
| Project Setup | 30 min | 0.5 hr |
| Player Ship | 1 hr | 1.5 hr |
| Projectile System | 45 min | 2.25 hr |
| Asteroid System | 1.5 hr | 3.75 hr |
| Spawner System | 45 min | 4.5 hr |
| Game Manager | 1 hr | 5.5 hr |
| Basic HUD | 45 min | 6.25 hr |
| Integration & Testing | 1 hr | **7.25 hr** |

**Total: ~7-8 hours** for a playable prototype.

With focused work: **1-2 days** to completion.

---

## File Checklist ✅ COMPLETE

**Scenes** (5 files):
- [x] `Src/void-survival/scenes/prototype/game.tscn`
- [x] `Src/void-survival/scenes/prototype/player.tscn`
- [x] `Src/void-survival/scenes/prototype/projectile.tscn`
- [x] `Src/void-survival/scenes/prototype/asteroid.tscn`
- [x] `Src/void-survival/scenes/ui/prototype_hud.tscn`

**Scripts** (6 files):
- [x] `Src/void-survival/scripts/player.gd`
- [x] `Src/void-survival/scripts/projectile.gd`
- [x] `Src/void-survival/scripts/asteroid.gd`
- [x] `Src/void-survival/scripts/spawner.gd`
- [x] `Src/void-survival/scripts/game_manager.gd`
- [x] `Src/void-survival/scripts/prototype_hud.gd`

**Total: 11 files** - All created and working!

---

## Prototype Philosophy

> "Build the smallest thing that proves the game is fun."

Focus on:
- ✅ **Feel** over features
- ✅ **Iteration speed** over perfection
- ✅ **Core loop** over content
- ✅ **Playability** over visuals

Everything else can be added after the core feels right.

---

## 🎉 Prototype Completion Summary

**Build Status**: ✅ **COMPLETE AND PLAYABLE**

### What Works
- ✅ Full player movement with inertia physics
- ✅ Responsive shooting system
- ✅ Asteroid spawning, splitting, and destruction
- ✅ Score tracking and HUD
- ✅ Game over and restart flow
- ✅ Invincibility frames prevent damage spam
- ✅ Knockback adds satisfying collision feedback

### Architecture Highlights
- ✅ Signal-based event system (decoupled components)
- ✅ Group-based node discovery (scalable)
- ✅ Clean separation of concerns (each script has one job)
- ✅ Screen wrapping for player and asteroids
- ✅ Auto-cleanup for off-screen projectiles

### Next Steps Completed
Based on original "Next Steps After Prototype" section:
1. ~~Add basic shield regeneration~~ → Keeping simple for now
2. ~~Add ONE enemy type (UFO)~~ → Not yet (waiting for Week 2)
3. ~~Add temporary pickup~~ → Not yet (waiting for Week 2)
4. ~~Add simple difficulty scaling~~ → Not yet (waiting for Week 2)

**Current Status**: Week 1 prototype complete and validated. Ready to proceed with Week 2 features or full Technical Spec implementation.

---

**Prototype completed!** 🚀 ✅
