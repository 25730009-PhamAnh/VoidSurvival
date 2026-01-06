class_name PickupSpawnConfig
extends Resource

## Configuration for a single pickup type spawning behavior
## Used by PickupSpawnerComponent to define what pickups spawn on entity death

@export_group("Pickup Type")
@export var pickup_type: PickupDefinition.PickupType = PickupDefinition.PickupType.CRYSTAL

@export_group("Spawn Probability")
## Percentage chance this pickup will spawn (0-100%)
## Each config rolls independently
@export_range(0.0, 100.0, 0.1) var spawn_chance: float = 100.0

@export_group("Spawn Count")
## Minimum number of pickups to spawn (if roll succeeds)
@export var min_count: int = 1
## Maximum number of pickups to spawn (if roll succeeds)
@export var max_count: int = 3

@export_group("Advanced")
## Custom spread radius for this pickup type
## -1 = use component's default spread_radius
@export var custom_spread_radius: float = -1.0
