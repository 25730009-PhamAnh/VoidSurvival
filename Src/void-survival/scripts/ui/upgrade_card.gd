class_name UpgradeCard
extends PanelContainer

signal upgrade_requested(item: ItemDefinition)
signal equip_requested(item: ItemDefinition)
signal unequip_requested(item: ItemDefinition)
signal card_selected(item: ItemDefinition)

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name_label: Label = %ItemName
@onready var category_label: Label = %CategoryLabel
@onready var level_label: Label = %LevelLabel
@onready var current_bonus_label: Label = %CurrentBonusLabel
@onready var next_bonus_label: Label = %NextBonusLabel
@onready var cost_label: Label = %CostLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var equip_button: Button = %EquipButton

var item_resource: ItemDefinition
var current_level: int = 0
var is_equipped: bool = false
var can_afford: bool = true


func _ready() -> void:
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	equip_button.pressed.connect(_on_equip_pressed)
	
	# Make card clickable
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func setup(item: ItemDefinition, level: int, equipped: bool, credits: int) -> void:
	if not item:
		push_error("UpgradeCard: Cannot setup with null item")
		return
	
	item_resource = item
	current_level = level
	is_equipped = equipped
	
	# Update display
	item_name_label.text = item.item_name
	category_label.text = item.category
	level_label.text = "Level %d" % current_level
	
	# Update icon
	if item.icon:
		item_icon.texture = item.icon
	else:
		item_icon.texture = null
	
	# Update bonus labels
	if current_level > 0:
		current_bonus_label.text = item.get_bonus_text(current_level)
		next_bonus_label.text = "→ " + item.get_bonus_text(current_level + 1)
	else:
		current_bonus_label.text = "Not Owned"
		next_bonus_label.text = "→ " + item.get_bonus_text(1)
	
	# Update cost
	var next_level_cost = item.get_cost_at_level(current_level + 1)
	cost_label.text = "Cost: %d" % next_level_cost
	can_afford = credits >= next_level_cost
	
	_update_buttons()


func _update_buttons() -> void:
	# Update upgrade button
	if current_level == 0:
		upgrade_button.text = "Purchase"
	else:
		upgrade_button.text = "Upgrade"
	
	upgrade_button.disabled = not can_afford
	
	# Update equip button
	if current_level == 0:
		# Can't equip unowned items
		equip_button.visible = false
	else:
		equip_button.visible = true
		if is_equipped:
			equip_button.text = "Unequip"
		else:
			equip_button.text = "Equip"
	
	# Visual feedback for equipped items
	if is_equipped:
		modulate = Color(0.8, 1.0, 0.8)
	else:
		modulate = Color(1.0, 1.0, 1.0)


func _on_upgrade_pressed() -> void:
	upgrade_requested.emit(item_resource)


func _on_equip_pressed() -> void:
	if is_equipped:
		unequip_requested.emit(item_resource)
	else:
		equip_requested.emit(item_resource)


func _on_mouse_entered() -> void:
	if not is_equipped:
		modulate = Color(1.1, 1.1, 1.1)


func _on_mouse_exited() -> void:
	if is_equipped:
		modulate = Color(0.8, 1.0, 0.8)
	else:
		modulate = Color(1.0, 1.0, 1.0)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_selected.emit(item_resource)
