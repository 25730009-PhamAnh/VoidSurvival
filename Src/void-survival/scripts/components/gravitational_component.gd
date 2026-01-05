class_name GravitationalComponent
extends Area2D

## Reusable component for applying gravitational force to nearby objects
##
## This component detects physics bodies within a detection radius and applies
## gravitational forces toward a center point (the parent node's position).
## Forces use linear falloff for more predictable gameplay physics.
##
## Signals: None (pure force application)

## Maximum pull force applied at detection radius
@export var pull_strength: float = 100000.0

## Radius at which objects start being affected by gravity
@export var detection_radius: float = 300.0

## Maximum distance for pull effect (beyond this, no pull)
@export var max_pull_distance: float = 500.0

## Whether projectiles are affected by gravity
@export var affects_projectiles: bool = true

## Whether the player is affected by gravity
@export var affects_player: bool = true

## Whether asteroids are affected by gravity
@export var affects_asteroids: bool = true

## Whether enemies are affected by gravity
@export var affects_enemies: bool = true

var _detected_bodies: Array[Node2D] = []


func _ready() -> void:
	# Set up Area2D for detection
	monitoring = true
	monitorable = false

	# Set up collision layers/masks
	# Layer 0: Don't collide physically (detection only)
	# Mask: Detect all layers (player=1, asteroids/enemies=2, projectiles=4)
	collision_layer = 0
	collision_mask = 0b1111  # Layers 1, 2, 3, 4 (player, asteroids, enemies, projectiles)

	# Configure collision shape (should exist in scene as child)
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		# Use existing CollisionShape2D from scene
		if not collision_shape.shape:
			# Create CircleShape2D if shape not set
			var circle = CircleShape2D.new()
			circle.radius = detection_radius
			collision_shape.shape = circle
		elif collision_shape.shape is CircleShape2D:
			# Update radius if already a CircleShape2D
			collision_shape.shape.radius = detection_radius
	else:
		# Fallback: create collision shape if not in scene
		push_warning("GravitationalComponent: CollisionShape2D not found in scene, creating dynamically")
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = detection_radius
		shape.shape = circle
		add_child(shape)

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_apply_gravitational_forces(delta)


func _apply_gravitational_forces(delta: float) -> void:
	for body in _detected_bodies:
		if not is_instance_valid(body):
			continue

		# Filter by type
		if not _should_affect_body(body):
			continue

		var direction = global_position - body.global_position
		var distance = direction.length()

		# Clamp distance to avoid extreme forces at very close range
		var safe_distance = max(distance, 20.0)
		# Linear falloff: at 100px with 10000 strength = 100 force (much stronger than inverse square)
		var force_magnitude = pull_strength / safe_distance

		# Apply force based on body type (different scaling for RigidBody2D vs CharacterBody2D)
		if body is RigidBody2D:
			# RigidBody2D: apply_central_force expects unscaled force per frame
			var force = direction.normalized() * force_magnitude
			body.apply_central_force(force)
		elif body is CharacterBody2D:
			# CharacterBody2D: needs delta-scaled force for velocity modification
			var force = direction.normalized() * force_magnitude * delta
			if body.has_method("apply_external_force"):
				body.apply_external_force(force)
			else:
				# Fallback: directly modify velocity
				body.velocity += force
		elif body is Area2D:
			# Area2D (projectiles): modify velocity directly
			if body.has("velocity"):
				var acceleration = direction.normalized() * force_magnitude * delta
				body.velocity += acceleration


func _should_affect_body(body: Node2D) -> bool:
	"""Check if this body should be affected by gravity based on type filters"""
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


func _on_body_entered(body: Node2D) -> void:
	"""Track bodies that enter the detection radius"""
	if body is RigidBody2D or body is CharacterBody2D or body is Area2D:
		if not _detected_bodies.has(body):
			_detected_bodies.append(body)


func _on_body_exited(body: Node2D) -> void:
	"""Stop tracking bodies that exit the detection radius"""
	_detected_bodies.erase(body)


## Update the pull strength dynamically
func set_pull_strength(strength: float) -> void:
	pull_strength = strength


## Update the detection radius dynamically
func set_detection_radius(radius: float) -> void:
	detection_radius = radius
	# Update collision shape if already created
	if get_child_count() > 0:
		var shape = get_child(0) as CollisionShape2D
		if shape and shape.shape is CircleShape2D:
			shape.shape.radius = radius
