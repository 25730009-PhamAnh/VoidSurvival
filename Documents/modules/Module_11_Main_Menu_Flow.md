# Module 11: Main Menu & Game Flow

**Priority**: Medium
**Dependencies**: Module 2 (Save System), Module 4 (Upgrade Shop)
**Estimated Duration**: 3-4 days

## Purpose
Complete game navigation flow with polished menu system.

## Core Components

### 11.1 Main Menu Scene
- **File**: `scenes/ui/main_menu.tscn`
- **Layout**:
  - Title logo
  - "Play" button (starts game or continues if in-progress)
  - "Upgrades" button (opens shop)
  - "Settings" button
  - "Quit" button
  - Credits display in corner

### 11.2 Settings Menu
- **File**: `scenes/ui/settings_menu.tscn`
- **Options**:
  - Audio sliders (SFX, Music)
  - Control display/remapping (future)
  - Graphics quality (particles on/off)
  - Reset progress (with confirmation)

### 11.3 Pause Menu
- **File**: `scenes/ui/pause_menu.tscn`
- **Shown during gameplay** when pause pressed
- **Options**:
  - Resume
  - Settings
  - Main Menu (with confirmation)

### 11.4 Scene Transitions
- Fade in/out between scenes
- Loading screen if needed (unlikely for 2D)

## Integration Points
- Main menu loads on startup
- Play button loads game world scene
- All menus connect to SaveSystem for persistence

## Extensibility
- Achievements screen
- Statistics/leaderboards
- Cosmetic unlocks

## Testing Checklist
- [ ] Can navigate all menus
- [ ] Settings persist correctly
- [ ] Pause works during gameplay
- [ ] Scene transitions smooth
- [ ] No memory leaks on scene changes

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
