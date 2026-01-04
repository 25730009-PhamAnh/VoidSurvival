# Module 7: Black Hole Hazard System

**Priority**: Medium
**Dependencies**: None
**Estimated Duration**: 3-4 days

## Purpose
Add dynamic black hole hazard with gravitational physics.

## Core Components

### 7.1 Black Hole Scene
- **File**: `scenes/gameplay/hazards/black_hole.tscn` + `black_hole.gd`
- **Type**: `Area2D` with detection zone
- **Behavior**:
  - Spawns at random location every 30-60 seconds
  - Applies gravitational force to all objects in radius (player, asteroids, enemies, projectiles)
  - Can be "overloaded" and destroyed by consuming enough mass
  - Emits particles/shader distortion effect

### 7.2 Gravitational Component
- **File**: `scripts/components/gravitational_component.gd`
- **Purpose**: Reusable component for applying force toward center
- **Usage**:
  ```gdscript
  func _physics_process(delta):
      for body in detected_bodies:
          var direction = global_position.direction_to(body.global_position)
          var distance = global_position.distance_to(body.global_position)
          var force = pull_strength / (distance * distance)
          body.apply_force(direction * force)
  ```

### 7.3 Black Hole Spawner
- **File**: Extend `game_manager.gd` or create `black_hole_spawner.gd`
- **Logic**:
  - Timer-based spawning (adjusts with difficulty)
  - Only 1 black hole at a time (or max 2 late game)
  - Random position avoiding player spawn area

### 7.4 Visual Effects
- Shader for distortion effect (optional but impactful)
- Particle system for swirling matter
- Pulsing animation

## Integration Points
- Affects player, asteroids, enemies equally
- Destroyed asteroids count toward overload meter
- Player takes damage if too close for too long

## Extensibility
- Different black hole types (pulsing, moving)
- White holes (repulsion instead of attraction)
- Wormhole pairs for teleportation

## Testing Checklist
- [ ] Black hole spawns at correct intervals
- [ ] Gravitational pull affects all objects
- [ ] Overload mechanic works
- [ ] Player can escape with enough thrust
- [ ] Visual effects perform well
- [ ] No physics glitches with high forces

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
