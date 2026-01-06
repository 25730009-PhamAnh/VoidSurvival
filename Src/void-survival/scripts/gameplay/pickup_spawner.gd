# DEPRECATED: Replaced by PickupSpawnerComponent
# This centralized spawner is no longer used in the codebase
# See: scripts/components/pickup_spawner_component.gd
#
# Migration notes:
# - Asteroids now use PickupSpawnerComponent attached to asteroid scene
# - Enemies now use PickupSpawnerComponent attached to enemy scenes
# - This file is kept temporarily for reference and can be deleted after testing

class_name PickupSpawner
extends Node

## DEPRECATED - Use PickupSpawnerComponent instead
## Centralized pickup spawning utility
## Manages weighted random spawning and scene instantiation
## Replaces hardcoded crystal spawning in Asteroid and EnemySpawner

# Default pickup definitions (loaded from resources/)
var _pickup_definitions: Dictionary = {}  # PickupType -> PickupDefinition
var _default_crystal_scene: PackedScene


func _ready() -> void:
	add_to_group("pickup_spawner")
	_load_pickup_definitions()


func _load_pickup_definitions() -> void:
	# Load all .tres files from resources/pickups/
	var pickup_dir = "res://resources/pickups/"
	var dir = DirAccess.open(pickup_dir)

	if not dir:
		push_warning("PickupSpawner: Could not open pickups directory")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource_path = pickup_dir + file_name
			var definition = load(resource_path) as PickupDefinition
			if definition:
				_pickup_definitions[definition.pickup_type] = definition
		file_name = dir.get_next()

	dir.list_dir_end()

	# Load default crystal scene for backward compatibility
	_default_crystal_scene = load("res://scenes/pickups/crystal.tscn")


## Spawn pickups at position with optional type selection
## @param count: Number of pickups to spawn
## @param position: World position to spawn at
## @param pickup_type: Specific type, or -1 for weighted random
## @param spread_radius: Radial spread around position
func spawn_pickups(count: int, position: Vector2, pickup_type: int = PickupDefinition.PickupType.CRYSTAL, spread_radius: float = 30.0) -> Array[PickupBase]:
	var spawned: Array[PickupBase] = []

	for i in count:
		var pickup = _spawn_single_pickup(pickup_type)
		if not pickup:
			continue

		# Position with radial spread
		var angle = (TAU / count) * i
		var offset = Vector2(spread_radius, 0).rotated(angle)
		pickup.global_position = position + offset

		# Add to scene
		get_tree().current_scene.add_child(pickup)
		spawned.append(pickup)

	return spawned


## Spawn a single pickup instance
func _spawn_single_pickup(pickup_type: int) -> PickupBase:
	var definition: PickupDefinition

	# Get definition for requested type
	if pickup_type >= 0 and pickup_type in _pickup_definitions:
		definition = _pickup_definitions[pickup_type]
	else:
		# Fallback to crystal
		definition = _pickup_definitions.get(PickupDefinition.PickupType.CRYSTAL)

	if not definition:
		push_warning("PickupSpawner: No definition found for type " + str(pickup_type))
		return null

	# Determine scene to instantiate
	var scene: PackedScene = definition.scene if definition.scene else _get_default_scene(definition.pickup_type)

	if not scene:
		push_warning("PickupSpawner: No scene for pickup type " + str(pickup_type))
		return null

	# Instantiate and configure
	var pickup = scene.instantiate() as PickupBase
	if pickup:
		pickup.set_pickup_definition(definition)

	return pickup


## Get default scene for pickup type (fallback if definition.scene is null)
func _get_default_scene(type: PickupDefinition.PickupType) -> PackedScene:
	match type:
		PickupDefinition.PickupType.CRYSTAL:
			return load("res://scenes/pickups/crystal.tscn")
		PickupDefinition.PickupType.HEALTH:
			return load("res://scenes/pickups/health_pickup.tscn")
		PickupDefinition.PickupType.SPEED_BOOST, PickupDefinition.PickupType.FIRE_RATE_BOOST, \
		PickupDefinition.PickupType.INVINCIBILITY, PickupDefinition.PickupType.MAGNET:
			return load("res://scenes/pickups/powerup_pickup.tscn")
		PickupDefinition.PickupType.BOMB, PickupDefinition.PickupType.SHIELD_REGEN:
			return load("res://scenes/pickups/ability_pickup.tscn")
		_:
			return null


## Weighted random pickup selection (for future use)
func get_random_pickup_type(available_types: Array[int] = []) -> int:
	if available_types.is_empty():
		# Default pool: mostly crystals, some health
		available_types = [
			PickupDefinition.PickupType.CRYSTAL,
			PickupDefinition.PickupType.CRYSTAL,
			PickupDefinition.PickupType.CRYSTAL,
			PickupDefinition.PickupType.HEALTH,
		]

	return available_types[randi() % available_types.size()]
