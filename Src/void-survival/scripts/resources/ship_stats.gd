class_name ShipStats
extends Resource

## Base ship parameter values and upgrade formulas
## This resource defines all base stats and their scaling with point allocation

# Shield Parameters
@export var base_max_shield: float = 100.0
@export var shield_per_level: float = 20.0
@export var base_shield_regen: float = 5.0
@export var shield_regen_per_level: float = 0.5
@export var base_shield_delay: float = 3.0
@export var shield_delay_reduction: float = 0.1
@export var min_shield_delay: float = 0.5

# Movement Parameters
@export var base_move_speed: float = 300.0
@export var move_speed_per_level: float = 5.0
@export var base_acceleration: float = 200.0
@export var accel_per_level: float = 5.0

# Weapon Parameters
@export var base_fire_rate: float = 2.0  # shots per second
@export var fire_rate_per_level: float = 0.1
@export var base_damage: float = 10.0
@export var damage_multiplier_per_level: float = 0.15  # 15% per level
@export var base_projectile_speed: float = 400.0
@export var projectile_speed_per_level: float = 10.0

# Utility Parameters
@export var base_collection_radius: float = 50.0
@export var collection_radius_per_level: float = 5.0
@export var base_luck: float = 1.0
@export var luck_per_level: float = 0.1


## Calculate base stats from point allocation
## @param levels: Dictionary with keys "defense", "mobility", "offense", "utility"
## @return: Dictionary of final base stats before item bonuses
func calculate_stats(levels: Dictionary) -> Dictionary:
	return {
		"max_shield": base_max_shield + levels.get("defense", 0) * shield_per_level,
		"shield_regen": base_shield_regen + levels.get("defense", 0) * shield_regen_per_level,
		"shield_delay": max(min_shield_delay, base_shield_delay - levels.get("defense", 0) * shield_delay_reduction),
		"move_speed": base_move_speed + levels.get("mobility", 0) * move_speed_per_level,
		"acceleration": base_acceleration + levels.get("mobility", 0) * accel_per_level,
		"fire_rate": base_fire_rate + levels.get("offense", 0) * fire_rate_per_level,
		"damage": base_damage * (1.0 + levels.get("offense", 0) * damage_multiplier_per_level),
		"projectile_speed": base_projectile_speed + levels.get("offense", 0) * projectile_speed_per_level,
		"collection_radius": base_collection_radius + levels.get("utility", 0) * collection_radius_per_level,
		"luck": base_luck + levels.get("utility", 0) * luck_per_level
	}
