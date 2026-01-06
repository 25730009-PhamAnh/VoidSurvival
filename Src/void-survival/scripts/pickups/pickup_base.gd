class_name PickupBase
extends RigidBody2D

## Abstract base class for all pickups
## Provides polymorphic interface and common behavior
## All pickup types must implement apply_effect(player)

signal collected(pickup: PickupBase)

var pickup_definition: PickupDefinition  # Set via set_pickup_definition(), not exposed in editor

# Visual components (to be overridden in derived classes)
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var color_rect: ColorRect = $ColorRect if has_node("ColorRect") else null
@onready var collection_particles: CPUParticles2D = $CollectionParticles if has_node("CollectionParticles") else null

var _was_collected: bool = false


func _ready() -> void:
	add_to_group("pickups")

	# Configure physics (common to all pickups)
	gravity_scale = 0.0
	linear_damp = 2.0

	# Subclasses can override _on_ready_extended()
	_on_ready_extended()


## Override in subclasses for additional setup
func _on_ready_extended() -> void:
	pass


## Set pickup definition and apply configuration
## Called by PickupSpawnerComponent after instantiation
func set_pickup_definition(definition: PickupDefinition) -> void:
	pickup_definition = definition
	if pickup_definition:
		_apply_visual_properties()


func _apply_visual_properties() -> void:
	print("[PickupBase] Applying visual properties for pickup: ", pickup_definition.pickup_name)
	if not pickup_definition:
		return

	print(" - Color: ", pickup_definition.color)

	# Option 1: ColorRect (preferred for solid colors)
	if color_rect:
		color_rect.color = pickup_definition.color

	# Option 2: Sprite2D with icon (for custom textures)
	if sprite:
		sprite.modulate = pickup_definition.color
		if pickup_definition.icon:
			print(" - Icon: ", pickup_definition.icon.resource_path if pickup_definition.icon else "None")
			sprite.texture = pickup_definition.icon


## ABSTRACT: Must be implemented by subclasses
## Apply pickup effect to the player
func apply_effect(player: Node2D) -> void:
	push_error("PickupBase.apply_effect() not implemented in " + get_script().resource_path)


## Get the value for collection (used by CollectionComponent)
func get_value() -> float:
	if pickup_definition:
		return pickup_definition.get_effective_value()
	return 0.0


## Get pickup type
func get_pickup_type() -> PickupDefinition.PickupType:
	if pickup_definition:
		return pickup_definition.pickup_type
	return PickupDefinition.PickupType.CRYSTAL


## Called when collected (common cleanup logic)
func on_collected() -> void:
	if _was_collected:
		return  # Prevent double collection

	_was_collected = true
	collected.emit(self)
	_play_collection_vfx()
	_cleanup()


## Play collection VFX
func _play_collection_vfx() -> void:
	if collection_particles:
		collection_particles.emitting = true
		collection_particles.one_shot = true

	# Hide visual elements and disable collision
	if sprite:
		sprite.visible = false
	if color_rect:
		color_rect.visible = false
	set_deferred("freeze", true)


## Cleanup and destroy
func _cleanup() -> void:
	# Wait for particles to finish
	await get_tree().create_timer(0.5).timeout
	queue_free()


## Optional: Floating animation (can be overridden)
func _process(delta: float) -> void:
	if not pickup_definition:
		return

	var time_elapsed = Time.get_ticks_msec() / 1000.0
	var float_offset = sin(time_elapsed * pickup_definition.float_speed) * pickup_definition.float_amplitude

	# Apply rotation and floating to available visual element
	if sprite:
		sprite.rotation += pickup_definition.rotation_speed * delta
		sprite.position.y = float_offset
	elif color_rect:
		color_rect.rotation += pickup_definition.rotation_speed * delta
		color_rect.position.y = float_offset
