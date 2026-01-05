class_name BlackHoleSpawner
extends Node

## Manages black hole spawning based on difficulty and time
##
## Black holes spawn at random intervals, with spawn rate increasing as the game
## progresses. Spawns are limited to a maximum number of active black holes, and
## they won't spawn too close to the player (safe zone).
##
## Early game: Maximum 1 black hole active
## Late game (300s+): Maximum 2 black holes active

@export var black_hole_scene: PackedScene

## Minimum time between spawns (seconds)
@export var min_spawn_interval: float = 45.0

## Maximum time between spawns (seconds)
@export var max_spawn_interval: float = 90.0

## Maximum active black holes in early game
@export var max_active_black_holes: int = 1

## Maximum active black holes in late game
@export var late_game_max: int = 2

## Time threshold for late game (seconds)
@export var late_game_threshold: float = 300.0

## Minimum distance from player for spawning (pixels)
@export var safe_zone_radius: float = 150.0

var _spawn_timer: float = 0.0
var _active_black_holes: Array[BlackHole] = []
var _game_manager: Node = null


func _ready() -> void:
	# Get reference to GameManager
	_game_manager = get_tree().get_first_node_in_group("game_manager")
	if not _game_manager:
		push_warning("BlackHoleSpawner: GameManager not found in scene tree")
	else:
		print("BlackHoleSpawner: GameManager found, is_playing = ", _game_manager.is_playing)

	# Initialize spawn timer
	_schedule_next_spawn()
	print("BlackHoleSpawner: Initial spawn timer set to ", _spawn_timer, " seconds")


func _process(delta: float) -> void:
	# Stop spawning if game is not playing
	if not _game_manager or not _game_manager.is_playing:
		return

	# Update spawn timer
	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_try_spawn_black_hole()
		_schedule_next_spawn()


func _try_spawn_black_hole() -> void:
	"""Attempt to spawn a black hole if conditions are met"""
	print("BlackHoleSpawner: Attempting to spawn black hole...")

	# Clean up destroyed black holes
	_clean_destroyed_black_holes()

	# Check if we're at the maximum active limit
	var max_allowed = _get_max_allowed_black_holes()
	if _active_black_holes.size() >= max_allowed:
		print("BlackHoleSpawner: Already at max active limit (", _active_black_holes.size(), "/", max_allowed, ")")
		return

	# Find a safe spawn position
	var spawn_pos = _get_safe_spawn_position()
	if spawn_pos == Vector2.ZERO:
		push_warning("BlackHoleSpawner: Failed to find safe spawn position")
		return

	# Spawn the black hole
	var black_hole = black_hole_scene.instantiate() as BlackHole
	if not black_hole:
		push_error("BlackHoleSpawner: Failed to instantiate black hole scene")
		return

	# Initialize and add to scene
	black_hole.initialize(spawn_pos)
	black_hole.destroyed.connect(_on_black_hole_destroyed.bind(black_hole))

	# Add to scene tree (same pattern as EnemySpawner)
	get_tree().current_scene.add_child(black_hole)

	# Track in active array
	_active_black_holes.append(black_hole)

	print("BlackHoleSpawner: Successfully spawned black hole at ", spawn_pos)


func _get_safe_spawn_position() -> Vector2:
	"""Find a spawn position away from the player"""
	var screen_size = get_viewport().get_visible_rect().size
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
				continue  # Too close, try again

		return pos

	# Failed to find safe position
	return Vector2.ZERO


func _schedule_next_spawn() -> void:
	"""Calculate the next spawn interval with difficulty scaling"""
	# Base random interval
	var interval = randf_range(min_spawn_interval, max_spawn_interval)

	# Apply difficulty modifier (spawns faster as game progresses)
	if _game_manager:
		var survival_time = _game_manager.current_run_time
		# Up to 40% reduction in spawn interval
		var difficulty_modifier = 1.0 - min(survival_time / 600.0, 0.4)
		interval *= difficulty_modifier

	# Use the calculated interval (no hardcoded minimum - respect export settings)
	_spawn_timer = interval


func _get_max_allowed_black_holes() -> int:
	"""Get maximum allowed black holes based on game time"""
	if not _game_manager:
		return max_active_black_holes

	var survival_time = _game_manager.current_run_time
	if survival_time >= late_game_threshold:
		return late_game_max
	else:
		return max_active_black_holes


func _on_black_hole_destroyed(black_hole: BlackHole) -> void:
	"""Handle black hole destruction"""
	_active_black_holes.erase(black_hole)


func _clean_destroyed_black_holes() -> void:
	"""Remove invalid references from active black holes array"""
	_active_black_holes = _active_black_holes.filter(func(bh): return is_instance_valid(bh))


## Stop spawning black holes
func stop_spawning() -> void:
	set_process(false)


## Resume spawning black holes
func resume_spawning() -> void:
	set_process(true)
	_schedule_next_spawn()
