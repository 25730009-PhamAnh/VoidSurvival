class_name PickupBase
extends RigidBody2D

## Abstract base class for all pickups
## Provides polymorphic interface and common behavior
## All pickup types must implement apply_effect(player)

signal collected(pickup: PickupBase)

@export var pickup_definition: PickupDefinition

# Visual components (to be overridden in derived classes)
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collection_particles: CPUParticles2D = $CollectionParticles if has_node("CollectionParticles") else null

var _was_collected: bool = false


func _ready() -> void:
	add_to_group("pickups")

	# Configure physics (common to all pickups)
	gravity_scale = 0.0
	linear_damp = 2.0

	# Apply definition visuals if available
	if pickup_definition and sprite:
		_apply_visual_properties()

	# Subclasses can override _on_ready_extended()
	_on_ready_extended()


## Override in subclasses for additional setup
func _on_ready_extended() -> void:
	pass


func _apply_visual_properties() -> void:
	if pickup_definition and sprite:
		sprite.modulate = pickup_definition.color
		if pickup_definition.icon:
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

	# Hide sprite and disable collision
	if sprite:
		sprite.visible = false
	set_deferred("freeze", true)


## Cleanup and destroy
func _cleanup() -> void:
	# Wait for particles to finish
	await get_tree().create_timer(0.5).timeout
	queue_free()


## Optional: Floating animation (can be overridden)
func _process(delta: float) -> void:
	if pickup_definition and sprite:
		var time_elapsed = Time.get_ticks_msec() / 1000.0
		sprite.rotation += pickup_definition.rotation_speed * delta
		var float_offset = sin(time_elapsed * pickup_definition.float_speed) * pickup_definition.float_amplitude
		sprite.position.y = float_offset
