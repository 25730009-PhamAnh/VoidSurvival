# Module 6: Enemy Variety & Spawning

**Priority**: Medium
**Dependencies**: None (extends prototype spawner)
**Estimated Duration**: 5-7 days

## Purpose
Add UFO and Comet enemies with unique behaviors and attack patterns.

## Core Components

### 6.1 Enemy Base Class (Optional)
- **File**: `scripts/gameplay/enemy_base.gd`
- **Purpose**: Shared behavior for all enemies (health, signals, screen wrapping)
- **Signals**:
  ```gdscript
  signal destroyed(score_value: int, crystal_drop_count: int)
  signal damaged(amount: int)
  ```

### 6.2 UFO Enemy
- **File**: `scenes/gameplay/hazards/enemy_ufo.tscn` + `enemy_ufo.gd`
- **Type**: `CharacterBody2D`
- **Behavior**:
  - Moves in sinusoidal pattern
  - Shoots at player with lead targeting (accuracy parameter)
  - Emits `destroyed` signal with higher score value
  - Drops more crystals than asteroids

### 6.3 Comet Enemy
- **File**: `scenes/gameplay/hazards/enemy_comet.tscn` + `enemy_comet.gd`
- **Type**: `RigidBody2D`
- **Behavior**:
  - Moves slowly, then charges toward player at high speed
  - Deals collision damage
  - Predictable charge pattern (telegraph with visual effect)

### 6.4 Enemy Spawner System
- **File**: `scripts/gameplay/spawners/enemy_spawner.gd`
- **Purpose**: Spawn enemies based on difficulty and timers
- **Config**:
  ```gdscript
  @export var ufo_spawn_interval: float = 20.0
  @export var comet_spawn_interval: float = 15.0
  @export var max_ufos: int = 3
  @export var max_comets: int = 5
  ```

### 6.5 Enemy Definition Resources
- **File**: `scripts/resources/enemy_definition.gd`
- **Purpose**: Data-driven enemy stats (health, speed, damage, score, crystals)
- Create `.tres` for each enemy type

## Integration Points
- GameManager connects to enemy `destroyed` signals
- ScoreManager tracks different enemy types
- Difficulty system modulates spawn rates and stats

## Extensibility
- Add new enemy types without changing spawner code
- Enemy variants (elite, champion) via resource duplication
- Special abilities as components

## Testing Checklist
- [ ] UFOs spawn and shoot correctly
- [ ] Comet charge telegraphs and executes
- [ ] Enemy collision damage applies
- [ ] Enemies wrap around screen
- [ ] Score and crystals award properly
- [ ] Multiple enemies on screen without lag

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
