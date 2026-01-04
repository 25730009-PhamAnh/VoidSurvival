extends CanvasLayer

# Stats labels
@onready var survival_time_label: Label = %SurvivalTimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var asteroids_label: Label = %AsteroidsLabel
@onready var crystals_label: Label = %CrystalsLabel

# Credits breakdown labels
@onready var base_credits_label: Label = %BaseCreditsLabel
@onready var time_bonus_label: Label = %TimeBonusLabel
@onready var destruction_bonus_label: Label = %DestructionBonusLabel
@onready var accuracy_bonus_label: Label = %AccuracyBonusLabel
@onready var total_credits_label: Label = %TotalCreditsLabel
@onready var total_credits_available_label: Label = %TotalCreditsAvailableLabel

# Buttons
@onready var retry_button: Button = %RetryButton
@onready var upgrades_button: Button = %UpgradesButton
@onready var main_menu_button: Button = %MainMenuButton

var session_stats: Dictionary = {}


func _ready() -> void:
	# Connect button signals
	retry_button.pressed.connect(_on_retry_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Connect to SessionManager
	SessionManager.session_ended.connect(_on_session_ended)

	# Start hidden
	hide()


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("restart"):
			_on_retry_pressed()
		elif event.is_action_pressed("ui_cancel"):  # ESC key
			_on_main_menu_pressed()
		elif event.is_action_pressed("ui_accept"):  # Enter key - go to upgrades
			_on_upgrades_pressed()


func _on_session_ended(stats: Dictionary) -> void:
	session_stats = stats
	_populate_stats(stats)
	show()


func _populate_stats(stats: Dictionary) -> void:
	# Format time as MM:SS
	var minutes = int(stats.survival_time) / 60
	var seconds = int(stats.survival_time) % 60
	survival_time_label.text = "Survived: %d:%02d" % [minutes, seconds]

	# Populate stats
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	var current_score = game_manager.current_score if game_manager else 0
	score_label.text = "Score: %d" % current_score
	accuracy_label.text = "Accuracy: %.1f%%" % stats.accuracy
	asteroids_label.text = "Asteroids Destroyed: %d" % stats.asteroids_destroyed
	crystals_label.text = "Crystals Collected: %d" % stats.crystals_collected

	# Calculate credit breakdown
	var base_credits = stats.crystals_collected
	var time_bonus = int(stats.survival_time / 10.0)
	var destruction_bonus = int((stats.asteroids_destroyed + stats.enemies_destroyed * 5) / 10.0)
	var accuracy_bonus = int(stats.accuracy * 0.5)
	var total_earned = stats.credits_earned

	# Populate credit breakdown
	base_credits_label.text = "+ %d (Crystals)" % base_credits
	time_bonus_label.text = "+ %d (Survival Bonus)" % time_bonus
	destruction_bonus_label.text = "+ %d (Combat Bonus)" % destruction_bonus
	accuracy_bonus_label.text = "+ %d (Accuracy Bonus)" % accuracy_bonus
	total_credits_label.text = "TOTAL: %d Credits" % total_earned

	# Show total available credits (after this session)
	total_credits_available_label.text = "Total Credits Available: %d" % ResourceManager.total_credits


func _on_retry_pressed() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.restart_game()


func _on_upgrades_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/upgrade_shop.tscn")


func _on_main_menu_pressed() -> void:
	# TODO: Implement in Module 12 - Load main menu scene
	print("Main menu button pressed - TODO: Implement main menu scene")
	push_warning("Main menu not yet implemented (Module 12)")
	# For now, just restart the game
	_on_retry_pressed()
