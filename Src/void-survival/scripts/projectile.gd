class_name Projectile
extends Area2D

const SPEED = 400.0
const DAMAGE = 10.0

var velocity: Vector2

func _ready() -> void:
	velocity = Vector2.UP.rotated(global_rotation) * SPEED
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroid"):
		var asteroid = body as Asteroid
		if asteroid:
			asteroid.take_damage(DAMAGE)
			queue_free()

func _on_screen_exited() -> void:
	queue_free()
