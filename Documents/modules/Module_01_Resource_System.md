# Module 1: Resource System & Item Pickups

**Priority**: High
**Dependencies**: None (extends prototype)
**Estimated Duration**: 3-5 days

## Purpose
Implement void crystals and the collection mechanic to create an in-game economy and resource loop.

## Core Components

### 1.1 Pickup Scene & Script
- **File**: `scenes/gameplay/pickups/crystal.tscn` + `crystal.gd`
- **Type**: `Area2D` with attractive force toward player
- **Behavior**:
  - Spawns from destroyed asteroids/enemies
  - Floats with slight rotation animation
  - Auto-collects when in player's collection radius
  - Emits `collected(value)` signal
  - Plays particle effect on collection

### 1.2 Collection Component
- **File**: `scripts/components/collection_component.gd`
- **Purpose**: Reusable node that handles collection radius and attraction
- **Signals**:
  ```gdscript
  signal item_collected(item: Node, value: int)
  ```
- **Properties**:
  ```gdscript
  @export var collection_radius: float = 50.0
  @export var attraction_strength: float = 100.0
  ```

### 1.3 Resource Manager (Optional Mini-Singleton)
- **File**: `autoload/resource_manager.gd`
- **Purpose**: Track crystals collected in current session
- **Signals**:
  ```gdscript
  signal crystals_changed(amount: int)
  signal crystals_collected(amount: int)
  ```

## Integration Points
- Player has `CollectionComponent` child node
- Asteroids spawn crystals on `destroyed` signal
- HUD displays crystal count via signal connection

## Extensibility
- Add new pickup types (health, power-ups) by creating new scenes
- Collection radius upgradeable via upgrade system (future)
- Pickup magnets, special effects easily added

## Testing Checklist
- [ ] Crystals spawn from asteroids
- [ ] Player can collect crystals
- [ ] Crystal count updates in HUD
- [ ] Collection radius visually debuggable
- [ ] Performance with 50+ crystals on screen

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
