class_name BlackHole
extends Node2D

## Black hole hazard with gravitational pull and kill zone
##
## Black holes pull nearby objects with GravitationalComponent and instantly
## destroy objects at the center with KillZoneComponent. They grow stronger
## as mass is absorbed and can be overloaded to trigger bonus points.
##
## Two-component system:
## - GravitationalComponent: Pulls objects toward center (300px radius)
## - KillZoneComponent: Instant death at center (20px radius)
##
## Signals:
## - destroyed: Emitted when the black hole is destroyed (lifetime or overload)
## - overloaded: Emitted when the black hole consumes enough mass to trigger overload

signal destroyed
signal overloaded

## Lifetime in seconds before auto-destruction
@export var lifetime: float = 60.0

## Total mass required to trigger overload
@export var overload_threshold: float = 100.0

## Initial gravitational pull strength
@export var initial_pull_strength: float = 10000.0

## Amount to increase pull strength per unit of mass absorbed
@export var pull_strength_growth: float = 500.0

@onready var gravitational_component: GravitationalComponent = $GravitationalComponent
@onready var kill_zone: KillZoneComponent = $KillZoneComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lifetime_timer: Timer = $LifetimeTimer

var _absorbed_mass: float = 0.0
var _is_overloaded: bool = false


func _ready() -> void:
	# Initialize gravitational component
	if gravitational_component:
		gravitational_component.pull_strength = initial_pull_strength

	# Initialize kill zone component
	if kill_zone:
		kill_zone.object_killed.connect(_on_object_killed)

	# Set up lifetime timer
	if lifetime_timer:
		lifetime_timer.wait_time = lifetime
		lifetime_timer.one_shot = true
		lifetime_timer.timeout.connect(_on_lifetime_expired)
		lifetime_timer.start()

	# Start pulsing animation
	if animation_player and animation_player.has_animation("pulse"):
		animation_player.play("pulse")

	# Create placeholder sprite if none exists
	_create_placeholder_sprite()


func _process(_delta: float) -> void:
	# Visual feedback: scale grows with absorbed mass
	if sprite:
		var mass_scale = 1.0 + (_absorbed_mass / overload_threshold) * 0.5
		sprite.scale = Vector2.ONE * mass_scale

	# Increase particle emission as mass grows
	if particles:
		var base_amount = 20
		var max_additional = 30
		particles.amount = int(base_amount + (_absorbed_mass / overload_threshold) * max_additional)


func _on_object_killed(body: Node2D, mass: float) -> void:
	"""Handle mass absorption from killed objects"""
	_absorbed_mass += mass

	# Increase pull strength as mass is absorbed
	if gravitational_component:
		gravitational_component.pull_strength += pull_strength_growth

	# Check for overload
	if _absorbed_mass >= overload_threshold and not _is_overloaded:
		_trigger_overload()


func _trigger_overload() -> void:
	"""Trigger overload: award points and destroy black hole"""
	_is_overloaded = true
	overloaded.emit()

	# Award bonus score for overloading black hole
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_score"):
		game_manager.add_score(500)

	# Wait briefly for potential VFX, then destroy
	await get_tree().create_timer(0.5).timeout
	_destroy()


func _on_lifetime_expired() -> void:
	"""Handle natural expiration after lifetime"""
	_destroy()


func _destroy() -> void:
	"""Clean up and remove black hole"""
	destroyed.emit()
	queue_free()


func initialize(spawn_position: Vector2) -> void:
	"""Initialize black hole at spawn position (called by spawner)"""
	global_position = spawn_position


func _create_placeholder_sprite() -> void:
	"""Create a procedural gradient texture if no sprite exists"""
	if not sprite or sprite.texture:
		return

	# Create radial gradient: bright purple center → transparent edge
	var gradient_tex = GradientTexture2D.new()
	var gradient = Gradient.new()

	# Set gradient colors (bright purple center, purple fading edge)
	gradient.set_color(0, Color(0.8, 0.5, 1.0, 1.0))  # Bright purple center
	gradient.set_color(1, Color(0.4, 0.2, 0.6, 0.0))  # Purple edge fading out

	gradient_tex.gradient = gradient
	gradient_tex.fill = GradientTexture2D.FILL_RADIAL
	gradient_tex.width = 256
	gradient_tex.height = 256

	sprite.texture = gradient_tex
