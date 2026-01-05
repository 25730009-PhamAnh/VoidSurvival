class_name HealthPickup
extends PickupBase

## Health restoration pickup - heals player's HealthComponent

func apply_effect(player: Node2D) -> void:
	if not player.has_node("HealthComponent"):
		push_warning("HealthPickup: Player has no HealthComponent")
		return

	var health_component = player.get_node("HealthComponent") as HealthComponent
	if health_component:
		var heal_amount = get_value()
		health_component.heal(heal_amount)

		# Optional: Track in SessionManager for stats
		# SessionManager.record_health_collected(heal_amount)
