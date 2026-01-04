extends CanvasLayer

@onready var shield_bar: ProgressBar = %ShieldBar
@onready var score_label: Label = %ScoreLabel
@onready var game_over_panel: CenterContainer = %GameOverPanel

func _ready() -> void:
	game_over_panel.hide()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.shield_changed.connect(_on_shield_changed)
		player.died.connect(_on_player_died)
	else:
		push_warning("HUD: No player found in scene!")

	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.score_updated.connect(_on_score_updated)
	else:
		push_warning("HUD: No game_manager found in scene!")

func _on_shield_changed(current: float, maximum: float) -> void:
	shield_bar.value = (current / maximum) * 100.0

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_player_died() -> void:
	game_over_panel.show()
