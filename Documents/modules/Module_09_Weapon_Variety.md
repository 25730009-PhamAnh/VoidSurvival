# Module 9: Weapon Variety System

**Priority**: Low-Medium
**Dependencies**: Module 5 (Stats/Items)
**Estimated Duration**: 5-7 days

## Purpose
Add alternate weapon types beyond basic laser (homing missiles, spread shot, beam).

## Core Components

### 9.1 Weapon Base Class
- **File**: `scripts/gameplay/weapon_base.gd`
- **Purpose**: Abstract weapon behavior
- **Interface**:
  ```gdscript
  class_name WeaponBase
  extends Node2D

  signal fired(projectile: Node2D)

  @export var fire_rate: float = 2.0
  @export var projectile_scene: PackedScene

  func can_fire() -> bool:
      return Time.get_ticks_msec() - last_fire_time >= 1000.0 / fire_rate

  func fire(direction: Vector2) -> void:
      # Override in subclasses
      pass
  ```

### 9.2 Weapon Types

**LaserWeapon** (current basic weapon):
- Single straight projectile

**SpreadWeapon**:
- Fires 3-5 projectiles in a cone
- Lower damage per shot

**HomingMissileWeapon**:
- Locks onto nearest enemy
- Slower fire rate, higher damage
- Projectile has `seek_target()` behavior

**BeamWeapon**:
- Continuous damage while firing
- Uses `RayCast2D` instead of projectiles
- High damage, limited range

### 9.3 Weapon System Manager
- **File**: `scripts/gameplay/weapon_system.gd`
- **Purpose**: Manages active weapons on player
- **Properties**:
  ```gdscript
  var primary_weapon: WeaponBase
  var secondary_weapon: WeaponBase  # Unlocked via upgrades
  ```

### 9.4 Weapon Upgrade Items
- Create items that unlock/upgrade weapons:
  - "Homing Tracker" item (adds homing missiles as secondary)
  - "Spread Amplifier" (converts primary to spread)
  - "Beam Emitter" (unlocks beam weapon)

## Integration Points
- Player has WeaponSystem node
- Items can modify WeaponSystem configuration
- Input handles primary/secondary fire separately

## Extensibility
- Add new weapon types as scenes + scripts
- Weapon mods (e.g., "fire damage", "pierce")
- Weapon combos/synergies

## Testing Checklist
- [ ] Can switch between weapon types
- [ ] Each weapon fires correctly
- [ ] Homing missiles track targets
- [ ] Beam weapon performs well visually
- [ ] Spread weapon angle correct
- [ ] Items unlock weapons properly

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
