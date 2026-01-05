# Module 6 Implementation Plan: Enemy Variety & Spawning

**Status**: Ready for Implementation
**Priority**: Medium
**Dependencies**: None (extends prototype spawner)
**Estimated Duration**: 5-7 days
**Phase**: Phase 2 - Content Expansion

---

## Overview

This module adds **UFO** and **Comet** enemies with unique behaviors and attack patterns, establishing a data-driven enemy system that can scale infinitely with difficulty.

**Goals**:
- Implement UFO enemy with sinusoidal movement and lead targeting
- Implement Comet enemy with charge attack pattern
- Create data-driven enemy spawner system
- Establish EnemyDefinition resource pattern for extensibility
- Integrate with existing difficulty and scoring systems

---

## Architecture Integration

### Core Systems Used
- **GameManager**: Difficulty scaling, game state management
- **ScoreManager**: Track enemy kills, award credits
- **Existing Spawner**: Extend asteroid spawner pattern

### New Resources
- `EnemyDefinition` custom Resource class
- UFO, Comet `.tres` data files

### Signal Flow
```
Enemy spawned → initialized with difficulty-scaled stats
Enemy destroyed → destroyed signal → GameManager/ScoreManager
Enemy damaged → damaged signal → VFX feedback (future)
```

---

## Implementation Steps

### Step 1: Create EnemyDefinition Resource Class

**File**: `Src/void-survival/scripts/resources/enemy_definition.gd`

**Purpose**: Data-driven enemy configuration with difficulty scaling formulas

**Implementation**:

```gdscript
class_name EnemyDefinition
extends Resource

## Base enemy parameters with difficulty scaling formulas

enum EnemyType {
	ASTEROID,
	UFO,
	COMET
}

@export var enemy_name: String = "Unknown"
@export var enemy_type: EnemyType = EnemyType.ASTEROID
@export var scene: PackedScene  # Enemy scene to instance

@export_group("Base Stats")
@export var base_health: float = 30.0
@export var base_speed: float = 2.0
@export var base_damage: float = 20.0
@export var score_value: int = 10
@export var crystal_drop_count: int = 2

@export_group("Difficulty Scaling")
@export var health_scaling: float = 0.1  # +10% per difficulty level
@export var speed_scaling: float = 0.05  # +5% per difficulty level
@export var damage_scaling: float = 0.12  # +12% per difficulty level

## Calculate stats at given difficulty level
func get_stats_at_difficulty(difficulty: float) -> Dictionary:
	return {
		"health": base_health * (1.0 + difficulty * health_scaling),
		"speed": base_speed * (1.0 + difficulty * speed_scaling),
		"damage": base_damage * (1.0 + difficulty * damage_scaling),
		"score": score_value,
		"crystals": crystal_drop_count
	}
```

**UID File**: Create `enemy_definition.gd.uid` with unique ID

**Testing Checkpoint**:
- [ ] Resource script compiles without errors
- [ ] Can create test `.tres` in editor
- [ ] `get_stats_at_difficulty()` returns correct values

---

### Step 2: Create UFO Enemy Scene & Script

**Scene**: `Src/void-survival/scenes/gameplay/hazards/enemy_ufo.tscn`

**Structure**:
```
EnemyUFO (CharacterBody2D)
├── Sprite2D (UFO graphic - use placeholder triangle for now)
├── CollisionShape2D (CircleShape2D)
├── ShootPoint (Marker2D) - offset for projectile spawn
└── ShootTimer (Timer) - controls fire rate
```

**Script**: `Src/void-survival/scenes/gameplay/hazards/enemy_ufo.gd`

```gdscript
class_name EnemyUFO
extends CharacterBody2D

## UFO enemy with sinusoidal movement and lead targeting

signal destroyed(score_value: int, crystal_count: int)
signal damaged(amount: int)

@export var projectile_scene: PackedScene  # Reuse player projectile or create enemy variant
@export var shoot_accuracy: float = 0.7  # 0-1, how accurate the lead targeting is

@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot_timer: Timer = $ShootTimer

# Stats (set by spawner)
var health: float = 50.0
var max_health: float = 50.0
var speed: float = 100.0
var damage: float = 20.0
var score: int = 20
var crystals: int = 3

# Movement
var _time: float = 0.0
var _base_direction: Vector2 = Vector2.ZERO
var _amplitude: float = 50.0  # How wide the sine wave is
var _frequency: float = 2.0    # How fast it oscillates

func _ready() -> void:
	add_to_group("enemies")

	# Random initial direction
	_base_direction = Vector2.RIGHT.rotated(randf() * TAU)

	# Start shooting
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func initialize(stats: Dictionary) -> void:
	health = stats.health
	max_health = stats.health
	speed = stats.speed
	damage = stats.damage
	score = stats.score
	crystals = stats.crystals

func _physics_process(delta: float) -> void:
	_time += delta

	# Sinusoidal movement pattern
	var forward = _base_direction * speed
	var perpendicular = _base_direction.rotated(PI / 2.0) * _amplitude
	var sine_offset = sin(_time * _frequency) * perpendicular

	velocity = forward + sine_offset * delta * speed
	move_and_slide()

	# Screen wrapping
	_wrap_around_screen()

func _wrap_around_screen() -> void:
	var screen_size = get_viewport_rect().size
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

func _on_shoot_timer_timeout() -> void:
	_shoot_at_player()

func _shoot_at_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Lead targeting with accuracy parameter
	var target_pos = player.global_position

	# Predict where player will be (simple lead)
	if player.has_method("get_velocity"):
		var player_velocity = player.velocity if player.velocity else Vector2.ZERO
		var time_to_hit = global_position.distance_to(target_pos) / 400.0  # Assume projectile speed
		target_pos += player_velocity * time_to_hit * shoot_accuracy

	# Spawn projectile
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = shoot_point.global_position
		projectile.global_rotation = global_position.direction_to(target_pos).angle()
		projectile.damage = damage * 0.5  # UFO shots do half damage
		get_tree().current_scene.add_child(projectile)

func take_damage(amount: float) -> void:
	health -= amount
	damaged.emit(amount)

	if health <= 0:
		_die()

func _die() -> void:
	destroyed.emit(score, crystals)
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Collision damage to player
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_die()  # UFO dies on collision
```

**Testing Checkpoint**:
- [ ] UFO scene loads without errors
- [ ] UFO moves in sinusoidal pattern
- [ ] UFO shoots projectiles toward player
- [ ] UFO wraps around screen
- [ ] UFO destroyed signal fires correctly

---

### Step 3: Create Comet Enemy Scene & Script

**Scene**: `Src/void-survival/scenes/gameplay/hazards/enemy_comet.tscn`

**Structure**:
```
EnemyComet (RigidBody2D)
├── Sprite2D (Comet graphic - elongated triangle)
├── CollisionShape2D (CapsuleShape2D)
├── ChargeTimer (Timer) - time before charge
└── TelegraphSprite (Sprite2D) - visual warning, initially hidden
```

**Script**: `Src/void-survival/scenes/gameplay/hazards/enemy_comet.gd`

```gdscript
class_name EnemyComet
extends RigidBody2D

## Comet enemy that charges at player after telegraphing

signal destroyed(score_value: int, crystal_count: int)
signal damaged(amount: int)

@onready var charge_timer: Timer = $ChargeTimer
@onready var telegraph_sprite: Sprite2D = $TelegraphSprite

# Stats
var health: float = 40.0
var max_health: float = 40.0
var speed: float = 50.0  # Slow drift speed
var charge_speed: float = 400.0  # Fast charge speed
var damage: float = 30.0
var score: int = 15
var crystals: int = 2

# State
enum State { DRIFTING, TELEGRAPHING, CHARGING }
var _state: State = State.DRIFTING
var _charge_direction: Vector2 = Vector2.ZERO
var _telegraph_duration: float = 1.0
var _telegraph_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	gravity_scale = 0.0

	# Start with random drift
	var drift_direction = Vector2.RIGHT.rotated(randf() * TAU)
	linear_velocity = drift_direction * speed

	# Start charge timer
	charge_timer.timeout.connect(_on_charge_timer_timeout)
	charge_timer.wait_time = randf_range(2.0, 4.0)
	charge_timer.start()

	telegraph_sprite.visible = false

func initialize(stats: Dictionary) -> void:
	health = stats.health
	max_health = stats.health
	speed = stats.speed
	charge_speed = stats.speed * 8.0  # Charge is 8x base speed
	damage = stats.damage
	score = stats.score
	crystals = stats.crystals

func _physics_process(delta: float) -> void:
	match _state:
		State.DRIFTING:
			# Slow drift, already handled by RigidBody2D
			pass

		State.TELEGRAPHING:
			_telegraph_timer += delta

			# Flash telegraph sprite
			telegraph_sprite.modulate.a = 0.5 + 0.5 * sin(_telegraph_timer * 10.0)

			if _telegraph_timer >= _telegraph_duration:
				_execute_charge()

		State.CHARGING:
			# Charging is handled by apply_central_impulse in _execute_charge
			pass

	_wrap_around_screen()

func _on_charge_timer_timeout() -> void:
	if _state == State.DRIFTING:
		_begin_telegraph()

func _begin_telegraph() -> void:
	_state = State.TELEGRAPHING
	_telegraph_timer = 0.0

	# Calculate charge direction toward player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		_charge_direction = global_position.direction_to(player.global_position)
	else:
		_charge_direction = Vector2.RIGHT.rotated(randf() * TAU)

	# Show telegraph
	telegraph_sprite.visible = true
	telegraph_sprite.rotation = _charge_direction.angle()

	# Stop drifting
	linear_velocity = Vector2.ZERO

func _execute_charge() -> void:
	_state = State.CHARGING
	telegraph_sprite.visible = false

	# Apply massive impulse
	apply_central_impulse(_charge_direction * charge_speed * mass)

	# After charge, return to drifting
	await get_tree().create_timer(3.0).timeout
	if _state == State.CHARGING:  # Check still alive
		_state = State.DRIFTING
		linear_velocity = _charge_direction * speed
		charge_timer.start()

func _wrap_around_screen() -> void:
	var screen_size = get_viewport_rect().size
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
	damaged.emit(amount)

	if health <= 0:
		_die()

func _die() -> void:
	destroyed.emit(score, crystals)
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Collision damage
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var collision_damage = damage
			if _state == State.CHARGING:
				collision_damage *= 1.5  # 50% more damage when charging
			body.take_damage(collision_damage)
		# Comet survives collision but loses health
		take_damage(max_health * 0.3)
```

**Testing Checkpoint**:
- [ ] Comet scene loads without errors
- [ ] Comet drifts slowly initially
- [ ] Telegraph visual appears before charge
- [ ] Comet charges toward player position
- [ ] Collision damage applies correctly

---

### Step 4: Create EnemyDefinition Resources

**Files**:
- `Src/void-survival/resources/enemies/ufo_data.tres`
- `Src/void-survival/resources/enemies/comet_data.tres`

**UFO Data** (`ufo_data.tres`):
```
[gd_resource type="Resource" script_class="EnemyDefinition" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/enemy_definition.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/gameplay/hazards/enemy_ufo.tscn" id="2"]

[resource]
script = ExtResource("1")
enemy_name = "UFO Scout"
enemy_type = 1
scene = ExtResource("2")
base_health = 50.0
base_speed = 100.0
base_damage = 15.0
score_value = 20
crystal_drop_count = 3
health_scaling = 0.12
speed_scaling = 0.06
damage_scaling = 0.10
```

**Comet Data** (`comet_data.tres`):
```
[gd_resource type="Resource" script_class="EnemyDefinition" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/enemy_definition.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/gameplay/hazards/enemy_comet.tscn" id="2"]

[resource]
script = ExtResource("1")
enemy_name = "Void Comet"
enemy_type = 2
scene = ExtResource("2")
base_health = 80.0
base_speed = 50.0
base_damage = 30.0
score_value = 15
crystal_drop_count = 2
health_scaling = 0.15
speed_scaling = 0.04
damage_scaling = 0.12
```

**Testing Checkpoint**:
- [ ] Resources load in editor without errors
- [ ] Can view/edit properties in inspector
- [ ] Scene references are valid

---

### Step 5: Create Enemy Spawner System

**File**: `Src/void-survival/scripts/gameplay/spawners/enemy_spawner.gd`

**Purpose**: Spawn UFOs and Comets based on difficulty and timers

```gdscript
class_name EnemySpawner
extends Node

## Spawns enemy types based on difficulty and intervals

@export var enemy_definitions: Array[EnemyDefinition] = []
@export var enabled: bool = true

# Spawn intervals (decreased by difficulty)
@export_group("UFO Spawning")
@export var ufo_spawn_interval: float = 20.0
@export var max_ufos: int = 3

@export_group("Comet Spawning")
@export var comet_spawn_interval: float = 15.0
@export var max_comets: int = 5

# Internal timers
var _ufo_timer: float = 0.0
var _comet_timer: float = 0.0
var _current_difficulty: float = 0.0

# Track active enemies
var _active_ufos: int = 0
var _active_comets: int = 0

func _ready() -> void:
	# Load enemy definitions if not set in editor
	if enemy_definitions.is_empty():
		_load_enemy_definitions()

	# Connect to difficulty system
	if GameManager:
		GameManager.difficulty_changed.connect(_on_difficulty_changed)
		_current_difficulty = GameManager.current_difficulty if GameManager.has_method("get_current_difficulty") else 0.0

	# Start timers at random offsets
	_ufo_timer = randf() * ufo_spawn_interval
	_comet_timer = randf() * comet_spawn_interval

func _load_enemy_definitions() -> void:
	# Load from resources folder
	var ufo_def = load("res://resources/enemies/ufo_data.tres") as EnemyDefinition
	var comet_def = load("res://resources/enemies/comet_data.tres") as EnemyDefinition

	if ufo_def:
		enemy_definitions.append(ufo_def)
	if comet_def:
		enemy_definitions.append(comet_def)

func _process(delta: float) -> void:
	if not enabled or not GameManager or not GameManager.is_playing:
		return

	# Update timers
	_ufo_timer -= delta
	_comet_timer -= delta

	# Spawn UFOs
	if _ufo_timer <= 0 and _active_ufos < max_ufos:
		_spawn_enemy_type(EnemyDefinition.EnemyType.UFO)
		_ufo_timer = _calculate_spawn_interval(ufo_spawn_interval)

	# Spawn Comets
	if _comet_timer <= 0 and _active_comets < max_comets:
		_spawn_enemy_type(EnemyDefinition.EnemyType.COMET)
		_comet_timer = _calculate_spawn_interval(comet_spawn_interval)

func _spawn_enemy_type(type: EnemyDefinition.EnemyType) -> void:
	# Find definition for this type
	var definition: EnemyDefinition = null
	for def in enemy_definitions:
		if def.enemy_type == type:
			definition = def
			break

	if not definition or not definition.scene:
		push_error("No definition or scene for enemy type: " + str(type))
		return

	# Instance enemy
	var enemy = definition.scene.instantiate()

	# Set spawn position (random edge)
	enemy.global_position = _get_random_edge_position()

	# Initialize with difficulty-scaled stats
	var stats = definition.get_stats_at_difficulty(_current_difficulty)
	if enemy.has_method("initialize"):
		enemy.initialize(stats)

	# Connect signals
	if enemy.has_signal("destroyed"):
		enemy.destroyed.connect(_on_enemy_destroyed.bind(type))

	# Add to scene
	get_tree().current_scene.add_child(enemy)

	# Track count
	match type:
		EnemyDefinition.EnemyType.UFO:
			_active_ufos += 1
		EnemyDefinition.EnemyType.COMET:
			_active_comets += 1

func _calculate_spawn_interval(base_interval: float) -> float:
	# Faster spawning at higher difficulty
	var difficulty_modifier = 1.0 - min(_current_difficulty * 0.01, 0.6)  # Max 60% reduction
	return base_interval * difficulty_modifier

func _get_random_edge_position() -> Vector2:
	var screen_size = get_viewport_rect().size
	var margin = 50.0
	var edge = randi() % 4

	match edge:
		0:  # Top
			return Vector2(randf() * screen_size.x, -margin)
		1:  # Right
			return Vector2(screen_size.x + margin, randf() * screen_size.y)
		2:  # Bottom
			return Vector2(randf() * screen_size.x, screen_size.y + margin)
		_:  # Left
			return Vector2(-margin, randf() * screen_size.y)

func _on_difficulty_changed(new_difficulty: float) -> void:
	_current_difficulty = new_difficulty

func _on_enemy_destroyed(score: int, crystals: int, type: EnemyDefinition.EnemyType) -> void:
	# Update tracking
	match type:
		EnemyDefinition.EnemyType.UFO:
			_active_ufos = max(0, _active_ufos - 1)
		EnemyDefinition.EnemyType.COMET:
			_active_comets = max(0, _active_comets - 1)

	# Award score and spawn crystals
	if ScoreManager:
		ScoreManager.add_score(score)

	# Spawn crystals (implement in Step 6)
	_spawn_crystals(crystals, get_tree().current_scene.get_node("Player").global_position)  # Placeholder

func _spawn_crystals(count: int, position: Vector2) -> void:
	# TODO: Implement crystal spawning
	# For now, directly add to ResourceManager
	if ResourceManager:
		ResourceManager.add_crystals(count)
```

**Testing Checkpoint**:
- [ ] Spawner loads enemy definitions
- [ ] UFOs spawn at correct intervals
- [ ] Comets spawn at correct intervals
- [ ] Max limits enforced
- [ ] Difficulty affects spawn rates

---

### Step 6: Integrate with Game Scene

**File**: `Src/void-survival/scenes/prototype/game.tscn`

**Changes**:
1. Add `EnemySpawner` node as child of Game root
2. Configure in editor:
   - Set `enemy_definitions` array with UFO and Comet resources
   - Adjust spawn intervals and max counts
   - Ensure `enabled = true`

**Script changes** (`game.gd` or equivalent):
```gdscript
# In _ready()
@onready var enemy_spawner: EnemySpawner = $EnemySpawner

func _ready():
	# ... existing code ...

	# Enable enemy spawner when game starts
	if enemy_spawner:
		enemy_spawner.enabled = true

func _on_game_over():
	# Disable spawning
	if enemy_spawner:
		enemy_spawner.enabled = false
```

**Testing Checkpoint**:
- [ ] Enemy spawner appears in scene tree
- [ ] Enemies spawn during gameplay
- [ ] Spawning stops on game over

---

### Step 7: Update Projectile Collision

**File**: `Src/void-survival/scripts/projectile.gd`

**Changes**: Ensure projectiles can hit enemies

```gdscript
# In projectile collision handler
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroid") or body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		# Update accuracy tracking
		if ScoreManager:
			ScoreManager.record_shot(true)

		queue_free()
```

**Testing Checkpoint**:
- [ ] Projectiles damage UFOs
- [ ] Projectiles damage Comets
- [ ] Hit detection is accurate

---

### Step 8: Connect Enemy Destruction to Crystal Spawning

**File**: `Src/void-survival/scenes/prototype/game.gd` (or create `gameplay_manager.gd`)

**Implementation**:

```gdscript
# In game manager or main game script
func _spawn_crystals(count: int, position: Vector2) -> void:
	var crystal_scene = preload("res://scenes/prototype/crystal.tscn")

	for i in count:
		var crystal = crystal_scene.instantiate()

		# Spawn in circle around position
		var angle = (TAU / count) * i
		var offset = Vector2(30, 0).rotated(angle)
		crystal.global_position = position + offset

		# Add random velocity for scatter effect
		if crystal.has_method("set_velocity"):
			var velocity = offset.normalized() * randf_range(50, 100)
			crystal.set_velocity(velocity)

		add_child(crystal)
```

**Update EnemySpawner**:
```gdscript
# In _on_enemy_destroyed()
func _on_enemy_destroyed(score: int, crystals: int, type: EnemyDefinition.EnemyType, position: Vector2) -> void:
	# ... existing code ...

	# Spawn crystals at enemy position
	var game = get_tree().current_scene
	if game.has_method("spawn_crystals"):
		game.spawn_crystals(crystals, position)
```

**Testing Checkpoint**:
- [ ] Crystals spawn when UFO destroyed
- [ ] Crystals spawn when Comet destroyed
- [ ] Crystal count matches definition

---

## Testing & Validation

### Functionality Tests

- [ ] **UFO Behavior**:
  - [ ] Moves in smooth sinusoidal pattern
  - [ ] Shoots projectiles at player
  - [ ] Lead targeting works (shots aim ahead of moving player)
  - [ ] Takes damage from player projectiles
  - [ ] Awards correct score and crystals on death
  - [ ] Wraps around screen edges

- [ ] **Comet Behavior**:
  - [ ] Drifts slowly initially
  - [ ] Telegraph visual appears before charge
  - [ ] Charges in correct direction (toward player)
  - [ ] Deals increased damage during charge
  - [ ] Returns to drifting after charge
  - [ ] Takes damage from projectiles
  - [ ] Wraps around screen edges

- [ ] **Spawner System**:
  - [ ] UFOs spawn at correct intervals
  - [ ] Comets spawn at correct intervals
  - [ ] Max enemy limits enforced
  - [ ] Spawn rate increases with difficulty
  - [ ] Spawning stops on game over
  - [ ] Enemies spawn at screen edges (not on player)

- [ ] **Difficulty Scaling**:
  - [ ] Enemy health scales with difficulty
  - [ ] Enemy speed scales with difficulty
  - [ ] Enemy damage scales with difficulty
  - [ ] Spawn rates adjust with difficulty

- [ ] **Integration**:
  - [ ] ScoreManager tracks enemy kills
  - [ ] ResourceManager receives crystals from enemy deaths
  - [ ] Multiple enemies on screen without lag (test 10+ active)
  - [ ] Player can kill enemies with projectiles
  - [ ] Enemies damage player on collision

### Performance Tests

- [ ] No frame drops with 5+ UFOs and 10+ Comets active
- [ ] Screen wrapping works smoothly
- [ ] Projectile collision detection is accurate
- [ ] Memory usage stable during long sessions

---

## Post-Implementation

### Cleanup Tasks
- [ ] Remove debug print statements
- [ ] Add doc comments to all public methods
- [ ] Verify all `@export` variables have tooltips
- [ ] Check for any hardcoded values → move to exports

### Documentation Updates
- [ ] Update `CLAUDE.md` with enemy system architecture
- [ ] Archive this plan to `Documents/archive/module_06_plan.md`
- [ ] Create completion summary in `Documents/archive/module_06_completion.md`

### Future Extensibility Validation
- [ ] Verify new enemy types can be added via `.tres` files only
- [ ] Test difficulty scaling formulas are designer-friendly
- [ ] Confirm spawner can handle arbitrary enemy count

---

## Next Module Preview

**Module 7: Black Hole Hazard System**
- Gravitational attraction mechanics
- Screen-space distortion effects
- Overload and destruction pattern
- Integration with existing hazard spawning

---

## Technical Reference

### Key Files Created
```
scripts/resources/enemy_definition.gd           # Resource class
scenes/gameplay/hazards/enemy_ufo.tscn          # UFO scene
scenes/gameplay/hazards/enemy_ufo.gd            # UFO behavior
scenes/gameplay/hazards/enemy_comet.tscn        # Comet scene
scenes/gameplay/hazards/enemy_comet.gd          # Comet behavior
scripts/gameplay/spawners/enemy_spawner.gd      # Spawner system
resources/enemies/ufo_data.tres                 # UFO stats
resources/enemies/comet_data.tres               # Comet stats
```

### Signal Reference
```gdscript
# EnemyUFO / EnemyComet
signal destroyed(score_value: int, crystal_count: int)
signal damaged(amount: int)

# EnemySpawner (internal)
# Connects to enemy.destroyed signals
```

### Architecture Compliance
✅ **Data-Driven**: Enemy stats in Resources
✅ **Signal-Based**: Enemies emit signals, no tight coupling
✅ **Modular**: Spawner system is independent
✅ **Extensible**: Add new enemies via Resource files
✅ **Infinite Scaling**: Difficulty formulas support endless progression

---

**End of Implementation Plan**
