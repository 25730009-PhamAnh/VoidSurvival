class_name PowerUpPickup
extends PickupBase

## Temporary stat boost pickup - applies timed buffs to player

func apply_effect(player: Node2D) -> void:
	if not pickup_definition:
		push_warning("PowerUpPickup: No pickup_definition set")
		return

	match pickup_definition.pickup_type:
		PickupDefinition.PickupType.SPEED_BOOST:
			_apply_speed_boost(player)
		PickupDefinition.PickupType.FIRE_RATE_BOOST:
			_apply_fire_rate_boost(player)
		PickupDefinition.PickupType.INVINCIBILITY:
			_apply_invincibility(player)
		PickupDefinition.PickupType.MAGNET:
			_apply_magnet(player)
		_:
			push_warning("PowerUpPickup: Unsupported type " + str(pickup_definition.pickup_type))


func _apply_speed_boost(player: Node2D) -> void:
	var multiplier = get_value()  # e.g., 1.5 = 150% speed
	var duration = pickup_definition.duration

	# Apply temporary speed increase
	var original_speed = player.max_speed
	player.max_speed *= multiplier

	# Restore after duration
	await get_tree().create_timer(duration).timeout
	player.max_speed = original_speed


func _apply_fire_rate_boost(player: Node2D) -> void:
	var multiplier = get_value()
	var duration = pickup_definition.duration

	var original_rate = player.fire_rate
	player.fire_rate *= multiplier

	await get_tree().create_timer(duration).timeout
	player.fire_rate = original_rate


func _apply_invincibility(player: Node2D) -> void:
	if not player.has_node("HealthComponent"):
		return

	var health_component = player.get_node("HealthComponent") as HealthComponent
	var duration = pickup_definition.duration

	# Temporarily enable invincibility
	var was_invincible = health_component.is_invincible
	health_component.is_invincible = true

	# Optional: Visual feedback (e.g., flashing sprite)

	await get_tree().create_timer(duration).timeout
	health_component.is_invincible = was_invincible


func _apply_magnet(player: Node2D) -> void:
	if not player.has_node("CollectionComponent"):
		return

	var collection_component = player.get_node("CollectionComponent") as CollectionComponent
	var multiplier = get_value()  # e.g., 2.0 = double radius
	var duration = pickup_definition.duration

	var original_radius = collection_component.attraction_radius
	collection_component.attraction_radius *= multiplier

	await get_tree().create_timer(duration).timeout
	collection_component.attraction_radius = original_radius
