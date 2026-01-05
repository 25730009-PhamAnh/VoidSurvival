# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**Void Survival** is a space shooter game built with **Godot 4.5** where players control a spaceship, destroy asteroids, and survive as long as possible.

**Current Status**: Phase 2 Content Expansion - Module 7 In Progress (Black Hole system partially implemented)
**Next Tasks**: Complete Module 7 - Black Hole Hazard System testing & polish
**Target Platforms**: Mobile (iOS/Android), PC

### Documentation Structure

All design and planning documentation is in `Documents/`:
- **[GDD](Documents/VoidSurvivor_GDD.md)**: Complete game design specification
- **[Technical Spec](Documents/VoidSurvivor_TechnicalSpec_Godot.md)**: Godot 4 implementation architecture
- **[Development Plan](Documents/Development_Plan_Overview.md)**: High-level strategy and phases
- **[Modules](Documents/modules/)**: 12 independent feature modules organized by priority
  - Phase 1 (High Priority): Modules 1-5 (Resource system, save/load, credits, shop, stats)
  - Phase 2 (Medium Priority): Modules 6-8 (Enemy variety, black holes, difficulty)
  - Phase 3 (Low-Medium Priority): Modules 9-12 (Weapons, VFX, menu, hyperspace)
- **[Archive](Documents/archive/)**: Completed plans (prototype, modules 1-5)

### Key Architecture Principles

- **Data-Driven**: All gameplay parameters in Resource files (no hardcoded stats)
- **Signal-Based**: Decoupled systems using Godot's signal system
- **Modular**: Reusable components and scenes
- **Infinite Progression**: Mathematical formulas for endless scaling
- **Extensible**: Add items/enemies via resources, no code changes needed

### Running the Game

- **Open in Godot Editor**: Open `Src/void-survival/project.godot` in Godot 4.5+
- **Run from Editor**: Press F5 or click the Play button
- **Main Scene**: `res://scenes/prototype/game.tscn`

### Project Structure

```
Src/void-survival/
├── scenes/
│   ├── prototype/              # Core gameplay (game.tscn, player.tscn, asteroid.tscn)
│   ├── gameplay/hazards/       # Hazard scenes (enemy_ufo, enemy_comet, black_hole)
│   ├── components/             # Reusable component scenes
│   ├── pickups/                # Crystal and other collectibles
│   └── ui/                     # HUD, game over, upgrade shop + components
├── scripts/
│   ├── autoload/               # ResourceManager, SaveSystem, SessionManager, UpgradeSystem
│   ├── components/             # Reusable components (health, movement, gravitational, kill_zone, collection)
│   ├── resources/              # ItemDefinition, EnemyDefinition custom Resource classes
│   ├── gameplay/spawners/      # EnemySpawner, BlackHoleSpawner systems
│   ├── pickups/                # Crystal and pickup scripts
│   └── ui/                     # UI component scripts
└── resources/
    ├── items/                  # .tres files (defensive/, offensive/, utility/)
    ├── enemies/                # .tres files (ufo_data, comet_data)
    ├── ship_parameters/        # Player ship stats
    └── config/                 # Game configuration resources
```

---

## Game Architecture

### Core Systems

**Signal-based architecture** with decoupled communication:

**Autoload Singletons**:
- **ResourceManager**: Crystals (session) + credits (persistent), emits `crystals_changed`/`credits_changed`
- **SaveSystem**: JSON persistence to `user://savegame.json`, auto-saves on game over
- **SessionManager**: Tracks stats (time, kills, accuracy), calculates credit bonuses
- **UpgradeSystem**: Manages `equipped_items` array, `item_levels` dict, 4 slots default

**Gameplay**: Player (CharacterBody2D) → shoots Projectiles → destroys Asteroids (RigidBody2D, splits 3→2→1) → spawns Crystals → CollectionComponent attracts → ResourceManager tracks

**UI**: HUD (in-game) → GameOverScreen (stats) → UpgradeShop (loads items from dirs) → UpgradeCard (per-item)

**Resources**: ItemDefinition custom Resource class, stored as `.tres` in `resources/items/{category}/`

### Key Signal Flows

```
Asteroid destroyed → destroyed signal → GameManager + Spawner → spawns Crystal
Player dies → died signal → SessionManager.end_session() → GameOverScreen
Shop upgrade → UpgradeSystem.upgrade_item() → credits_changed + item_upgraded → auto-save
```

### Input Actions

Defined in `project.godot`:
- `thrust_forward`: W key - Move ship forward
- `rotate_left`: A key - Rotate counterclockwise
- `rotate_right`: D key - Rotate clockwise
- `fire`: SPACE - Shoot projectile
- `restart`: R key - Restart game after death
- `ui_cancel`: ESC - Back button in menus (default Godot action)

### Physics Layers

1. **Layer 1**: Player
2. **Layer 2**: Asteroids & Enemies (UFOs, Comets)
4. **Layer 4**: Projectiles

**Note**: Zero gravity (`2d/default_gravity=0.0`) and no linear damping for space physics.

### Component System

**Reusable Components** (composition-based architecture):
- **HealthComponent**: Health tracking with damage/death signals
- **MovementComponent**: Customizable movement patterns (sinusoidal, drift, charge)
- **CollectionComponent**: Attracts and collects pickups (crystals) in range
- **GravitationalComponent**: Applies gravitational pull to nearby physics bodies
- **KillZoneComponent**: Destroys objects that enter center area (used by black holes)

### Enemy System (Module 6)

**Enemy Types**:
- **UFO Scout**: Sinusoidal movement pattern, shoots at player with lead targeting
- **Void Comet**: Drifts slowly, then telegraphs and charges at high speed toward player

**EnemyDefinition Resource**: Data-driven enemy configuration with difficulty scaling
- Base stats: health, speed, damage, score value, crystal drops
- Scaling formulas: health/speed/damage increase with difficulty
- Scene reference: PackedScene for enemy type

**EnemySpawner**: Manages enemy spawning based on difficulty
- Spawn intervals decrease with difficulty (survival time / 10)
- Max limits per enemy type (3 UFOs, 5 Comets)
- Automatic crystal spawning on enemy destruction
- Tracks enemy kills in SessionManager

**Signal Flow**:
```
Enemy spawned → initialized with difficulty-scaled stats
Enemy destroyed → destroyed(score, crystals, position) → GameManager.add_score() + spawn crystals
Enemy damaged → damaged signal (for future VFX)
```

### Black Hole Hazard System (Module 7 - In Progress)

**Black Hole Mechanics**:
- Spawns periodically in safe zones (away from player)
- Applies gravitational pull to ALL physics objects (player, asteroids, enemies, projectiles)
- Center kill zone destroys anything that reaches it
- Can be "overloaded" and destroyed by absorbing enough mass

**Components Used**:
- **GravitationalComponent**: Pulls objects toward center with inverse-square force
- **KillZoneComponent**: Destroys objects in center area
- Dedicated black_hole.gd script manages lifecycle, visual effects, and mass tracking

**BlackHoleSpawner**: Manages black hole spawning
- Time-based spawning with difficulty scaling
- Position safety checks (minimum distance from player)
- Max active black holes limit
- Coordinates with GameManager for hazard lifecycle

### Progression & Persistence

**Meta-progression**: Crystals (session) → Credits (permanent) → Purchase/upgrade items → Equip 4 slots

**Save data** (`user://savegame.json`): `total_credits`, `item_levels` (path→level), `equipped_items` (paths), `unlocked_slots`, `stats`

**Item cost**: `base_cost * pow(cost_scaling, level)` | **Credits**: Crystals 1:1 + time/combat/accuracy bonuses

---

## Development Patterns

**Adding items**: Create `.tres` in `resources/items/{category}/`, shop auto-loads (no code changes)

**Adding enemies**: Create `.tres` EnemyDefinition in `resources/enemies/`, reference enemy scene, spawner auto-configures

**Component-based design**: Attach components (Health, Movement, Gravitational, etc.) to scenes for reusable behavior

**Autoload order**: ResourceManager → SaveSystem → SessionManager → UpgradeSystem

**Scene flow**: `game.tscn` → `game_over_screen.tscn` → `upgrade_shop.tscn` → back to game

**Groups**: `"player"`, `"game_manager"`, `"enemies"` - use `get_tree().get_first_node_in_group("player")`

**Spawner pattern**: GameManager coordinates spawners (asteroids, enemies, black holes) via child nodes

---

## Godot Best Practices (General)

You are an expert in **Godot 4** and **GDScript**, and you strictly follow **Godot best practices** for scalable game development.

---

## Key Principles

- Write clear, technical responses with precise **Godot 4 + GDScript** examples.
- Prefer **simple, idiomatic Godot solutions** over complex patterns borrowed from other engines.
- Use **Godot’s built-in nodes, resources, signals, and tools** before reaching for addons or custom frameworks.
- Prioritize **readability, maintainability, and editor-friendliness** in all code and architecture decisions.
- Follow **GDScript style guidelines**:
  - `snake_case` for variables and functions.
  - `PascalCase` for classes.
  - `ALL_CAPS` for constants.
- Design systems around **nodes, scenes, and signals**, not global singletons unless truly necessary.

---

## Godot / GDScript Best Practices

### Architecture & Structure

- Use **scenes as reusable units**:
  - Treat `.tscn` scenes like prefabs or components.
  - Use **composition** (child nodes + scripts) over deep inheritance trees.
- Attach GDScript to nodes for behavior:
  - Keep scripts focused and small; avoid “god classes” doing everything.
  - Split large systems into multiple collaborating nodes/scenes.
- Use **autoloads (singletons)** sparingly:
  - Only for truly global concerns (e.g., settings, save system, analytics).
  - Keep them lean and avoid packing gameplay logic into them.

### Data & Configuration

- Use **Resources** for configuration and data:
  - `Resource`-based configs (`.tres/.res`) for stats, items, enemy definitions, etc.
  - Custom `Resource` scripts for structured data (avoiding ad-hoc dictionaries).
- Use `@export` to expose configurable properties in the editor:
  - Make scripts designer-friendly by exposing tunable values.
  - Prefer typed exports (`@export var speed: float = 200.0`).

### Input Handling

- Use the **Input Map** with named actions:
  - Avoid checking raw key codes directly in game logic.
  - Use `Input.is_action_pressed()` and `Input.is_action_just_pressed()` for clarity and rebindability.
- Handle input in:
  - `_unhandled_input(event)` for gameplay input where UI might consume earlier.
  - `_input(event)` for low-level, always-available input.

### Signals & Decoupling

- Use **signals** for communication instead of tight coupling:
  - Define custom signals for events like `health_changed`, `died`, `score_updated`.
  - Connect signals in the editor where possible for better visibility.
- Prefer **one-directional dependencies**:
  - Child notifies parent via signal instead of calling parent methods directly.
  - Systems listen to events rather than polling state constantly.

### UI & UX

- Build UI using **Control** nodes and containers:
  - Use layout containers (`HBoxContainer`, `VBoxContainer`, `GridContainer`) for responsive layouts.
  - Avoid hard-coded positions when a container/layout can solve it.
- Use **CanvasLayer** for screen-space UI that stays independent of camera movement.
- Keep UI logic in dedicated scripts, separate from core gameplay scripts.

---

## Error Handling, Debugging & Tooling

- Use **assertions** and runtime checks:
  - `assert(node != null)` after `get_node()` where required.
  - Validate required children/resources in `_ready()` and fail early.
- Logging:
  - Use `print()`, `print_debug()`, `push_warning()`, and `push_error()` judiciously.
  - Avoid noisy logging in production paths; gate with a debug flag if needed.
- Debugging and profiling:
  - Use the **debugger**, **remote scene tree**, and **remote inspector** during runtime.
  - Use the **profiler** to measure script time, physics, and rendering.
- Editor tools:
  - Use `@tool` scripts for editor-time helpers (auto-setup, validation), but:
    - Keep them stable and robust so they don’t spam errors in the editor.
  - Create small **EditorPlugins** when you see repeated manual editor work.

---

## Godot-Specific Guidelines

### Scene & Node Organization

- Maintain a clear and consistent folder structure:
  - `scenes/`, `scripts/`, `ui/`, `resources/`, `autoload/`, `addons/`, etc.
- Name scenes and scripts clearly:
  - Match scene and script names when they are tightly coupled (e.g., `Player.tscn` / `player.gd`).
- Use **groups** for logical classification:
  - Example groups: `"enemies"`, `"damageable"`, `"projectiles"`, `"ui"`.
  - Use `get_tree().call_group("enemies", "on_freeze")`-style broadcast when appropriate.

### Physics & Interactions

- Use the correct body types:
  - `CharacterBody2D/3D` for controlled characters.
  - `RigidBody2D/3D` for physically simulated bodies.
  - `StaticBody*` for non-moving collision.
  - `Area*` for detection and triggers.
- Physics best practices:
  - Keep collision shapes simple; avoid excessive polygon complexity.
  - Use **collision layers & masks** instead of manual checks wherever possible.

### Animation

- Prefer **AnimationPlayer** for property-based animations and simple sequences.
- Use **AnimationTree** (with state machines/blend spaces) for complex character animation logic.
- Avoid “magic timing” in code when you can drive behavior from animation signals/tracks.

---

## Performance Optimization (Godot-Oriented)

- Minimize unnecessary processing:
  - Disable `_process`/`_physics_process` on nodes that don’t need them: `set_process(false)`, `set_physics_process(false)`.
  - Use signals, timers, or coroutines (`await create_timer`) instead of constant polling.
- Node lifecycle:
  - Avoid frequent `instance`/`queue_free` in tight loops; use **object pooling** for bullets, VFX, etc.
- Rendering:
  - Share materials where possible to help batching.
  - Use atlases/sprite sheets for 2D.
  - Avoid excessive overdraw and too many overlapping transparent sprites.
- Physics:
  - Only enable physics where needed.
  - Reduce the number of active bodies and areas when possible.
- Heavy work:
  - Move long-running operations off the main thread where safe, without calling Godot APIs from worker threads.
  - Break large computations into chunks processed over multiple frames.

---

## Key Conventions (Godot Best Practices Summary)

1. **Think in nodes, scenes, and signals**: design systems around these core concepts.
2. **Keep scripts small and focused**: one responsibility per script/node whenever feasible.
3. **Use Resources and exports** for clean, editor-friendly data and configuration.
4. **Favor composition and signals over inheritance and globals** to keep systems decoupled.
5. **Optimize by disabling what you don't need**: avoid unnecessary processing, physics, and allocations.
6. **Leverage the editor**: make everything as configurable and visual as possible for faster iteration.

---

## Current Status

**✅ Complete**: Phase 1 Foundation (Modules 1-5) + Module 6
- Module 1-2: Resource system (crystals, credits) + Save/Load
- Module 3: Credit economy & post-game flow
- Module 4: Shop UI with equip/upgrade
- Module 5: Stat calculation system (items modify player stats in real-time)
- Module 6: Enemy Variety & Spawning (UFO + Comet enemies with data-driven system)

**🚧 In Progress**: Module 7 - Black Hole Hazard System (GravitationalComponent, KillZoneComponent, and BlackHole scene implemented)

**📋 Remaining**: Modules 8-12 (difficulty scaling, weapons, VFX, menus, hyperspace)

**Core Progression Loop**: Fully functional - Play → Earn Crystals → Buy/Upgrade Items → Equip Items → Stats Increase → Play Better

See `Documents/Development_Plan_Overview.md` and `Documents/modules/` for details.

---

## Testing & Debugging

**Run Game**: Open `Src/void-survival/project.godot` in Godot 4.5+ and press F5

**Check Save Data**: Save file location is `user://savegame.json`
- On macOS: `~/Library/Application Support/Godot/app_userdata/Void Survival/`
- On Windows: `%APPDATA%\Godot\app_userdata\Void Survival\`
- On Linux: `~/.local/share/godot/app_userdata/Void Survival/`

**Debug Signals**: Use `print()` or connect to signals in editor for visibility

**Test Components**: Components are reusable - test by attaching to test scenes

**Physics Debugging**: Enable "Visible Collision Shapes" in Debug menu to see collision areas
