extends RigidBody2D
class_name Crystal

## Floating crystal that responds to collection component attraction
## Emits collected signal when picked up

signal collected(value: int)

@export var crystal_value: int = 1
@export var rotation_speed: float = 2.0
@export var float_amplitude: float = 5.0
@export var float_speed: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collection_particles: CPUParticles2D = $CollectionParticles

var time_elapsed: float = 0.0


func _ready() -> void:
	add_to_group("pickups")

	# Configure physics
	gravity_scale = 0.0
	linear_damp = 2.0

	# Connect to own collected signal
	collected.connect(_on_collected)


func _process(delta: float) -> void:
	time_elapsed += delta

	# Rotate continuously
	sprite.rotation += rotation_speed * delta

	# Float with sine wave motion (applied to sprite, not body, so physics still works)
	var float_offset = sin(time_elapsed * float_speed) * float_amplitude
	sprite.position.y = float_offset


func _on_collected(_value: int) -> void:
	# Play particle effect
	if collection_particles:
		collection_particles.emitting = true
		collection_particles.one_shot = true

	# Hide sprite and disable collision
	sprite.visible = false
	set_deferred("freeze", true)

	# Wait for particles to finish then destroy
	await get_tree().create_timer(0.5).timeout
	queue_free()
