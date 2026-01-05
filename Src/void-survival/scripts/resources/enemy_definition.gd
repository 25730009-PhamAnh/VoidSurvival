class_name EnemyDefinition
extends Resource

## Base enemy parameters with difficulty scaling formulas

enum EnemyType {
	ASTEROID,
	UFO,
	COMET
}

@export var enemy_name: String = "Unknown"
@export var enemy_type: EnemyType = EnemyType.ASTEROID
@export var scene: PackedScene  # Enemy scene to instance

@export_group("Base Stats")
@export var base_health: float = 30.0
@export var base_speed: float = 2.0
@export var base_damage: float = 20.0
@export var score_value: int = 10
@export var crystal_drop_count: int = 2

@export_group("Difficulty Scaling")
@export var health_scaling: float = 0.1  # +10% per difficulty level
@export var speed_scaling: float = 0.05  # +5% per difficulty level
@export var damage_scaling: float = 0.12  # +12% per difficulty level

## Calculate stats at given difficulty level
func get_stats_at_difficulty(difficulty: float) -> Dictionary:
	return {
		"health": base_health * (1.0 + difficulty * health_scaling),
		"speed": base_speed * (1.0 + difficulty * speed_scaling),
		"damage": base_damage * (1.0 + difficulty * damage_scaling),
		"score": score_value,
		"crystals": crystal_drop_count
	}
