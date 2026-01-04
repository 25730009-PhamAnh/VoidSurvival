class_name Asteroid
extends RigidBody2D

signal destroyed(score_value: int)

enum Size {LARGE, MEDIUM, SMALL}

@export var size: Size = Size.LARGE

var health: float
var collision_damage: float
var score_value: int
var rotation_speed: float

func _ready() -> void:
	add_to_group("asteroid")
	_setup_size()
	rotation_speed = randf_range(-1.0, 1.0)
	body_entered.connect(_on_body_entered)

func _setup_size() -> void:
	match size:
		Size.LARGE:
			health = 30.0
			collision_damage = 40.0
			score_value = 100
			scale = Vector2.ONE * 1.0
		Size.MEDIUM:
			health = 15.0
			collision_damage = 20.0
			score_value = 50
			scale = Vector2.ONE * 0.6
		Size.SMALL:
			health = 5.0
			collision_damage = 10.0
			score_value = 25
			scale = Vector2.ONE * 0.35

func _physics_process(delta: float) -> void:
	rotate(rotation_speed * delta)
	_wrap_around_screen()

func _wrap_around_screen() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var pos = global_position

	if pos.x < -50:
		pos.x = screen_size.x + 50
	elif pos.x > screen_size.x + 50:
		pos.x = -50

	if pos.y < -50:
		pos.y = screen_size.y + 50
	elif pos.y > screen_size.y + 50:
		pos.y = -50

	global_position = pos

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
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
