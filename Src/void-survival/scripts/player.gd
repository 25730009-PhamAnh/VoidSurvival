class_name Player
extends CharacterBody2D

signal died
signal shield_changed(current: float, maximum: float)

const ACCELERATION = 200.0
const MAX_SPEED = 300.0
const ROTATION_SPEED = 3.0
const FIRE_RATE = 0.5  # seconds between shots
const INVINCIBILITY_TIME = 1.0  # seconds of invincibility after taking damage
const BOUNCE_FORCE = 100.0  # knockback force when hitting asteroid

@export var projectile_scene: PackedScene
@export var max_shield: float = 100.0

var current_shield: float
var _fire_timer: float = 0.0
var _invincibility_timer: float = 0.0

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

	# Invincibility timer
	if _invincibility_timer > 0:
		_invincibility_timer -= delta

func _update_movement(_delta: float) -> void:
	move_and_slide()

	# Check for collisions with asteroids (only if not invincible)
	if _invincibility_timer <= 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and collider.is_in_group("asteroid"):
				var asteroid = collider as Asteroid
				if asteroid:
					# Apply bounce/knockback
					var bounce_direction = collision.get_normal()
					velocity = bounce_direction * BOUNCE_FORCE

					# Take damage
					take_damage(asteroid.collision_damage)
					break  # Only take damage from one asteroid per frame

func _fire() -> void:
	if not projectile_scene:
		push_error("Player: projectile_scene not set!")
		return

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
	else:
		# Activate invincibility after taking damage
		_invincibility_timer = INVINCIBILITY_TIME
