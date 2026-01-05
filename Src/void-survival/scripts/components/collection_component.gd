extends Area2D
class_name CollectionComponent

## Reusable component for detecting and attracting pickups
## Emits signal when items are collected

signal item_collected(item: Node2D, value: int)

@export var collection_radius: float = 15.0:
	set(value):
		collection_radius = value
		_update_collection_shape()

@export var attraction_strength: float = 600.0
@export var attraction_radius: float = 200.0:
	set(value):
		attraction_radius = value
		_update_attraction_shape()

@onready var collection_shape: CollisionShape2D = $CollisionShape2D
@onready var attraction_area: Area2D = $AttractionArea
@onready var attraction_shape: CollisionShape2D = $AttractionArea/CollisionShape2D


func _ready() -> void:
	_update_collection_shape()
	_update_attraction_shape()

	# Enable monitoring on both areas
	monitoring = true
	monitorable = false
	if attraction_area:
		attraction_area.monitoring = true
		attraction_area.monitorable = false

	# Connect signals
	body_entered.connect(_on_body_entered)
	if attraction_area:
		attraction_area.body_entered.connect(_on_attraction_area_body_entered)
		attraction_area.body_exited.connect(_on_attraction_area_body_exited)


func _physics_process(delta: float) -> void:
	# Apply attraction force to nearby pickups
	if not attraction_area:
		return

	var overlapping = attraction_area.get_overlapping_bodies()

	for body in overlapping:
		if body.is_in_group("pickups") and body is RigidBody2D:
			var direction = (global_position - body.global_position).normalized()
			var distance = global_position.distance_to(body.global_position)

			# Skip if outside attraction radius (shouldn't happen, but safety check)
			if distance > attraction_radius:
				continue

			# Calculate pull strength that gets stronger as pickup gets closer
			var pull_strength = 1.0 - (distance / attraction_radius)
			pull_strength = pull_strength * pull_strength  # Square for more aggressive pull

			# Directly modify velocity for more responsive attraction
			var target_velocity = direction * attraction_strength * pull_strength
			body.linear_velocity = body.linear_velocity.lerp(target_velocity, delta * 5.0)


func _update_collection_shape() -> void:
	if not is_inside_tree():
		return
	if collection_shape and collection_shape.shape is CircleShape2D:
		collection_shape.shape.radius = collection_radius


func _update_attraction_shape() -> void:
	if not is_inside_tree():
		return
	if attraction_shape and attraction_shape.shape is CircleShape2D:
		attraction_shape.shape.radius = attraction_radius


func _on_body_entered(body: Node2D) -> void:
	# Type-safe polymorphic check (NEW)
	if body is PickupBase:
		var pickup = body as PickupBase
		var value = pickup.get_value()
		item_collected.emit(pickup, int(value))
	# Backward compatibility during migration (OLD)
	elif body.is_in_group("pickups"):
		var value = body.get("crystal_value") if body.has_method("get") else 1
		item_collected.emit(body, value)


func _on_attraction_area_body_entered(_body: Node2D) -> void:
	# Bodies entering attraction radius are tracked automatically by get_overlapping_bodies()
	pass


func _on_attraction_area_body_exited(_body: Node2D) -> void:
	# Bodies leaving attraction radius are removed automatically from get_overlapping_bodies()
	pass


## Set collection radius (called by stat system)
func set_radius(new_radius: float) -> void:
	collection_radius = new_radius
