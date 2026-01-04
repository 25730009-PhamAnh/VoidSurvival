class_name ItemDefinition
extends Resource

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
@export var affected_stat: String = "max_shield"


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
	return "+%.0f%% %s" % [bonus * 100, affected_stat.replace("_", " ").capitalize()]
