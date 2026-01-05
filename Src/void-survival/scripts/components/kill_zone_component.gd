class_name KillZoneComponent
extends Area2D

## Reusable component for instant-death zones
##
## Detects bodies within a kill zone radius and triggers instant death
## through massive damage to HealthComponent or direct queue_free.
## Emits signals with mass information for absorption tracking.
##
## Usage pattern:
## - Parent connects to object_killed signal to track mass/score
## - Component independently filters what types of bodies to affect
## - Works alongside other components (GravitationalComponent, etc.)

signal object_killed(body: Node2D, mass: float)
signal kill_attempted(body: Node2D)

@export_group("Kill Zone")
## Radius at which objects are instantly destroyed
@export var kill_zone_radius: float = 20.0:
	set(value):
		kill_zone_radius = value
		_update_collision_shape()

## Damage amount to deal to HealthComponent (instant kill)
@export var massive_damage_amount: float = 999999.0

@export_group("Type Filtering")
## Whether the player is affected by kill zone
@export var affects_player: bool = true

## Whether asteroids are affected by kill zone
@export var affects_asteroids: bool = true

## Whether enemies are affected by kill zone
@export var affects_enemies: bool = true

## Whether projectiles are affected by kill zone
@export var affects_projectiles: bool = true

@export_group("Mass Calculation")
## Mass values for different entity types (used for absorption tracking)
@export var player_mass: float = 20.0
@export var asteroid_mass: float = 10.0
@export var enemy_mass: float = 15.0
@export var projectile_mass: float = 0.5
@export var default_mass: float = 1.0

var _detected_bodies: Array[Node2D] = []


func _ready() -> void:
	# Set up Area2D for kill zone detection
	monitoring = true
	monitorable = false

	# Collision setup: detect all relevant layers
	# Layer 0: Don't collide physically (detection only)
	# Mask: Detect player(1), asteroids/enemies(2), projectiles(4)
	collision_layer = 0
	collision_mask = 0b1111  # Layers 1, 2, 3, 4

	# Configure collision shape
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		if not collision_shape.shape:
			var circle = CircleShape2D.new()
			circle.radius = kill_zone_radius
			collision_shape.shape = circle
		elif collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = kill_zone_radius
	else:
		# Fallback: create collision shape
		push_warning("KillZoneComponent: CollisionShape2D not found in scene, creating dynamically")
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = kill_zone_radius
		shape.shape = circle
		add_child(shape)

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Check detected bodies and kill them
	for body in _detected_bodies:
		if not is_instance_valid(body):
			continue

		if not _should_affect_body(body):
			continue

		# Kill the body
		_kill_body(body)

func set_kill_zone_radius(radius: float) -> void:
	"""Update kill zone radius dynamically"""
	kill_zone_radius = radius


func _should_affect_body(body: Node2D) -> bool:
	"""Check if this body should be affected by kill zone"""
	if body.is_in_group("player"):
		return affects_player
	elif body.is_in_group("asteroid"):
		return affects_asteroids
	elif body.is_in_group("enemies"):
		return affects_enemies
	elif body.is_in_group("projectile"):
		return affects_projectiles

	# Default: affect all other bodies
	return true


func _kill_body(body: Node2D) -> void:
	"""Handle instant death of body"""
	# Calculate mass for absorption tracking
	var mass = _calculate_mass(body)

	# Emit signals BEFORE destruction
	kill_attempted.emit(body)
	object_killed.emit(body, mass)

	# Remove from tracking immediately to prevent double-kill
	_detected_bodies.erase(body)

	# Apply death through HealthComponent if available
	if body.has_node("HealthComponent"):
		var health_comp = body.get_node("HealthComponent")
		# Deal massive damage to trigger normal death sequence
		# This allows asteroids to split, enemies to emit destroyed signal, etc.
		health_comp.take_damage(massive_damage_amount)
	else:
		# Fallback: direct destruction
		# This is for bodies without health (like simple projectiles)
		body.queue_free()


func _calculate_mass(body: Node2D) -> float:
	"""Calculate mass value based on body type"""
	if body.is_in_group("player"):
		return player_mass
	elif body.is_in_group("asteroid"):
		return asteroid_mass
	elif body.is_in_group("enemies"):
		return enemy_mass
	elif body.is_in_group("projectile"):
		return projectile_mass

	return default_mass


func _on_body_entered(body: Node2D) -> void:
	"""Track bodies that enter the kill zone"""
	if body is RigidBody2D or body is CharacterBody2D or body is Area2D:
		if not _detected_bodies.has(body):
			_detected_bodies.append(body)


func _on_body_exited(body: Node2D) -> void:
	"""Stop tracking bodies that exit the kill zone"""
	_detected_bodies.erase(body)


func _update_collision_shape() -> void:
	"""Update collision shape when radius changes"""
	if not is_inside_tree():
		return

	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = kill_zone_radius
