# Module 05 Implementation Plan: Stat Calculation & Upgrade System

**Status**: Ready for Implementation
**Module Reference**: [Module_05_Stats_Upgrade_System.md](../modules/Module_05_Stats_Upgrade_System.md)
**Dependencies**: Module 04 (Shop UI) ✅
**Estimated Effort**: 3-5 days

---

## Overview

This module implements the core stat calculation system that makes items actually affect gameplay. Currently, items can be purchased and equipped, but they don't modify player stats. This module bridges that gap by:

1. Creating a centralized base stats resource
2. Implementing stat calculation logic in UpgradeSystem
3. Making items apply bonuses to stats
4. Connecting player/weapons to use calculated stats instead of hardcoded values

---

## Current State Analysis

### ✅ Already Complete
- `UpgradeSystem` autoload exists with equip/unequip/upgrade logic (scripts/autoload/upgrade_system.gd:1)
- `ItemDefinition` resource class with cost/bonus scaling (scripts/resources/item_definition.gd:1)
- Basic items created: energy_amplifier, rapid_fire_module, crystal_magnet
- Shop UI loads and displays items with purchase/upgrade functionality
- `stats_updated` signal already emitted in UpgradeSystem:41,58,81

### ❌ Missing (To Be Implemented)
- ShipStats resource class for base stat formulas
- base_ship_stats.tres resource instance
- `get_final_stats()` method in UpgradeSystem
- `apply_to_stats()` method in ItemDefinition
- Player stat application from UpgradeSystem
- Weapon system stat application
- CollectionComponent radius stat application

---

## Implementation Steps

### Phase 1: Foundation - Base Stats System

#### Task 1.1: Create ShipStats Resource Class
**File**: `Src/void-survival/scripts/resources/ship_stats.gd` (NEW)

**Purpose**: Define base stat formulas and calculation logic.

**Implementation**:
```gdscript
class_name ShipStats
extends Resource

# Shield Parameters
@export var base_max_shield: float = 100.0
@export var shield_per_level: float = 20.0
@export var base_shield_regen: float = 5.0
@export var shield_regen_per_level: float = 0.5
@export var base_shield_delay: float = 3.0
@export var shield_delay_reduction: float = 0.1
@export var min_shield_delay: float = 0.5

# Movement Parameters
@export var base_move_speed: float = 300.0
@export var move_speed_per_level: float = 5.0
@export var base_acceleration: float = 200.0
@export var accel_per_level: float = 5.0

# Weapon Parameters
@export var base_fire_rate: float = 2.0  # shots per second
@export var fire_rate_per_level: float = 0.1
@export var base_damage: float = 10.0
@export var damage_multiplier_per_level: float = 0.15  # 15% per level
@export var base_projectile_speed: float = 400.0
@export var projectile_speed_per_level: float = 10.0

# Utility Parameters
@export var base_collection_radius: float = 50.0
@export var collection_radius_per_level: float = 5.0
@export var base_luck: float = 1.0
@export var luck_per_level: float = 0.1

## Calculate base stats from point allocation
func calculate_stats(levels: Dictionary) -> Dictionary:
	return {
		"max_shield": base_max_shield + levels.get("defense", 0) * shield_per_level,
		"shield_regen": base_shield_regen + levels.get("defense", 0) * shield_regen_per_level,
		"shield_delay": max(min_shield_delay, base_shield_delay - levels.get("defense", 0) * shield_delay_reduction),
		"move_speed": base_move_speed + levels.get("mobility", 0) * move_speed_per_level,
		"acceleration": base_acceleration + levels.get("mobility", 0) * accel_per_level,
		"fire_rate": base_fire_rate + levels.get("offense", 0) * fire_rate_per_level,
		"damage": base_damage * (1.0 + levels.get("offense", 0) * damage_multiplier_per_level),
		"projectile_speed": base_projectile_speed + levels.get("offense", 0) * projectile_speed_per_level,
		"collection_radius": base_collection_radius + levels.get("utility", 0) * collection_radius_per_level,
		"luck": base_luck + levels.get("utility", 0) * luck_per_level
	}
```

**Validation**:
- [ ] File created and compiles without errors
- [ ] All @export variables visible in editor
- [ ] `calculate_stats()` returns correct Dictionary structure

---

#### Task 1.2: Create Base Ship Stats Resource
**File**: `Src/void-survival/resources/ship_parameters/base_ship_stats.tres` (NEW)

**Purpose**: Default stat values for the game (will use all base values initially).

**Implementation**:
1. Create `resources/ship_parameters/` directory
2. In Godot Editor: Right-click → Create New → Resource → ShipStats
3. Save as `base_ship_stats.tres`
4. Leave all values at defaults (defined in ShipStats.gd)

**Validation**:
- [ ] Resource file created successfully
- [ ] Can be loaded in editor without errors
- [ ] All default values match player.gd constants

---

### Phase 2: Item System Enhancement

#### Task 2.1: Enhance ItemDefinition with Stat Application
**File**: `Src/void-survival/scripts/resources/item_definition.gd` (MODIFY)

**Changes**:
1. Change `affected_stat` from String to Array[String] to support multiple stats
2. Add `scaling_type` enum for additive vs multiplicative bonuses
3. Implement `apply_to_stats()` method

**Implementation**:
```gdscript
# Add enum at top of file
enum ScalingType {
	ADDITIVE,      # Flat bonus: base * (1 + 0.25)
	MULTIPLICATIVE # Stacking: base * 1.25 * 1.25...
}

# Replace existing affected_stat with:
@export var affected_stats: Array[String] = ["max_shield"]
@export var scaling_type: ScalingType = ScalingType.ADDITIVE

# Add new method:
func apply_to_stats(stats: Dictionary, level: int) -> void:
	"""Apply this item's bonuses to the stats dictionary."""
	if level <= 0:
		return

	var bonus_multiplier = get_bonus_at_level(level)

	for stat_name in affected_stats:
		if stat_name not in stats:
			push_warning("ItemDefinition: Stat '%s' not found in stats dictionary" % stat_name)
			continue

		var base_value = stats[stat_name]

		if scaling_type == ScalingType.ADDITIVE:
			# Add percentage of base: base * (1 + bonus)
			stats[stat_name] = base_value * (1.0 + bonus_multiplier)
		else:  # MULTIPLICATIVE
			# Multiply: base * (1 + bonus)
			stats[stat_name] = base_value * (1.0 + bonus_multiplier)

# Update get_bonus_text to handle multiple stats:
func get_bonus_text(level: int) -> String:
	var bonus = get_bonus_at_level(level)
	var stat_names = ", ".join(affected_stats.map(func(s): return s.replace("_", " ").capitalize()))
	return "+%.0f%% %s" % [bonus * 100, stat_names]
```

**Migration Notes**:
- Existing `.tres` files with `affected_stat` (singular) need updating to `affected_stats` (array)
- This is handled automatically by Godot's resource migration

**Validation**:
- [ ] Enum added and accessible
- [ ] `affected_stats` array exports correctly
- [ ] `apply_to_stats()` modifies dictionary correctly
- [ ] Existing items still load (auto-migrated)

---

#### Task 2.2: Update Existing Item Resources
**Files**:
- `resources/items/defensive/energy_amplifier.tres`
- `resources/items/offensive/rapid_fire_module.tres`
- `resources/items/utility/crystal_magnet.tres`

**Changes**:
For each item, update to use array format and appropriate scaling:

**Energy Amplifier**:
```
affected_stats = ["max_shield"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.10
bonus_per_level = 0.02
```

**Rapid Fire Module**:
```
affected_stats = ["fire_rate"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.15
bonus_per_level = 0.03
```

**Crystal Magnet**:
```
affected_stats = ["collection_radius"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.20
bonus_per_level = 0.05
```

**Validation**:
- [ ] All three items load without errors
- [ ] Inspector shows `affected_stats` as array
- [ ] Bonus text displays correctly in shop

---

### Phase 3: UpgradeSystem Integration

#### Task 3.1: Implement get_final_stats() Method
**File**: `Src/void-survival/scripts/autoload/upgrade_system.gd` (MODIFY)

**Add at top**:
```gdscript
@export var ship_stats_resource: ShipStats
var point_levels: Dictionary = {}  # For future point allocation system
```

**Add method**:
```gdscript
func get_final_stats() -> Dictionary:
	"""Calculate final ship stats from base + equipped item bonuses."""
	# Start with base stats (currently all levels are 0)
	var stats = ship_stats_resource.calculate_stats(point_levels)

	# Apply bonuses from equipped items
	for item in equipped_items:
		if not item:
			continue
		var level = get_item_level(item)
		item.apply_to_stats(stats, level)

	return stats
```

**In _ready(), add**:
```gdscript
func _ready() -> void:
	# Load the ship stats resource
	if not ship_stats_resource:
		ship_stats_resource = load("res://resources/ship_parameters/base_ship_stats.tres")
		if not ship_stats_resource:
			push_error("UpgradeSystem: Failed to load base_ship_stats.tres")

	_load_from_save()
```

**Validation**:
- [ ] `get_final_stats()` returns correct Dictionary structure
- [ ] With no items equipped, returns base stats
- [ ] With items equipped, applies bonuses correctly
- [ ] Multiple items stack properly

---

### Phase 4: Player Integration

#### Task 4.1: Connect Player to Stat System
**File**: `Src/void-survival/scripts/player.gd` (MODIFY)

**Remove hardcoded constants**:
```gdscript
# DELETE these lines:
const ACCELERATION = 200.0
const MAX_SPEED = 300.0
const ROTATION_SPEED = 3.0
const FIRE_RATE = 0.5
const INVINCIBILITY_TIME = 1.0
const BOUNCE_FORCE = 100.0

# KEEP (not stat-based):
const ROTATION_SPEED = 3.0
const INVINCIBILITY_TIME = 1.0
const BOUNCE_FORCE = 100.0
```

**Add properties**:
```gdscript
# Stats (set from UpgradeSystem)
var max_speed: float = 300.0
var acceleration: float = 200.0
var fire_rate: float = 2.0  # shots per second
var projectile_damage: float = 10.0
var projectile_speed: float = 400.0
```

**Update _ready()**:
```gdscript
func _ready() -> void:
	# Connect to stat updates
	UpgradeSystem.stats_updated.connect(_on_stats_updated)

	# Apply initial stats
	_apply_stats(UpgradeSystem.get_final_stats())

	# Initialize shield
	current_shield = max_shield
	shield_changed.emit(current_shield, max_shield)

	# Connect collection
	collection_component.item_collected.connect(_on_item_collected)

func _on_stats_updated() -> void:
	_apply_stats(UpgradeSystem.get_final_stats())

func _apply_stats(stats: Dictionary) -> void:
	max_shield = stats.max_shield
	max_speed = stats.move_speed
	acceleration = stats.acceleration
	fire_rate = stats.fire_rate
	projectile_damage = stats.damage
	projectile_speed = stats.projectile_speed

	# Update collection radius
	if collection_component:
		collection_component.set_radius(stats.collection_radius)
```

**Update _handle_input() to use dynamic fire_rate**:
```gdscript
func _handle_input(delta: float) -> void:
	# ... existing rotation/thrust code ...

	# Auto-fire with dynamic rate
	if _fire_timer > 0:
		_fire_timer -= delta
	else:
		_fire()  # This will reset timer
```

**Update _fire() to use fire_rate**:
```gdscript
func _fire() -> void:
	if not projectile_scene:
		push_error("Player: projectile_scene not set!")
		return

	_fire_timer = 1.0 / fire_rate  # Convert shots-per-second to delay
	SessionManager.record_shot_fired()

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.global_rotation = global_rotation

	# Apply stats to projectile
	if projectile.has_method("set_damage"):
		projectile.set_damage(projectile_damage)
	if projectile.has_method("set_speed"):
		projectile.set_speed(projectile_speed)

	get_parent().add_child(projectile)
```

**Update _handle_input thrust to use acceleration/max_speed**:
```gdscript
# Thrust
if Input.is_action_pressed("thrust_forward"):
	var direction = Vector2.UP.rotated(rotation)
	velocity += direction * acceleration * delta
	velocity = velocity.limit_length(max_speed)
```

**Validation**:
- [ ] Player stats load from UpgradeSystem on start
- [ ] Equipping items updates player stats immediately
- [ ] Fire rate changes with offensive items
- [ ] Movement changes with mobility items
- [ ] Shield changes with defensive items

---

#### Task 4.2: Update Projectile to Accept Stat Overrides
**File**: `Src/void-survival/scripts/projectile.gd` (MODIFY - if not already done)

**Add methods**:
```gdscript
func set_damage(value: float) -> void:
	damage = value

func set_speed(value: float) -> void:
	speed = value
```

**Validation**:
- [ ] Projectile accepts damage/speed from player
- [ ] Higher damage items increase projectile damage
- [ ] Projectile speed increases with items

---

#### Task 4.3: Update CollectionComponent Radius
**File**: `Src/void-survival/scripts/components/collection_component.gd` (CHECK/MODIFY)

**Ensure method exists**:
```gdscript
func set_radius(new_radius: float) -> void:
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = new_radius
```

**Validation**:
- [ ] Collection radius updates when utility items equipped
- [ ] Visual feedback matches actual radius (if debugging)

---

### Phase 5: Additional Items

#### Task 5.1: Create Remaining Defensive Items

**Nano Repair System**
**File**: `resources/items/defensive/nano_repair.tres`
```
script = item_definition.gd
item_name = "Nano Repair System"
description = "Microscopic repair drones continuously restore your shield integrity."
category = 0  # Defensive
base_cost = 150
cost_exponent = 1.18
affected_stats = ["shield_regen"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.20
bonus_per_level = 0.04
```

**Reactive Armor**
**File**: `resources/items/defensive/reactive_armor.tres`
```
script = item_definition.gd
item_name = "Reactive Armor"
description = "Adaptive plating that reduces shield regeneration delay after damage."
category = 0  # Defensive
base_cost = 200
cost_exponent = 1.20
affected_stats = ["shield_delay"]
scaling_type = 0  # ADDITIVE
base_bonus = -0.15  # Reduces delay (negative is good)
bonus_per_level = -0.03
```

**Note**: Shield delay is special - negative bonus improves it. Handle in apply_to_stats if needed.

---

#### Task 5.2: Create Remaining Offensive Items

**Plasma Infusion**
**File**: `resources/items/offensive/plasma_infusion.tres`
```
script = item_definition.gd
item_name = "Plasma Infusion"
description = "Superheats projectiles with plasma energy, increasing damage output."
category = 1  # Offensive
base_cost = 180
cost_exponent = 1.16
affected_stats = ["damage"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.15
bonus_per_level = 0.03
```

**Kinetic Accelerator**
**File**: `resources/items/offensive/kinetic_accelerator.tres`
```
script = item_definition.gd
item_name = "Kinetic Accelerator"
description = "Electromagnetic rails propel projectiles at extreme velocities."
category = 1  # Offensive
base_cost = 120
cost_exponent = 1.14
affected_stats = ["projectile_speed"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.12
bonus_per_level = 0.02
```

---

#### Task 5.3: Create Remaining Utility Items

**Fortune Matrix**
**File**: `resources/items/utility/fortune_matrix.tres`
```
script = item_definition.gd
item_name = "Fortune Matrix"
description = "Quantum probability manipulator increases crystal yields and rare drops."
category = 2  # Utility
base_cost = 250
cost_exponent = 1.22
affected_stats = ["luck"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.10
bonus_per_level = 0.02
```

**Note**: Luck stat doesn't affect gameplay yet (Module 6+), but infrastructure is ready.

---

#### Task 5.4: Create Multi-Stat Hybrid Items

**Quantum Core**
**File**: `resources/items/utility/quantum_core.tres`
```
script = item_definition.gd
item_name = "Quantum Core"
description = "Experimental reactor boosts all ship systems simultaneously."
category = 2  # Utility
base_cost = 500
cost_exponent = 1.30
affected_stats = ["max_shield", "fire_rate", "move_speed"]
scaling_type = 0  # ADDITIVE
base_bonus = 0.05
bonus_per_level = 0.01
```

**Validation**:
- [ ] All new items load in shop
- [ ] Multi-stat items affect all listed stats
- [ ] Costs scale appropriately

---

### Phase 6: Testing & Validation

#### Task 6.1: Unit Testing Scenarios

**Test 1: Base Stats Calculation**
```gdscript
# Expected: All base values with no point allocation
var stats = UpgradeSystem.get_final_stats()
assert(stats.max_shield == 100.0)
assert(stats.fire_rate == 2.0)
assert(stats.move_speed == 300.0)
```

**Test 2: Single Item Bonus**
```gdscript
# Equip Energy Amplifier L1 (+10% max shield)
var item = load("res://resources/items/defensive/energy_amplifier.tres")
UpgradeSystem.upgrade_item(item)
UpgradeSystem.equip_item(item)
var stats = UpgradeSystem.get_final_stats()
assert(stats.max_shield == 110.0)  # 100 * 1.10
```

**Test 3: Multiple Items Stacking**
```gdscript
# Equip both Energy Amplifier L1 and Rapid Fire L1
var energy = load(".../energy_amplifier.tres")
var rapid = load(".../rapid_fire_module.tres")
UpgradeSystem.upgrade_item(energy)
UpgradeSystem.upgrade_item(rapid)
UpgradeSystem.equip_item(energy)
UpgradeSystem.equip_item(rapid)
var stats = UpgradeSystem.get_final_stats()
assert(stats.max_shield == 110.0)   # +10%
assert(stats.fire_rate == 2.3)      # 2.0 * 1.15
```

**Test 4: High-Level Item Scaling**
```gdscript
# Upgrade item to level 100
var item = load(".../energy_amplifier.tres")
for i in range(100):
	UpgradeSystem.upgrade_item(item)
UpgradeSystem.equip_item(item)
var stats = UpgradeSystem.get_final_stats()
# Level 100: base_bonus (0.10) + (99 * 0.02) = 2.08 = 208%
assert(stats.max_shield == 308.0)  # 100 * (1 + 2.08)
```

**Validation**:
- [ ] Base stats match expected values
- [ ] Single item applies correctly
- [ ] Multiple items stack additively
- [ ] High levels don't overflow or break
- [ ] No performance issues with all slots filled

---

#### Task 6.2: Integration Testing

**Test Scenario 1: Shop → Stats → Gameplay**
1. Start new game
2. Collect crystals, trigger game over
3. Purchase Energy Amplifier in shop
4. Equip Energy Amplifier
5. Start new game
6. Verify max_shield increased in HUD
7. Verify can survive more hits

**Test Scenario 2: Multiple Items**
1. Purchase 3 different items
2. Equip all 3
3. Verify all stats updated
4. Unequip 1 item
5. Verify stats recalculated correctly

**Test Scenario 3: Upgrade During Session**
- Currently not supported (shop only between sessions)
- Document for future: stats_updated signal already in place

**Validation**:
- [ ] Purchasing item doesn't change stats (not equipped)
- [ ] Equipping item immediately updates gameplay
- [ ] Unequipping reverts stats
- [ ] Stats persist across game restarts
- [ ] HUD displays updated values

---

#### Task 6.3: Performance Testing

**Test 1: Stat Calculation Performance**
```gdscript
# Measure get_final_stats() with 4 equipped items
var start = Time.get_ticks_usec()
for i in range(1000):
	var stats = UpgradeSystem.get_final_stats()
var end = Time.get_ticks_usec()
print("1000 calls: %d μs" % (end - start))
# Target: < 10ms for 1000 calls
```

**Test 2: Item Application Performance**
```gdscript
# Apply 4 high-level items to stats
var stats = base_stats.duplicate()
for item in all_items:
	item.apply_to_stats(stats, 100)
# Should be instant (< 1ms)
```

**Validation**:
- [ ] get_final_stats() is fast enough for realtime use
- [ ] No frame drops when equipping/unequipping items
- [ ] Save/load doesn't lag with max items

---

### Phase 7: Documentation & Polish

#### Task 7.1: Update CLAUDE.md

Add to "Current Status" section:
```markdown
**✅ Complete**: Prototype + Modules 1-5 (foundation complete - stat system working)
**🚧 Next**: Module 6 - Enemy variety and challenge escalation
```

---

#### Task 7.2: Code Documentation

Add docstrings to:
- `ShipStats.calculate_stats()` - Explain point allocation system (future)
- `ItemDefinition.apply_to_stats()` - Explain scaling types
- `UpgradeSystem.get_final_stats()` - Explain calculation flow

---

#### Task 7.3: Create Module Completion Report

**File**: `Documents/archive/module_05_completion.md`

Contents:
- Implementation summary
- Deviations from plan (if any)
- Known limitations
- Future enhancement opportunities
- Test results summary

---

## Risk Assessment & Mitigation

### Risk 1: Breaking Existing Gameplay Balance
**Likelihood**: High
**Impact**: Medium
**Mitigation**: Start with conservative bonus values (5-10%), tune after testing

### Risk 2: Performance Issues with Complex Stat Calculations
**Likelihood**: Low
**Impact**: Medium
**Mitigation**: Profile early, cache stats if needed, only recalculate on stats_updated

### Risk 3: Save Data Migration Issues
**Likelihood**: Medium
**Impact**: High
**Mitigation**: Test save/load extensively, ensure backwards compatibility

---

## Definition of Done

Module 05 is complete when:

- [ ] All tasks in Phases 1-6 are validated
- [ ] Player stats respond to equipped items in realtime gameplay
- [ ] At least 8 items implemented and working
- [ ] Shop displays correct bonuses for all items
- [ ] Save/load preserves item levels and stats
- [ ] No console errors during normal gameplay
- [ ] Performance targets met (< 10ms for stat recalculation)
- [ ] Documentation updated (CLAUDE.md, completion report)

---

## Next Steps (Post-Module 05)

After completing this module:
1. Archive this plan to `Documents/archive/`
2. Update `Development_Plan_Overview.md` progress
3. Begin Module 06: Enemy Variety & Challenge Escalation
4. Consider balance tuning based on playtesting

---

## Technical Debt & Future Enhancements

**Point Allocation System** (deferred to future module):
- Currently `point_levels` dictionary is empty
- Future: Allow spending credits to allocate points to defense/offense/mobility/utility
- Infrastructure ready in `ShipStats.calculate_stats()`

**Conditional Bonuses** (mentioned in Module 05 spec):
- Example: "If shield < 30%, +50% damage"
- Requires ItemDefinition enhancement
- Deferred to Module 8+ (advanced item mechanics)

**Stat Synergies** (mentioned in Module 05 spec):
- Example: "Fire rate bonus increased by 1% per shield regen item equipped"
- Requires cross-item calculation logic
- Deferred to Module 9+

---

**Plan Created**: 2026-01-05
**Ready for Implementation**: Yes
**Blockers**: None
