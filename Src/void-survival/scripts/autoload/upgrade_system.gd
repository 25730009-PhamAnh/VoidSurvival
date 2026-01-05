extends Node

# Signals
signal item_equipped(item: ItemDefinition)
signal item_unequipped(item: ItemDefinition)
signal item_upgraded(item: ItemDefinition, new_level: int)
signal stats_updated()

# Resources
var ship_stats_resource: ShipStats

# State
var equipped_items: Array[ItemDefinition] = []
var item_levels: Dictionary = {}  # resource_path -> level
var unlocked_slots: int = 4
var point_levels: Dictionary = {}  # For future point allocation system (defense, offense, mobility, utility)


func _ready() -> void:
	# Load the ship stats resource
	if not ship_stats_resource:
		ship_stats_resource = load("res://resources/ship_parameters/base_ship_stats.tres")
		if not ship_stats_resource:
			push_error("UpgradeSystem: Failed to load base_ship_stats.tres")

	_load_from_save()


func equip_item(item: ItemDefinition) -> bool:
	if not item:
		push_error("UpgradeSystem: Cannot equip null item")
		return false
	
	# Check if already equipped
	if is_item_equipped(item):
		push_warning("UpgradeSystem: Item already equipped")
		return false
	
	# Check if player owns the item (level > 0)
	if get_item_level(item) <= 0:
		push_warning("UpgradeSystem: Cannot equip unowned item")
		return false
	
	# Check if slots available
	if equipped_items.size() >= unlocked_slots:
		push_warning("UpgradeSystem: No equipment slots available")
		return false
	
	equipped_items.append(item)
	item_equipped.emit(item)
	stats_updated.emit()
	_save_to_system()
	return true


func unequip_item(item: ItemDefinition) -> bool:
	if not item:
		push_error("UpgradeSystem: Cannot unequip null item")
		return false
	
	var index = equipped_items.find(item)
	if index == -1:
		push_warning("UpgradeSystem: Item not equipped")
		return false
	
	equipped_items.remove_at(index)
	item_unequipped.emit(item)
	stats_updated.emit()
	_save_to_system()
	return true


func upgrade_item(item: ItemDefinition) -> bool:
	if not item:
		push_error("UpgradeSystem: Cannot upgrade null item")
		return false
	
	var current_level = get_item_level(item)
	var cost = item.get_cost_at_level(current_level + 1)
	
	# Try to spend credits
	if not ResourceManager.spend_credits(cost):
		push_warning("UpgradeSystem: Insufficient credits for upgrade")
		return false
	
	# Increment level
	var path = item.resource_path
	item_levels[path] = current_level + 1
	
	item_upgraded.emit(item, current_level + 1)
	stats_updated.emit()
	_save_to_system()
	return true


func get_item_level(item: ItemDefinition) -> int:
	if not item:
		return 0
	
	var path = item.resource_path
	if path in item_levels:
		return item_levels[path]
	return 0


func is_item_equipped(item: ItemDefinition) -> bool:
	if not item:
		return false
	return item in equipped_items


## Calculate final ship stats from base + equipped item bonuses
## @return: Dictionary of final stats with all bonuses applied
func get_final_stats() -> Dictionary:
	if not ship_stats_resource:
		push_error("UpgradeSystem: ship_stats_resource not loaded!")
		return {}

	# Start with base stats (currently all point_levels are 0)
	var stats = ship_stats_resource.calculate_stats(point_levels)

	# Apply bonuses from equipped items
	for item in equipped_items:
		if not item:
			continue
		var level = get_item_level(item)
		item.apply_to_stats(stats, level)

	return stats


func _load_from_save() -> void:
	var save_data = SaveSystem.load_game()
	
	# Load item levels
	if "item_levels" in save_data:
		item_levels = save_data["item_levels"].duplicate()
	
	# Load unlocked slots
	if "unlocked_slots" in save_data:
		unlocked_slots = save_data["unlocked_slots"]
	
	# Load equipped items (convert paths back to resources)
	equipped_items.clear()
	if "equipped_items" in save_data:
		var equipped_paths = save_data["equipped_items"]
		for path in equipped_paths:
			var item = load(path) as ItemDefinition
			if item:
				equipped_items.append(item)
			else:
				push_warning("UpgradeSystem: Could not load equipped item: " + str(path))


func _save_to_system() -> void:
	var save_data = SaveSystem.load_game()
	
	# Convert equipped items to paths
	var equipped_paths: Array = []
	for item in equipped_items:
		if item and item.resource_path:
			equipped_paths.append(item.resource_path)
	
	save_data["equipped_items"] = equipped_paths
	save_data["item_levels"] = item_levels.duplicate()
	save_data["unlocked_slots"] = unlocked_slots
	
	SaveSystem.save_game()
