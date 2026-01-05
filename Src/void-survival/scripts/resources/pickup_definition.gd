class_name PickupDefinition
extends Resource

## Data-driven pickup configuration
## Defines visual, behavioral, and effect parameters for pickups
## Follows the same pattern as ItemDefinition and EnemyDefinition

enum PickupType {
	CRYSTAL,           # Currency (crystals)
	HEALTH,            # Restore health/shield
	SPEED_BOOST,       # Temporary speed increase
	INVINCIBILITY,     # Temporary damage immunity
	FIRE_RATE_BOOST,   # Temporary attack speed
	SHIELD_REGEN,      # Instant shield restoration
	BOMB,              # Instant area damage
	MAGNET,            # Increase collection radius temporarily
}

@export_group("Identity")
@export var pickup_name: String = "Unnamed Pickup"
@export var pickup_type: PickupType = PickupType.CRYSTAL
@export var description: String = ""

@export_group("Visual")
@export var icon: Texture2D
@export var color: Color = Color.WHITE
@export var rotation_speed: float = 2.0
@export var float_amplitude: float = 5.0
@export var float_speed: float = 3.0

@export_group("Effect Parameters")
@export var base_value: float = 1.0  # Currency amount, heal amount, boost multiplier, etc.
@export var duration: float = 0.0  # 0 = instant, >0 = temporary effect duration
@export var stack_behavior: bool = false  # Can multiple instances stack?

@export_group("Spawning")
@export var spawn_weight: float = 1.0  # For weighted random spawning
@export var scene: PackedScene  # Override default pickup scene if needed


## Get effective value (can be scaled by difficulty, player stats, etc.)
func get_effective_value(multiplier: float = 1.0) -> float:
	return base_value * multiplier


## Helper to check if this is an instant effect
func is_instant_effect() -> bool:
	return duration <= 0.0


## Helper to check if this is a temporary buff
func is_temporary_effect() -> bool:
	return duration > 0.0
