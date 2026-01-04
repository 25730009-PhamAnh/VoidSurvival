# Void Survivor - Development Plan

**Version**: 1.0  
**Last Updated**: January 4, 2026  
**Status**: Planning Phase

---

## Overview

This document outlines a modular, feature-by-feature development plan for **Void Survivor**. Each feature is designed to be **independent** and **extensible**, following Godot best practices with signal-based communication and resource-driven configuration.

### Development Philosophy

- **Modular Architecture**: Each feature is self-contained with clear interfaces
- **Signal-Based Integration**: Features communicate via signals, not direct coupling
- **Resource-Driven**: Configuration in `.tres` files, not hardcoded values
- **Incremental Delivery**: Each feature can be completed and tested independently
- **Extensibility First**: Design for easy addition of new content (items, enemies, mechanics)

### Current State

✅ **Week 1 Prototype Complete**:
- Basic player movement with inertia physics
- Projectile shooting system
- Asteroid spawning and destruction with splitting
- Basic HUD (shield bar, score)
- Game over and restart functionality
- Signal-based event system established

---

## Feature Modules

The remaining development is organized into **10 independent feature modules**, each building upon the prototype foundation without tight coupling.

---

## Module 1: Resource System & Item Pickups

**Priority**: High  
**Dependencies**: None (extends prototype)  
**Estimated Duration**: 3-5 days

### Purpose
Implement void crystals and the collection mechanic to create an in-game economy and resource loop.

### Core Components

#### 1.1 Pickup Scene & Script
- **File**: `scenes/gameplay/pickups/crystal.tscn` + `crystal.gd`
- **Type**: `Area2D` with attractive force toward player
- **Behavior**:
  - Spawns from destroyed asteroids/enemies
  - Floats with slight rotation animation
  - Auto-collects when in player's collection radius
  - Emits `collected(value)` signal
  - Plays particle effect on collection

#### 1.2 Collection Component
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

#### 1.3 Resource Manager (Optional Mini-Singleton)
- **File**: `autoload/resource_manager.gd`
- **Purpose**: Track crystals collected in current session
- **Signals**:
  ```gdscript
  signal crystals_changed(amount: int)
  signal crystals_collected(amount: int)
  ```

### Integration Points
- Player has `CollectionComponent` child node
- Asteroids spawn crystals on `destroyed` signal
- HUD displays crystal count via signal connection

### Extensibility
- Add new pickup types (health, power-ups) by creating new scenes
- Collection radius upgradeable via upgrade system (future)
- Pickup magnets, special effects easily added

### Testing Checklist
- [ ] Crystals spawn from asteroids
- [ ] Player can collect crystals
- [ ] Crystal count updates in HUD
- [ ] Collection radius visually debuggable
- [ ] Performance with 50+ crystals on screen

---

## Module 2: Save/Load System

**Priority**: High  
**Dependencies**: None  
**Estimated Duration**: 2-4 days

### Purpose
Persist player progression (credits, unlocked items, settings) across sessions.

### Core Components

#### 2.1 SaveSystem Singleton
- **File**: `autoload/save_system.gd`
- **Purpose**: Handle all save/load operations
- **Save Data Structure**:
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
      "total_asteroids_destroyed": 0
    }
  }
  ```

#### 2.2 Implementation
- Use `FileAccess` to write JSON to `user://savegame.save`
- Validate save data version on load
- Handle missing/corrupted saves gracefully
- Auto-save after each game session

#### 2.3 Settings Integration
- Save audio volumes, control preferences
- Load settings on game startup

### Integration Points
- GameManager calls `SaveSystem.save_game()` on game over
- UpgradeSystem loads progression data on startup
- Main menu shows "Continue" button if save exists

### Extensibility
- Cloud save integration (future): Abstract save backend
- Multiple save slots: Array of save data
- Achievements: Add to save structure

### Testing Checklist
- [ ] Save data persists after closing game
- [ ] Corrupted save handled without crash
- [ ] Version mismatch detected and handled
- [ ] Auto-save after every run
- [ ] Settings loaded correctly on startup

---

## Module 3: Credit Economy & Post-Game Flow

**Priority**: High  
**Dependencies**: Module 1 (Resource System), Module 2 (Save System)  
**Estimated Duration**: 2-3 days

### Purpose
Convert in-game performance into persistent currency for upgrades.

### Core Components

#### 3.1 Credit Calculation
- **Location**: `autoload/score_manager.gd`
- **Formula**:
  ```gdscript
  func calculate_credits() -> int:
      var base_credits = crystals_collected
      var time_bonus = int(survival_time / 10.0)
      var destruction_bonus = (asteroids_destroyed + enemies_destroyed * 5) / 10
      var accuracy_bonus = int(accuracy * 50)
      return base_credits + time_bonus + destruction_bonus + accuracy_bonus
  ```

#### 3.2 Game Over Screen
- **File**: `scenes/ui/game_over_screen.tscn`
- **Display**:
  - Survival time
  - Score breakdown
  - Credits earned (with animation)
  - Total credits available
  - Buttons: "Upgrades" | "Main Menu" | "Retry"

#### 3.3 ScoreManager Extension
- Track all session statistics
- Emit `session_ended` signal with full stats dictionary
- Calculate and award credits

### Integration Points
- GameManager shows game over screen when player dies
- Credits added to SaveSystem total
- Transition to upgrade shop or retry

### Extensibility
- Multipliers from items (luck stat)
- Bonus challenges for extra credits
- Daily rewards, login bonuses

### Testing Checklist
- [ ] Credits calculated correctly
- [ ] Game over screen shows all stats
- [ ] Credits persist to next session
- [ ] Can restart or go to upgrades from game over

---

## Module 4: Upgrade Shop UI

**Priority**: High  
**Dependencies**: Module 3 (Credits)  
**Estimated Duration**: 4-6 days

### Purpose
Provide interface for spending credits on permanent upgrades.

### Core Components

#### 4.1 Upgrade Shop Scene
- **File**: `scenes/ui/upgrade_shop.tscn`
- **Layout**:
  - Header: Credits display, back button
  - Item Grid: Scrollable container of upgrade cards
  - Item Detail Panel: Shows selected item stats, upgrade button
  - Equipment Slots: Shows equipped items (4-8 slots)

#### 4.2 Upgrade Card Component
- **File**: `scenes/ui/components/upgrade_card.tscn`
- **Display**:
  - Item icon and name
  - Current level
  - Current bonus (e.g., "+25% Shield")
  - Next level bonus (e.g., "+27% Shield")
  - Upgrade cost
  - "Upgrade" / "Equip" / "Unequip" buttons

#### 4.3 Shop Logic Script
- **File**: `scripts/ui/upgrade_shop.gd`
- **Responsibilities**:
  - Load all available items from `resources/items/`
  - Display equipped vs unequipped items
  - Handle purchase/upgrade transactions
  - Update UI when credits change
  - Validate purchases (enough credits, slot available)

### Integration Points
- Access from main menu or game over screen
- Connected to UpgradeSystem for equipped items
- Connected to SaveSystem for credit balance

### Extensibility
- Filter items by category
- Search/sort functionality
- Item comparison tools
- Build presets (save/load equipment configs)

### Testing Checklist
- [ ] All items load correctly
- [ ] Purchase validation works
- [ ] UI updates after purchase
- [ ] Equipment slots display correctly
- [ ] Can equip/unequip items
- [ ] Tooltips show accurate calculations

---

## Module 5: Stat Calculation & Upgrade System

**Priority**: High  
**Dependencies**: Module 4 (Shop UI)  
**Estimated Duration**: 3-5 days

### Purpose
Calculate final ship stats from base values + equipped items with infinite scaling.

### Core Components

#### 5.1 ShipStats Resource
- **File**: `resources/ship_parameters/base_ship_stats.tres`
- Contains all base stat formulas (already defined in Technical Spec)

#### 5.2 ItemDefinition Resource Base Class
- **File**: `scripts/resources/item_definition.gd`
- Defines scaling formulas, costs, effects (already defined in Technical Spec)

#### 5.3 Individual Item Resources
Create `.tres` files for each item:
- `resources/items/defensive/energy_amplifier.tres`
- `resources/items/defensive/nano_repair.tres`
- `resources/items/defensive/reactive_armor.tres`
- `resources/items/offensive/rapid_accelerator.tres`
- `resources/items/offensive/plasma_infusion.tres`
- `resources/items/utility/crystal_magnet.tres`
- (etc., 15-20 items total)

#### 5.4 UpgradeSystem Singleton
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

#### 5.5 Player Stat Application
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

### Integration Points
- Shop UI calls `UpgradeSystem.upgrade_item(item)`
- UpgradeSystem emits `stats_updated` signal
- Player, weapons, collection radius all update from stats

### Extensibility
- Add new items without code changes (just new `.tres` files)
- Stat synergies between items
- Conditional bonuses (e.g., "if < 30% shield, +50% damage")

### Testing Checklist
- [ ] Base stats calculate correctly
- [ ] Item bonuses apply correctly
- [ ] Multiple items stack properly
- [ ] Stats update when item equipped/unequipped
- [ ] High-level items (100+) calculate without overflow
- [ ] Performance with all slots filled

---

## Module 6: Enemy Variety & Spawning

**Priority**: Medium  
**Dependencies**: None (extends prototype spawner)  
**Estimated Duration**: 5-7 days

### Purpose
Add UFO and Comet enemies with unique behaviors and attack patterns.

### Core Components

#### 6.1 Enemy Base Class (Optional)
- **File**: `scripts/gameplay/enemy_base.gd`
- **Purpose**: Shared behavior for all enemies (health, signals, screen wrapping)
- **Signals**:
  ```gdscript
  signal destroyed(score_value: int, crystal_drop_count: int)
  signal damaged(amount: int)
  ```

#### 6.2 UFO Enemy
- **File**: `scenes/gameplay/hazards/enemy_ufo.tscn` + `enemy_ufo.gd`
- **Type**: `CharacterBody2D`
- **Behavior**:
  - Moves in sinusoidal pattern
  - Shoots at player with lead targeting (accuracy parameter)
  - Emits `destroyed` signal with higher score value
  - Drops more crystals than asteroids

#### 6.3 Comet Enemy
- **File**: `scenes/gameplay/hazards/enemy_comet.tscn` + `enemy_comet.gd`
- **Type**: `RigidBody2D`
- **Behavior**:
  - Moves slowly, then charges toward player at high speed
  - Deals collision damage
  - Predictable charge pattern (telegraph with visual effect)

#### 6.4 Enemy Spawner System
- **File**: `scripts/gameplay/spawners/enemy_spawner.gd`
- **Purpose**: Spawn enemies based on difficulty and timers
- **Config**:
  ```gdscript
  @export var ufo_spawn_interval: float = 20.0
  @export var comet_spawn_interval: float = 15.0
  @export var max_ufos: int = 3
  @export var max_comets: int = 5
  ```

#### 6.5 Enemy Definition Resources
- **File**: `scripts/resources/enemy_definition.gd`
- **Purpose**: Data-driven enemy stats (health, speed, damage, score, crystals)
- Create `.tres` for each enemy type

### Integration Points
- GameManager connects to enemy `destroyed` signals
- ScoreManager tracks different enemy types
- Difficulty system modulates spawn rates and stats

### Extensibility
- Add new enemy types without changing spawner code
- Enemy variants (elite, champion) via resource duplication
- Special abilities as components

### Testing Checklist
- [ ] UFOs spawn and shoot correctly
- [ ] Comet charge telegraphs and executes
- [ ] Enemy collision damage applies
- [ ] Enemies wrap around screen
- [ ] Score and crystals award properly
- [ ] Multiple enemies on screen without lag

---

## Module 7: Black Hole Hazard System

**Priority**: Medium  
**Dependencies**: None  
**Estimated Duration**: 3-4 days

### Purpose
Add dynamic black hole hazard with gravitational physics.

### Core Components

#### 7.1 Black Hole Scene
- **File**: `scenes/gameplay/hazards/black_hole.tscn` + `black_hole.gd`
- **Type**: `Area2D` with detection zone
- **Behavior**:
  - Spawns at random location every 30-60 seconds
  - Applies gravitational force to all objects in radius (player, asteroids, enemies, projectiles)
  - Can be "overloaded" and destroyed by consuming enough mass
  - Emits particles/shader distortion effect

#### 7.2 Gravitational Component
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

#### 7.3 Black Hole Spawner
- **File**: Extend `game_manager.gd` or create `black_hole_spawner.gd`
- **Logic**:
  - Timer-based spawning (adjusts with difficulty)
  - Only 1 black hole at a time (or max 2 late game)
  - Random position avoiding player spawn area

#### 7.4 Visual Effects
- Shader for distortion effect (optional but impactful)
- Particle system for swirling matter
- Pulsing animation

### Integration Points
- Affects player, asteroids, enemies equally
- Destroyed asteroids count toward overload meter
- Player takes damage if too close for too long

### Extensibility
- Different black hole types (pulsing, moving)
- White holes (repulsion instead of attraction)
- Wormhole pairs for teleportation

### Testing Checklist
- [ ] Black hole spawns at correct intervals
- [ ] Gravitational pull affects all objects
- [ ] Overload mechanic works
- [ ] Player can escape with enough thrust
- [ ] Visual effects perform well
- [ ] No physics glitches with high forces

---

## Module 8: Dynamic Difficulty System

**Priority**: Medium  
**Dependencies**: Module 6 (Enemies), Module 5 (Stats for power rating)  
**Estimated Duration**: 4-5 days

### Purpose
Implement real-time difficulty adjustment based on player performance.

### Core Components

#### 8.1 DifficultyManager Component
- **File**: `scripts/gameplay/difficulty_manager.gd`
- **Purpose**: Calculate and adjust difficulty level
- **Signals**:
  ```gdscript
  signal difficulty_changed(new_level: float)
  signal difficulty_tier_changed(tier: int)
  ```

#### 8.2 Performance Tracker
- **Track Metrics** (every 5-10 seconds):
  - Shield percentage
  - Damage taken rate
  - Accuracy
  - Crystals collected
  - Survival time
- **Calculate Performance Score**:
  ```gdscript
  func calculate_performance() -> float:
      var shield_factor = current_shield / max_shield
      var damage_factor = clamp(1.0 - damage_rate / 10.0, 0.0, 1.0)
      var accuracy_factor = accuracy
      return (shield_factor + damage_factor + accuracy_factor) / 3.0
  ```

#### 8.3 Difficulty Scaling Formula
- **Base Difficulty**: Increases with time (0.1 per minute)
- **Performance Modifier**: -0.5 to +0.5 based on performance score
- **Player Power Rating**: Factor in equipped upgrades
- **Apply to Spawners**:
  ```gdscript
  func apply_difficulty(difficulty: float):
      asteroid_spawner.spawn_rate = base_rate * (1.0 + difficulty * 0.1)
      enemy_spawner.spawn_rate = base_rate * (1.0 + difficulty * 0.15)
      # etc.
  ```

#### 8.4 Enemy Stat Scaling
- Modify enemy resources on spawn based on difficulty:
  ```gdscript
  func spawn_enemy():
      var enemy = enemy_scene.instantiate()
      enemy.health *= (1.0 + difficulty * 0.1)
      enemy.damage *= (1.0 + difficulty * 0.12)
      # etc.
  ```

### Integration Points
- GameManager owns DifficultyManager
- Spawners listen to `difficulty_changed` signal
- HUD optionally shows difficulty level (debug mode)

### Extensibility
- Different difficulty modes (easy, normal, hard base curves)
- Difficulty modifiers as unlockable items
- "Challenge runs" with forced high difficulty

### Testing Checklist
- [ ] Difficulty increases naturally over time
- [ ] Performance affects difficulty correctly
- [ ] Low shield triggers difficulty decrease
- [ ] Spawners respond to difficulty changes
- [ ] Enemy stats scale appropriately
- [ ] No sudden difficulty spikes (smooth transitions)

---

## Module 9: Weapon Variety System

**Priority**: Low-Medium  
**Dependencies**: Module 5 (Stats/Items)  
**Estimated Duration**: 5-7 days

### Purpose
Add alternate weapon types beyond basic laser (homing missiles, spread shot, beam).

### Core Components

#### 9.1 Weapon Base Class
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

#### 9.2 Weapon Types

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

#### 9.3 Weapon System Manager
- **File**: `scripts/gameplay/weapon_system.gd`
- **Purpose**: Manages active weapons on player
- **Properties**:
  ```gdscript
  var primary_weapon: WeaponBase
  var secondary_weapon: WeaponBase  # Unlocked via upgrades
  ```

#### 9.4 Weapon Upgrade Items
- Create items that unlock/upgrade weapons:
  - "Homing Tracker" item (adds homing missiles as secondary)
  - "Spread Amplifier" (converts primary to spread)
  - "Beam Emitter" (unlocks beam weapon)

### Integration Points
- Player has WeaponSystem node
- Items can modify WeaponSystem configuration
- Input handles primary/secondary fire separately

### Extensibility
- Add new weapon types as scenes + scripts
- Weapon mods (e.g., "fire damage", "pierce")
- Weapon combos/synergies

### Testing Checklist
- [ ] Can switch between weapon types
- [ ] Each weapon fires correctly
- [ ] Homing missiles track targets
- [ ] Beam weapon performs well visually
- [ ] Spread weapon angle correct
- [ ] Items unlock weapons properly

---

## Module 10: Visual Effects & Juice

**Priority**: Low  
**Dependencies**: All gameplay systems  
**Estimated Duration**: 4-6 days

### Purpose
Enhance game feel with particles, screen shake, trails, and feedback.

### Core Components

#### 10.1 Particle Effects
- **Explosion Effect**: `scenes/vfx/explosion.tscn`
  - CPUParticles2D or GPUParticles2D
  - Used for asteroid destruction, enemy death
  - Color-coded by type (white for asteroids, red for enemies)
  
- **Thrust Trail**: Attached to player
  - Particle trail when accelerating
  
- **Pickup Shine**: Crystal collection flash
  
- **Black Hole Swirl**: Particles orbiting black hole

#### 10.2 Screen Shake Component
- **File**: `scripts/components/screen_shake.gd`
- **Purpose**: Reusable camera shake
- **Usage**:
  ```gdscript
  ScreenShake.shake(intensity: float, duration: float)
  ```
- Attached to Camera2D

#### 10.3 Impact Feedback
- Freeze frames on big explosions (0.05s pause)
- Player ship flash white when hit
- Hit particles at collision point

#### 10.4 Audio Integration
- Placeholder for sound effects
- Positional audio for explosions
- Engine thrust sound loop

### Integration Points
- All destruction events spawn particles
- Camera shake on player hit, large asteroid destroyed
- VFX pool for performance (object pooling)

### Extensibility
- Different VFX for weapon types
- Customizable player ship trails (cosmetics)
- Screen filters/shaders (damage vignette)

### Testing Checklist
- [ ] Explosions spawn at correct positions
- [ ] Screen shake feels good (not nauseating)
- [ ] Particles don't tank performance (100+ on screen)
- [ ] Trails follow player smoothly
- [ ] Can toggle effects off (accessibility)

---

## Module 11: Main Menu & Game Flow

**Priority**: Medium  
**Dependencies**: Module 2 (Save System), Module 4 (Upgrade Shop)  
**Estimated Duration**: 3-4 days

### Purpose
Complete game navigation flow with polished menu system.

### Core Components

#### 11.1 Main Menu Scene
- **File**: `scenes/ui/main_menu.tscn`
- **Layout**:
  - Title logo
  - "Play" button (starts game or continues if in-progress)
  - "Upgrades" button (opens shop)
  - "Settings" button
  - "Quit" button
  - Credits display in corner

#### 11.2 Settings Menu
- **File**: `scenes/ui/settings_menu.tscn`
- **Options**:
  - Audio sliders (SFX, Music)
  - Control display/remapping (future)
  - Graphics quality (particles on/off)
  - Reset progress (with confirmation)

#### 11.3 Pause Menu
- **File**: `scenes/ui/pause_menu.tscn`
- **Shown during gameplay** when pause pressed
- **Options**:
  - Resume
  - Settings
  - Main Menu (with confirmation)

#### 11.4 Scene Transitions
- Fade in/out between scenes
- Loading screen if needed (unlikely for 2D)

### Integration Points
- Main menu loads on startup
- Play button loads game world scene
- All menus connect to SaveSystem for persistence

### Extensibility
- Achievements screen
- Statistics/leaderboards
- Cosmetic unlocks

### Testing Checklist
- [ ] Can navigate all menus
- [ ] Settings persist correctly
- [ ] Pause works during gameplay
- [ ] Scene transitions smooth
- [ ] No memory leaks on scene changes

---

## Module 12: Hyperspace Jump Mechanic

**Priority**: Low  
**Dependencies**: None  
**Estimated Duration**: 2-3 days

### Purpose
Add emergency teleport ability with risk/reward.

### Core Components

#### 12.1 Hyperspace Logic
- **File**: Extend `player.gd`
- **Behavior**:
  - Input action "hyperspace" (e.g., Shift key)
  - Teleport to random screen position
  - Brief invulnerability (0.5s)
  - Cooldown (10s base, upgradeable)
  - Risk: Can land near asteroids/enemies

#### 12.2 Visual Effect
- Particle burst at departure and arrival
- Screen flash
- Trail effect during teleport

#### 12.3 Upgrade Items
- "Hyperspace Stabilizer" (reduces cooldown)
- "Safe Jump" (scans landing area, avoids hazards)

### Integration Points
- Player input handling
- HUD shows cooldown indicator
- Upgrades affect cooldown

### Extensibility
- Chain jumps (rapid multiple teleports)
- Tactical teleport (target position)
- Leave clone/decoy behind

### Testing Checklist
- [ ] Teleport works correctly
- [ ] Can't teleport off screen
- [ ] Cooldown enforced
- [ ] Invulnerability period works
- [ ] Visual effects clean

---

## Implementation Order

### Phase 1: Foundation (Weeks 2-3)
Focus on core systems that other features depend on:
1. **Module 1**: Resource System & Pickups
2. **Module 2**: Save/Load System
3. **Module 3**: Credit Economy
4. **Module 4**: Upgrade Shop UI
5. **Module 5**: Stat Calculation & Upgrades

**Milestone**: Can earn credits, buy upgrades, see stats change in-game.

---

### Phase 2: Content Expansion (Weeks 4-5)
Add gameplay variety:
6. **Module 6**: Enemy Variety (UFO, Comet)
7. **Module 7**: Black Hole Hazard
8. **Module 8**: Dynamic Difficulty

**Milestone**: Game feels varied, difficulty adapts, enemies challenge player.

---

### Phase 3: Polish & Depth (Weeks 6-7)
Enhance feel and options:
9. **Module 9**: Weapon Variety
10. **Module 10**: Visual Effects & Juice
11. **Module 11**: Main Menu & Flow
12. **Module 12**: Hyperspace Jump

**Milestone**: Game feels polished, complete core loop.

---

### Phase 4: Balance & Testing (Week 8)
- Playtest all systems together
- Balance item costs and stat formulas
- Optimize performance
- Bug fixes
- Prepare for release build

---

## Technical Debt & Refactoring Plan

### Current Prototype Issues to Address
1. **Hardcoded values**: Move to resources (⚠️ Priority)
2. **Scene references**: Use groups and signals instead of `get_node()` where possible
3. **Magic numbers**: Define constants or export variables

### Refactoring Opportunities
- **Object Pooling**: Implement for projectiles, particles, crystals (Module 10)
- **Component System**: Extract health, movement into reusable components (Module 5)
- **Data-Driven Enemies**: Replace hardcoded asteroid logic with resource system (Module 6)

---

## Documentation & Knowledge Transfer

### Code Documentation Standards
- Use `##` doc comments for public methods
- `@export` variables should have tooltips
- Each script should have class header comment

### Resources to Create
- Item catalog spreadsheet (for designers)
- Difficulty curve visualization tool
- Stat calculator spreadsheet (for balancing)

---

## Testing Strategy

### Per-Module Testing
Each module includes testing checklist (see individual modules above).

### Integration Testing
- After Phase 1: Test upgrade→stat→gameplay flow
- After Phase 2: Test difficulty scaling with multiple hazards
- After Phase 3: Full playtest from menu to game over to upgrades

### Performance Testing
- Target: 60 FPS on mid-range mobile devices
- Test with 100+ objects on screen
- Profile physics, particle systems, audio

### Balance Testing
- Item cost/power ratio validation
- Difficulty curve feels fair at all skill levels
- Upgrade progression satisfying (not too grindy)

---

## Risk Management

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Performance issues with many objects | Medium | High | Object pooling, particle limits |
| Stat calculation overflow at high levels | Low | Medium | Use `float` for all calculations, clamp values |
| Save corruption | Low | High | Version checking, backups, validation |
| Signal spaghetti (too many connections) | Medium | Medium | Document signal flow, use clear naming |

### Design Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Upgrade system too grindy | High | High | Playtesting, adjustable formulas |
| Difficulty too hard/easy | Medium | Medium | Dynamic difficulty testing, player feedback |
| Not enough content variety | Low | High | Modular item/enemy system allows easy additions |

---

## Success Metrics

### Technical Metrics
- ✅ 60 FPS maintained with 100+ active objects
- ✅ Load times < 2 seconds on mobile
- ✅ No crashes in 1-hour play session
- ✅ Save/load reliability 100%

### Gameplay Metrics
- ✅ Average session length: 3-5 minutes
- ✅ Player retention: 70%+ return after first session
- ✅ Upgrade engagement: 80%+ players use shop after run
- ✅ Difficulty feel: 60%+ players survive 2+ minutes by run 10

---

## Future Expansion (Post-Launch)

### Potential Modules (Not in Initial Plan)
- **Daily Challenges**: Specific modifiers, leaderboards
- **Prestige System**: Reset for permanent bonuses
- **Boss Fights**: Scripted encounters at difficulty milestones
- **Ship Variants**: Different starting ships with unique abilities
- **Cosmetics**: Ship skins, trail colors, projectile effects
- **Achievements**: Steam/mobile achievement integration
- **Leaderboards**: Global high scores, daily/weekly competitions

### Expansion Readiness
The modular architecture ensures these can be added without rewriting core systems:
- Items: Just create new `.tres` files
- Enemies: New scenes + enemy_definition resources
- Weapons: Extend WeaponBase class
- Progression: Add new stats to ShipStats resource

---

## Appendix: Development Tools & Workflows

### Recommended Godot Plugins
- **GUT** (Godot Unit Testing): For automated testing
- **Dialogic**: If adding tutorial/story elements
- **AsepriteWizard**: If using Aseprite for sprites

### Asset Pipeline
- Sprites: Export to `assets/sprites/` as PNG
- Audio: Export to `assets/audio/` as OGG (compressed)
- Fonts: Place in `assets/fonts/`

### Version Control
- Use Git with `.gitignore` for Godot projects
- Branch per module (e.g., `feature/module-1-resources`)
- Merge to `develop` after testing, then to `main` for releases

### Build Pipeline
- Export presets for Android, iOS, Windows, Linux
- Automated builds via CI/CD (GitHub Actions)
- TestFlight/Google Play internal testing

---

## Questions for Stakeholders

Before starting implementation:
1. **Priority Confirmation**: Agree on Phase 1-2-3 order?
2. **Scope**: Are all 12 modules needed for MVP, or can some be post-launch?
3. **Platform**: Confirm mobile-first, or should PC be prioritized?
4. **Monetization**: Free with ads? Premium? IAP? (Affects Module 3 credit economy)
5. **Timeline**: 8-week timeline realistic, or need adjustments?

---

## Summary

This development plan breaks **Void Survivor** into **12 independent, extensible modules** that can be implemented incrementally. Each module:
- ✅ Has clear scope and purpose
- ✅ Uses signal-based integration (loose coupling)
- ✅ Leverages Godot resources for data-driven design
- ✅ Includes testing criteria
- ✅ Supports future expansion

The architecture prioritizes **modularity** and **extensibility**, allowing new content (items, enemies, weapons) to be added via resources without code changes. Signal-based communication ensures features remain independent while working together seamlessly.

**Next Steps**: Review and approve this plan, then begin Phase 1 implementation starting with Module 1 (Resource System).
