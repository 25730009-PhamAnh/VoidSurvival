class_name Projectile
extends Area2D

var speed: float = 400.0
var damage: float = 10.0
var velocity: Vector2

func _ready() -> void:
	add_to_group("projectile")
	velocity = Vector2.UP.rotated(global_rotation) * speed
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func set_damage(value: float) -> void:
	damage = value

func set_speed(value: float) -> void:
	speed = value
	# Update velocity if already initialized
	if velocity != Vector2.ZERO:
		velocity = Vector2.UP.rotated(global_rotation) * speed

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroid"):
		var asteroid = body as Asteroid
		if asteroid:
			asteroid.take_damage(damage)
			SessionManager.record_shot_hit()
			queue_free()
	elif body.is_in_group("enemies"):
		# Handle enemy damage
		if body.has_method("take_damage"):
			body.take_damage(damage)
			SessionManager.record_shot_hit()
			queue_free()

func _on_screen_exited() -> void:
	queue_free()
