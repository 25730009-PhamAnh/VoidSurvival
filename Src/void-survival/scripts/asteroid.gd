class_name Asteroid
extends RigidBody2D

signal destroyed(score_value: int)

enum Size {LARGE, MEDIUM, SMALL}

# Size configuration constants
const LARGE_HEALTH: float = 10.0
const LARGE_DAMAGE: float = 40.0
const LARGE_SCORE: int = 100
const LARGE_SCALE: float = 1.0

const MEDIUM_HEALTH: float = 5.0
const MEDIUM_DAMAGE: float = 20.0
const MEDIUM_SCORE: int = 50
const MEDIUM_SCALE: float = 0.6

const SMALL_HEALTH: float = 1.0
const SMALL_DAMAGE: float = 10.0
const SMALL_SCORE: int = 25
const SMALL_SCALE: float = 0.35

@export var size: Size = Size.LARGE

var collision_damage: float
var score_value: int
var rotation_speed: float

@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent

func _ready() -> void:
	add_to_group("asteroid")
	_setup_size()
	rotation_speed = randf_range(-1.0, 1.0)
	body_entered.connect(_on_body_entered)

	# Connect component signal
	if health_component:
		health_component.died.connect(_on_health_component_died)

func _setup_size() -> void:
	var health_value: float
	match size:
		Size.LARGE:
			health_value = LARGE_HEALTH
			collision_damage = LARGE_DAMAGE
			score_value = LARGE_SCORE
			scale = Vector2.ONE * LARGE_SCALE
		Size.MEDIUM:
			health_value = MEDIUM_HEALTH
			collision_damage = MEDIUM_DAMAGE
			score_value = MEDIUM_SCORE
			scale = Vector2.ONE * MEDIUM_SCALE
		Size.SMALL:
			health_value = SMALL_HEALTH
			collision_damage = SMALL_DAMAGE
			score_value = SMALL_SCORE
			scale = Vector2.ONE * SMALL_SCALE

	# Configure component health
	if health_component:
		health_component.max_health = health_value
		health_component.current_health = health_value

func _physics_process(delta: float) -> void:
	rotate(rotation_speed * delta)

# Convenience wrapper for projectiles
func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)

func _on_health_component_died() -> void:
	"""Handle death - MUST run before queue_free"""
	# Crystal spawning now handled by PickupSpawnerComponent
	_split()
	destroyed.emit(score_value)
	queue_free()

func _split() -> void:
	if size == Size.SMALL:
		return  # Don't split, just destroy

	var next_size = Size.MEDIUM if size == Size.LARGE else Size.SMALL
	var split_count = 3 if size == Size.LARGE else 2

	for i in split_count:
		var asteroid = duplicate() as Asteroid
		asteroid.size = next_size
		asteroid.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))

		# Random velocity for split pieces
		var angle = (TAU / split_count) * i + randf_range(-0.3, 0.3)
		var speed = randf_range(100, 200)
		asteroid.linear_velocity = Vector2.UP.rotated(angle) * speed

		get_parent().call_deferred("add_child", asteroid)


func _on_body_entered(_body: Node) -> void:
	# Collision with player handled by player script
	pass
