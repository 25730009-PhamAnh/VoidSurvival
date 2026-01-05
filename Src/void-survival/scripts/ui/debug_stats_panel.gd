extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var stats_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsLabel

var is_visible: bool = false

func _ready() -> void:
	# Start hidden
	panel.visible = false

	# Connect to stats updates
	if UpgradeSystem:
		UpgradeSystem.stats_updated.connect(_on_stats_updated)
		# Initial update
		_update_display(UpgradeSystem.get_final_stats())
	else:
		push_error("DebugStatsPanel: UpgradeSystem not found!")

func _input(event: InputEvent) -> void:
	# Toggle with F3 key
	if event is InputEventKey and event.keycode == KEY_F3 and event.pressed and not event.echo:
		is_visible = !is_visible
		panel.visible = is_visible
		if is_visible:
			_update_display(UpgradeSystem.get_final_stats())

func _on_stats_updated() -> void:
	if is_visible:
		_update_display(UpgradeSystem.get_final_stats())

func _update_display(stats: Dictionary) -> void:
	if not stats_label:
		return

	var text = "[b]DEBUG STATS (F3 to toggle)[/b]\n\n"
	text += "DEFENSE\n"
	text += "  Max Shield: %.1f\n" % stats.get("max_shield", 0)
	text += "  Shield Regen: %.1f/s\n" % stats.get("shield_regen", 0)
	text += "  Shield Delay: %.2fs\n\n" % stats.get("shield_delay", 0)

	text += "OFFENSE\n"
	text += "  Damage: %.1f\n" % stats.get("damage", 0)
	text += "  Fire Rate: %.2f/s\n" % stats.get("fire_rate", 0)
	text += "  Projectile Speed: %.1f\n\n" % stats.get("projectile_speed", 0)

	text += "MOBILITY\n"
	text += "  Move Speed: %.1f\n" % stats.get("move_speed", 0)
	text += "  Acceleration: %.1f\n\n" % stats.get("acceleration", 0)

	text += "UTILITY\n"
	text += "  Collection Radius: %.1f\n" % stats.get("collection_radius", 0)
	text += "  Luck: %.2f" % stats.get("luck", 0)

	stats_label.text = text
