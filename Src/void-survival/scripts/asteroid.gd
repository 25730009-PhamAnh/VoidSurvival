class_name Asteroid
extends RigidBody2D

signal destroyed(score_value: int)

enum Size {LARGE, MEDIUM, SMALL}

@export var size: Size = Size.LARGE
@export var crystal_scene: PackedScene

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
			health_value = 30.0
			collision_damage = 40.0
			score_value = 100
			scale = Vector2.ONE * 1.0
		Size.MEDIUM:
			health_value = 15.0
			collision_damage = 20.0
			score_value = 50
			scale = Vector2.ONE * 0.6
		Size.SMALL:
			health_value = 5.0
			collision_damage = 10.0
			score_value = 25
			scale = Vector2.ONE * 0.35

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
	_spawn_crystals()
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


func _spawn_crystals() -> void:
	if not crystal_scene:
		return

	var crystal_count = 0
	match size:
		Size.LARGE: crystal_count = randi_range(3, 5)
		Size.MEDIUM: crystal_count = randi_range(2, 3)
		Size.SMALL: crystal_count = 1

	for i in crystal_count:
		var crystal = crystal_scene.instantiate()
		crystal.global_position = global_position + Vector2(
			randf_range(-15, 15),
			randf_range(-15, 15)
		)
		get_parent().call_deferred("add_child", crystal)


func _on_body_entered(_body: Node) -> void:
	# Collision with player handled by player script
	pass
