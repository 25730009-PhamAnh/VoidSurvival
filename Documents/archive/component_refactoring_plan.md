# Component-Based Refactoring Plan

**Document Version**: 1.0
**Created**: 2026-01-05
**Completed**: 2026-01-05
**Status**: Completed
**Priority**: High
**Actual Effort**: 1 day

---

## Executive Summary

This plan outlines the refactoring of Void Survival to align with the component-based architecture specified in the Technical Specification. The current implementation is functional but lacks critical reusable components, leading to code duplication and reduced maintainability. This refactor will implement missing components and migrate existing monolithic scripts to use them.

**Key Goals**:
1. Implement missing HealthComponent and MovementComponent
2. Refactor Player, Asteroid, UFO, and Comet to use components
3. Eliminate code duplication (especially screen wrapping)
4. Maintain full backwards compatibility with save data and existing features
5. Improve testability and extensibility

**Expected Impact**:
- Reduce total codebase size by ~200 lines
- Eliminate 4 instances of duplicated screen-wrapping logic
- Enable health/shield behavior reuse across all entities
- Simplify future entity creation (e.g., new enemy types)

---

## Current State Analysis

### ✅ What's Working Well

1. **CollectionComponent** - Fully implemented and integrated
   - Location: `scripts/components/collection_component.gd`
   - Used by: Player
   - Provides: Dual-radius attraction and collection system

2. **Signal-Based Architecture** - Properly decoupled
   - GameManager, SessionManager, UpgradeSystem communicate via signals
   - UI systems listen to game events without tight coupling

3. **Data-Driven Enemy System** - Excellent implementation
   - EnemyDefinition resources with difficulty scaling
   - EnemySpawner manages spawning with max limits
   - Zero code changes needed to add new enemy types

4. **Autoload Singletons** - Clean separation of concerns
   - ResourceManager (crystals/credits)
   - SaveSystem (persistence)
   - SessionManager (session stats)
   - UpgradeSystem (progression)

### ❌ Critical Gaps

1. **HealthComponent** - MISSING
   - Specified in Technical Spec (Section 5.1, lines 504-576)
   - **Impact**: Health/shield logic duplicated in 4 scripts
   - **Duplication**: player.gd, asteroid.gd, enemy_ufo.gd, enemy_comet.gd
   - **Lost Features**: Regeneration system only implemented in Player, not available for enemies/asteroids

2. **MovementComponent** - MISSING
   - Specified in Technical Spec (Section 5.2, lines 579-632)
   - **Impact**: Screen wrapping duplicated 4 times
   - **Duplication**: player.gd, asteroid.gd, enemy_ufo.gd, enemy_comet.gd
   - **Lost Benefits**: No unified movement abstraction for inertia-based entities

### ⚠️ Monolithic Scripts (Needs Refactoring)

| Script | Current LOC | With Components | Reduction | Issues |
|--------|------------|-----------------|-----------|--------|
| player.gd | 158 | ~80 | -49% | Health, movement, wrapping embedded |
| asteroid.gd | 110 | ~70 | -36% | Health, wrapping embedded |
| enemy_ufo.gd | 136 | ~80 | -41% | Health, wrapping embedded |
| enemy_comet.gd | 156 | ~100 | -36% | Health, wrapping embedded |
| **Total** | **560** | **~330** | **-41%** | |

---

## Refactoring Strategy

### Phase 1: Implement Core Components (Day 1)

#### Task 1.1: Implement HealthComponent

**File**: `Src/void-survival/scripts/components/health_component.gd`

**Specification** (from Technical Spec Section 5.1):
```gdscript
class_name HealthComponent
extends Node

## Reusable health/shield component with regeneration

signal health_changed(current: float, maximum: float)
signal damage_taken(amount: float)
signal died
signal regeneration_started
signal regeneration_stopped

@export var max_health: float = 100.0
@export var regeneration_rate: float = 5.0  # per second
@export var regeneration_delay: float = 3.0  # seconds after damage
@export var auto_regenerate: bool = true

var current_health: float
var _regen_timer: float = 0.0
var _is_regenerating: bool = false

# Methods: take_damage(), heal(), get_health_percentage()
```

**Key Features**:
- Automatic regeneration after delay (configurable)
- Signals for UI updates and death handling
- Can be disabled per entity (e.g., asteroids don't regenerate)
- Health percentage helper for UI/difficulty systems

**Integration Points**:
- Player: `max_health` from UpgradeSystem stats (`max_shield`)
- Enemies: `max_health` from EnemyDefinition.get_stats_at_difficulty()
- Asteroids: `auto_regenerate = false` for traditional health

**Testing Strategy**:
- Unit test: Damage → regeneration delay → regeneration starts
- Integration test: Player takes damage → shield bar updates → regeneration after 3s

---

#### Task 1.2: Implement MovementComponent

**File**: `Src/void-survival/scripts/components/movement_component.gd`

**Specification** (from Technical Spec Section 5.2):
```gdscript
class_name MovementComponent
extends Node

## Inertia-based movement with screen wrapping

@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var rotation_speed: float = 3.0
@export var enable_screen_wrap: bool = true

var velocity: Vector2 = Vector2.ZERO
var _body: Node2D  # CharacterBody2D or RigidBody2D

# Methods: apply_thrust(), apply_rotation(), update_movement()
```

**Key Features**:
- Velocity-based movement with max speed limiting
- Unified screen wrapping (eliminates 4 duplicates)
- Works with both CharacterBody2D and RigidBody2D
- Configurable per entity

**Integration Points**:
- Player: Velocity-based movement with thrust input
- Asteroids: Constant velocity (no thrust, just initial impulse)
- UFO: Sinusoidal movement (custom movement script + wrapping from component)
- Comet: State-based movement (drift/charge) + wrapping from component

**Design Decision**:
- **Option A**: Full movement abstraction (thrust, rotation, physics)
- **Option B**: Screen wrapping utility + optional movement helpers
- **Chosen**: **Option B** - MovementComponent provides screen wrapping + basic inertia, but allows entities to override movement logic for custom patterns (UFO sinusoidal, Comet charge)

**Testing Strategy**:
- Unit test: apply_thrust() increases velocity up to max speed
- Integration test: Entity moves across screen edge → wraps to opposite side

---

### Phase 2: Refactor Entities (Day 2)

#### Task 2.1: Refactor Player to Use Components

**Current**: `player.gd` - 158 lines (monolithic)

**Target Structure**:
```
Player (CharacterBody2D)
├── Polygon2D
├── CollisionPolygon2D
├── ShootPoint (Marker2D)
├── HealthComponent (Node)        # NEW
├── MovementComponent (Node)      # NEW
└── CollectionComponent (Area2D)  # ✅ Existing
```

**Refactoring Steps**:
1. Add HealthComponent node to player.tscn
2. Add MovementComponent node to player.tscn
3. Migrate shield/regeneration logic to HealthComponent
   - Remove: `shield`, `max_shield`, `shield_regen_rate`, `shield_regen_delay`, `_shield_regen_timer`
   - Connect: `HealthComponent.health_changed` → `_on_shield_changed()` (emit `shield_changed` signal for HUD)
   - Connect: `HealthComponent.died` → `_on_death()` (existing logic)
4. Migrate movement/wrapping logic to MovementComponent
   - Remove: `_apply_thrust()`, `_apply_rotation()`, `_wrap_around_screen()`
   - Replace with: `MovementComponent.apply_thrust()`, `MovementComponent.apply_rotation()`, `MovementComponent.update_movement()`
5. Simplify `_apply_stats()` to configure component properties
6. Update `_physics_process()` to delegate to components

**Expected Result**: player.gd reduced to ~80 lines

**Signals to Preserve**:
- `died` (emitted from HealthComponent.died handler)
- `shield_changed` (emitted from HealthComponent.health_changed handler)

**Compatibility**:
- UpgradeSystem stats still applied via `_apply_stats()`
- HUD still listens to `shield_changed` signal
- GameManager still listens to `died` signal

---

#### Task 2.2: Refactor Asteroid to Use HealthComponent

**Current**: `asteroid.gd` - 110 lines

**Target Structure**:
```
Asteroid (RigidBody2D)
├── Polygon2D
├── CollisionPolygon2D
└── HealthComponent (Node)  # NEW
```

**Refactoring Steps**:
1. Add HealthComponent node to asteroid.tscn
2. Configure: `auto_regenerate = false` (asteroids don't regenerate)
3. Migrate health logic
   - Remove: `health`, `max_health`, `take_damage()`
   - Replace with: `HealthComponent.take_damage()`
   - Connect: `HealthComponent.died` → `_on_destroyed()`
4. Keep screen wrapping logic (asteroids use RigidBody2D physics, different from MovementComponent)

**Expected Result**: asteroid.gd reduced to ~70 lines

**Signals to Preserve**:
- `destroyed(score_value: int, crystal_count: int, hit_position: Vector2)`

**Compatibility**:
- Spawner still receives `destroyed` signal
- GameManager still tracks asteroid kills
- Crystal spawning still works

---

#### Task 2.3: Refactor Enemy UFO to Use Components

**Current**: `enemy_ufo.gd` - 136 lines

**Target Structure**:
```
EnemyUFO (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── ShootPoint (Marker2D)
├── ShootTimer (Timer)
├── HealthComponent (Node)      # NEW
└── MovementComponent (Node)    # NEW (wrapping only)
```

**Refactoring Steps**:
1. Add HealthComponent node to enemy_ufo.tscn
2. Add MovementComponent node (for screen wrapping)
3. Migrate health logic
   - Remove: `health`, `max_health`, `take_damage()`
   - Replace with: `HealthComponent.take_damage()`
   - Connect: `HealthComponent.died` → `_on_destroyed()`
4. Migrate screen wrapping
   - Remove: `_wrap_around_screen()`
   - Use: `MovementComponent._wrap_around_screen()` (call from `_physics_process()`)
5. Keep sinusoidal movement logic (unique to UFO)
   - Sinusoidal pattern stays in `enemy_ufo.gd` (not a component concern)

**Expected Result**: enemy_ufo.gd reduced to ~80 lines

**Signals to Preserve**:
- `destroyed(score_value: int, crystal_count: int, position: Vector2)`
- `damaged(amount: float)` (for future VFX)

**Compatibility**:
- EnemySpawner still receives `destroyed` signal
- EnemyDefinition difficulty scaling still applied via `initialize()`

---

#### Task 2.4: Refactor Enemy Comet to Use Components

**Current**: `enemy_comet.gd` - 156 lines

**Target Structure**:
```
EnemyComet (RigidBody2D)
├── Sprite2D
├── CollisionShape2D
├── TelegraphTimer (Timer)
├── HealthComponent (Node)      # NEW
└── MovementComponent (Node)    # NEW (wrapping only)
```

**Refactoring Steps**:
1. Add HealthComponent node to enemy_comet.tscn
2. Add MovementComponent node (for screen wrapping)
3. Migrate health logic
   - Remove: `health`, `max_health`, `take_damage()`
   - Replace with: `HealthComponent.take_damage()`
   - Connect: `HealthComponent.died` → `_on_destroyed()`
4. Migrate screen wrapping
   - Remove: `_wrap_around_screen()`
   - Use: `MovementComponent._wrap_around_screen()` (call from `_physics_process()`)
5. Keep state machine logic (unique to Comet)
   - Drift/telegraph/charge states stay in `enemy_comet.gd`

**Expected Result**: enemy_comet.gd reduced to ~100 lines

**Signals to Preserve**:
- `destroyed(score_value: int, crystal_count: int, position: Vector2)`
- `damaged(amount: float)` (for future VFX)

**Compatibility**:
- EnemySpawner still receives `destroyed` signal
- EnemyDefinition difficulty scaling still applied via `initialize()`

---

### Phase 3: Testing & Validation (Day 3)

#### Task 3.1: Unit Testing

**HealthComponent Tests**:
- Test: Damage reduces current_health
- Test: Death signal emitted when health <= 0
- Test: Regeneration starts after delay
- Test: Regeneration stops when taking damage
- Test: heal() increases health (clamped to max_health)
- Test: get_health_percentage() returns correct ratio

**MovementComponent Tests**:
- Test: apply_thrust() increases velocity up to max speed
- Test: Screen wrapping works at all 4 edges
- Test: Velocity limiting works correctly

**Test Framework**: Use GUT (Godot Unit Test) if available, or manual test scenes

---

#### Task 3.2: Integration Testing

**Test Scenarios**:
1. **Player Shield Regeneration**:
   - Take damage from asteroid
   - Wait 3 seconds
   - Verify shield bar starts regenerating
   - Verify HUD updates correctly

2. **Enemy Health Scaling**:
   - Spawn UFO at difficulty 50
   - Verify health is scaled correctly from EnemyDefinition
   - Destroy with projectiles
   - Verify destruction signal emitted

3. **Screen Wrapping Consistency**:
   - Move player off each edge
   - Move asteroid off each edge
   - Move UFO off each edge
   - Move comet off each edge
   - Verify all wrap consistently

4. **Asteroid Splitting**:
   - Destroy large asteroid
   - Verify HealthComponent.died signal triggers split
   - Verify medium asteroids spawn with correct health

5. **Save/Load Compatibility**:
   - Play session, upgrade items, quit
   - Load save
   - Verify player stats correctly applied to HealthComponent
   - Verify shield regeneration rate matches upgrades

---

#### Task 3.3: Performance Validation

**Metrics to Check**:
- Frame rate with 20+ active enemies (target: 60 FPS)
- Memory usage (target: < 150 MB on mobile)
- No new performance regressions from component overhead

**Profiling**:
- Use Godot's built-in profiler
- Monitor `_process()` and `_physics_process()` times
- Check for signal emission overhead

---

## Implementation Checklist

### Phase 1: Implement Core Components ✅
- [ ] Create `scripts/components/health_component.gd`
  - [ ] Implement regeneration system
  - [ ] Add all required signals
  - [ ] Write docstrings
- [ ] Create `scripts/components/movement_component.gd`
  - [ ] Implement screen wrapping
  - [ ] Add velocity limiting
  - [ ] Support both CharacterBody2D and RigidBody2D
- [ ] Create unit test scenes for components
  - [ ] Test HealthComponent regeneration
  - [ ] Test MovementComponent wrapping

### Phase 2: Refactor Entities ✅
- [ ] Refactor Player
  - [ ] Add HealthComponent to player.tscn
  - [ ] Add MovementComponent to player.tscn
  - [ ] Migrate health logic to HealthComponent
  - [ ] Migrate movement logic to MovementComponent
  - [ ] Update `_apply_stats()` to configure components
  - [ ] Test player gameplay (shooting, movement, death)
- [ ] Refactor Asteroid
  - [ ] Add HealthComponent to asteroid.tscn
  - [ ] Migrate health logic
  - [ ] Test asteroid destruction and splitting
- [ ] Refactor Enemy UFO
  - [ ] Add HealthComponent to enemy_ufo.tscn
  - [ ] Add MovementComponent to enemy_ufo.tscn
  - [ ] Migrate health logic
  - [ ] Migrate wrapping logic
  - [ ] Test UFO spawning and combat
- [ ] Refactor Enemy Comet
  - [ ] Add HealthComponent to enemy_comet.tscn
  - [ ] Add MovementComponent to enemy_comet.tscn
  - [ ] Migrate health logic
  - [ ] Migrate wrapping logic
  - [ ] Test Comet charge behavior

### Phase 3: Testing & Validation ✅
- [ ] Unit testing
  - [ ] HealthComponent tests
  - [ ] MovementComponent tests
- [ ] Integration testing
  - [ ] Player shield regeneration
  - [ ] Enemy health scaling
  - [ ] Screen wrapping consistency
  - [ ] Asteroid splitting
  - [ ] Save/load compatibility
- [ ] Performance validation
  - [ ] Frame rate check (20+ enemies)
  - [ ] Memory usage check
  - [ ] Profiler analysis

### Documentation ✅
- [ ] Update CLAUDE.md with new component patterns
- [ ] Add component usage examples
- [ ] Document breaking changes (if any)
- [ ] Update Technical Spec status

---

## Risk Assessment

### High Risk
- **Save/Load Compatibility**: Player stats now go through HealthComponent
  - **Mitigation**: Keep `_apply_stats()` as interface, route to component properties
  - **Validation**: Test save/load before and after refactor

### Medium Risk
- **Signal Chain Breakage**: HUD/GameManager listen to entity signals
  - **Mitigation**: Keep all existing signals, emit from component handlers
  - **Validation**: Test all UI updates and game flow

### Low Risk
- **Performance Overhead**: Additional nodes in scene tree
  - **Mitigation**: Components are lightweight (no physics, minimal processing)
  - **Validation**: Profile before/after

---

## Breaking Changes

### None Expected

All refactoring is **internal** to entity scripts. External APIs (signals, public methods) remain unchanged.

**Preserved Interfaces**:
- `Player.died` signal → Still emitted (from HealthComponent.died handler)
- `Player.shield_changed` signal → Still emitted (from HealthComponent.health_changed handler)
- `Asteroid.destroyed` signal → Still emitted (from HealthComponent.died handler)
- `Enemy*.destroyed` signals → Still emitted (from HealthComponent.died handler)
- `UpgradeSystem.stats_updated` → Player still listens and applies stats

**Save Data**: No changes required
- Save format remains JSON with `total_credits`, `item_levels`, `equipped_items`
- Player stats still calculated from UpgradeSystem

---

## Future Extensions Enabled

### Module 7: Black Hole Hazard System
- Can use HealthComponent for black hole overload mechanics
- Can use MovementComponent for gravitational effects on other entities

### Module 8: Dynamic Difficulty System
- HealthComponent.health_changed can be monitored for difficulty metrics
- Performance tracking simplified (all entities use same component)

### Module 9: Weapon Variety System
- DamageComponent can be added later to standardize damage dealing
- HealthComponent provides unified interface for damage application

### Module 10: VFX & Juice
- HealthComponent signals can trigger VFX:
  - `damage_taken` → Screen shake, particle effects
  - `died` → Explosion VFX
  - `regeneration_started` → Shield recharge effect

---

## Success Criteria

### Functional
- [ ] All gameplay features work identically to pre-refactor
- [ ] Player can move, shoot, take damage, regenerate shield
- [ ] Asteroids can be destroyed and split
- [ ] Enemies spawn, move, shoot, and are destroyed
- [ ] Crystals drop and can be collected
- [ ] Upgrades apply correctly to player stats
- [ ] Save/load works without corruption

### Code Quality
- [ ] Total codebase reduced by ~200 lines
- [ ] Screen wrapping logic exists in 1 place (not 4)
- [ ] Health/shield logic exists in 1 place (not 4)
- [ ] All entity scripts are < 100 lines
- [ ] Component scripts have clear, single responsibilities

### Performance
- [ ] No frame rate degradation (60 FPS maintained)
- [ ] No memory increase (< 150 MB on mobile)
- [ ] No signal emission overhead (profiler confirms)

### Maintainability
- [ ] New enemy types can be added with minimal code (< 50 lines)
- [ ] Future features (black holes, new weapons) can leverage components
- [ ] Components are testable in isolation

---

## Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 1: Implement Components | 1 day | None |
| Phase 2: Refactor Entities | 1 day | Phase 1 complete |
| Phase 3: Testing & Validation | 0.5-1 day | Phase 2 complete |
| **Total** | **2.5-3 days** | |

**Start Date**: TBD
**Target Completion**: TBD + 3 days

---

## Approval

- [ ] Architecture Review (Lead Developer)
- [ ] Testing Plan Approval (QA)
- [ ] Timeline Approval (Project Manager)

---

## Appendix A: Technical Spec Alignment

This refactoring implements the following sections from `Documents/VoidSurvivor_TechnicalSpec_Godot.md`:

- **Section 5.1**: HealthComponent (lines 504-576) ✅
- **Section 5.2**: MovementComponent (lines 579-632) ✅
- **Section 5.3**: CollectionComponent (lines 637-675) ✅ Already implemented

**After Refactor**: 100% of specified component system will be implemented.

---

## Appendix B: Code Duplication Elimination

### Screen Wrapping (Before)
- `player.gd` lines 124-138 (15 lines)
- `asteroid.gd` lines 39-53 (15 lines)
- `enemy_ufo.gd` lines 88-102 (15 lines)
- `enemy_comet.gd` lines 107-121 (15 lines)
- **Total**: 60 lines duplicated

### Screen Wrapping (After)
- `movement_component.gd` (15 lines, reused 4 times)
- **Total**: 15 lines
- **Reduction**: -45 lines (-75%)

### Health Management (Before)
- `player.gd` health/shield/regen logic (40 lines)
- `asteroid.gd` health logic (10 lines)
- `enemy_ufo.gd` health logic (10 lines)
- `enemy_comet.gd` health logic (10 lines)
- **Total**: 70 lines

### Health Management (After)
- `health_component.gd` (60 lines, reused 4 times)
- Entity scripts: 5 lines each to configure component
- **Total**: 60 + 20 = 80 lines
- **Reduction**: -10 lines functional code, +reusability

**Total Code Reduction**: ~200 lines + improved maintainability

---

**End of Plan**
