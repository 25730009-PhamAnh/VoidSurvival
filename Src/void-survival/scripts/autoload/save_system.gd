extends Node

## SaveSystem Singleton
## Handles all save/load operations with JSON persistence

const SAVE_PATH = "user://savegame.save"
const SAVE_VERSION = "1.0"


func save_game() -> void:
	var save_data = {
		"version": SAVE_VERSION,
		"credits": ResourceManager.total_credits,
		"total_crystals_collected": ResourceManager.total_crystals_collected,
		"equipped_items": [],
		"item_levels": {},
		"unlocked_slots": 4,
		"settings": {
			"sfx_volume": 0.8,
			"music_volume": 0.6
		},
		"stats": {
			"total_playtime": 0.0,
			"best_survival_time": 0.0,
			"total_asteroids_destroyed": 0,
			"total_runs": 0
		}
	}

	# Load existing data to preserve stats
	if save_exists():
		var existing_data = load_game()
		save_data.stats = existing_data.get("stats", save_data.stats)
		save_data.settings = existing_data.get("settings", save_data.settings)
		save_data.equipped_items = existing_data.get("equipped_items", [])
		save_data.item_levels = existing_data.get("item_levels", {})
		save_data.unlocked_slots = existing_data.get("unlocked_slots", 4)

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
	else:
		push_error("SaveSystem: Failed to write save file!")


func load_game() -> Dictionary:
	if not save_exists():
		return get_default_save_data()

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("SaveSystem: Failed to read save file!")
		return get_default_save_data()

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_warning("SaveSystem: JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return get_default_save_data()

	var save_data = json.data
	if not validate_save_data(save_data):
		push_warning("SaveSystem: Invalid save data, using defaults")
		return get_default_save_data()

	return save_data


func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if save_exists():
		DirAccess.remove_absolute(SAVE_PATH)


func get_default_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"credits": 0,
		"total_crystals_collected": 0,
		"equipped_items": [],
		"item_levels": {},
		"unlocked_slots": 4,
		"settings": {
			"sfx_volume": 0.8,
			"music_volume": 0.6
		},
		"stats": {
			"total_playtime": 0.0,
			"best_survival_time": 0.0,
			"total_asteroids_destroyed": 0,
			"total_runs": 0
		}
	}


func validate_save_data(data: Dictionary) -> bool:
	if not data.has("version"):
		return false

	# For now, just check version exists
	# Future: Add version migration logic here
	return true


func save_settings(sfx_volume: float, music_volume: float) -> void:
	var save_data = load_game()
	save_data.settings.sfx_volume = sfx_volume
	save_data.settings.music_volume = music_volume
	save_game()


func load_settings() -> Dictionary:
	var save_data = load_game()
	return save_data.get("settings", {"sfx_volume": 0.8, "music_volume": 0.6})
