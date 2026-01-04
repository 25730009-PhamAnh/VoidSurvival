# Module 04 Implementation Plan: Upgrade Shop UI

**Module**: Upgrade Shop UI
**Priority**: High
**Dependencies**: Module 3 (Credits System)
**Estimated Duration**: 4-6 days

## Overview
Create a comprehensive shop interface for purchasing and managing permanent upgrades using the credit system from Module 3. This module builds the UI layer on top of the UpgradeSystem from Module 1.

---

## Phase 1: Core Scene Structure (Day 1)

### 1.1 Create Upgrade Shop Scene
- **File**: `scenes/ui/upgrade_shop.tscn`
- **Root Node**: `Control` (full screen)
- **Layout Structure**:
  ```
  UpgradeShop (Control)
  ├── Background (ColorRect - dark overlay)
  ├── MainContainer (MarginContainer)
  │   └── VBoxContainer
  │       ├── Header (HBoxContainer)
  │       │   ├── TitleLabel ("Upgrade Shop")
  │       │   ├── Spacer (Control - expand)
  │       │   ├── CreditsDisplay (HBoxContainer)
  │       │   │   ├── CreditIcon (TextureRect)
  │       │   │   └── %CreditsLabel (Label - unique name)
  │       │   └── %BackButton (Button)
  │       ├── ContentContainer (HBoxContainer - expand)
  │       │   ├── ItemListPanel (PanelContainer)
  │       │   │   └── %ItemScrollContainer (ScrollContainer)
  │       │   │       └── %ItemGrid (GridContainer)
  │       │   └── DetailPanel (PanelContainer)
  │       │       └── VBoxContainer
  │       │           ├── %ItemName (Label)
  │       │           ├── %ItemIcon (TextureRect)
  │       │           ├── %ItemDescription (RichTextLabel)
  │       │           ├── StatsContainer (VBoxContainer)
  │       │           │   ├── %CurrentStats (Label)
  │       │           │   └── %NextStats (Label)
  │       │           ├── Spacer
  │       │           └── %UpgradeButton (Button)
  │       └── EquipmentSlots (HBoxContainer)
  │           └── %EquippedItemsContainer (HBoxContainer)
  ```

### 1.2 Create Base Stylesheet
- **File**: `resources/ui/shop_theme.tres` (Theme resource)
- Define consistent colors, fonts, button styles
- Create reusable style boxes for panels and cards

**Success Criteria**:
- Scene opens in editor without errors
- Layout scales properly at different resolutions (test 1920x1080, 1280x720, 720x1280)
- All unique name nodes accessible via `%NodeName`

---

## Phase 2: Upgrade Card Component (Day 2)

### 2.1 Create Upgrade Card Scene
- **File**: `scenes/ui/components/upgrade_card.tscn`
- **Root Node**: `PanelContainer`
- **Layout**:
  ```
  UpgradeCard (PanelContainer)
  └── MarginContainer
      └── VBoxContainer
          ├── Header (HBoxContainer)
          │   ├── %ItemIcon (TextureRect - 64x64)
          │   └── %ItemName (Label)
          ├── %LevelLabel (Label - "Level 3")
          ├── StatsSection (VBoxContainer)
          │   ├── %CurrentBonus (Label - "+25% Shield")
          │   └── %NextBonus (Label - "→ +27% Shield" - dimmed)
          ├── Spacer
          └── ActionButtons (HBoxContainer)
              ├── %CostLabel (Label)
              └── %ActionButton (Button - "Upgrade"/"Equip"/"Unequip")
  ```

### 2.2 Create Upgrade Card Script
- **File**: `scripts/ui/upgrade_card.gd`
- **Key Methods**:
  ```gdscript
  class_name UpgradeCard
  extends PanelContainer

  signal upgrade_requested(item_resource: UpgradeItemResource)
  signal equip_requested(item_resource: UpgradeItemResource)
  signal unequip_requested(item_resource: UpgradeItemResource)

  var item_resource: UpgradeItemResource
  var current_level: int = 0
  var is_equipped: bool = false

  func setup(item: UpgradeItemResource, level: int, equipped: bool) -> void
  func _update_display() -> void
  func _calculate_next_bonus() -> String
  func _on_action_button_pressed() -> void
  ```

**Success Criteria**:
- Card displays mock item data correctly
- Buttons emit proper signals
- Visual states change based on equipped/unequipped status

---

## Phase 3: Shop Logic Implementation (Days 3-4)

### 3.1 Create Shop Controller Script
- **File**: `scripts/ui/upgrade_shop.gd`
- **Dependencies**:
  - `UpgradeSystem` autoload (Module 1)
  - `SaveSystem` autoload (Module 2)
  - `SessionManager` autoload (Module 3 - for credits)

### 3.2 Core Shop Logic
```gdscript
class_name UpgradeShop
extends Control

@onready var item_grid: GridContainer = %ItemGrid
@onready var credits_label: Label = %CreditsLabel
@onready var equipped_container: HBoxContainer = %EquippedItemsContainer
@onready var detail_panel = $ContentContainer/DetailPanel
@onready var upgrade_button: Button = %UpgradeButton

var all_items: Array[UpgradeItemResource] = []
var selected_item: UpgradeItemResource = null

func _ready() -> void:
    _load_all_items()
    _populate_item_grid()
    _update_credits_display()
    _update_equipped_slots()
    _connect_signals()
    detail_panel.visible = false

func _load_all_items() -> void:
    # Scan resources/items/ directory
    # Load all UpgradeItemResource files
    pass

func _populate_item_grid() -> void:
    # Clear existing cards
    # For each item, instance UpgradeCard
    # Setup card with item data and current level from UpgradeSystem
    # Connect card signals
    pass

func _on_card_selected(item: UpgradeItemResource) -> void:
    # Update detail panel with item info
    pass

func _on_upgrade_requested(item: UpgradeItemResource) -> void:
    var cost = _calculate_upgrade_cost(item)
    if not _validate_purchase(cost):
        _show_insufficient_credits_message()
        return

    # Deduct credits via SessionManager
    # Upgrade item via UpgradeSystem
    # Update UI
    # Save game
    pass

func _on_equip_requested(item: UpgradeItemResource) -> void:
    # Check if slot available
    # Call UpgradeSystem.equip_item()
    # Update UI
    pass

func _on_unequip_requested(item: UpgradeItemResource) -> void:
    # Call UpgradeSystem.unequip_item()
    # Update UI
    pass

func _validate_purchase(cost: int) -> bool:
    return SessionManager.get_credits() >= cost

func _calculate_upgrade_cost(item: UpgradeItemResource) -> int:
    # Use formula from item resource or default scaling
    pass

func _update_credits_display() -> void:
    credits_label.text = str(SessionManager.get_credits())

func _update_equipped_slots() -> void:
    # Clear equipped container
    # For each equipped item from UpgradeSystem
    # Create small icon display in equipment slot
    pass

func _connect_signals() -> void:
    SessionManager.credits_changed.connect(_on_credits_changed)
    %BackButton.pressed.connect(_on_back_pressed)
    pass
```

### 3.3 Helper Functions
- Item filtering by category (if implemented)
- Sorting (by cost, by level, alphabetically)
- Search functionality (optional for Phase 1)
- Animation helpers for smooth transitions

**Success Criteria**:
- Shop loads all items from `resources/items/`
- Credits display updates in real-time
- Purchase validation prevents overdraft
- Equipment slots show correct items
- All transactions save properly

---

## Phase 4: Integration & Navigation (Day 4)

### 4.1 Add Shop Access Points
**From Main Menu** (if exists):
- Add "Upgrade Shop" button
- Transition to shop scene

**From Game Over Screen**:
- Add "Upgrade Shop" button below "Restart"
- Shows credits earned in current run

### 4.2 Scene Transitions
```gdscript
# In game_over_screen.gd
func _on_shop_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/upgrade_shop.tscn")

# In upgrade_shop.gd
func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
    # or wherever we came from
```

### 4.3 Integration Testing
- Test flow: Game Over → Shop → Purchase → Return → Start Game
- Verify equipped items apply bonuses in-game
- Verify credits persist across sessions

**Success Criteria**:
- Smooth navigation between screens
- No data loss during transitions
- Back button returns to correct scene

---

## Phase 5: Polish & UX (Day 5)

### 5.1 Visual Feedback
- Hover effects on cards
- Purchase success animation (flash, particle effect)
- Insufficient credits shake/red flash
- Level-up glow effect on upgraded cards

### 5.2 Audio
- Card select sound
- Purchase success sound
- Equip/unequip sound
- Insufficient credits error sound
- Ambient shop music (optional)

### 5.3 Tooltips & Help
- Hover tooltips explaining stats
- "?" info button explaining upgrade system
- First-time tutorial overlay (optional)

### 5.4 Responsive Design
- Test on portrait mobile (720x1280)
- Test on landscape mobile (1280x720)
- Test on desktop (1920x1080)
- Adjust GridContainer columns based on screen width

**Success Criteria**:
- All interactions have clear feedback
- UI readable on all target resolutions
- Shop feels responsive and polished

---

## Phase 6: Extensibility Features (Day 6 - Optional)

### 6.1 Category Filtering
- Add category tabs (Weapons, Defense, Utility)
- Filter item grid by selected category

### 6.2 Search/Sort
- Search bar for item names
- Sort dropdown (Cost, Level, Name)

### 6.3 Build Presets
- Save current equipment loadout
- Quick-swap between saved builds
- **File**: `scripts/ui/build_preset_manager.gd`

### 6.4 Item Comparison
- Select two items to compare side-by-side
- Highlight differences in stats

**Success Criteria**:
- Features work without breaking core functionality
- UI remains clean and not cluttered
- Performance stays smooth with filters active

---

## Testing Checklist

### Functional Tests
- [ ] All items load from `resources/items/` directory
- [ ] Item cards display correct icons, names, levels
- [ ] Current and next level bonuses calculate correctly
- [ ] Purchase button disabled when insufficient credits
- [ ] Credits deducted correctly on purchase
- [ ] Item level increases after successful purchase
- [ ] Equipment slots show max 4-8 items (based on design)
- [ ] Equip button disabled when all slots full
- [ ] Unequip button removes item from slot
- [ ] Detail panel updates when selecting different cards
- [ ] Back button returns to previous scene
- [ ] All changes persist after save/load

### UI/UX Tests
- [ ] Shop layout scales to 1920x1080
- [ ] Shop layout scales to 1280x720
- [ ] Shop layout scales to 720x1280 (portrait)
- [ ] All text readable at minimum resolution
- [ ] Buttons have hover states
- [ ] Tooltips appear on hover (if implemented)
- [ ] Animations smooth at 60 FPS
- [ ] No visual glitches during transitions

### Integration Tests
- [ ] Equipped items apply bonuses in gameplay
- [ ] Credits from Module 3 display correctly
- [ ] Save system persists shop purchases
- [ ] UpgradeSystem reflects equipped items
- [ ] Shop accessible from main menu
- [ ] Shop accessible from game over screen
- [ ] No errors in console during normal use

### Edge Cases
- [ ] Purchasing with exact credit amount works
- [ ] Attempting purchase with 1 credit short fails gracefully
- [ ] Equipping when all slots full shows message
- [ ] Opening shop with 0 credits shows all locked items
- [ ] Rapidly clicking upgrade button doesn't double-spend
- [ ] Opening shop with no items in resources/ handles gracefully

---

## File Checklist

### New Files to Create
- [ ] `scenes/ui/upgrade_shop.tscn`
- [ ] `scenes/ui/components/upgrade_card.tscn`
- [ ] `scripts/ui/upgrade_shop.gd`
- [ ] `scripts/ui/upgrade_card.gd`
- [ ] `resources/ui/shop_theme.tres` (optional)

### Files to Modify
- [ ] `scenes/ui/game_over_screen.tscn` (add shop button)
- [ ] `scripts/ui/game_over_screen.gd` (add navigation)
- [ ] `scenes/ui/main_menu.tscn` (add shop button, if menu exists)
- [ ] Update project settings if adding new input actions

### Files to Reference (Do Not Modify)
- `scripts/autoload/upgrade_system.gd` (Module 1)
- `scripts/autoload/save_system.gd` (Module 2)
- `scripts/autoload/session_manager.gd` (Module 3)
- `resources/items/*.tres` (item definitions)

---

## Risk Assessment

### High Risk
- **Complex UI layout**: May need iteration to get right
  - Mitigation: Build incrementally, test early on target resolutions
- **Integration with three different systems**: Potential for coupling issues
  - Mitigation: Use signals for communication, keep shop logic isolated

### Medium Risk
- **Performance with many items**: GridContainer with 50+ cards
  - Mitigation: Lazy loading, pagination, or category filters
- **Save/load during shop operations**: Race conditions
  - Mitigation: Disable interactions during save, clear success/fail feedback

### Low Risk
- **Visual polish**: Can always improve later
  - Mitigation: MVP first, polish in Phase 5

---

## Success Metrics

- Shop opens without errors on first launch
- All items purchasable when player has credits
- Equipment system fully functional from shop UI
- Zero crashes during normal shop operations
- UI responsive on all target platforms
- Code passes review with no major refactors needed

---

## Next Steps After Completion

1. Gather playtest feedback on shop UX
2. Iterate on visual design based on feedback
3. Add extensibility features (filters, search, presets)
4. Move to Module 5: Player Stats Screen
5. Consider shop analytics (track popular items, purchase patterns)

---

[← Back to Module Overview](../modules/Module_04_Upgrade_Shop_UI.md)
[← Back to Development Plan](../Development_Plan_Overview.md)
