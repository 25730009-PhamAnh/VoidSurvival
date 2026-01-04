extends Node

## SessionManager Singleton
## Tracks all statistics for the current play session

signal session_ended(stats: Dictionary)
signal accuracy_changed(accuracy: float)

# Combat stats
var shots_fired: int = 0
var shots_hit: int = 0
var asteroids_destroyed: int = 0
var enemies_destroyed: int = 0  # Future: for Module 6

# Resource stats
var crystals_collected: int = 0
var total_damage_taken: float = 0.0

# Time stats
var survival_time: float = 0.0
var session_start_time: float = 0.0

# Calculated stats
var accuracy: float:
	get:
		if shots_fired == 0:
			return 0.0
		return (float(shots_hit) / float(shots_fired)) * 100.0


func start_session() -> void:
	shots_fired = 0
	shots_hit = 0
	asteroids_destroyed = 0
	enemies_destroyed = 0
	crystals_collected = 0
	total_damage_taken = 0.0
	survival_time = 0.0
	session_start_time = Time.get_ticks_msec() / 1000.0


func end_session() -> Dictionary:
	var final_stats = {
		"survival_time": survival_time,
		"asteroids_destroyed": asteroids_destroyed,
		"enemies_destroyed": enemies_destroyed,
		"crystals_collected": crystals_collected,
		"shots_fired": shots_fired,
		"shots_hit": shots_hit,
		"accuracy": accuracy,
		"damage_taken": total_damage_taken,
		"credits_earned": calculate_credits()
	}
	session_ended.emit(final_stats)
	return final_stats


func calculate_credits() -> int:
	# Base credits from crystals (already collected via ResourceManager)
	var base_credits = crystals_collected

	# Time bonus: 1 credit per 10 seconds survived
	var time_bonus = int(survival_time / 10.0)

	# Destruction bonus: 1 credit per 10 asteroids (+ 5x for enemies later)
	var destruction_bonus = int((asteroids_destroyed + enemies_destroyed * 5) / 10.0)

	# Accuracy bonus: Up to 50 credits for 100% accuracy
	var accuracy_bonus = int(accuracy * 0.5)

	return base_credits + time_bonus + destruction_bonus + accuracy_bonus


func record_shot_fired() -> void:
	shots_fired += 1


func record_shot_hit() -> void:
	shots_hit += 1
	accuracy_changed.emit(accuracy)


func record_asteroid_destroyed() -> void:
	asteroids_destroyed += 1


func record_enemy_destroyed() -> void:
	enemies_destroyed += 1


func record_crystal_collected(amount: int) -> void:
	crystals_collected += amount


func record_damage_taken(amount: float) -> void:
	total_damage_taken += amount


func update_survival_time(delta: float) -> void:
	survival_time += delta
