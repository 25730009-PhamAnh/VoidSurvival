# Module 04: Upgrade Shop UI - Implementation Plan

## Overview
Implement a fully functional upgrade shop UI for purchasing and managing permanent upgrades. This requires creating a minimal UpgradeSystem autoload stub first (dependency), then building the shop interface.

## Key Dependencies Discovered
- **ResourceManager**: `spend_credits(amount) -> bool` - handles purchases and auto-saves
- **SaveSystem**: Already preserves `equipped_items[]`, `item_levels{}`, `unlocked_slots` (lines 35-37)
- **SessionManager**: Credits already calculated and added to ResourceManager at game over
- **GameOverScreen**: Has placeholder at line 93-96 for shop navigation

## Implementation Phases

### Phase 0: Foundation - UpgradeSystem Stub

**Critical: Must be done first so shop has something to integrate with**

#### 0.1 Create ItemDefinition Resource Class
**File**: `Src/void-survival/scripts/resources/item_definition.gd`

```gdscript
class_name ItemDefinition
extends Resource

@export var item_name: String = "Unnamed Item"
@export var description: String = ""
@export var icon: Texture2D
@export_enum("Defensive", "Offensive", "Utility") var category: String = "Defensive"

# Cost scaling
@export var base_cost: int = 100
@export var cost_exponent: float = 1.15

# Bonus scaling
@export var base_bonus: float = 0.10
@export var bonus_per_level: float = 0.02
@export var affected_stat: String = "max_shield"

func get_cost_at_level(level: int) -> int:
    if level <= 0:
        return base_cost
    return int(base_cost * pow(cost_exponent, level - 1))

func get_bonus_at_level(level: int) -> float:
    if level <= 0:
        return 0.0
    return base_bonus + (bonus_per_level * (level - 1))

func get_bonus_text(level: int) -> String:
    var bonus = get_bonus_at_level(level)
    return "+%.0f%% %s" % [bonus * 100, affected_stat.replace("_", " ").capitalize()]
```

#### 0.2 Create UpgradeSystem Autoload
**File**: `Src/void-survival/scripts/autoload/upgrade_system.gd`

Key responsibilities:
- Manage `equipped_items: Array[ItemDefinition]` (max 4)
- Track `item_levels: Dictionary` (resource_path -> level)
- Track `unlocked_slots: int = 4`
- Signals: `item_equipped`, `item_unequipped`, `item_upgraded`, `stats_updated`
- Methods:
  - `equip_item(item) -> bool` - Add to equipped_items if space available
  - `unequip_item(item) -> bool` - Remove from equipped_items
  - `upgrade_item(item) -> bool` - Call ResourceManager.spend_credits(), increment level
  - `get_item_level(item) -> int` - Return level from dictionary
  - `is_item_equipped(item) -> bool` - Check if in equipped_items
  - `_load_from_save()` - Load from SaveSystem.load_game()
  - `_save_to_system()` - Update save data, call SaveSystem.save_game()

**Integration with SaveSystem**:
```gdscript
func _save_to_system() -> void:
    var save_data = SaveSystem.load_game()

    # Convert equipped items to paths
    var equipped_paths: Array = []
    for item in equipped_items:
        equipped_paths.append(item.resource_path)

    save_data["equipped_items"] = equipped_paths
    save_data["item_levels"] = item_levels
    save_data["unlocked_slots"] = unlocked_slots

    SaveSystem.save_game()
```

#### 0.3 Register UpgradeSystem in project.godot
**File**: `Src/void-survival/project.godot`

Add after line 22:
```ini
UpgradeSystem="*res://scripts/autoload/upgrade_system.gd"
```

#### 0.4 Create Sample Item Resources

**Create directories**:
- `Src/void-survival/resources/items/defensive/`
- `Src/void-survival/resources/items/offensive/`
- `Src/void-survival/resources/items/utility/`

**Create 3 sample items** (as .tres files):
1. `defensive/energy_amplifier.tres` - Increases max shield (base_cost: 100)
2. `offensive/rapid_fire_module.tres` - Increases fire rate (base_cost: 150)
3. `utility/crystal_magnet.tres` - Increases collection radius (base_cost: 80)

### Phase 1: Upgrade Card Component

#### 1.1 Create Upgrade Card Scene
**File**: `Src/void-survival/scenes/ui/components/upgrade_card.tscn`

**Root**: PanelContainer (220x280 minimum size)
- MarginContainer (10px margins)
  - VBoxContainer
    - Header (HBoxContainer): %ItemIcon (48x48), VBox with %ItemName + %CategoryLabel
    - %LevelLabel - "Level 0"
    - HSeparator
    - %CurrentBonusLabel - "+20% Max Shield"
    - %NextBonusLabel - "→ +22%" (dimmed)
    - Spacer
    - ActionArea (VBoxContainer):
      - %CostLabel - "Cost: 100"
      - ButtonsContainer (HBoxContainer): %UpgradeButton, %EquipButton

#### 1.2 Create Upgrade Card Script
**File**: `Src/void-survival/scripts/ui/upgrade_card.gd`

```gdscript
class_name UpgradeCard
extends PanelContainer

signal upgrade_requested(item: ItemDefinition)
signal equip_requested(item: ItemDefinition)
signal unequip_requested(item: ItemDefinition)
signal card_selected(item: ItemDefinition)

# @onready node references with %
var item_resource: ItemDefinition
var current_level: int = 0
var is_equipped: bool = false
var can_afford: bool = true

func setup(item: ItemDefinition, level: int, equipped: bool, credits: int) -> void:
    # Update all labels and button states
    # Set affordability based on credits vs cost

func _update_buttons() -> void:
    # Enable/disable based on affordability
    # Show "Purchase" vs "Upgrade" based on level
    # Show/hide equip button based on ownership
```

### Phase 2: Upgrade Shop Scene

#### 2.1 Create Shop Scene Structure
**File**: `Src/void-survival/scenes/ui/upgrade_shop.tscn`

**Root**: CanvasLayer
- Background (ColorRect - 80% opacity black overlay)
- MainContainer (MarginContainer - 40px top/bottom, 60px left/right)
  - VBoxContainer
    - HeaderContainer (HBoxContainer):
      - TitleLabel "UPGRADE SHOP"
      - Spacer
      - CreditsContainer: Icon + %CreditsLabel
      - %BackButton "Back [ESC]"
    - ContentContainer (HBoxContainer - expand):
      - ItemListPanel (PanelContainer - expand):
        - VBoxContainer:
          - FilterContainer (optional category buttons)
          - %ItemScrollContainer (ScrollContainer)
            - %ItemGrid (GridContainer, 2 columns)
      - DetailPanel (PanelContainer - 300px width, initially hidden):
        - VBoxContainer: %DetailItemName, %DetailItemIcon, %DetailDescription, stats, %DetailUpgradeButton
    - EquipmentSlots (PanelContainer):
      - %EquippedItemsContainer (HBoxContainer - show 4 slots)

### Phase 3: Shop Logic

#### 3.1 Create Shop Script
**File**: `Src/void-survival/scripts/ui/upgrade_shop.gd`

```gdscript
extends CanvasLayer

var all_items: Array[ItemDefinition] = []
var selected_item: ItemDefinition = null
var upgrade_card_scene = preload("res://scenes/ui/components/upgrade_card.tscn")

func _ready() -> void:
    _connect_signals()
    _load_all_items()
    _populate_item_grid()
    _update_credits_display()
    _update_equipped_slots()

func _connect_signals() -> void:
    ResourceManager.credits_changed.connect(_on_credits_changed)
    UpgradeSystem.item_equipped.connect(_on_item_equipped)
    UpgradeSystem.item_unequipped.connect(_on_item_unequipped)
    UpgradeSystem.item_upgraded.connect(_on_item_upgraded)

func _load_all_items() -> void:
    # Scan resources/items/defensive/, offensive/, utility/
    # Use DirAccess.open() and load .tres files
    # Add to all_items array

func _populate_item_grid() -> void:
    # Clear grid
    # For each item, instantiate upgrade_card_scene
    # Call card.setup(item, level, equipped, credits)
    # Connect card signals to handlers
    # Add to grid

func _on_card_upgrade_requested(item: ItemDefinition) -> void:
    UpgradeSystem.upgrade_item(item)  # Handles spend_credits internally

func _on_card_equip_requested(item: ItemDefinition) -> void:
    UpgradeSystem.equip_item(item)

func _on_card_unequip_requested(item: ItemDefinition) -> void:
    UpgradeSystem.unequip_item(item)

func _on_credits_changed(new_credits: int) -> void:
    _update_credits_display()
    _populate_item_grid()  # Refresh affordability

func _on_item_equipped/unequipped/upgraded(...) -> void:
    _update_equipped_slots()
    _populate_item_grid()  # Refresh display
```

**Item Loading Pattern**:
```gdscript
func _load_items_from_directory(dir_path: String) -> Array[ItemDefinition]:
    var items: Array[ItemDefinition] = []
    var dir = DirAccess.open(dir_path)
    if not dir:
        return items

    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".tres"):
            var item = load(dir_path + file_name) as ItemDefinition
            if item:
                items.append(item)
        file_name = dir.get_next()
    dir.list_dir_end()
    return items
```

### Phase 4: Integration

#### 4.1 Update Game Over Screen Navigation
**File**: `Src/void-survival/scripts/ui/game_over_screen.gd`

**Modify line 93-96**:
```gdscript
func _on_upgrades_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/upgrade_shop.tscn")
```

#### 4.2 Add Back Navigation from Shop
In `upgrade_shop.gd`:
```gdscript
func _on_back_pressed() -> void:
    # TODO: Track where we came from
    # For now, assume game over screen
    get_tree().change_scene_to_file("res://scenes/prototype/game.tscn")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):  # ESC
        _on_back_pressed()
```

### Phase 5: Polish & Testing

#### 5.1 Visual Feedback
- Hover effects on cards (modulate on mouse_entered/exited)
- Disabled button styling
- Green highlight for equipped items
- Update detail panel on card selection

#### 5.2 Error Handling
- Graceful handling of empty item directories
- Validation before equip (check if owned, check slots available)
- Clear console messages for debugging

#### 5.3 Edge Cases to Test
- [ ] Purchase with exact credits
- [ ] Purchase with insufficient credits
- [ ] Equip when all slots full
- [ ] Unequip last item
- [ ] Rapid clicking upgrade button
- [ ] Save/load persistence

## File Summary

### New Files (13 total):

**Scripts (4)**:
1. `Src/void-survival/scripts/resources/item_definition.gd`
2. `Src/void-survival/scripts/autoload/upgrade_system.gd`
3. `Src/void-survival/scripts/ui/upgrade_shop.gd`
4. `Src/void-survival/scripts/ui/upgrade_card.gd`

**Scenes (2)**:
5. `Src/void-survival/scenes/ui/upgrade_shop.tscn`
6. `Src/void-survival/scenes/ui/components/upgrade_card.tscn`

**Resources (3 sample items)**:
7. `Src/void-survival/resources/items/defensive/energy_amplifier.tres`
8. `Src/void-survival/resources/items/offensive/rapid_fire_module.tres`
9. `Src/void-survival/resources/items/utility/crystal_magnet.tres`

**Directories (5)**:
10. `Src/void-survival/resources/items/`
11. `Src/void-survival/resources/items/defensive/`
12. `Src/void-survival/resources/items/offensive/`
13. `Src/void-survival/resources/items/utility/`
14. `Src/void-survival/scenes/ui/components/`

### Modified Files (2):
1. `Src/void-survival/project.godot` - Add UpgradeSystem to autoload (after line 22)
2. `Src/void-survival/scripts/ui/game_over_screen.gd` - Update _on_upgrades_pressed() (lines 93-96)

## Implementation Order

1. **Phase 0** - Foundation (ItemDefinition, UpgradeSystem, project.godot, sample items)
2. **Phase 1** - Upgrade Card Component (scene + script)
3. **Phase 2** - Shop Scene Structure (layout and nodes)
4. **Phase 3** - Shop Logic (script implementation)
5. **Phase 4** - Integration (game over navigation)
6. **Phase 5** - Polish & Testing

## Success Criteria

- [ ] Shop loads all items from resources/items/
- [ ] Can purchase item with sufficient credits
- [ ] Can equip/unequip owned items
- [ ] Can upgrade owned items to higher levels
- [ ] Credits update in real-time
- [ ] Equipment slots display correctly (4 slots)
- [ ] All purchases persist through save/load
- [ ] Back button navigates correctly
- [ ] No console errors during normal operation
- [ ] Insufficient credits disables upgrade button
- [ ] Full equipment slots prevents new equips

## Key Integration Points

**ResourceManager Integration**:
- Read: `ResourceManager.total_credits`
- Listen: `ResourceManager.credits_changed` signal
- Call: `ResourceManager.spend_credits(amount)` returns bool

**UpgradeSystem Integration**:
- Call: `upgrade_item()`, `equip_item()`, `unequip_item()`
- Read: `get_item_level()`, `is_item_equipped()`, `equipped_items`
- Listen: `item_equipped`, `item_unequipped`, `item_upgraded` signals

**SaveSystem Integration**:
- Automatic via UpgradeSystem._save_to_system()
- SaveSystem already preserves upgrade fields (save_system.gd:35-37)

## Notes

- UpgradeSystem is a **minimal stub** for Module 04 - will be expanded in future modules
- Items don't actually apply bonuses to gameplay yet (that's Module 5+)
- Shop is fully functional for purchases, equipping, and persistence
- UI follows existing patterns: CanvasLayer root, unique names (%), signal-based communication

---

[← Back to Module Overview](../modules/Module_04_Upgrade_Shop_UI.md)
[← Back to Development Plan](../Development_Plan_Overview.md)
