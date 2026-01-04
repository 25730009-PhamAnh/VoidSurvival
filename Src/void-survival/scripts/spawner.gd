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
	if not asteroid_scene:
		push_error("Spawner: asteroid_scene not set!")
		return

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
