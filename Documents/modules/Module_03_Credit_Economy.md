# Module 3: Credit Economy & Post-Game Flow

**Priority**: High
**Dependencies**: Module 1 (Resource System), Module 2 (Save System)
**Estimated Duration**: 2-3 days

## Purpose
Convert in-game performance into persistent currency for upgrades.

## Core Components

### 3.1 Credit Calculation
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

### 3.2 Game Over Screen
- **File**: `scenes/ui/game_over_screen.tscn`
- **Display**:
  - Survival time
  - Score breakdown
  - Credits earned (with animation)
  - Total credits available
  - Buttons: "Upgrades" | "Main Menu" | "Retry"

### 3.3 ScoreManager Extension
- Track all session statistics
- Emit `session_ended` signal with full stats dictionary
- Calculate and award credits

## Integration Points
- GameManager shows game over screen when player dies
- Credits added to SaveSystem total
- Transition to upgrade shop or retry

## Extensibility
- Multipliers from items (luck stat)
- Bonus challenges for extra credits
- Daily rewards, login bonuses

## Testing Checklist
- [ ] Credits calculated correctly
- [ ] Game over screen shows all stats
- [ ] Credits persist to next session
- [ ] Can restart or go to upgrades from game over

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
