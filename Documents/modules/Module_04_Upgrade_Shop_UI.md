# Module 4: Upgrade Shop UI

**Priority**: High
**Dependencies**: Module 3 (Credits)
**Estimated Duration**: 4-6 days

## Purpose
Provide interface for spending credits on permanent upgrades.

## Core Components

### 4.1 Upgrade Shop Scene
- **File**: `scenes/ui/upgrade_shop.tscn`
- **Layout**:
  - Header: Credits display, back button
  - Item Grid: Scrollable container of upgrade cards
  - Item Detail Panel: Shows selected item stats, upgrade button
  - Equipment Slots: Shows equipped items (4-8 slots)

### 4.2 Upgrade Card Component
- **File**: `scenes/ui/components/upgrade_card.tscn`
- **Display**:
  - Item icon and name
  - Current level
  - Current bonus (e.g., "+25% Shield")
  - Next level bonus (e.g., "+27% Shield")
  - Upgrade cost
  - "Upgrade" / "Equip" / "Unequip" buttons

### 4.3 Shop Logic Script
- **File**: `scripts/ui/upgrade_shop.gd`
- **Responsibilities**:
  - Load all available items from `resources/items/`
  - Display equipped vs unequipped items
  - Handle purchase/upgrade transactions
  - Update UI when credits change
  - Validate purchases (enough credits, slot available)

## Integration Points
- Access from main menu or game over screen
- Connected to UpgradeSystem for equipped items
- Connected to SaveSystem for credit balance

## Extensibility
- Filter items by category
- Search/sort functionality
- Item comparison tools
- Build presets (save/load equipment configs)

## Testing Checklist
- [ ] All items load correctly
- [ ] Purchase validation works
- [ ] UI updates after purchase
- [ ] Equipment slots display correctly
- [ ] Can equip/unequip items
- [ ] Tooltips show accurate calculations

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
