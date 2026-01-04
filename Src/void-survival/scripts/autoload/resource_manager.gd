extends Node

## ResourceManager Singleton
## Tracks crystals collected during current session and total credits

signal crystals_changed(current: int)
signal crystals_collected(amount: int)
signal credits_changed(current: int)

var current_crystals: int = 0:
	set(value):
		current_crystals = value
		crystals_changed.emit(current_crystals)

var total_credits: int = 0:
	set(value):
		total_credits = value
		credits_changed.emit(total_credits)

var total_crystals_collected: int = 0  # Lifetime stat


func _ready() -> void:
	var save_data = SaveSystem.load_game()
	total_credits = save_data.get("credits", 0)
	total_crystals_collected = save_data.get("total_crystals_collected", 0)


func add_crystals(amount: int) -> void:
	current_crystals += amount
	crystals_collected.emit(amount)


func reset_crystals() -> void:
	current_crystals = 0


func convert_crystals_to_credits() -> void:
	total_credits += current_crystals
	total_crystals_collected += current_crystals
	reset_crystals()
	SaveSystem.save_game()


func add_credits(amount: int) -> void:
	total_credits += amount


func spend_credits(amount: int) -> bool:
	if total_credits >= amount:
		total_credits -= amount
		SaveSystem.save_game()
		return true
	return false
