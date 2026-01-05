class_name MovementComponent
extends Node

## Handles screen wrapping for entities
## Supports both hard boundary (teleport at edge) and soft boundary (buffer zone)

# === CONFIGURATION ===
@export_group("Screen Wrapping")
@export var enabled: bool = true
@export var wrap_mode: WrapMode = WrapMode.SOFT

@export_group("Soft Wrapping")
@export var wrap_margin: float = 50.0  # Buffer zone outside screen

enum WrapMode {
	HARD,  # Player: wrap exactly at screen edge
	SOFT   # Enemies/asteroids: wrap with margin buffer
}

# === LIFECYCLE ===
func _physics_process(_delta: float) -> void:
	if not enabled:
		return

	var owner_node = get_parent()
	if not owner_node:
		return

	_wrap_screen(owner_node)

# === PUBLIC API ===
func wrap_now() -> void:
	"""Force immediate wrap check (called manually by entity)"""
	var owner_node = get_parent()
	if owner_node:
		_wrap_screen(owner_node)

# === INTERNAL ===
func _wrap_screen(entity: Node2D) -> void:
	"""Apply screen wrapping to entity position"""
	var screen_size = get_viewport().get_visible_rect().size
	var pos = entity.global_position

	match wrap_mode:
		WrapMode.HARD:
			# Player mode: wrap exactly at edges
			if pos.x < 0:
				pos.x = screen_size.x
			elif pos.x > screen_size.x:
				pos.x = 0

			if pos.y < 0:
				pos.y = screen_size.y
			elif pos.y > screen_size.y:
				pos.y = 0

		WrapMode.SOFT:
			# Enemy/asteroid mode: wrap with margin
			var margin = wrap_margin
			if pos.x < -margin:
				pos.x = screen_size.x + margin
			elif pos.x > screen_size.x + margin:
				pos.x = -margin

			if pos.y < -margin:
				pos.y = screen_size.y + margin
			elif pos.y > screen_size.y + margin:
				pos.y = -margin

	entity.global_position = pos
