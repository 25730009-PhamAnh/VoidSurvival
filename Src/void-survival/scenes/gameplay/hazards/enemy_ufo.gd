class_name EnemyUFO
extends CharacterBody2D

## UFO enemy with sinusoidal movement and lead targeting

signal destroyed(score_value: int, crystal_count: int, death_position: Vector2)
signal damaged(amount: int)

@export var projectile_scene: PackedScene
@export var shoot_accuracy: float = 0.7  # 0-1, how accurate the lead targeting is
@export var shoot_interval: float = 2.0  # Seconds between shots

@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot_timer: Timer = $ShootTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent

# Stats (set by spawner)
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

	# Load default projectile if not set
	if not projectile_scene:
		projectile_scene = load("res://scenes/prototype/projectile.tscn")

	# Random initial direction
	_base_direction = Vector2.RIGHT.rotated(randf() * TAU)

	# Start shooting
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()

	# Connect component signals
	if health_component:
		health_component.damaged.connect(_on_health_component_damaged)
		health_component.died.connect(_on_health_component_died)

func initialize(stats: Dictionary) -> void:
	if health_component:
		health_component.max_health = stats.health
		health_component.current_health = stats.health
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

	# Rotate to face movement direction
	if velocity.length() > 0:
		rotation = velocity.angle()

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
		var direction = global_position.direction_to(target_pos)
		projectile.rotation = direction.angle()

		# Set projectile properties if they exist
		if projectile.has_method("set_damage"):
			projectile.set_damage(damage * 0.5)  # UFO shots do half damage
		elif "damage" in projectile:
			projectile.damage = damage * 0.5

		get_tree().current_scene.add_child(projectile)

# Convenience wrapper for projectiles
func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)

func _on_health_component_damaged(amount: float) -> void:
	"""Forward component signal to maintain VFX compatibility"""
	damaged.emit(int(amount))

func _on_health_component_died() -> void:
	"""Handle death"""
	destroyed.emit(score, crystals, global_position)
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Collision damage to player
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# UFO dies on collision
		if health_component:
			health_component.take_damage(health_component.max_health)
