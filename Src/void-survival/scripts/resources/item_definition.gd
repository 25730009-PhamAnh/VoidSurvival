class_name ItemDefinition
extends Resource

enum ScalingType {
	ADDITIVE,      # Flat bonus: base * (1 + 0.25)
	MULTIPLICATIVE # Stacking: base * 1.25 * 1.25...
}

@export var item_name: String = "Unnamed Item"
@export var description: String = ""
@export var icon: Texture2D
@export_enum("Defensive", "Offensive", "Utility") var category: String = "Defensive"

# Cost scaling
@export var base_cost: int = 100
@export var cost_exponent: float = 1.15

# Bonus scaling
@export var base_bonus: float = 0.10
@export var bonus_per_level: float = 0.02
@export var affected_stats: Array[String] = ["max_shield"]
@export var scaling_type: ScalingType = ScalingType.ADDITIVE


func get_cost_at_level(level: int) -> int:
	if level <= 0:
		return base_cost
	return int(base_cost * pow(cost_exponent, level - 1))


func get_bonus_at_level(level: int) -> float:
	if level <= 0:
		return 0.0
	return base_bonus + (bonus_per_level * (level - 1))


func get_bonus_text(level: int) -> String:
	var bonus = get_bonus_at_level(level)
	var stat_names = ", ".join(affected_stats.map(func(s): return s.replace("_", " ").capitalize()))
	return "+%.0f%% %s" % [bonus * 100, stat_names]


## Apply this item's bonuses to the stats dictionary
## @param stats: Dictionary of stats to modify (modified in-place)
## @param level: Current level of this item
func apply_to_stats(stats: Dictionary, level: int) -> void:
	if level <= 0:
		return

	var bonus_multiplier = get_bonus_at_level(level)

	for stat_name in affected_stats:
		if stat_name not in stats:
			push_warning("ItemDefinition '%s': Stat '%s' not found in stats dictionary" % [item_name, stat_name])
			continue

		var base_value = stats[stat_name]

		if scaling_type == ScalingType.ADDITIVE:
			# Add percentage of base: base * (1 + bonus)
			stats[stat_name] = base_value * (1.0 + bonus_multiplier)
		else:  # MULTIPLICATIVE
			# Multiply: base * (1 + bonus)
			stats[stat_name] = base_value * (1.0 + bonus_multiplier)
