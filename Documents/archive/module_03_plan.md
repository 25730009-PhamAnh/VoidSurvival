# Implementation Plan: Module 3 - Credit Economy & Post-Game Flow

**Created**: 2026-01-04
**Module**: Module 3 (Credit Economy & Post-Game Flow)
**Priority**: High
**Dependencies**: Module 1 (Resource System), Module 2 (Save System)
**Estimated Duration**: 2-3 days

---

## Overview

This plan implements the post-game reward system that converts in-game performance into persistent currency. It bridges the gap between gameplay sessions and the upgrade economy by:
1. Tracking detailed session statistics (accuracy, time survived, enemies destroyed)
2. Calculating credit rewards with bonuses for good performance
3. Presenting a polished game over screen with reward breakdown
4. Providing clear navigation options (Retry, Upgrades, Main Menu)

This creates the psychological reward loop: Play → Perform well → Earn credits → Feel motivated to upgrade → Play again.

---

## Phase 1: Session Statistics Tracking

### 1.1 Create SessionManager Singleton

**File**: `scripts/autoload/session_manager.gd`

**Purpose**: Track all statistics for the current play session

**Signals**:
```gdscript
signal session_ended(stats: Dictionary)
signal accuracy_changed(accuracy: float)
```

**Properties**:
```gdscript
# Combat stats
var shots_fired: int = 0
var shots_hit: int = 0
var asteroids_destroyed: int = 0
var enemies_destroyed: int = 0  # Future: for Module 6

# Resource stats
var crystals_collected: int = 0
var total_damage_taken: float = 0.0

# Time stats
var survival_time: float = 0.0
var session_start_time: float = 0.0

# Calculated stats
var accuracy: float = 0.0:
	get:
		if shots_fired == 0:
			return 0.0
		return (float(shots_hit) / float(shots_fired)) * 100.0
```

**Key Methods**:
```gdscript
func start_session() -> void:
	# Reset all stats to 0
	shots_fired = 0
	shots_hit = 0
	asteroids_destroyed = 0
	enemies_destroyed = 0
	crystals_collected = 0
	total_damage_taken = 0.0
	survival_time = 0.0
	session_start_time = Time.get_ticks_msec() / 1000.0

func end_session() -> Dictionary:
	# Calculate final stats
	var final_stats = {
		"survival_time": survival_time,
		"asteroids_destroyed": asteroids_destroyed,
		"enemies_destroyed": enemies_destroyed,
		"crystals_collected": crystals_collected,
		"shots_fired": shots_fired,
		"shots_hit": shots_hit,
		"accuracy": accuracy,
		"damage_taken": total_damage_taken,
		"credits_earned": calculate_credits()
	}
	session_ended.emit(final_stats)
	return final_stats

func calculate_credits() -> int:
	# Base credits from crystals (already collected via ResourceManager)
	var base_credits = crystals_collected

	# Time bonus: 1 credit per 10 seconds survived
	var time_bonus = int(survival_time / 10.0)

	# Destruction bonus: 1 credit per 10 asteroids (+ 5x for enemies later)
	var destruction_bonus = int((asteroids_destroyed + enemies_destroyed * 5) / 10.0)

	# Accuracy bonus: Up to 50 credits for 100% accuracy
	var accuracy_bonus = int(accuracy * 0.5)

	return base_credits + time_bonus + destruction_bonus + accuracy_bonus

func record_shot_fired() -> void:
	shots_fired += 1

func record_shot_hit() -> void:
	shots_hit += 1
	accuracy_changed.emit(accuracy)

func record_asteroid_destroyed() -> void:
	asteroids_destroyed += 1

func record_enemy_destroyed() -> void:
	enemies_destroyed += 1

func record_crystal_collected(amount: int) -> void:
	crystals_collected += amount

func record_damage_taken(amount: float) -> void:
	total_damage_taken += amount

func update_survival_time(delta: float) -> void:
	survival_time += delta
```

**Integration**:
- Register as autoload in `project.godot`: `SessionManager` at `res://scripts/autoload/session_manager.gd`

### 1.2 Integrate SessionManager with Existing Systems

**File**: `scripts/game_manager.gd` (modify)

**Changes**:
```gdscript
func _ready() -> void:
	# ... existing code ...
	SessionManager.start_session()

func _process(delta: float) -> void:
	if is_playing:
		current_run_time += delta
		SessionManager.update_survival_time(delta)  # NEW

func add_score(amount: int) -> void:
	current_score += amount
	total_asteroids_destroyed += 1
	SessionManager.record_asteroid_destroyed()  # NEW
	score_updated.emit(current_score)

func restart_game() -> void:
	ResourceManager.reset_crystals()
	SessionManager.start_session()  # NEW: Reset session stats
	get_tree().reload_current_scene()
```

**File**: `scripts/player.gd` (modify)

**Changes**:
```gdscript
func _fire() -> void:
	if not projectile_scene:
		push_error("Player: projectile_scene not set!")
		return

	_fire_timer = FIRE_RATE
	SessionManager.record_shot_fired()  # NEW

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.global_rotation = global_rotation
	get_parent().add_child(projectile)

func take_damage(amount: float) -> void:
	current_shield -= amount
	SessionManager.record_damage_taken(amount)  # NEW
	shield_changed.emit(current_shield, max_shield)

	if current_shield <= 0:
		died.emit()
		queue_free()
	else:
		_invincibility_timer = INVINCIBILITY_TIME

func _on_item_collected(item: Node2D, value: int) -> void:
	if item.has_signal("collected"):
		item.collected.emit(value)
	ResourceManager.add_crystals(value)
	SessionManager.record_crystal_collected(value)  # NEW
```

**File**: `scripts/projectile.gd` (modify)

**Add to _on_body_entered method**:
```gdscript
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		SessionManager.record_shot_hit()  # NEW
		queue_free()
```

---

## Phase 2: Game Over Screen UI

### 2.1 Create Game Over Screen Scene

**File**: `scenes/ui/game_over_screen.tscn`

**Purpose**: Professional end-game screen with stats breakdown and navigation

**Scene Structure**:
```
GameOverScreen (CanvasLayer)
└── CenterContainer
    └── PanelContainer
        └── MarginContainer (margins: 40px all sides)
            └── VBoxContainer (spacing: 20)
                ├── TitleLabel (Label)
                │   └── Text: "GAME OVER"
                │   └── Theme: Large title font, centered
                ├── HSeparator
                ├── StatsContainer (VBoxContainer, spacing: 10)
                │   ├── SurvivalTimeLabel (Label) - "Survived: {time}"
                │   ├── ScoreLabel (Label) - "Score: {score}"
                │   ├── AccuracyLabel (Label) - "Accuracy: {accuracy}%"
                │   ├── AsteroidsLabel (Label) - "Asteroids Destroyed: {count}"
                │   └── CrystalsLabel (Label) - "Crystals Collected: {count}"
                ├── HSeparator
                ├── CreditsContainer (VBoxContainer, spacing: 10)
                │   ├── CreditsBreakdownLabel (Label)
                │   │   └── Text: "CREDITS EARNED"
                │   ├── BaseCreditsLabel (Label) - "+ {crystals} (Crystals)"
                │   ├── TimeBonusLabel (Label) - "+ {bonus} (Survival Bonus)"
                │   ├── DestructionBonusLabel (Label) - "+ {bonus} (Combat Bonus)"
                │   ├── AccuracyBonusLabel (Label) - "+ {bonus} (Accuracy Bonus)"
                │   ├── HSeparator
                │   └── TotalCreditsLabel (Label)
                │       └── Text: "TOTAL: {total} Credits"
                │       └── Theme: Large, highlighted
                ├── TotalCreditsAvailableLabel (Label)
                │   └── Text: "Total Credits Available: {total}"
                │   └── Theme: Slightly smaller, subtle color
                ├── HSeparator
                └── ButtonsContainer (HBoxContainer, spacing: 20)
                    ├── RetryButton (Button) - "RETRY (R)"
                    ├── UpgradesButton (Button) - "UPGRADES (U)"
                    └── MainMenuButton (Button) - "MAIN MENU (ESC)"
```

**Unique Names**:
- `%TitleLabel`
- `%SurvivalTimeLabel`
- `%ScoreLabel`
- `%AccuracyLabel`
- `%AsteroidsLabel`
- `%CrystalsLabel`
- `%BaseCreditsLabel`
- `%TimeBonusLabel`
- `%DestructionBonusLabel`
- `%AccuracyBonusLabel`
- `%TotalCreditsLabel`
- `%TotalCreditsAvailableLabel`
- `%RetryButton`
- `%UpgradesButton`
- `%MainMenuButton`

**Visual Design Notes**:
- Use a semi-transparent dark background for the panel
- Add subtle padding and spacing for readability
- Use color coding:
  - Gold/yellow for credits and bonuses
  - Green for positive stats
  - White for neutral stats
- Button styling: Clear, prominent, with hover states

### 2.2 Create Game Over Screen Script

**File**: `scripts/ui/game_over_screen.gd`

**Purpose**: Populate stats and handle navigation

**Script**:
```gdscript
extends CanvasLayer

# Stats labels
@onready var survival_time_label: Label = %SurvivalTimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var accuracy_label: Label = %AccuracyLabel
@onready var asteroids_label: Label = %AsteroidsLabel
@onready var crystals_label: Label = %CrystalsLabel

# Credits breakdown labels
@onready var base_credits_label: Label = %BaseCreditsLabel
@onready var time_bonus_label: Label = %TimeBonusLabel
@onready var destruction_bonus_label: Label = %DestructionBonusLabel
@onready var accuracy_bonus_label: Label = %AccuracyBonusLabel
@onready var total_credits_label: Label = %TotalCreditsLabel
@onready var total_credits_available_label: Label = %TotalCreditsAvailableLabel

# Buttons
@onready var retry_button: Button = %RetryButton
@onready var upgrades_button: Button = %UpgradesButton
@onready var main_menu_button: Button = %MainMenuButton

var session_stats: Dictionary = {}


func _ready() -> void:
	# Connect button signals
	retry_button.pressed.connect(_on_retry_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Connect to SessionManager
	SessionManager.session_ended.connect(_on_session_ended)


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("restart"):
			_on_retry_pressed()
		elif event.is_action_pressed("ui_cancel"):  # ESC key
			_on_main_menu_pressed()
		elif event.is_action_pressed("ui_accept"):  # Enter key - go to upgrades
			_on_upgrades_pressed()


func _on_session_ended(stats: Dictionary) -> void:
	session_stats = stats
	_populate_stats(stats)
	show()


func _populate_stats(stats: Dictionary) -> void:
	# Format time as MM:SS
	var minutes = int(stats.survival_time) / 60
	var seconds = int(stats.survival_time) % 60
	survival_time_label.text = "Survived: %d:%02d" % [minutes, seconds]

	# Populate stats
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	var current_score = game_manager.current_score if game_manager else 0
	score_label.text = "Score: %d" % current_score
	accuracy_label.text = "Accuracy: %.1f%%" % stats.accuracy
	asteroids_label.text = "Asteroids Destroyed: %d" % stats.asteroids_destroyed
	crystals_label.text = "Crystals Collected: %d" % stats.crystals_collected

	# Calculate credit breakdown
	var base_credits = stats.crystals_collected
	var time_bonus = int(stats.survival_time / 10.0)
	var destruction_bonus = int((stats.asteroids_destroyed + stats.enemies_destroyed * 5) / 10.0)
	var accuracy_bonus = int(stats.accuracy * 0.5)
	var total_earned = stats.credits_earned

	# Populate credit breakdown
	base_credits_label.text = "+ %d (Crystals)" % base_credits
	time_bonus_label.text = "+ %d (Survival Bonus)" % time_bonus
	destruction_bonus_label.text = "+ %d (Combat Bonus)" % destruction_bonus
	accuracy_bonus_label.text = "+ %d (Accuracy Bonus)" % accuracy_bonus
	total_credits_label.text = "TOTAL: %d Credits" % total_earned

	# Show total available credits (after this session)
	total_credits_available_label.text = "Total Credits Available: %d" % ResourceManager.total_credits


func _on_retry_pressed() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.restart_game()


func _on_upgrades_pressed() -> void:
	# TODO: Implement in Module 4 - Load upgrade shop scene
	print("Upgrades button pressed - TODO: Implement upgrade shop scene")
	# For now, just show a placeholder message
	push_warning("Upgrades shop not yet implemented (Module 4)")


func _on_main_menu_pressed() -> void:
	# TODO: Implement in Module 12 - Load main menu scene
	print("Main menu button pressed - TODO: Implement main menu scene")
	# For now, just restart the game
	push_warning("Main menu not yet implemented (Module 12)")
	_on_retry_pressed()
```

---

## Phase 3: Integration & Polish

### 3.1 Replace Simple Game Over Panel

**File**: `scenes/ui/prototype_hud.tscn` (modify)

**Changes**:
1. Remove the existing `%GameOverPanel` (CenterContainer with simple text)
2. Add `GameOverScreen` scene as a child of the root CanvasLayer

**File**: `scripts/prototype_hud.gd` (modify)

**Changes**:
```gdscript
extends CanvasLayer

@onready var shield_bar: ProgressBar = %ShieldBar
@onready var score_label: Label = %ScoreLabel
@onready var crystal_label: Label = %CrystalLabel
# Remove: game_over_panel reference (handled by separate scene now)

func _ready() -> void:
	# Remove: game_over_panel.hide()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.shield_changed.connect(_on_shield_changed)
		# Remove: player.died.connect(_on_player_died)
	else:
		push_warning("HUD: No player found in scene!")

	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.score_updated.connect(_on_score_updated)
	else:
		push_warning("HUD: No game_manager found in scene!")

	ResourceManager.crystals_changed.connect(_on_crystals_changed)

func _on_shield_changed(current: float, maximum: float) -> void:
	shield_bar.value = (current / maximum) * 100.0

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_crystals_changed(current: int) -> void:
	crystal_label.text = "Crystals: %d" % current

# Remove: _on_player_died() method (handled by GameOverScreen now)
```

### 3.2 Update GameManager to Trigger Game Over Screen

**File**: `scripts/game_manager.gd` (modify)

**Changes**:
```gdscript
func _on_player_died() -> void:
	is_playing = false

	# End session and calculate credits
	var session_stats = SessionManager.end_session()  # NEW

	# Convert crystals to credits (this will save automatically)
	ResourceManager.convert_crystals_to_credits()

	# Save run stats (existing)
	_save_run_stats()

	# Note: game_over signal now triggers GameOverScreen via SessionManager.session_ended
	# game_over.emit()  # Keep this for any other listeners if needed
```

### 3.3 Add Input Actions for Navigation

**File**: `project.godot` (modify)

**Add new input actions**:
```gdscript
# In InputMap section, add:
"ui_accept" (if not already present): ENTER/RETURN key
"ui_cancel" (if not already present): ESC key
```

**Note**: These are usually already defined by Godot by default.

---

## Phase 4: Credit Earning Animation (Optional Polish)

### 4.1 Add Animated Credit Counter

**File**: `scripts/ui/game_over_screen.gd` (enhance)

**Add animation for credits counting up**:
```gdscript
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Add to scene

var _credits_animation_target: int = 0
var _credits_animation_current: float = 0.0
var _credits_animation_speed: float = 50.0  # Credits per second


func _process(delta: float) -> void:
	if _credits_animation_current < _credits_animation_target:
		_credits_animation_current += _credits_animation_speed * delta
		if _credits_animation_current >= _credits_animation_target:
			_credits_animation_current = _credits_animation_target
		total_credits_label.text = "TOTAL: %d Credits" % int(_credits_animation_current)


func _populate_stats(stats: Dictionary) -> void:
	# ... existing stats population ...

	# Animate credit counter
	_credits_animation_current = 0.0
	_credits_animation_target = stats.credits_earned

	# Start animation after a short delay
	await get_tree().create_timer(0.5).timeout
	set_process(true)
```

### 4.2 Add Screen Fade-In Animation

**File**: `scenes/ui/game_over_screen.tscn` (add AnimationPlayer)

**Add AnimationPlayer node with animation**:
- Animation: `fade_in` (0.5s duration)
  - Track: Modulate alpha (0.0 → 1.0)
  - Track: Position offset (slightly down → normal position)
- Auto-play on `_on_session_ended`

---

## Phase 5: Testing & Validation

### 5.1 Session Statistics Testing

- [ ] Shots fired count increases with each projectile
- [ ] Shots hit count increases only when projectile hits asteroid
- [ ] Accuracy calculates correctly (0% with no shots, 100% with all hits)
- [ ] Asteroids destroyed count matches score
- [ ] Crystals collected count matches ResourceManager
- [ ] Damage taken accumulates correctly
- [ ] Survival time tracks accurately

### 5.2 Credit Calculation Testing

- [ ] Base credits = crystals collected (1:1)
- [ ] Time bonus = survival_time / 10 (rounded down)
- [ ] Destruction bonus = asteroids_destroyed / 10 (rounded down)
- [ ] Accuracy bonus = accuracy * 0.5 (0% = 0 credits, 100% = 50 credits)
- [ ] Total credits calculation is correct sum of all bonuses
- [ ] Credits added to ResourceManager.total_credits
- [ ] Credits persist after game restart

### 5.3 Game Over Screen Testing

- [ ] Screen appears when player dies
- [ ] All stats display correctly formatted
- [ ] Credit breakdown shows all bonuses
- [ ] Total credits available shows updated amount (old + new)
- [ ] "Retry" button restarts game and resets stats
- [ ] "Upgrades" button shows placeholder message (Module 4)
- [ ] "Main Menu" button shows placeholder message (Module 12)
- [ ] Keyboard shortcuts work (R, U, ESC)
- [ ] Screen is visually polished and readable

### 5.4 Integration Testing

- [ ] Full game loop: Play → Die → See stats → See credits → Retry
- [ ] Credits persist across multiple sessions
- [ ] SessionManager resets correctly on restart
- [ ] No memory leaks from game over screen
- [ ] Game over screen doesn't block input inappropriately

---

## Phase 6: Polish & Extensibility

### 6.1 Visual Polish (Optional)

- [ ] Add color coding to credit bonuses (green for positive)
- [ ] Add icons next to stat labels
- [ ] Add subtle background animation/particles
- [ ] Add sound effects for credit counting
- [ ] Add "New Record!" banner for best survival time

### 6.2 Extensibility Hooks

**For Module 4 (Upgrade Shop)**:
- `_on_upgrades_pressed()` ready to load shop scene
- `ResourceManager.spend_credits()` already implemented

**For Module 6 (Enemy Variety)**:
- `enemies_destroyed` stat already tracked
- Credit formula already includes enemy multiplier (5x)

**For Module 12 (Main Menu)**:
- `_on_main_menu_pressed()` ready to load menu scene

**For Future Multipliers**:
```gdscript
# In SessionManager.calculate_credits(), add:
var luck_multiplier = 1.0  # TODO: Load from equipped items (Module 4)
return int((base_credits + time_bonus + destruction_bonus + accuracy_bonus) * luck_multiplier)
```

---

## Critical Files to Create

| File | Purpose |
|------|---------|
| `scripts/autoload/session_manager.gd` | Session statistics tracking singleton |
| `scenes/ui/game_over_screen.tscn` | Professional game over UI |
| `scripts/ui/game_over_screen.gd` | Game over screen logic and navigation |

---

## Critical Files to Modify

| File | Type | Changes |
|------|------|---------|
| `project.godot` | Config | Add SessionManager autoload |
| `scripts/game_manager.gd` | Modify | Integrate SessionManager, trigger session end |
| `scripts/player.gd` | Modify | Track shots fired, damage taken |
| `scripts/projectile.gd` | Modify | Track shots hit on collision |
| `scripts/prototype_hud.gd` | Modify | Remove simple game over panel logic |
| `scenes/ui/prototype_hud.tscn` | Modify | Remove GameOverPanel, add GameOverScreen instance |
| `scripts/autoload/resource_manager.gd` | Minimal | Already has credit conversion, may need signal enhancements |

---

## Dependencies & Prerequisites

**Required**:
- Module 1 (Resource System): ResourceManager for credits ✅
- Module 2 (Save System): SaveSystem for persistence ✅

**Godot Version**: 4.5+

**External Dependencies**: None

---

## Risk Mitigation

**Potential Issues**:
1. **Stats tracking out of sync**: Multiple systems tracking same data differently
2. **Credit calculation too generous/stingy**: Balance needs playtesting
3. **UI too cluttered**: Too much information on game over screen
4. **Navigation confusion**: Players don't know what buttons do

**Mitigation Strategies**:
- Use SessionManager as single source of truth for session stats
- Make credit formula constants easy to tweak (@export variables)
- Use clear visual hierarchy and spacing in UI
- Add clear button labels with keyboard shortcuts
- Playtest credit earning rates and adjust bonuses

---

## Completion Criteria

**Module 3 Complete When**:
- ✅ SessionManager tracks all session stats accurately
- ✅ Credit calculation formula works with bonuses
- ✅ Game over screen displays all stats and breakdown
- ✅ Credits persist correctly across sessions
- ✅ Navigation buttons work (Retry functional, others show placeholders)
- ✅ All testing checklists passed
- ✅ No critical bugs or UI issues
- ✅ Code follows Godot best practices (CLAUDE.md compliance)

---

## Next Steps After Completion

After Module 3 is complete:
- **Module 4**: Upgrade shop UI where players spend credits
- **Module 5**: Stat tracking UI to see lifetime achievements
- The credit economy will be fully connected: Earn → Display → Persist → Spend

The psychological reward loop will be complete, motivating players to keep improving their performance to earn more credits.

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
