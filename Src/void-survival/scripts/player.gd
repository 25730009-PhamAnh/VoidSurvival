class_name Player
extends CharacterBody2D

signal died
signal shield_changed(current: float, maximum: float)

const ROTATION_SPEED = 3.0
const INVINCIBILITY_TIME = 1.0  # seconds of invincibility after taking damage
const BOUNCE_FORCE = 100.0  # knockback force when hitting asteroid

@export var projectile_scene: PackedScene

# Stats (set from UpgradeSystem)
var max_shield: float = 100.0
var max_speed: float = 300.0
var acceleration: float = 200.0
var fire_rate: float = 2.0  # shots per second
var projectile_damage: float = 10.0
var projectile_speed: float = 400.0

var current_shield: float
var _fire_timer: float = 0.0
var _invincibility_timer: float = 0.0

@onready var shoot_point: Marker2D = $ShootPoint
@onready var collection_component: Area2D = $CollectionComponent

func _ready() -> void:
	# Connect to stat updates
	UpgradeSystem.stats_updated.connect(_on_stats_updated)

	# Apply initial stats
	_apply_stats(UpgradeSystem.get_final_stats())

	# Initialize shield
	current_shield = max_shield
	shield_changed.emit(current_shield, max_shield)

	# Connect collection
	collection_component.item_collected.connect(_on_item_collected)


func _on_stats_updated() -> void:
	_apply_stats(UpgradeSystem.get_final_stats())


func _apply_stats(stats: Dictionary) -> void:
	max_shield = stats.max_shield
	max_speed = stats.move_speed
	acceleration = stats.acceleration
	fire_rate = stats.fire_rate
	projectile_damage = stats.damage
	projectile_speed = stats.projectile_speed

	# Update collection radius
	if collection_component and collection_component.has_method("set_radius"):
		collection_component.set_radius(stats.collection_radius)

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
		velocity += direction * acceleration * delta
		velocity = velocity.limit_length(max_speed)

	# Auto-fire
	if _fire_timer > 0:
		_fire_timer -= delta
	else:
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

	_fire_timer = 1.0 / fire_rate  # Convert shots-per-second to delay
	SessionManager.record_shot_fired()

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.global_rotation = global_rotation

	# Apply stats to projectile
	if projectile.has_method("set_damage"):
		projectile.set_damage(projectile_damage)
	if projectile.has_method("set_speed"):
		projectile.set_speed(projectile_speed)

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
	SessionManager.record_damage_taken(amount)
	shield_changed.emit(current_shield, max_shield)

	if current_shield <= 0:
		died.emit()
		queue_free()
	else:
		# Activate invincibility after taking damage
		_invincibility_timer = INVINCIBILITY_TIME


func _on_item_collected(item: Node2D, value: int) -> void:
	if item.has_signal("collected"):
		item.collected.emit(value)
	ResourceManager.add_crystals(value)
	SessionManager.record_crystal_collected(value)
