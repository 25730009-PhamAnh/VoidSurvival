class_name CrystalPickup
extends PickupBase

## Currency pickup - adds crystals to ResourceManager
## Maintains backward compatibility with existing crystal system

func apply_effect(player: Node2D) -> void:
	var value = int(get_value())
	ResourceManager.add_crystals(value)
	SessionManager.record_crystal_collected(value)
