class_name HealthComponent
extends Node

## Reusable health/shield management component
## Supports simple health, regeneration, and invincibility frames

# === SIGNALS (exact compatibility with entity signals) ===
signal health_changed(current: float, maximum: float)
signal shield_changed(current: float, maximum: float)  # Alias for health_changed
signal damaged(amount: float)  # For VFX/feedback
signal died()  # Emitted BEFORE owner queue_free

# === CONFIGURATION ===
@export_group("Health")
@export var max_health: float = 100.0:
	set(value):
		max_health = value
		# Update current health if needed
		if current_health > max_health:
			current_health = max_health
			_emit_health_signals()

@export var starting_health: float = -1.0  # -1 = use max_health

@export_group("Regeneration")
@export var regeneration_enabled: bool = false
@export var regeneration_rate: float = 5.0  # HP per second
@export var regeneration_delay: float = 3.0  # Seconds after damage before regen starts
@export var regeneration_start_percent: float = 0.0  # Only regen above this % (0.0 = always)

@export_group("Invincibility")
@export var invincibility_enabled: bool = false
@export var invincibility_duration: float = 1.0  # Seconds after taking damage

@export_group("Integration")
@export var track_damage_in_session: bool = false  # Player-specific: call SessionManager

# === STATE ===
var current_health: float
var is_invincible: bool = false
var _invincibility_timer: float = 0.0
var _regeneration_timer: float = 0.0

# === LIFECYCLE ===
func _ready() -> void:
	# Initialize health
	current_health = starting_health if starting_health > 0 else max_health
	_emit_health_signals()

	# Only enable _process if regeneration or invincibility is used
	if not regeneration_enabled and not invincibility_enabled:
		set_process(false)

func _process(delta: float) -> void:
	# Invincibility timer
	if invincibility_enabled and _invincibility_timer > 0:
		_invincibility_timer -= delta
		if _invincibility_timer <= 0:
			is_invincible = false

	# Regeneration
	if regeneration_enabled and current_health < max_health:
		_regeneration_timer -= delta
		if _regeneration_timer <= 0:
			var regen_threshold = max_health * regeneration_start_percent
			if current_health >= regen_threshold:
				current_health = min(current_health + regeneration_rate * delta, max_health)
				_emit_health_signals()

# === PUBLIC API ===
func take_damage(amount: float) -> void:
	"""Main damage entry point - called by entities or projectiles"""
	if is_invincible:
		return

	current_health -= amount

	# Track in SessionManager if configured (player-specific)
	if track_damage_in_session and SessionManager:
		SessionManager.record_damage_taken(amount)

	# Emit signals
	damaged.emit(amount)
	_emit_health_signals()

	# Reset regeneration timer
	if regeneration_enabled:
		_regeneration_timer = regeneration_delay

	# Death check
	if current_health <= 0:
		died.emit()  # Entity handles queue_free and pre-death logic (e.g., _split())
	elif invincibility_enabled:
		# Activate invincibility frames
		is_invincible = true
		_invincibility_timer = invincibility_duration

func heal(amount: float) -> void:
	"""Restore health"""
	current_health = min(current_health + amount, max_health)
	_emit_health_signals()

func set_max_health(new_max: float) -> void:
	"""Update max health (called by stat system)"""
	max_health = new_max

func get_health_percent() -> float:
	"""Returns 0.0 to 1.0"""
	return current_health / max_health if max_health > 0 else 0.0

# === INTERNAL ===
func _emit_health_signals() -> void:
	"""Emit both health_changed and shield_changed (for player compatibility)"""
	health_changed.emit(current_health, max_health)
	shield_changed.emit(current_health, max_health)  # Player HUD expects this
