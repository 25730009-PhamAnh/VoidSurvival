# Void Survivor - Technical Specification (Godot 4)

## Document Overview

**Version**: 1.0
**Engine**: Godot 4.x
**Language**: GDScript
**Target Platforms**: Mobile (iOS/Android), PC
**Design Philosophy**: Data-driven, modular, extensible with minimal code changes

---

## 1. Architecture Overview

### 1.1 Core Design Principles

1. **Data-Driven Configuration**: All gameplay parameters stored in `Resource` files
2. **Signal-Based Communication**: Decoupled systems using Godot's signal system
3. **Scene Composition**: Reusable scenes as modular building blocks
4. **Minimal Autoloads**: Only for truly global systems
5. **Resource-Based Upgrades**: Infinite progression through parameterized `Resource` definitions

### 1.2 High-Level System Architecture

```
Game
├── Core Systems (Autoloads)
│   ├── GameManager (game state, difficulty)
│   ├── UpgradeSystem (persistent progression)
│   ├── ScoreManager (scoring, statistics)
│   └── SaveSystem (persistence)
├── Gameplay Layer (Scenes)
│   ├── GameWorld (main gameplay scene)
│   ├── Player (ship, input, weapons)
│   ├── Hazards (asteroids, enemies, black holes)
│   └── Spawners (procedural generation)
├── UI Layer (CanvasLayer)
│   ├── HUD
│   ├── MenuSystem
│   └── UpgradeShop
└── Data Layer (Resources)
    ├── Ship Parameters
    ├── Item Definitions
    ├── Enemy Definitions
    └── Difficulty Curves
```

---

## 2. Project Structure

```
Void_Survival/
├── Src/
│   ├── autoload/              # Singleton systems
│   │   ├── game_manager.gd
│   │   ├── upgrade_system.gd
│   │   ├── score_manager.gd
│   │   └── save_system.gd
│   ├── scenes/
│   │   ├── gameplay/
│   │   │   ├── game_world.tscn
│   │   │   ├── player/
│   │   │   │   ├── player.tscn
│   │   │   │   └── player.gd
│   │   │   ├── hazards/
│   │   │   │   ├── asteroid.tscn
│   │   │   │   ├── asteroid.gd
│   │   │   │   ├── enemy_ufo.tscn
│   │   │   │   ├── enemy_comet.tscn
│   │   │   │   └── black_hole.tscn
│   │   │   ├── weapons/
│   │   │   │   ├── projectile.tscn
│   │   │   │   └── weapon_system.gd
│   │   │   └── spawners/
│   │   │       ├── asteroid_spawner.gd
│   │   │       ├── enemy_spawner.gd
│   │   │       └── black_hole_spawner.gd
│   │   ├── ui/
│   │   │   ├── hud.tscn
│   │   │   ├── main_menu.tscn
│   │   │   ├── upgrade_shop.tscn
│   │   │   └── game_over_screen.tscn
│   │   └── vfx/
│   │       ├── explosion.tscn
│   │       └── pickup.tscn
│   ├── scripts/
│   │   ├── components/         # Reusable components
│   │   │   ├── health_component.gd
│   │   │   ├── damage_component.gd
│   │   │   ├── movement_component.gd
│   │   │   └── collection_component.gd
│   │   └── utilities/
│   │       ├── screen_wrapper.gd
│   │       └── object_pool.gd
│   ├── resources/
│   │   ├── ship_parameters/
│   │   │   └── base_ship_stats.tres
│   │   ├── items/
│   │   │   ├── item_definition.gd (base class)
│   │   │   ├── defensive/
│   │   │   │   ├── energy_amplifier.tres
│   │   │   │   ├── nano_repair.tres
│   │   │   │   └── reactive_armor.tres
│   │   │   ├── offensive/
│   │   │   │   ├── rapid_accelerator.tres
│   │   │   │   └── plasma_infusion.tres
│   │   │   └── utility/
│   │   │       ├── crystal_magnet.tres
│   │   │       └── fortune_matrix.tres
│   │   ├── enemies/
│   │   │   ├── enemy_definition.gd (base class)
│   │   │   ├── asteroid_data.tres
│   │   │   ├── ufo_data.tres
│   │   │   └── comet_data.tres
│   │   └── difficulty/
│   │       └── difficulty_curve.tres
│   └── shaders/              # Custom shaders
│       └── distortion.gdshader
└── assets/                   # Art, audio, fonts
    ├── sprites/
    ├── audio/
    └── fonts/
```

---

## 3. Core Systems (Autoloads)

### 3.1 GameManager (Singleton)

**Purpose**: Central game state management, difficulty scaling, session orchestration

**Responsibilities**:
- Track current game state (menu, playing, paused, game_over)
- Manage difficulty level and dynamic difficulty adjustments
- Coordinate spawners and game flow
- Emit signals for major game events

**Key Signals**:
```gdscript
signal game_started
signal game_paused
signal game_resumed
signal game_over(stats: Dictionary)
signal difficulty_changed(new_level: int)
```

**Key Properties**:
```gdscript
@export var difficulty_curve: DifficultyConfig  # Resource
var current_difficulty: float = 0.0
var survival_time: float = 0.0
var is_playing: bool = false
```

**Key Methods**:
```gdscript
func start_game() -> void
func end_game() -> void
func update_difficulty(delta: float) -> void
func calculate_performance_modifier() -> float
```

---

### 3.2 UpgradeSystem (Singleton)

**Purpose**: Manage persistent player upgrades and build configurations

**Responsibilities**:
- Store equipped items and their levels
- Calculate final ship stats from base + upgrades
- Handle item purchase and slot unlocking
- Persist upgrade data

**Key Signals**:
```gdscript
signal item_purchased(item: ItemDefinition)
signal item_equipped(item: ItemDefinition, slot: int)
signal item_upgraded(item: ItemDefinition, new_level: int)
signal stats_updated(new_stats: Dictionary)
```

**Key Properties**:
```gdscript
var equipped_items: Array[ItemDefinition] = []
var item_levels: Dictionary = {}  # ItemDefinition -> int
var unlocked_slots: int = 4
var total_points_spent: int = 0
```

**Key Methods**:
```gdscript
func get_final_stats() -> Dictionary
func purchase_item(item: ItemDefinition) -> bool
func upgrade_item(item: ItemDefinition) -> bool
func equip_item(item: ItemDefinition, slot: int) -> void
func calculate_stat_bonuses() -> Dictionary
```

---

### 3.3 ScoreManager (Singleton)

**Purpose**: Track scoring, statistics, and performance metrics

**Responsibilities**:
- Track survival time, kills, accuracy, crystals collected
- Calculate final score and credit rewards
- Monitor performance for dynamic difficulty
- Handle achievements

**Key Signals**:
```gdscript
signal score_updated(new_score: int)
signal credits_earned(amount: int)
signal achievement_unlocked(achievement_id: String)
signal stat_changed(stat_name: String, value: Variant)
```

**Key Properties**:
```gdscript
var current_score: int = 0
var crystals_collected: int = 0
var asteroids_destroyed: int = 0
var enemies_destroyed: int = 0
var shots_fired: int = 0
var shots_hit: int = 0
var accuracy: float = 0.0
```

**Key Methods**:
```gdscript
func add_score(amount: int) -> void
func record_destruction(type: String) -> void
func record_shot(hit: bool) -> void
func calculate_credits() -> int
func get_performance_metrics() -> Dictionary
```

---

### 3.4 SaveSystem (Singleton)

**Purpose**: Handle save/load for persistent progression

**Responsibilities**:
- Save/load upgrade progress
- Save/load settings and preferences
- Cloud save integration (future)

**Key Methods**:
```gdscript
func save_game() -> void
func load_game() -> void
func has_save_data() -> bool
func delete_save() -> void
```

---

## 4. Data Layer (Resources)

### 4.1 ShipStats Resource

**Purpose**: Define base ship parameters and upgrade formulas

**File**: `ship_stats.gd` (extends `Resource`)

```gdscript
class_name ShipStats
extends Resource

## Base ship parameter values and upgrade formulas

# Shield Parameters
@export var base_max_shield: float = 100.0
@export var shield_per_level: float = 20.0
@export var base_shield_regen: float = 5.0
@export var shield_regen_per_level: float = 0.5
@export var base_shield_delay: float = 3.0
@export var shield_delay_reduction: float = 0.1
@export var min_shield_delay: float = 0.5

# Movement Parameters
@export var base_move_speed: float = 5.0
@export var move_speed_per_level: float = 0.3
@export var base_acceleration: float = 10.0
@export var accel_per_level: float = 0.5

# Weapon Parameters
@export var base_fire_rate: float = 2.0
@export var fire_rate_per_level: float = 0.1
@export var base_damage: float = 10.0
@export var damage_multiplier_per_level: float = 0.15
@export var base_projectile_speed: float = 15.0
@export var projectile_speed_per_level: float = 0.2

# Utility Parameters
@export var base_collection_radius: float = 2.0
@export var collection_radius_per_level: float = 0.15
@export var base_luck: float = 1.0
@export var luck_per_level: float = 0.05

## Calculate stats at given levels
func calculate_stats(levels: Dictionary) -> Dictionary:
	return {
		"max_shield": base_max_shield + levels.get("defense", 0) * shield_per_level,
		"shield_regen": base_shield_regen + levels.get("defense", 0) * shield_regen_per_level,
		"shield_delay": max(min_shield_delay, base_shield_delay - levels.get("defense", 0) * shield_delay_reduction),
		"move_speed": base_move_speed + levels.get("mobility", 0) * move_speed_per_level,
		"acceleration": base_acceleration + levels.get("mobility", 0) * accel_per_level,
		"fire_rate": base_fire_rate + levels.get("offense", 0) * fire_rate_per_level,
		"damage": base_damage * (1.0 + levels.get("offense", 0) * damage_multiplier_per_level),
		"projectile_speed": base_projectile_speed + levels.get("offense", 0) * projectile_speed_per_level,
		"collection_radius": base_collection_radius + levels.get("utility", 0) * collection_radius_per_level,
		"luck": base_luck + levels.get("utility", 0) * luck_per_level
	}
```

**Instance**: Create `base_ship_stats.tres` in the editor with default values.

---

### 4.2 ItemDefinition Resource

**Purpose**: Define upgradeable items with infinite scaling formulas

**File**: `item_definition.gd` (extends `Resource`)

```gdscript
class_name ItemDefinition
extends Resource

## Base class for all permanent upgrade items

enum ItemCategory {
	DEFENSIVE,
	OFFENSIVE,
	UTILITY
}

enum ScalingType {
	LINEAR,        # base + (level * increment)
	MULTIPLICATIVE # base * (1 + level * multiplier)
}

@export var item_name: String = "Unknown Item"
@export var description: String = ""
@export var icon: Texture2D
@export_category: ItemCategory = ItemCategory.UTILITY

@export_group("Scaling")
@export var base_cost: int = 100
@export var cost_exponent: float = 1.12
@export var scaling_type: ScalingType = ScalingType.LINEAR

@export_group("Effects")
@export var affected_stats: Array[String] = []  # e.g., ["max_shield", "shield_regen"]
@export var base_bonus: float = 0.25  # 25% bonus at level 1
@export var bonus_per_level: float = 0.02  # +2% per level

## Calculate cost at specific level
func get_cost_at_level(level: int) -> int:
	return int(base_cost * pow(cost_exponent, level))

## Calculate bonus at specific level
func get_bonus_at_level(level: int) -> float:
	match scaling_type:
		ScalingType.LINEAR:
			return base_bonus + (level * bonus_per_level)
		ScalingType.MULTIPLICATIVE:
			return base_bonus * (1.0 + level * bonus_per_level)
	return base_bonus

## Apply this item's effects to a stats dictionary
func apply_to_stats(stats: Dictionary, level: int) -> void:
	var bonus = get_bonus_at_level(level)
	for stat_name in affected_stats:
		if stats.has(stat_name):
			stats[stat_name] *= (1.0 + bonus)
```

**Concrete Examples** (create as `.tres` files):

```gdscript
# resources/items/defensive/energy_amplifier.tres
[gd_resource type="ItemDefinition"]

[resource]
item_name = "Energy Amplifier"
description = "Increases maximum shield capacity"
category = 0  # DEFENSIVE
base_cost = 100
cost_exponent = 1.12
scaling_type = 1  # MULTIPLICATIVE
affected_stats = ["max_shield"]
base_bonus = 0.25
bonus_per_level = 0.02
```

**Benefits**:
- **Zero code changes** to add new items - just create new `.tres` files
- Designers can tweak values in the editor
- Easy to balance via data files

---

### 4.3 EnemyDefinition Resource

**Purpose**: Define enemy types with difficulty scaling formulas

**File**: `enemy_definition.gd` (extends `Resource`)

```gdscript
class_name EnemyDefinition
extends Resource

## Base enemy parameters with difficulty scaling

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
@export var credit_reward: int = 2

@export_group("Difficulty Scaling")
@export var health_scaling: float = 0.1  # +10% per difficulty level
@export var speed_scaling: float = 0.05  # +5% per difficulty level
@export var damage_scaling: float = 0.12
@export var spawn_rate_scaling: float = 0.01

## Calculate stats at given difficulty level
func get_stats_at_difficulty(difficulty: float) -> Dictionary:
	return {
		"health": base_health * (1.0 + difficulty * health_scaling),
		"speed": base_speed * (1.0 + difficulty * speed_scaling),
		"damage": base_damage * (1.0 + difficulty * damage_scaling),
		"credits": credit_reward
	}
```

**Instance Example**: `resources/enemies/asteroid_data.tres`

---

### 4.4 DifficultyConfig Resource

**Purpose**: Configure dynamic difficulty system parameters

**File**: `difficulty_config.gd` (extends `Resource`)

```gdscript
class_name DifficultyConfig
extends Resource

## Dynamic difficulty system configuration

@export_group("Difficulty Range")
@export var min_difficulty: float = 15.0
@export var max_difficulty: float = 95.0
@export var starting_difficulty: float = 20.0

@export_group("Scaling Triggers")
@export var scale_up_shield_threshold: float = 0.7  # 70% shield
@export var scale_up_duration: float = 30.0  # seconds
@export var scale_down_shield_threshold: float = 0.3  # 30% shield
@export var scale_down_duration: float = 10.0

@export_group("Scaling Rates")
@export var scale_up_rate: float = 5.0  # difficulty points per interval
@export var scale_down_rate: float = 15.0
@export var time_modifier: float = 2.0  # +2 difficulty per minute

@export_group("Performance Weights")
@export var accuracy_weight: float = 0.3
@export var survival_weight: float = 0.4
@export var collection_weight: float = 0.2
@export var destruction_weight: float = 0.1

@export_group("Update Frequency")
@export var metrics_sample_interval: float = 5.0  # seconds
@export var difficulty_update_interval: float = 10.0
@export var max_change_per_update: float = 5.0
```

**Instance**: `resources/difficulty/default_difficulty.tres`

---

## 5. Component System

### 5.1 HealthComponent

**Purpose**: Reusable health/shield management

**File**: `scripts/components/health_component.gd`

```gdscript
class_name HealthComponent
extends Node

## Reusable health/shield component with regeneration

signal health_changed(current: float, maximum: float)
signal damage_taken(amount: float)
signal died
signal regeneration_started
signal regeneration_stopped

@export var max_health: float = 100.0
@export var regeneration_rate: float = 5.0  # per second
@export var regeneration_delay: float = 3.0  # seconds after damage
@export var auto_regenerate: bool = true

var current_health: float
var _regen_timer: float = 0.0
var _is_regenerating: bool = false

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if not auto_regenerate:
		return

	# Handle regeneration delay
	if _regen_timer > 0:
		_regen_timer -= delta
		if _regen_timer <= 0 and not _is_regenerating:
			_is_regenerating = true
			regeneration_started.emit()

	# Regenerate health
	if _is_regenerating and current_health < max_health:
		var old_health = current_health
		current_health = min(max_health, current_health + regeneration_rate * delta)
		if current_health != old_health:
			health_changed.emit(current_health, max_health)

		if current_health >= max_health:
			_is_regenerating = false
			regeneration_stopped.emit()

func take_damage(amount: float) -> void:
	current_health -= amount
	_regen_timer = regeneration_delay
	_is_regenerating = false
	regeneration_stopped.emit()
	damage_taken.emit(amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0.0
```

**Usage**: Add as child node to Player, Enemies, etc. Configure via exported properties.

---

### 5.2 MovementComponent

**Purpose**: Reusable inertia-based movement with screen wrapping

**File**: `scripts/components/movement_component.gd`

```gdscript
class_name MovementComponent
extends Node

## Inertia-based movement with screen wrapping

@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var rotation_speed: float = 3.0
@export var enable_screen_wrap: bool = true

var velocity: Vector2 = Vector2.ZERO
var _body: CharacterBody2D

func _ready() -> void:
	_body = get_parent() as CharacterBody2D
	assert(_body != null, "MovementComponent must be child of CharacterBody2D")

func apply_thrust(direction: Vector2, delta: float) -> void:
	velocity += direction.normalized() * acceleration * delta
	velocity = velocity.limit_length(speed)

func apply_rotation(amount: float, delta: float) -> void:
	_body.rotation += amount * rotation_speed * delta

func update_movement(delta: float) -> void:
	_body.velocity = velocity
	_body.move_and_slide()

	if enable_screen_wrap:
		_wrap_around_screen()

func _wrap_around_screen() -> void:
	var screen_size = get_viewport_rect().size
	var pos = _body.global_position

	if pos.x < 0:
		pos.x = screen_size.x
	elif pos.x > screen_size.x:
		pos.x = 0

	if pos.y < 0:
		pos.y = screen_size.y
	elif pos.y > screen_size.y:
		pos.y = 0

	_body.global_position = pos
```

---

### 5.3 CollectionComponent

**Purpose**: Auto-collect nearby pickups

**File**: `scripts/components/collection_component.gd`

```gdscript
class_name CollectionComponent
extends Area2D

## Auto-collects nearby pickups within radius

signal item_collected(item: Node)

@export var collection_radius: float = 2.0

func _ready() -> void:
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	_update_radius()

func set_radius(new_radius: float) -> void:
	collection_radius = new_radius
	_update_radius()

func _update_radius() -> void:
	if not is_inside_tree():
		await ready

	# Assuming CollisionShape2D child with CircleShape2D
	var shape = $CollisionShape2D as CollisionShape2D
	if shape and shape.shape is CircleShape2D:
		shape.shape.radius = collection_radius * 16  # Convert to pixels

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("pickup"):
		item_collected.emit(body)
		body.queue_free()
```

---

## 6. Gameplay Systems

### 6.1 Player System

**Scene**: `scenes/gameplay/player/player.tscn`

**Structure**:
```
Player (CharacterBody2D)
├── Sprite2D (triangle ship)
├── CollisionShape2D
├── HealthComponent
├── MovementComponent
├── CollectionComponent
├── WeaponSystem
└── Camera2D
```

**Script**: `player.gd`

```gdscript
class_name Player
extends CharacterBody2D

signal died

@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var collector: CollectionComponent = $CollectionComponent
@onready var weapon: WeaponSystem = $WeaponSystem

func _ready() -> void:
	_apply_upgrade_stats()
	health.died.connect(_on_death)
	collector.item_collected.connect(_on_item_collected)

func _apply_upgrade_stats() -> void:
	var stats = UpgradeSystem.get_final_stats()
	health.max_health = stats.max_shield
	health.regeneration_rate = stats.shield_regen
	health.regeneration_delay = stats.shield_delay
	movement.speed = stats.move_speed
	movement.acceleration = stats.acceleration
	weapon.fire_rate = stats.fire_rate
	weapon.damage = stats.damage
	weapon.projectile_speed = stats.projectile_speed
	collector.set_radius(stats.collection_radius)

func _physics_process(delta: float) -> void:
	_handle_input(delta)
	movement.update_movement(delta)

func _handle_input(delta: float) -> void:
	# Thrust
	if Input.is_action_pressed("thrust_forward"):
		var direction = Vector2.UP.rotated(rotation)
		movement.apply_thrust(direction, delta)

	# Rotation
	var rotation_input = Input.get_axis("rotate_left", "rotate_right")
	movement.apply_rotation(rotation_input, delta)

	# Shooting
	if Input.is_action_pressed("fire"):
		weapon.fire()

func _on_death() -> void:
	died.emit()
	GameManager.end_game()

func _on_item_collected(item: Node) -> void:
	# Handle pickup collection
	pass
```

**Benefits**:
- Components handle all logic
- Stats applied from UpgradeSystem
- Easy to test and extend

---

### 6.2 Weapon System

**Scene**: Add as child to Player

**Script**: `weapon_system.gd`

```gdscript
class_name WeaponSystem
extends Node2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 2.0
@export var damage: float = 10.0
@export var projectile_speed: float = 15.0
@export var muzzle_offset: float = 20.0

var _fire_timer: float = 0.0

func _process(delta: float) -> void:
	if _fire_timer > 0:
		_fire_timer -= delta

func fire() -> void:
	if _fire_timer > 0:
		return

	_fire_timer = 1.0 / fire_rate
	_spawn_projectile()
	ScoreManager.record_shot(false)  # Will update if hits

func _spawn_projectile() -> void:
	var projectile = projectile_scene.instantiate()
	var spawn_pos = global_position + Vector2.UP.rotated(global_rotation) * muzzle_offset

	projectile.global_position = spawn_pos
	projectile.global_rotation = global_rotation
	projectile.damage = damage
	projectile.speed = projectile_speed

	get_tree().current_scene.add_child(projectile)
```

---

### 6.3 Spawner System

**Purpose**: Spawn hazards based on difficulty

**Script**: `spawners/asteroid_spawner.gd`

```gdscript
class_name AsteroidSpawner
extends Node

@export var asteroid_data: EnemyDefinition
@export var base_spawn_interval: float = 2.0

var _spawn_timer: float = 0.0

func _ready() -> void:
	GameManager.difficulty_changed.connect(_on_difficulty_changed)

func _process(delta: float) -> void:
	if not GameManager.is_playing:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_asteroid()
		_spawn_timer = _calculate_spawn_interval()

func _spawn_asteroid() -> void:
	var asteroid = asteroid_data.scene.instantiate()

	# Random spawn position at screen edge
	var spawn_pos = _get_random_edge_position()
	var stats = asteroid_data.get_stats_at_difficulty(GameManager.current_difficulty)

	asteroid.global_position = spawn_pos
	asteroid.initialize(stats)

	get_tree().current_scene.add_child(asteroid)

func _calculate_spawn_interval() -> float:
	var difficulty_modifier = 1.0 - min(GameManager.current_difficulty * 0.01, 0.75)
	return base_spawn_interval * difficulty_modifier

func _get_random_edge_position() -> Vector2:
	var screen_size = get_viewport_rect().size
	var edge = randi() % 4

	match edge:
		0: return Vector2(randf() * screen_size.x, 0)  # Top
		1: return Vector2(screen_size.x, randf() * screen_size.y)  # Right
		2: return Vector2(randf() * screen_size.x, screen_size.y)  # Bottom
		_: return Vector2(0, randf() * screen_size.y)  # Left

func _on_difficulty_changed(_new_difficulty: float) -> void:
	# Optionally adjust spawn behavior
	pass
```

**Benefits**:
- Data-driven via `EnemyDefinition`
- Automatically responds to difficulty changes
- Easy to add new enemy types

---

## 7. UI System

### 7.1 HUD

**Scene**: `scenes/ui/hud.tscn` (CanvasLayer)

**Structure**:
```
HUD (CanvasLayer)
├── MarginContainer
│   ├── VBoxContainer
│   │   ├── TopBar (HBoxContainer)
│   │   │   ├── ScoreLabel
│   │   │   └── TimeLabel
│   │   └── BottomBar (HBoxContainer)
│   │       ├── ShieldBar (ProgressBar)
│   │       └── CrystalLabel
```

**Script**: `hud.gd`

```gdscript
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel
@onready var shield_bar: ProgressBar = %ShieldBar
@onready var crystal_label: Label = %CrystalLabel

func _ready() -> void:
	ScoreManager.score_updated.connect(_on_score_updated)
	ScoreManager.stat_changed.connect(_on_stat_changed)

	var player = get_tree().get_first_node_in_group("player")
	if player and player.health:
		player.health.health_changed.connect(_on_health_changed)

func _process(_delta: float) -> void:
	time_label.text = "Time: %.1f" % GameManager.survival_time

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_health_changed(current: float, maximum: float) -> void:
	shield_bar.value = (current / maximum) * 100.0

func _on_stat_changed(stat_name: String, value: Variant) -> void:
	if stat_name == "crystals_collected":
		crystal_label.text = "Crystals: %d" % value
```

---

### 7.2 Upgrade Shop

**Scene**: `scenes/ui/upgrade_shop.tscn`

**Structure**:
```
UpgradeShop (Control)
├── PanelContainer
│   ├── VBoxContainer
│   │   ├── TitleLabel
│   │   ├── CreditLabel
│   │   ├── ItemGrid (GridContainer)
│   │   └── BackButton
```

**Script**: `upgrade_shop.gd`

```gdscript
extends Control

@export var item_card_scene: PackedScene
@export var available_items: Array[ItemDefinition] = []

@onready var item_grid: GridContainer = %ItemGrid
@onready var credit_label: Label = %CreditLabel

var _current_credits: int = 0

func _ready() -> void:
	_load_available_items()
	_populate_grid()
	UpgradeSystem.stats_updated.connect(_on_stats_updated)

func show_shop(credits: int) -> void:
	_current_credits = credits
	credit_label.text = "Credits: %d" % credits
	visible = true

func _load_available_items() -> void:
	# Load all ItemDefinition resources from resources/items/
	var defensive_items = _load_items_from_dir("res://Src/resources/items/defensive/")
	var offensive_items = _load_items_from_dir("res://Src/resources/items/offensive/")
	var utility_items = _load_items_from_dir("res://Src/resources/items/utility/")

	available_items = defensive_items + offensive_items + utility_items

func _load_items_from_dir(path: String) -> Array[ItemDefinition]:
	var items: Array[ItemDefinition] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item = load(path + file_name) as ItemDefinition
				if item:
					items.append(item)
			file_name = dir.get_next()
	return items

func _populate_grid() -> void:
	# Clear existing
	for child in item_grid.get_children():
		child.queue_free()

	# Create cards for each item
	for item in available_items:
		var card = item_card_scene.instantiate()
		card.setup(item, UpgradeSystem.item_levels.get(item, 0))
		card.purchase_requested.connect(_on_purchase_requested.bind(item))
		item_grid.add_child(card)

func _on_purchase_requested(item: ItemDefinition) -> void:
	var current_level = UpgradeSystem.item_levels.get(item, 0)
	var cost = item.get_cost_at_level(current_level + 1)

	if _current_credits >= cost:
		if UpgradeSystem.upgrade_item(item):
			_current_credits -= cost
			credit_label.text = "Credits: %d" % _current_credits
			_populate_grid()  # Refresh

func _on_stats_updated(_new_stats: Dictionary) -> void:
	_populate_grid()
```

**Benefits**:
- **Automatically discovers new items** from file system
- No code changes to add items
- Designer-friendly

---

## 8. Infinite Progression Implementation

### 8.1 UpgradeSystem Implementation

**Full Implementation**: `autoload/upgrade_system.gd`

```gdscript
extends Node

signal item_purchased(item: ItemDefinition)
signal item_upgraded(item: ItemDefinition, new_level: int)
signal stats_updated(new_stats: Dictionary)

@export var base_ship_stats: ShipStats

# Persistent data
var equipped_items: Array[ItemDefinition] = []
var item_levels: Dictionary = {}  # ItemDefinition -> int
var unlocked_slots: int = 4
var total_credits_spent: int = 0

func _ready() -> void:
	_load_progression()

## Get final calculated ship stats with all bonuses
func get_final_stats() -> Dictionary:
	var base_stats = base_ship_stats.calculate_stats({
		"defense": 0,
		"mobility": 0,
		"offense": 0,
		"utility": 0
	})

	# Apply item bonuses
	for item in equipped_items:
		var level = item_levels.get(item, 0)
		if level > 0:
			item.apply_to_stats(base_stats, level)

	return base_stats

## Upgrade an item to the next level
func upgrade_item(item: ItemDefinition) -> bool:
	var current_level = item_levels.get(item, 0)
	var cost = item.get_cost_at_level(current_level + 1)

	# Check if can afford (caller manages credits)
	item_levels[item] = current_level + 1
	total_credits_spent += cost

	# Auto-equip if not already equipped and slots available
	if not item in equipped_items and equipped_items.size() < unlocked_slots:
		equipped_items.append(item)

	item_upgraded.emit(item, current_level + 1)
	stats_updated.emit(get_final_stats())
	_save_progression()
	return true

## Equip/unequip items
func equip_item(item: ItemDefinition, slot_index: int) -> void:
	if slot_index >= unlocked_slots:
		return

	while equipped_items.size() <= slot_index:
		equipped_items.append(null)

	equipped_items[slot_index] = item
	stats_updated.emit(get_final_stats())
	_save_progression()

func unequip_item(slot_index: int) -> void:
	if slot_index < equipped_items.size():
		equipped_items[slot_index] = null
		stats_updated.emit(get_final_stats())
		_save_progression()

## Unlock additional item slot
func unlock_slot(cost: int) -> bool:
	unlocked_slots += 1
	total_credits_spent += cost
	_save_progression()
	return true

func _save_progression() -> void:
	SaveSystem.save_game()

func _load_progression() -> void:
	SaveSystem.load_game()
```

---

## 9. Performance Optimization Strategies

### 9.1 Object Pooling

**Purpose**: Reuse projectiles and particles instead of instantiate/free

**Script**: `scripts/utilities/object_pool.gd`

```gdscript
class_name ObjectPool
extends Node

@export var pooled_scene: PackedScene
@export var initial_size: int = 20
@export var grow_size: int = 10

var _pool: Array[Node] = []
var _active: Array[Node] = []

func _ready() -> void:
	_grow_pool(initial_size)

func get_object() -> Node:
	var obj: Node = null

	if _pool.is_empty():
		_grow_pool(grow_size)

	obj = _pool.pop_back()
	_active.append(obj)
	obj.set_process(true)
	obj.set_physics_process(true)
	obj.show()

	return obj

func return_object(obj: Node) -> void:
	if obj in _active:
		_active.erase(obj)
		_pool.append(obj)
		obj.set_process(false)
		obj.set_physics_process(false)
		obj.hide()

func _grow_pool(amount: int) -> void:
	for i in amount:
		var obj = pooled_scene.instantiate()
		add_child(obj)
		obj.set_process(false)
		obj.set_physics_process(false)
		obj.hide()
		_pool.append(obj)
```

**Usage**:
```gdscript
# In game_world.tscn, add ObjectPool nodes
@onready var projectile_pool: ObjectPool = $ProjectilePool

func spawn_projectile():
	var proj = projectile_pool.get_object()
	proj.global_position = spawn_pos
	# When projectile expires, call projectile_pool.return_object(proj)
```

---

### 9.2 Disable Unnecessary Processing

**Pattern**: Turn off `_process`/`_physics_process` when not needed

```gdscript
# In spawner scripts
func _on_game_paused() -> void:
	set_process(false)

func _on_game_resumed() -> void:
	set_process(true)
```

---

## 10. Extensibility Patterns

### 10.1 Adding New Items (Zero Code Changes)

**Steps**:
1. Open Godot editor
2. Navigate to `Src/resources/items/[category]/`
3. Create new `ItemDefinition` resource
4. Fill in exported properties:
   - `item_name`, `description`, `icon`
   - `affected_stats` (e.g., `["fire_rate", "damage"]`)
   - `base_bonus`, `bonus_per_level`
   - `base_cost`, `cost_exponent`
5. Save as `.tres`
6. Item automatically appears in upgrade shop

**Result**: No scripts modified, no rebuild needed.

---

### 10.2 Adding New Enemy Types

**Steps**:
1. Create enemy scene (e.g., `enemy_laser_drone.tscn`)
2. Create `EnemyDefinition` resource (`laser_drone_data.tres`)
3. Set `scene` property to point to your scene
4. Configure base stats and scaling formulas
5. Add to spawner's enemy pool

**Code Impact**: Only modify spawner to include new enemy definition.

---

### 10.3 Modifying Difficulty Curve

**Steps**:
1. Open `resources/difficulty/default_difficulty.tres`
2. Adjust exported properties in editor
3. Test immediately

**Code Impact**: Zero

---

### 10.4 Adding New Ship Stats

**Steps**:
1. Add new property to `ShipStats.calculate_stats()`:
   ```gdscript
   "crit_chance": base_crit_chance + levels.get("offense", 0) * crit_per_level
   ```
2. Add corresponding `@export` variables for base value and scaling
3. Items can now target this stat via `affected_stats`

**Code Impact**: Modify one function, data layer handles rest.

---

## 11. Testing Strategy

### 11.1 Unit Tests (GUT Framework)

**Setup**: Use [GUT (Godot Unit Test)](https://github.com/bitwes/Gut)

**Example Test**: `tests/test_item_definition.gd`

```gdscript
extends GutTest

var item: ItemDefinition

func before_each():
	item = ItemDefinition.new()
	item.base_cost = 100
	item.cost_exponent = 1.15
	item.base_bonus = 0.25
	item.bonus_per_level = 0.02

func test_cost_scaling():
	assert_eq(item.get_cost_at_level(1), 100)
	assert_almost_eq(item.get_cost_at_level(10), 404.5, 1.0)

func test_bonus_scaling():
	assert_eq(item.get_bonus_at_level(1), 0.25)
	assert_eq(item.get_bonus_at_level(10), 0.45)
```

---

### 11.2 Integration Tests

**Test Scenarios**:
- Player takes damage → shield decreases → regen starts after delay
- Item purchased → stats update → player reflects changes
- Difficulty scales up → enemies spawn faster → enemies have higher stats

---

### 11.3 Playtesting Tools

**Debug HUD**: Create debug overlay showing:
- Current difficulty level
- Performance metrics
- Active spawners and rates
- Item effects breakdown

**Script**: `debug_hud.gd`

```gdscript
extends CanvasLayer

@onready var debug_label: Label = $DebugLabel

func _process(_delta: float) -> void:
	if not OS.is_debug_build():
		visible = false
		return

	debug_label.text = """
	Difficulty: %.1f
	Survival: %.1f
	Accuracy: %.1f%%
	Active Objects: %d
	""" % [
		GameManager.current_difficulty,
		GameManager.survival_time,
		ScoreManager.accuracy * 100.0,
		get_tree().current_scene.get_child_count()
	]
```

---

## 12. Build and Deployment

### 12.1 Export Presets

**Mobile (Android/iOS)**:
- Enable **Mobile Renderer**
- Optimize texture import (compress, mipmaps)
- Set target API levels
- Configure permissions (vibration for haptics)

**PC**:
- Use **Forward+ Renderer**
- Include debug console
- Support keyboard + gamepad

---

### 12.2 Performance Targets

| Platform | Target FPS | Max Memory | Load Time |
|----------|-----------|------------|-----------|
| Mobile (Mid-range) | 60 FPS | 150 MB | < 3s |
| PC | 120+ FPS | 300 MB | < 2s |

---

## 13. Future Extensibility

### 13.1 Modding Support (Future)

**Pattern**: All game data is in `Resource` files (`.tres`)
- Export data as JSON for community modding
- Load custom item definitions at runtime
- Workshop integration

---

### 13.2 Multiplayer (Future)

**Architecture Ready**:
- Signal-based events easy to network
- Component-based entities can be synced via `MultiplayerSynchronizer`
- Authoritative server model fits difficulty system

---

## 14. Summary: Why This Architecture Excels

### 14.1 Data-Driven Benefits

✅ **Add items**: Create `.tres` file → Done
✅ **Balance gameplay**: Edit resource properties → Test instantly
✅ **New enemies**: Create scene + resource → Works automatically
✅ **Tune difficulty**: Adjust sliders in editor → No rebuild

### 14.2 Modular Components

✅ **Reusability**: HealthComponent used for player, enemies, asteroids
✅ **Testing**: Test components in isolation
✅ **Maintenance**: Bug fixes in one place benefit all users

### 14.3 Signal-Based Decoupling

✅ **HUD updates**: Listens to score signals, no tight coupling
✅ **Game state**: GameManager emits events, systems respond
✅ **Extensibility**: Add new listeners without modifying emitters

### 14.4 Infinite Progression via Math

✅ **No level caps**: Formulas scale infinitely
✅ **Balanced**: Exponential costs + diminishing returns
✅ **Predictable**: Players can plan ahead with transparent math

---

## 15. Next Steps for Implementation

### Phase 1: Core Foundation (Week 1)
1. Set up project structure and autoloads
2. Implement `ShipStats`, `ItemDefinition`, `EnemyDefinition` resources
3. Create HealthComponent, MovementComponent
4. Basic Player + input handling

### Phase 2: Gameplay Loop (Week 2)
5. Asteroid spawning and destruction
6. Weapon system with object pooling
7. Dynamic difficulty system
8. Basic HUD

### Phase 3: Progression (Week 3)
9. UpgradeSystem implementation
10. Upgrade shop UI
11. SaveSystem
12. Item creation (10+ items)

### Phase 4: Polish (Week 4)
13. VFX and audio
14. Enemy types (UFO, Comet, Black Holes)
15. Achievements
16. Balancing and playtesting

---

## 16. Appendix: Quick Reference

### 16.1 Key File Paths

| System | Path |
|--------|------|
| Autoloads | `Src/autoload/*.gd` |
| Ship Stats | `Src/resources/ship_parameters/base_ship_stats.tres` |
| Items | `Src/resources/items/[category]/*.tres` |
| Enemies | `Src/resources/enemies/*.tres` |
| Difficulty | `Src/resources/difficulty/default_difficulty.tres` |

### 16.2 Signal Reference

| Signal | Emitter | Purpose |
|--------|---------|---------|
| `game_started` | GameManager | Game begins |
| `difficulty_changed` | GameManager | Difficulty updates |
| `stats_updated` | UpgradeSystem | Player stats change |
| `health_changed` | HealthComponent | Health/shield updates |
| `died` | Player/Enemies | Entity death |
| `score_updated` | ScoreManager | Score changes |

### 16.3 Resource Types

| Resource | Extends | Purpose |
|----------|---------|---------|
| ShipStats | Resource | Base ship parameters |
| ItemDefinition | Resource | Upgrade items |
| EnemyDefinition | Resource | Enemy types |
| DifficultyConfig | Resource | Difficulty system config |

---

**End of Technical Specification**

*This architecture ensures Void Survivor can grow infinitely while remaining maintainable, testable, and designer-friendly. All core systems are data-driven, allowing rapid iteration without code changes.*
