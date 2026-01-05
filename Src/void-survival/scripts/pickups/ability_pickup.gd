class_name AbilityPickup
extends PickupBase

## Instant ability pickup - triggers immediate effects

func apply_effect(player: Node2D) -> void:
	if not pickup_definition:
		push_warning("AbilityPickup: No pickup_definition set")
		return

	match pickup_definition.pickup_type:
		PickupDefinition.PickupType.BOMB:
			_trigger_bomb(player)
		PickupDefinition.PickupType.SHIELD_REGEN:
			_trigger_shield_regen(player)
		_:
			push_warning("AbilityPickup: Unsupported type " + str(pickup_definition.pickup_type))


func _trigger_bomb(player: Node2D) -> void:
	# Damage all nearby enemies
	var damage_radius = get_value()  # e.g., 200 pixels
	var damage_amount = 50.0  # Could be in pickup_definition

	# Get all enemies in range
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = damage_radius
	query.shape = shape
	query.transform = Transform2D(0, player.global_position)
	query.collision_mask = 2  # Layer 2 = asteroids & enemies

	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result.collider
		if body.has_node("HealthComponent"):
			var health_comp = body.get_node("HealthComponent") as HealthComponent
			health_comp.take_damage(damage_amount)

	# TODO: Spawn explosion VFX


func _trigger_shield_regen(player: Node2D) -> void:
	if not player.has_node("HealthComponent"):
		return

	var health_component = player.get_node("HealthComponent") as HealthComponent
	var regen_amount = get_value()
	health_component.heal(regen_amount)
