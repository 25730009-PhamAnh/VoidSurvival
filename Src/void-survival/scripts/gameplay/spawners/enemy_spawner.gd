class_name EnemySpawner
extends Node

## Spawns enemy types (UFO, Comet) based on difficulty and intervals

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

# Reference to game manager for scoring
var _game_manager: GameManager = null

func _ready() -> void:
	# Load enemy definitions if not set in editor
	if enemy_definitions.is_empty():
		_load_enemy_definitions()

	# Get game manager reference
	_game_manager = get_tree().get_first_node_in_group("game_manager")

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
	if not enabled or not _game_manager or not _game_manager.is_playing:
		return

	# Simple difficulty based on survival time
	_current_difficulty = _game_manager.current_run_time / 10.0  # +1 difficulty per 10 seconds

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
	var screen_size = get_viewport().get_visible_rect().size
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

func _on_enemy_destroyed(score: int, crystals: int, position: Vector2, type: EnemyDefinition.EnemyType) -> void:
	# Update tracking
	match type:
		EnemyDefinition.EnemyType.UFO:
			_active_ufos = max(0, _active_ufos - 1)
		EnemyDefinition.EnemyType.COMET:
			_active_comets = max(0, _active_comets - 1)

	# Award score
	if _game_manager:
		_game_manager.add_score(score)

	# Crystal spawning now handled by PickupSpawnerComponent on enemy

	# Track in session manager
	SessionManager.record_enemy_destroyed()
