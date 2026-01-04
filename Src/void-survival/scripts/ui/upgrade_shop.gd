extends CanvasLayer

@onready var credits_label: Label = %CreditsLabel
@onready var back_button: Button = %BackButton
@onready var item_grid: GridContainer = %ItemGrid
@onready var item_scroll: ScrollContainer = %ItemScrollContainer
@onready var detail_panel: PanelContainer = %DetailPanel
@onready var detail_name: Label = %DetailItemName
@onready var detail_icon: TextureRect = %DetailItemIcon
@onready var detail_description: Label = %DetailDescription
@onready var detail_stats: Label = %DetailStats
@onready var detail_upgrade_button: Button = %DetailUpgradeButton
@onready var equipped_container: HBoxContainer = %EquippedItemsContainer

var all_items: Array[ItemDefinition] = []
var selected_item: ItemDefinition = null
var upgrade_card_scene = preload("res://scenes/ui/components/upgrade_card.tscn")


func _ready() -> void:
	_connect_signals()
	_load_all_items()
	_populate_item_grid()
	_update_credits_display()
	_update_equipped_slots()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC
		_on_back_pressed()


func _connect_signals() -> void:
	ResourceManager.credits_changed.connect(_on_credits_changed)
	UpgradeSystem.item_equipped.connect(_on_item_equipped)
	UpgradeSystem.item_unequipped.connect(_on_item_unequipped)
	UpgradeSystem.item_upgraded.connect(_on_item_upgraded)
	back_button.pressed.connect(_on_back_pressed)
	detail_upgrade_button.pressed.connect(_on_detail_upgrade_pressed)


func _load_all_items() -> void:
	all_items.clear()
	
	# Load items from each category directory
	var categories = ["defensive", "offensive", "utility"]
	for category in categories:
		var dir_path = "res://resources/items/" + category + "/"
		var items = _load_items_from_directory(dir_path)
		all_items.append_array(items)
	
	print("UpgradeShop: Loaded %d items" % all_items.size())


func _load_items_from_directory(dir_path: String) -> Array[ItemDefinition]:
	var items: Array[ItemDefinition] = []
	var dir = DirAccess.open(dir_path)
	
	if not dir:
		push_warning("UpgradeShop: Could not open directory: " + dir_path)
		return items
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = dir_path + file_name
			var item = load(full_path) as ItemDefinition
			if item:
				items.append(item)
			else:
				push_warning("UpgradeShop: Failed to load item: " + full_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return items


func _populate_item_grid() -> void:
	# Clear existing cards
	for child in item_grid.get_children():
		child.queue_free()
	
	var current_credits = ResourceManager.total_credits
	
	# Create card for each item
	for item in all_items:
		var card = upgrade_card_scene.instantiate() as UpgradeCard
		var level = UpgradeSystem.get_item_level(item)
		var equipped = UpgradeSystem.is_item_equipped(item)
		
		# Add to scene tree first so @onready variables are initialized
		item_grid.add_child(card)
		
		# Now setup can safely access the nodes
		card.setup(item, level, equipped, current_credits)
		
		# Connect signals
		card.upgrade_requested.connect(_on_card_upgrade_requested)
		card.equip_requested.connect(_on_card_equip_requested)
		card.unequip_requested.connect(_on_card_unequip_requested)
		card.card_selected.connect(_on_card_selected)


func _update_credits_display() -> void:
	credits_label.text = str(ResourceManager.total_credits)


func _update_equipped_slots() -> void:
	# Clear existing slot display
	for child in equipped_container.get_children():
		child.queue_free()
	
	# Show equipped items
	var equipped_items = UpgradeSystem.equipped_items
	var total_slots = UpgradeSystem.unlocked_slots
	
	for i in range(total_slots):
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(100, 100)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 5)
		margin.add_theme_constant_override("margin_top", 5)
		margin.add_theme_constant_override("margin_right", 5)
		margin.add_theme_constant_override("margin_bottom", 5)
		slot_panel.add_child(margin)
		
		var vbox = VBoxContainer.new()
		margin.add_child(vbox)
		
		if i < equipped_items.size():
			# Show equipped item
			var item = equipped_items[i]
			var icon = TextureRect.new()
			icon.custom_minimum_size = Vector2(64, 64)
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			if item.icon:
				icon.texture = item.icon
			vbox.add_child(icon)
			
			var name_label = Label.new()
			name_label.text = item.item_name
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			vbox.add_child(name_label)
		else:
			# Show empty slot
			var empty_label = Label.new()
			empty_label.text = "Empty Slot"
			empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			vbox.add_child(empty_label)
		
		equipped_container.add_child(slot_panel)


func _on_card_upgrade_requested(item: ItemDefinition) -> void:
	if UpgradeSystem.upgrade_item(item):
		print("UpgradeShop: Successfully upgraded " + item.item_name)
	else:
		print("UpgradeShop: Failed to upgrade " + item.item_name)


func _on_card_equip_requested(item: ItemDefinition) -> void:
	if UpgradeSystem.equip_item(item):
		print("UpgradeShop: Successfully equipped " + item.item_name)
	else:
		print("UpgradeShop: Failed to equip " + item.item_name)


func _on_card_unequip_requested(item: ItemDefinition) -> void:
	if UpgradeSystem.unequip_item(item):
		print("UpgradeShop: Successfully unequipped " + item.item_name)
	else:
		print("UpgradeShop: Failed to unequip " + item.item_name)


func _on_card_selected(item: ItemDefinition) -> void:
	selected_item = item
	_update_detail_panel()


func _update_detail_panel() -> void:
	if not selected_item:
		detail_panel.visible = false
		return
	
	detail_panel.visible = true
	detail_name.text = selected_item.item_name
	detail_description.text = selected_item.description
	
	if selected_item.icon:
		detail_icon.texture = selected_item.icon
	else:
		detail_icon.texture = null
	
	var level = UpgradeSystem.get_item_level(selected_item)
	var bonus_text = selected_item.get_bonus_text(level) if level > 0 else "Not Owned"
	var next_cost = selected_item.get_cost_at_level(level + 1)
	
	detail_stats.text = "Current: %s\nNext Level Cost: %d" % [bonus_text, next_cost]
	
	var can_afford = ResourceManager.total_credits >= next_cost
	detail_upgrade_button.disabled = not can_afford
	detail_upgrade_button.text = "Purchase" if level == 0 else "Upgrade"


func _on_detail_upgrade_pressed() -> void:
	if selected_item:
		_on_card_upgrade_requested(selected_item)


func _on_credits_changed(new_credits: int) -> void:
	_update_credits_display()
	_populate_item_grid()
	if selected_item:
		_update_detail_panel()


func _on_item_equipped(item: ItemDefinition) -> void:
	_update_equipped_slots()
	_populate_item_grid()


func _on_item_unequipped(item: ItemDefinition) -> void:
	_update_equipped_slots()
	_populate_item_grid()


func _on_item_upgraded(item: ItemDefinition, new_level: int) -> void:
	_populate_item_grid()
	if selected_item == item:
		_update_detail_panel()


func _on_back_pressed() -> void:
	# Navigate back to game over screen or main menu
	get_tree().change_scene_to_file("res://scenes/prototype/game.tscn")
