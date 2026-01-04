# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**Void Survival** is a space shooter game built with **Godot 4.5** where players control a spaceship, destroy asteroids, and survive as long as possible.

**Current Status**: Week 1 Prototype ✅ Complete
**Next Phase**: Phase 1 Foundation (Modules 1-5) - Resource system, save/load, credit economy, upgrade shop
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
- **[Archive](Documents/archive/)**: Completed plans including the prototype plan

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
│   ├── prototype/          # Core gameplay scenes
│   │   ├── game.tscn       # Main game scene (entry point)
│   │   ├── player.tscn     # Player ship
│   │   ├── asteroid.tscn   # Asteroid enemy
│   │   └── projectile.tscn # Player bullet
│   └── ui/
│       └── prototype_hud.tscn  # HUD overlay
└── scripts/                # GDScript files matching scenes
    ├── game_manager.gd
    ├── player.gd
    ├── asteroid.gd
    ├── projectile.gd
    ├── spawner.gd
    └── prototype_hud.gd
```

---

## Game Architecture

### Core Systems

This game uses a **signal-based event system** for decoupled communication between gameplay systems:

1. **GameManager** (`game_manager.gd`)
   - Central coordinator for game state and score tracking
   - Listens to player death and asteroid destruction events
   - Uses `get_tree().node_added` to auto-connect to dynamically spawned asteroids
   - Handles game restart via input action "restart"

2. **Player** (`player.gd`)
   - `CharacterBody2D` with custom movement physics (thrust + rotation)
   - Emits `died` signal when shield reaches zero
   - Emits `shield_changed(current, maximum)` signal for UI updates
   - Instantiates projectiles at `ShootPoint` Marker2D with fire rate limiting

3. **Spawner** (`spawner.gd`)
   - Spawns asteroids at random screen edges with velocity toward center
   - Tracks active asteroid count to enforce `max_asteroids` limit
   - Decrements count when asteroids are destroyed via signal connection

4. **Asteroid** (`asteroid.gd`)
   - `RigidBody2D` with three sizes: LARGE, MEDIUM, SMALL
   - Emits `destroyed(score_value)` signal before queue_free()
   - Splits into smaller asteroids when destroyed (3 for LARGE, 2 for MEDIUM)
   - Uses `duplicate()` for spawning split pieces
   - Screen wrapping handled in `_physics_process`

5. **Projectile** (`projectile.gd`)
   - `Area2D` with linear velocity
   - Auto-destroys when leaving screen via `VisibleOnScreenNotifier2D`
   - Deals damage to asteroids on collision then queue_free()

6. **HUD** (`prototype_hud.gd`)
   - `CanvasLayer` for screen-space UI
   - Finds player and game_manager via groups on `_ready()`
   - Connects to signals for reactive UI updates
   - Uses unique name references (`%ShieldBar`, `%ScoreLabel`) for node access

### Signal Flow

```
Asteroid destroyed → GameManager.add_score() → score_updated → HUD updates score label
                  → Spawner._on_asteroid_destroyed() → decrements active count

Player hit → Player.take_damage() → shield_changed → HUD updates shield bar
          → (if dead) died → GameManager._on_player_died() → game_over

Projectile hits asteroid → Asteroid.take_damage() → destroyed signal → (see above)
```

### Input Actions

Defined in `project.godot`:
- `thrust_forward`: W key - Move ship forward
- `rotate_left`: A key - Rotate counterclockwise
- `rotate_right`: D key - Rotate clockwise
- `fire`: SPACE - Shoot projectile
- `restart`: R key - Restart game after death

### Physics Layers

1. **Layer 1**: Player
2. **Layer 2**: Asteroids
4. **Layer 4**: Projectiles

**Note**: Zero gravity (`2d/default_gravity=0.0`) and no linear damping for space physics.

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
5. **Optimize by disabling what you don’t need**: avoid unnecessary processing, physics, and allocations.
6. **Leverage the editor**: make everything as configurable and visual as possible for faster iteration.
