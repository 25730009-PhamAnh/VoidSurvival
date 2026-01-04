# Implementation Plan: Module 1 & 2 - Resource System & Save/Load System

**Created**: 2026-01-04
**Modules**: Module 1 (Resource System), Module 2 (Save/Load System)
**Priority**: High
**Estimated Duration**: 5-9 days total

---

## Overview

This plan implements the foundational economy and persistence systems for Void Survival by adding:
1. **Module 1**: Void crystals as collectible resources with pickup mechanics
2. **Module 2**: Save/load system for persistent player progression

These modules work together to create a complete resource loop: collect crystals → convert to credits → persist progress.

---

## Phase 1: Project Structure Setup

### 1.1 Create New Directories

Create the following folder structure:

```
Src/void-survival/
├── autoload/                    # NEW: Global singleton scripts
├── scenes/
│   ├── pickups/                 # NEW: Pickup item scenes
│   └── components/              # NEW: Reusable component scenes
├── scripts/
│   ├── components/              # NEW: Reusable component scripts
│   ├── pickups/                 # NEW: Pickup behavior scripts
│   └── autoload/                # NEW: Autoload script implementations
└── resources/                   # NEW: Data-driven configuration
    └── config/                  # Game configuration resources
```

### 1.2 Files to Create

**Module 1 - Resource System**:
- `scripts/autoload/resource_manager.gd` - Singleton for tracking crystals/credits
- `scripts/components/collection_component.gd` - Reusable collection radius logic
- `scenes/components/collection_component.tscn` - Collection component scene
- `scripts/pickups/crystal.gd` - Crystal pickup behavior
- `scenes/pickups/crystal.tscn` - Crystal pickup scene with visuals

**Module 2 - Save/Load System**:
- `scripts/autoload/save_system.gd` - Singleton for save/load operations
- `resources/config/default_save_data.tres` - Default save state resource (optional)

---

## Phase 2: Module 1 Implementation - Resource System

### 2.1 Create ResourceManager Singleton

**File**: `scripts/autoload/resource_manager.gd`

**Purpose**: Track crystals collected during current session and total credits

**Signals**:
```gdscript
signal crystals_changed(current: int)
signal crystals_collected(amount: int)
signal credits_changed(current: int)
```

**Properties**:
```gdscript
var current_crystals: int = 0  # Crystals in current run
var total_credits: int = 0     # Persistent currency
```

**Key Methods**:
```gdscript
func add_crystals(amount: int) -> void
func reset_crystals() -> void  # Called on game over
func convert_crystals_to_credits() -> void  # 1:1 conversion on game over
func add_credits(amount: int) -> void
func spend_credits(amount: int) -> bool
```

**Integration**:
- Register as autoload in `project.godot`: `ResourceManager` at `res://scripts/autoload/resource_manager.gd`
- Connect to GameManager's `game_over` signal to auto-convert crystals to credits

### 2.2 Create CollectionComponent

**File**: `scripts/components/collection_component.gd`

**Purpose**: Reusable Area2D-based component for detecting and attracting pickups

**Extends**: `Area2D`

**Signals**:
```gdscript
signal item_collected(item: Node2D, value: int)
```

**Exported Properties**:
```gdscript
@export var collection_radius: float = 50.0
@export var attraction_strength: float = 100.0
@export var attraction_radius: float = 150.0  # Larger than collection
```

**Behavior**:
- Detects pickups in `attraction_radius` and applies pull force
- Auto-collects when pickup enters `collection_radius`
- Emits `item_collected` signal with pickup reference and value

**Scene Structure** (`scenes/components/collection_component.tscn`):
```
CollectionComponent (Area2D)
├── CollisionShape2D (CircleShape2D with radius = collection_radius)
└── AttractionArea (Area2D, optional visual debug)
    └── CollisionShape2D (CircleShape2D with radius = attraction_radius)
```

**Physics Layers**:
- Layer: None (detection only)
- Mask: Layer 8 (new "Pickups" layer)

### 2.3 Create Crystal Pickup

**File**: `scripts/pickups/crystal.gd`

**Purpose**: Floating crystal that responds to collection component attraction

**Extends**: `RigidBody2D`

**Exported Properties**:
```gdscript
@export var crystal_value: int = 1
@export var rotation_speed: float = 2.0
@export var float_amplitude: float = 5.0
@export var float_speed: float = 3.0
```

**Signals**:
```gdscript
signal collected(value: int)
```

**Behavior**:
- Floats with sine wave motion
- Rotates continuously
- Responds to attraction force from CollectionComponent
- Emits `collected(crystal_value)` and destroys self when collected
- Particle effect on collection (CPUParticles2D)

**Scene Structure** (`scenes/pickups/crystal.tscn`):
```
Crystal (RigidBody2D)
├── Sprite2D (placeholder diamond/gem visual)
├── CollisionShape2D (CircleShape2D, radius ~8)
├── CollectionParticles (CPUParticles2D, one-shot sparkle effect)
└── VisibleOnScreenNotifier2D (optional cleanup for off-screen crystals)
```

**Physics Layers**:
- Layer: 8 (new "Pickups" layer)
- Mask: 0 (no collision with other objects)
- Gravity: 0.0, Linear Damp: 2.0 (for smooth attraction)

### 2.4 Integrate Collection into Player

**File**: `scenes/prototype/player.tscn` (modify)

**Changes**:
1. Add `CollectionComponent` as child node
2. Instance `scenes/components/collection_component.tscn`
3. Configure radius (50.0 collection, 150.0 attraction)

**File**: `scripts/player.gd` (modify)

**Changes**:
```gdscript
@onready var collection_component: Area2D = $CollectionComponent

func _ready() -> void:
    # ... existing code ...
    collection_component.item_collected.connect(_on_item_collected)

func _on_item_collected(item: Node2D, value: int) -> void:
    if item.has_signal("collected"):
        item.collected.emit(value)
    ResourceManager.add_crystals(value)
```

### 2.5 Integrate Crystal Spawning into Asteroids

**File**: `scripts/asteroid.gd` (modify)

**Changes in `take_damage()` method**:
```gdscript
@export var crystal_scene: PackedScene  # Assign in editor

func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        _spawn_crystals()  # NEW: Spawn before splitting
        _split()
        destroyed.emit(score_value)
        queue_free()

func _spawn_crystals() -> void:
    var crystal_count = 0
    match size:
        Size.LARGE: crystal_count = randi_range(3, 5)
        Size.MEDIUM: crystal_count = randi_range(2, 3)
        Size.SMALL: crystal_count = 1

    for i in crystal_count:
        var crystal = crystal_scene.instantiate()
        crystal.global_position = global_position + Vector2(
            randf_range(-15, 15),
            randf_range(-15, 15)
        )
        get_parent().call_deferred("add_child", crystal)
```

### 2.6 Update HUD to Display Crystals

**File**: `scenes/ui/prototype_hud.tscn` (modify)

**Changes**:
1. Add `CrystalLabel` (Label) to TopBar HBoxContainer
2. Set unique name `%CrystalLabel`
3. Position after ScoreLabel

**File**: `scripts/prototype_hud.gd` (modify)

**Changes**:
```gdscript
@onready var crystal_label: Label = %CrystalLabel

func _ready() -> void:
    # ... existing code ...
    ResourceManager.crystals_changed.connect(_on_crystals_changed)

func _on_crystals_changed(current: int) -> void:
    crystal_label.text = "Crystals: %d" % current
```

### 2.7 Integrate with GameManager

**File**: `scripts/game_manager.gd` (modify)

**Changes**:
```gdscript
func _on_player_died() -> void:
    is_playing = false
    ResourceManager.convert_crystals_to_credits()  # NEW: Convert on death
    game_over.emit()

func restart_game() -> void:
    ResourceManager.reset_crystals()  # NEW: Reset crystals for new run
    # ... existing restart code ...
```

---

## Phase 3: Module 2 Implementation - Save/Load System

### 3.1 Create SaveSystem Singleton

**File**: `scripts/autoload/save_system.gd`

**Purpose**: Handle all save/load operations with JSON persistence

**Constants**:
```gdscript
const SAVE_PATH = "user://savegame.save"
const SAVE_VERSION = "1.0"
```

**Save Data Structure**:
```gdscript
{
    "version": "1.0",
    "credits": 0,
    "total_crystals_collected": 0,
    "equipped_items": [],
    "item_levels": {},
    "unlocked_slots": 4,
    "settings": {
        "sfx_volume": 0.8,
        "music_volume": 0.6
    },
    "stats": {
        "total_playtime": 0.0,
        "best_survival_time": 0.0,
        "total_asteroids_destroyed": 0,
        "total_runs": 0
    }
}
```

**Key Methods**:
```gdscript
func save_game() -> void
func load_game() -> Dictionary
func save_exists() -> bool
func delete_save() -> void
func get_default_save_data() -> Dictionary
func validate_save_data(data: Dictionary) -> bool
```

**Error Handling**:
- Validate save version on load
- Return default data if save missing/corrupted
- Use `push_warning()` for validation failures
- Never crash on bad save data

**Integration**:
- Register as autoload in `project.godot`: `SaveSystem` at `res://scripts/autoload/save_system.gd`
- Auto-save on `game_over` signal from GameManager

### 3.2 Integrate Save/Load with ResourceManager

**File**: `scripts/autoload/resource_manager.gd` (modify)

**Changes**:
```gdscript
var total_crystals_collected: int = 0  # Lifetime stat

func _ready() -> void:
    var save_data = SaveSystem.load_game()
    total_credits = save_data.get("credits", 0)
    total_crystals_collected = save_data.get("total_crystals_collected", 0)

func convert_crystals_to_credits() -> void:
    total_credits += current_crystals
    total_crystals_collected += current_crystals
    credits_changed.emit(total_credits)
    SaveSystem.save_game()  # Auto-save after conversion

func spend_credits(amount: int) -> bool:
    if total_credits >= amount:
        total_credits -= amount
        credits_changed.emit(total_credits)
        SaveSystem.save_game()  # Auto-save after spending
        return true
    return false
```

### 3.3 Integrate Save/Load with GameManager

**File**: `scripts/game_manager.gd` (modify)

**Changes**:
```gdscript
var total_asteroids_destroyed: int = 0
var current_run_time: float = 0.0

func _ready() -> void:
    # ... existing code ...
    var save_data = SaveSystem.load_game()
    # Load any game manager state if needed

func _process(delta: float) -> void:
    if is_playing:
        current_run_time += delta

func add_score(amount: int) -> void:
    current_score += amount
    total_asteroids_destroyed += 1  # Track stat
    score_updated.emit(current_score)

func _on_player_died() -> void:
    is_playing = false
    ResourceManager.convert_crystals_to_credits()
    _save_run_stats()  # NEW: Save stats
    game_over.emit()

func _save_run_stats() -> void:
    var save_data = SaveSystem.load_game()
    save_data.stats.total_runs += 1
    save_data.stats.total_asteroids_destroyed += total_asteroids_destroyed
    if current_run_time > save_data.stats.best_survival_time:
        save_data.stats.best_survival_time = current_run_time
    save_data.stats.total_playtime += current_run_time
    SaveSystem.save_game()
```

### 3.4 Settings Integration (Optional for Phase 1)

**File**: `scripts/autoload/save_system.gd` (enhance)

**Audio Settings Methods**:
```gdscript
func save_settings(sfx_volume: float, music_volume: float) -> void:
    var save_data = load_game()
    save_data.settings.sfx_volume = sfx_volume
    save_data.settings.music_volume = music_volume
    save_game()

func load_settings() -> Dictionary:
    var save_data = load_game()
    return save_data.get("settings", {"sfx_volume": 0.8, "music_volume": 0.6})
```

---

## Phase 4: Testing & Validation

### 4.1 Module 1 Testing Checklist

- [ ] Crystals spawn from destroyed asteroids (LARGE: 3-5, MEDIUM: 2-3, SMALL: 1)
- [ ] Crystals float with rotation animation
- [ ] Player collection radius attracts nearby crystals
- [ ] Crystals auto-collect when entering collection radius
- [ ] Crystal count updates in HUD in real-time
- [ ] Collection particle effect plays on pickup
- [ ] ResourceManager correctly tracks crystals
- [ ] Performance test: 50+ crystals on screen simultaneously
- [ ] Crystals convert to credits on game over
- [ ] Crystals reset to 0 on new run

### 4.2 Module 2 Testing Checklist

- [ ] Save file created at `user://savegame.save` after first game over
- [ ] Credits persist after closing and reopening game
- [ ] Stats (total runs, playtime, best time) persist correctly
- [ ] Corrupted save file handled gracefully (returns default data)
- [ ] Missing save file handled gracefully (creates new save)
- [ ] Version mismatch detected (validation passes/fails appropriately)
- [ ] Auto-save triggers on game over
- [ ] Manual save_exists() check works for "Continue" button (future)
- [ ] Settings (volumes) save and load correctly

### 4.3 Integration Testing

- [ ] Full loop: Play game → Collect crystals → Die → Crystals convert to credits → Credits saved → Restart game → Credits loaded
- [ ] ResourceManager and SaveSystem work together without conflicts
- [ ] GameManager properly coordinates save triggers
- [ ] No memory leaks from pickup instantiation/destruction
- [ ] No performance degradation with 100+ pickups
- [ ] Save file remains valid after multiple sessions

---

## Phase 5: Polish & Optimization

### 5.1 Visual Polish

- [ ] Create proper crystal sprite (diamond/gem visual)
- [ ] Add collection particle effect (sparkle, glow)
- [ ] Add collection sound effect (SFX placeholder)
- [ ] Optional: Add crystal glow shader (future enhancement)

### 5.2 Performance Optimization

- [ ] Object pooling for crystals (if 100+ crystals cause lag)
- [ ] Limit max crystals on screen (despawn oldest if > 200)
- [ ] Optimize attraction physics (distance checks every 0.1s instead of every frame)

### 5.3 Debug Tools

- [ ] Add debug overlay to visualize collection radius (CollectionComponent)
- [ ] Add cheat commands for testing (spawn crystals, add credits)
- [ ] Add console command to delete save file

---

## Critical Files to Modify

| File | Type | Changes |
|------|------|---------|
| `project.godot` | Config | Add autoloads: ResourceManager, SaveSystem; Add Layer 8 "Pickups" |
| `scripts/player.gd` | Modify | Add collection component connection, handle item_collected signal |
| `scenes/prototype/player.tscn` | Modify | Add CollectionComponent child node |
| `scripts/asteroid.gd` | Modify | Add crystal spawning in take_damage(), add crystal_scene export |
| `scenes/prototype/asteroid.tscn` | Modify | Assign crystal scene to crystal_scene property |
| `scripts/game_manager.gd` | Modify | Add crystal→credit conversion, save triggers, stat tracking |
| `scripts/prototype_hud.gd` | Modify | Add crystal label connection and update handler |
| `scenes/ui/prototype_hud.tscn` | Modify | Add CrystalLabel to TopBar |

---

## Critical Files to Create

| File | Purpose |
|------|---------|
| `scripts/autoload/resource_manager.gd` | Currency and resource tracking singleton |
| `scripts/autoload/save_system.gd` | Save/load persistence singleton |
| `scripts/components/collection_component.gd` | Reusable collection radius logic |
| `scenes/components/collection_component.tscn` | Collection component scene |
| `scripts/pickups/crystal.gd` | Crystal pickup behavior |
| `scenes/pickups/crystal.tscn` | Crystal pickup scene with visuals |

---

## Dependencies & Prerequisites

**No external dependencies required** - all features use built-in Godot 4 systems:
- FileAccess for save/load
- Area2D for collection detection
- RigidBody2D for crystal physics
- Signals for decoupled communication

**Godot Version**: 4.5+

---

## Extensibility for Future Modules

This implementation is designed to support:

1. **Module 3 (Credit Shop)**:
   - `ResourceManager.spend_credits(amount)` ready for shop transactions
   - Save system already tracks `equipped_items` and `item_levels`

2. **Module 6 (Enemy Variety)**:
   - Enemies can use same crystal spawning pattern
   - CollectionComponent works with any pickup type

3. **Module 12 (Power-ups)**:
   - Create new pickup types by duplicating crystal.tscn
   - CollectionComponent already generic for all pickups

4. **Upgrade System**:
   - `collection_radius` is exported and upgradeable
   - Crystal value can be modified by multipliers

---

## Risk Mitigation

**Potential Issues**:
1. **Too many crystals cause lag**: Implement object pooling or max cap
2. **Save corruption**: Validation and default fallback already planned
3. **Crystal physics instability**: Use high linear damping and low bounce
4. **Collection radius too small/large**: Make it @export and tune in editor

**Mitigation Strategies**:
- Test performance with 200+ crystals before optimization
- Use version validation to handle schema changes
- Use visual debug overlays to tune collection radius
- Start conservative with spawn counts, increase after testing

---

## Completion Criteria

**Module 1 Complete When**:
- ✅ Crystals spawn from all asteroid sizes
- ✅ Player can collect crystals with visual feedback
- ✅ Crystal count displays in HUD
- ✅ Crystals convert to credits on game over
- ✅ ResourceManager fully integrated

**Module 2 Complete When**:
- ✅ Save file persists across sessions
- ✅ Credits and stats load correctly
- ✅ Corrupted/missing saves handled gracefully
- ✅ Auto-save on game over works
- ✅ SaveSystem fully integrated

**Both Modules Complete When**:
- ✅ Full game loop tested: Play → Collect → Die → Save → Load → Continue
- ✅ All testing checklists passed
- ✅ No critical bugs or performance issues
- ✅ Code follows Godot best practices (CLAUDE.md compliance)

---

## Next Steps After Completion

After Modules 1-2 are complete, the foundation is ready for:
- **Module 3**: Credit economy and shop UI
- **Module 4**: Upgrade shop with item progression
- **Module 5**: Stat tracking UI and achievements

The resource loop will be fully functional: Collect crystals → Convert to credits → Spend in shop → Upgrade player → Collect more efficiently.

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
