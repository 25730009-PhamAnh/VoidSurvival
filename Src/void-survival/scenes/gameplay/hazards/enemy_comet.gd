class_name EnemyComet
extends RigidBody2D

## Comet enemy that charges at player after telegraphing

signal destroyed(score_value: int, crystal_count: int, death_position: Vector2)
signal damaged(amount: int)

@onready var charge_timer: Timer = $ChargeTimer
@onready var telegraph_sprite: Sprite2D = $TelegraphSprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent

# Stats
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
	contact_monitor = true
	max_contacts_reported = 4

	# Start with random drift
	var drift_direction = Vector2.RIGHT.rotated(randf() * TAU)
	linear_velocity = drift_direction * speed

	# Start charge timer
	charge_timer.timeout.connect(_on_charge_timer_timeout)
	charge_timer.wait_time = randf_range(2.0, 4.0)
	charge_timer.start()

	telegraph_sprite.visible = false

	# Connect collision signal
	body_entered.connect(_on_body_entered)

	# Connect component signals
	if health_component:
		health_component.damaged.connect(_on_health_component_damaged)
		health_component.died.connect(_on_health_component_died)

func initialize(stats: Dictionary) -> void:
	if health_component:
		health_component.max_health = stats.health
		health_component.current_health = stats.health
	speed = stats.speed
	charge_speed = stats.speed * 8.0  # Charge is 8x base speed
	damage = stats.damage
	score = stats.score
	crystals = stats.crystals

func _physics_process(delta: float) -> void:
	match _state:
		State.DRIFTING:
			# Face the direction of movement
			if linear_velocity.length() > 0:
				rotation = linear_velocity.angle()

		State.TELEGRAPHING:
			_telegraph_timer += delta

			# Smoothly rotate to face the charge direction
			var target_angle = _charge_direction.angle()
			rotation = lerp_angle(rotation, target_angle, delta * 5.0)  # Smooth rotation

			# Flash telegraph sprite
			telegraph_sprite.modulate.a = 0.5 + 0.5 * sin(_telegraph_timer * 10.0)

			if _telegraph_timer >= _telegraph_duration:
				_execute_charge()

		State.CHARGING:
			# Face the direction of movement while charging
			if linear_velocity.length() > 0:
				rotation = linear_velocity.angle()

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

	# Show telegraph (rotation handled by parent in _physics_process)
	telegraph_sprite.visible = true

	# Stop drifting
	linear_velocity = Vector2.ZERO

func _execute_charge() -> void:
	_state = State.CHARGING
	telegraph_sprite.visible = false

	# Apply massive impulse
	apply_central_impulse(_charge_direction * charge_speed * mass)

	# After charge, return to drifting
	await get_tree().create_timer(3.0).timeout
	if _state == State.CHARGING and is_inside_tree():  # Check still alive and in scene
		_state = State.DRIFTING
		linear_velocity = _charge_direction * speed
		charge_timer.start()

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
	# Collision damage
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var collision_damage = damage
			if _state == State.CHARGING:
				collision_damage *= 1.5  # 50% more damage when charging
			body.take_damage(collision_damage)
		# Comet survives collision but loses health
		if health_component:
			take_damage(health_component.max_health * 0.3)
