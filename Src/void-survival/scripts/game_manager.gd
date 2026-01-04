class_name GameManager
extends Node

signal score_updated(new_score: int)
signal game_over

var current_score: int = 0
var is_playing: bool = true

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("game_manager")

	if player:
		player.died.connect(_on_player_died)
	else:
		push_warning("GameManager: No player found in scene!")

	# Connect to all asteroids' destroyed signals
	get_tree().node_added.connect(_on_node_added)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not is_playing:
		get_tree().reload_current_scene()

func add_score(amount: int) -> void:
	current_score += amount
	score_updated.emit(current_score)

func _on_player_died() -> void:
	is_playing = false
	game_over.emit()

func _on_node_added(node: Node) -> void:
	if node is Asteroid:
		node.destroyed.connect(add_score)
