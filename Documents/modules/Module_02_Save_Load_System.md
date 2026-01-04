# Module 2: Save/Load System

**Priority**: High
**Dependencies**: None
**Estimated Duration**: 2-4 days

## Purpose
Persist player progression (credits, unlocked items, settings) across sessions.

## Core Components

### 2.1 SaveSystem Singleton
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

### 2.2 Implementation
- Use `FileAccess` to write JSON to `user://savegame.save`
- Validate save data version on load
- Handle missing/corrupted saves gracefully
- Auto-save after each game session

### 2.3 Settings Integration
- Save audio volumes, control preferences
- Load settings on game startup

## Integration Points
- GameManager calls `SaveSystem.save_game()` on game over
- UpgradeSystem loads progression data on startup
- Main menu shows "Continue" button if save exists

## Extensibility
- Cloud save integration (future): Abstract save backend
- Multiple save slots: Array of save data
- Achievements: Add to save structure

## Testing Checklist
- [ ] Save data persists after closing game
- [ ] Corrupted save handled without crash
- [ ] Version mismatch detected and handled
- [ ] Auto-save after every run
- [ ] Settings loaded correctly on startup

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
