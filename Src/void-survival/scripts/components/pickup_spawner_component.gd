class_name PickupSpawnerComponent
extends Node

## Spawns pickups when parent entity dies
## Auto-connects to HealthComponent.died signal
## Supports multiple pickup types with independent spawn chances

@export var spawn_configs: Array[PickupSpawnConfig] = []
@export var spread_radius: float = 30.0
@export var debug_logging: bool = false

# Cached references
var _health_component: HealthComponent = null
var _pickup_definitions: Dictionary = {}  # PickupType -> PickupDefinition


func _ready() -> void:
	_load_pickup_definitions()
	_find_and_connect_health_component()


func _find_and_connect_health_component() -> void:
	"""Auto-discover and connect to HealthComponent on parent/owner"""
	# Search parent first, then owner (covers both direct attachment and scene tree)
	var parent = get_parent()
	if parent and parent is Node:
		_health_component = parent.get_node_or_null("HealthComponent")

	if not _health_component and owner:
		_health_component = owner.get_node_or_null("HealthComponent")

	if _health_component:
		_health_component.died.connect(_on_health_died)
		if debug_logging:
			print("[PickupSpawnerComponent] Connected to HealthComponent on ", owner.name if owner else parent.name)
	else:
		push_warning("PickupSpawnerComponent on " + str(get_parent()) + " could not find HealthComponent")


func _load_pickup_definitions() -> void:
	"""Load all pickup definitions from resources/pickups/ directory"""
	var pickup_dir = "res://resources/pickups/"
	var dir = DirAccess.open(pickup_dir)

	if not dir:
		push_error("PickupSpawnerComponent: Could not open pickups directory")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource_path = pickup_dir + file_name
			var definition = load(resource_path) as PickupDefinition
			if definition:
				_pickup_definitions[definition.pickup_type] = definition
				if debug_logging:
					print("[PickupSpawnerComponent] Loaded: ", definition.pickup_name,
						  " → ", definition.scene.resource_path if definition.scene else "NO SCENE")
		file_name = dir.get_next()

	dir.list_dir_end()


func _on_health_died() -> void:
	"""Handle parent death - spawn pickups based on configs"""
	var spawn_position = owner.global_position if owner else get_parent().global_position

	for config in spawn_configs:
		_process_spawn_config(config, spawn_position)


func _process_spawn_config(config: PickupSpawnConfig, position: Vector2) -> void:
	"""Roll chance and spawn pickups for a single config"""
	# Roll spawn chance
	var roll = randf() * 100.0
	if roll > config.spawn_chance:
		if debug_logging:
			print("[PickupSpawnerComponent] Failed spawn roll: ", roll, " > ", config.spawn_chance)
		return

	# Determine count
	var count = randi_range(config.min_count, config.max_count)
	if count <= 0:
		return

	# Determine spread radius
	var effective_spread = config.custom_spread_radius if config.custom_spread_radius >= 0 else spread_radius

	# Spawn pickups
	_spawn_pickups(count, position, config.pickup_type, effective_spread)


func _spawn_pickups(count: int, position: Vector2, pickup_type: PickupDefinition.PickupType, spread: float) -> void:
	"""Instantiate and position pickup instances"""
	var definition = _pickup_definitions.get(pickup_type)
	if not definition:
		push_warning("PickupSpawnerComponent: No definition for pickup type ", pickup_type)
		return

	# Get scene from definition (REQUIRED - no fallback)
	if not definition.scene:
		push_error("PickupSpawnerComponent: PickupDefinition '", definition.pickup_name, "' has no scene assigned!")
		return

	var scene = definition.scene

	print("[PickupSpawnerComponent] Spawning ", count, " x ", definition.pickup_name,
			" at ", position, " with spread ", spread)
	for i in count:
		var pickup = scene.instantiate() as PickupBase
		if not pickup:
			push_error("PickupSpawnerComponent: Failed to instantiate pickup scene for type ", pickup_type)
			continue

		# Position with radial spread
		var angle = (TAU / count) * i
		var offset = Vector2(spread, 0).rotated(angle)
		pickup.global_position = position + offset

		# Set unique name for the pickup instance
		pickup.name = definition.pickup_name + "_" + str(Time.get_ticks_msec()) + "_" + str(i)

		# Add to scene (this triggers _ready() which initializes @onready variables)
		get_tree().current_scene.add_child(pickup)

		# Set definition and apply configuration (AFTER _ready() has been called)
		pickup.set_pickup_definition(definition)
