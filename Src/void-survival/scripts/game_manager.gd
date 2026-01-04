class_name GameManager
extends Node

signal score_updated(new_score: int)
signal game_over

var current_score: int = 0
var is_playing: bool = true
var total_asteroids_destroyed: int = 0
var current_run_time: float = 0.0

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("game_manager")

	if player:
		player.died.connect(_on_player_died)
	else:
		push_warning("GameManager: No player found in scene!")

	# Connect to all asteroids' destroyed signals
	get_tree().node_added.connect(_on_node_added)


func _process(delta: float) -> void:
	if is_playing:
		current_run_time += delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not is_playing:
		restart_game()

func add_score(amount: int) -> void:
	current_score += amount
	total_asteroids_destroyed += 1
	score_updated.emit(current_score)


func restart_game() -> void:
	ResourceManager.reset_crystals()
	get_tree().reload_current_scene()


func _on_player_died() -> void:
	is_playing = false
	ResourceManager.convert_crystals_to_credits()
	_save_run_stats()
	game_over.emit()


func _save_run_stats() -> void:
	var save_data = SaveSystem.load_game()
	save_data.stats.total_runs += 1
	save_data.stats.total_asteroids_destroyed += total_asteroids_destroyed
	if current_run_time > save_data.stats.best_survival_time:
		save_data.stats.best_survival_time = current_run_time
	save_data.stats.total_playtime += current_run_time
	SaveSystem.save_game()


func _on_node_added(node: Node) -> void:
	if node is Asteroid:
		node.destroyed.connect(add_score)
