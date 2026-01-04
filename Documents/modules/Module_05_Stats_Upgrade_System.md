# Module 5: Stat Calculation & Upgrade System

**Priority**: High
**Dependencies**: Module 4 (Shop UI)
**Estimated Duration**: 3-5 days

## Purpose
Calculate final ship stats from base values + equipped items with infinite scaling.

## Core Components

### 5.1 ShipStats Resource
- **File**: `resources/ship_parameters/base_ship_stats.tres`
- Contains all base stat formulas (already defined in Technical Spec)

### 5.2 ItemDefinition Resource Base Class
- **File**: `scripts/resources/item_definition.gd`
- Defines scaling formulas, costs, effects (already defined in Technical Spec)

### 5.3 Individual Item Resources
Create `.tres` files for each item:
- `resources/items/defensive/energy_amplifier.tres`
- `resources/items/defensive/nano_repair.tres`
- `resources/items/defensive/reactive_armor.tres`
- `resources/items/offensive/rapid_accelerator.tres`
- `resources/items/offensive/plasma_infusion.tres`
- `resources/items/utility/crystal_magnet.tres`
- (etc., 15-20 items total)

### 5.4 UpgradeSystem Singleton
- **File**: `autoload/upgrade_system.gd`
- **Core Method**:
  ```gdscript
  func get_final_stats() -> Dictionary:
      var base_stats = ship_stats_resource.calculate_stats(point_levels)

      for item in equipped_items:
          var level = item_levels.get(item, 0)
          item.apply_to_stats(base_stats, level)

      return base_stats
  ```

### 5.5 Player Stat Application
- Player reads final stats on `_ready()` and when stats change:
  ```gdscript
  func _ready():
      UpgradeSystem.stats_updated.connect(_on_stats_updated)
      _apply_stats(UpgradeSystem.get_final_stats())

  func _apply_stats(stats: Dictionary):
      max_shield = stats.max_shield
      shield_regen_rate = stats.shield_regen
      # ... etc
  ```

## Integration Points
- Shop UI calls `UpgradeSystem.upgrade_item(item)`
- UpgradeSystem emits `stats_updated` signal
- Player, weapons, collection radius all update from stats

## Extensibility
- Add new items without code changes (just new `.tres` files)
- Stat synergies between items
- Conditional bonuses (e.g., "if < 30% shield, +50% damage")

## Testing Checklist
- [ ] Base stats calculate correctly
- [ ] Item bonuses apply correctly
- [ ] Multiple items stack properly
- [ ] Stats update when item equipped/unequipped
- [ ] High-level items (100+) calculate without overflow
- [ ] Performance with all slots filled

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
