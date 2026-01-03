# Game Design Document: Void Survivor

## 1. Game Overview

### Description

Void Survivor is a 2D arcade-style shooter/survival game where players control a small spaceship navigating an endless void of space, battling asteroids, black holes, and enemy entities. Drawing inspiration from Asteroids, the game emphasizes reactive shooting, inertia-based movement, and strategic survival. Players collect resources to upgrade their ship, adding depth through tactical choices. The core loop involves shooting hazards, avoiding collisions, and surviving waves of increasing difficulty in an endless mode. The game is designed for mobile platforms, with short, intense sessions that reward skill and planning.

### Key Features

- **Endless Survival Mode**: No fixed levels; survive as long as possible with escalating challenges.
- **Infinite Progression System**: Endless upgrade paths and difficulty scaling through parameter-based systems.
- **Dual Upgrade System**: Temporary in-game pickups for immediate buffs and permanent post-game upgrades for meta-progression.
- **Minimalist Space Theme**: Procedural hazards like asteroids, black holes, and enemies create dynamic replayability.
- **Target Audience**: Ages 8-17 (easy entry for kids, strategic depth for teens).
- **Genre**: Shooter/Survival (Arcade).
- **Platforms**: Primarily mobile (iOS/Android), with potential PC port.
- **Unique Selling Points (USPs)**: Simple controls with deep customization; nostalgic Asteroids feel with modern progression; infinite scaling for endless replayability.

### Objectives

- Create an addictive survival experience that balances frustration and achievement.
- Ensure accessibility for younger players while offering tactical variety for older ones.
- Achieve high replayability through procedural elements and upgrades, targeting 50+ hours of total playtime per user.

## 2. Core Gameplay Mechanics

### Core Loop

1. **Spawn and Engage**: The player starts in the center of the screen with a basic ship. Asteroids and enemies spawn procedurally.
2. **Maneuver and Shoot**: Use inertia-based movement to navigate, shoot to destroy hazards, and collect resources.
3. **Survive and Adapt**: Dodge dynamic threats (e.g., black holes sucking in objects); pick up temporary buffs.
4. **Dynamic Difficulty**: Game difficulty automatically adjusts based on player performance - increases when player is doing well, decreases when struggling to create natural breathing moments.
5. **End and Progress**: Game over on ship destruction; convert performance to credits for permanent upgrades.

### Key Mechanics

#### Ship Controls
- Inertia physics (Unity Rigidbody2D) – thrust forward/backward, rotate left/right
- Screen wrap-around (exiting one edge re-enters opposite)
- Hyperspace jump (random teleport, with risk of landing near hazards)

#### Shooting
- Fire lasers (line projectiles) to break asteroids into smaller, faster fragments
- Enemies require precise aiming

#### Hazards
- **Asteroids**: Large polygons that split into smaller ones on hit; random trajectories
- **Black Holes**: Randomly spawn (every 30-60 seconds); apply gravitational pull (AddForce) to all objects, including the ship. Can be "overloaded" by sucking in enough asteroids to despawn
- **Enemies**: UFOs (squares that shoot back) and comets (triangles with high-speed charges). Spawn frequency increases over time

#### Resource Collection
- Void crystals (small circles) drop from destroyed objects; auto-collect on proximity

#### Shield and Failure
- Shield system with energy bar that depletes on damage (collisions, enemy fire, black hole exposure)
- Shield regenerates slowly when not taking damage (modern auto-heal concept)
- Shield can be upgraded for more capacity and faster regeneration
- Game over when shield is completely depleted

#### Dynamic Difficulty System
- **Difficulty Meter**: Invisible system that tracks player performance (survival time, accuracy, crystals collected)
- **Scaling Up**: When player performs well (high accuracy, minimal damage taken), gradually increase spawn rate, enemy speed, and hazard density
- **Scaling Down**: When player struggles (low shield, sustained damage, poor accuracy), reduce spawn rate and hazard intensity to provide breathing room and shield regeneration time
- **Smooth Transitions**: Difficulty adjusts continuously over 15-30 second intervals, creating organic difficulty curves without obvious breaks
- **No Rest Periods**: Players never get forced pauses; difficulty ebbs and flows naturally based on their skill and current state

### Win/Loss Conditions

- **Win**: No traditional win; high score from survival time, destructions, and crystals collected
- **Loss**: Shield fully depleted; triggers post-game menu for upgrades

### Objectives

- Balance mechanics for fairness: Ensure inertia feels intuitive but challenging; hazards scale without overwhelming new players
- Test for fun factor: Aim for 80% player retention after first session through satisfying destruction feedback (e.g., particle explosions)

## 3. Infinite Progression Parameter System

### Overview

Void Survivor features an **infinite progression system** where ship stats, upgrades, and enemy difficulty can scale endlessly. Unlike traditional games with level caps, this system uses mathematical formulas to calculate power levels, ensuring balanced gameplay at any stage while providing meaningful long-term goals. The system is built on three interconnected parameter frameworks: **Ship Parameters**, **Item Parameters**, and **Enemy Parameters**.

### Design Philosophy

- **No Artificial Caps**: Players can upgrade indefinitely; progression rate slows naturally through exponential cost scaling
- **Balanced Power Curve**: Each upgrade provides diminishing but always meaningful returns
- **Predictable Math**: All calculations use transparent formulas that players can understand and optimize
- **Endless Challenge**: Enemy difficulty scales infinitely to match player power, maintaining engagement
- **Strategic Depth**: Multiple stat paths allow diverse builds even at high progression levels

### Ship Parameters (Character Stats)

The player's ship has core parameters that govern all gameplay interactions. Each parameter can be upgraded infinitely using a base + scaling formula.

#### Core Ship Parameters

| Parameter | Symbol | Base Value | Effect | Upgrade Formula |
|-----------|--------|------------|--------|-----------------|
| **Max Shield** | `S_max` | 100 | Total shield capacity | `S_max = 100 + (Level × 20)` |
| **Shield Regen Rate** | `S_regen` | 5/sec | Shield restored per second | `S_regen = 5 + (Level × 0.5)` |
| **Shield Regen Delay** | `S_delay` | 3 sec | Time before regen starts | `S_delay = 3 - (Level × 0.1)` (min 0.5s) |
| **Move Speed** | `M_speed` | 5 u/s | Base movement velocity | `M_speed = 5 + (Level × 0.3)` |
| **Acceleration** | `M_accel` | 10 u/s² | Thrust responsiveness | `M_accel = 10 + (Level × 0.5)` |
| **Fire Rate** | `W_rate` | 2/sec | Shots fired per second | `W_rate = 2 + (Level × 0.1)` |
| **Projectile Damage** | `W_damage` | 10 | Base damage per shot | `W_damage = 10 × (1 + Level × 0.15)` |
| **Projectile Speed** | `W_speed` | 15 u/s | Shot travel velocity | `W_speed = 15 + (Level × 0.2)` |
| **Collection Radius** | `C_radius` | 2 units | Crystal auto-collect range | `C_radius = 2 + (Level × 0.15)` |
| **Luck** | `L_factor` | 1.0x | Pickup/reward multiplier | `L_factor = 1.0 + (Level × 0.05)` |

#### Ship Level System

Players don't upgrade individual stats directly. Instead, they purchase **upgrade points** that are allocated to different stat categories:

- **Defensive Points**: Applied to Shield parameters (Max, Regen, Delay)
- **Mobility Points**: Applied to Movement parameters (Speed, Acceleration)  
- **Offensive Points**: Applied to Weapon parameters (Rate, Damage, Speed)
- **Utility Points**: Applied to Collection and Luck parameters

**Cost Scaling Formula:**
```
Point Cost = Base_Cost × (1.15 ^ Total_Points_Purchased)

Example:
- Point 1: 100 credits
- Point 10: 405 credits
- Point 50: 108,366 credits
- Point 100: 13.2 million credits
```

This exponential scaling ensures:
- Early progression feels rewarding
- Mid-game requires strategic resource allocation
- Late-game progression is always possible but requires dedication

### Item Parameters (Upgrade System)

Items (permanent upgrades) are modular bonuses that modify ship parameters. Unlike the previous fixed-level system, items now have **infinite levels** with diminishing returns.

#### Item Structure

Each item has:
- **Base Effect**: Starting bonus at Level 1
- **Scaling Type**: Linear, multiplicative, or exponential
- **Cost Progression**: How expensive each level becomes
- **Synergy Tags**: Which stats or other items it interacts with

#### Example Items with Infinite Scaling

##### Defensive Items

**Energy Amplifier** (Shield Capacity)
- Base Effect: +25% Max Shield
- Formula: `Bonus = 25% + (Level × 2%)`
- Level 1: +25% | Level 10: +43% | Level 50: +125% | Level 100: +225%
- Cost: `100 × (1.12 ^ Level)`
- Synergy: Works multiplicatively with base Shield stat

**Nano-Repair System** (Shield Regeneration)
- Base Effect: +30% Shield Regen Rate
- Formula: `Bonus = 30% + (Level × 1.5%)`
- Level 1: +30% | Level 10: +43.5% | Level 50: +105% | Level 100: +180%
- Cost: `150 × (1.13 ^ Level)`

**Reactive Armor** (Damage Reduction)
- Base Effect: 5% damage reduction
- Formula: `Reduction = 5% + (Level × 0.4%)` (max 75%)
- Level 1: 5% | Level 10: 9% | Level 50: 25% | Level 100: 45%
- Cost: `180 × (1.14 ^ Level)`
- Note: Diminishing returns prevent invulnerability

##### Offensive Items

**Rapid Accelerator** (Fire Rate)
- Base Effect: +20% Fire Rate
- Formula: `Bonus = 20% + (Level × 1%)`
- Level 1: +20% | Level 10: +30% | Level 50: +70% | Level 100: +120%
- Cost: `120 × (1.12 ^ Level)`

**Plasma Infusion** (Damage Multiplier)
- Base Effect: +15% Damage
- Formula: `Bonus = 15% + (Level × 1.2%)`
- Level 1: +15% | Level 10: +27% | Level 50: +75% | Level 100: +135%
- Cost: `150 × (1.13 ^ Level)`

**Homing Tracker** (Adds Homing Missiles)
- Base Effect: 1 missile every 8 seconds
- Formula: `Missiles = 1 + floor(Level / 10)`, Cooldown = `8 - (Level × 0.05)` (min 3s)
- Level 1: 1 missile/8s | Level 20: 2 missiles/7s | Level 50: 5 missiles/5.5s
- Cost: `200 × (1.15 ^ Level)`

##### Utility Items

**Crystal Magnet** (Collection Range)
- Base Effect: +50% Collection Radius
- Formula: `Bonus = 50% + (Level × 2%)`
- Level 1: +50% | Level 10: +70% | Level 50: +150% | Level 100: +250%
- Cost: `90 × (1.10 ^ Level)`

**Fortune Matrix** (Luck/Rewards)
- Base Effect: +10% credit earning
- Formula: `Bonus = 10% + (Level × 0.8%)`
- Level 1: +10% | Level 10: +17.2% | Level 50: +50% | Level 100: +90%
- Cost: `160 × (1.14 ^ Level)`

#### Item Slot System Evolution

- **Starting Slots**: 4 slots (can equip 4 different items)
- **Unlockable Slots**: Purchase additional slots, cost scales exponentially
  - Slot 5: 1,000 credits
  - Slot 6: 5,000 credits
  - Slot 7: 25,000 credits
  - Slot 8: 100,000 credits
  - Slot 9+: `100,000 × (2 ^ (Slot - 8))` credits

Players must choose which items to equip and how many levels to invest in each. Late-game players might have:
- Few items at very high levels (specialist build)
- Many items at moderate levels (generalist build)

### Enemy Parameters (Difficulty Scaling)

Enemies scale infinitely based on **Difficulty Level**, which increases over time and player performance. All enemy stats are calculated from base values multiplied by difficulty modifiers.

#### Difficulty Level Calculation

```
Difficulty_Level = Base_Difficulty + Time_Factor + Performance_Factor

Time_Factor = Survival_Minutes × 0.5
Performance_Factor = (Player_Power_Rating / 100) × 10

Player_Power_Rating = Total_Upgrade_Points_Spent + Item_Power_Sum
Item_Power_Sum = Sum of (Item_Level × Item_Weight) for all equipped items
```

This ensures:
- Difficulty increases naturally over time
- Strong players face proportionally harder challenges
- Dynamic difficulty adjustments still apply (from Section 3)

#### Enemy Types and Parameter Scaling

##### Asteroid Parameters

| Parameter | Base Value | Scaling Formula |
|-----------|------------|-----------------|
| Health | 30 HP | `30 × (1 + Difficulty_Level × 0.1)` |
| Speed | 2 u/s | `2 × (1 + Difficulty_Level × 0.05)` |
| Fragment Count | 3 | `3 + floor(Difficulty_Level / 20)` |
| Spawn Rate | 1 per 2s | `1 per (2 - min(Difficulty_Level × 0.01, 1.5))` |

**Example Scaling:**
- Difficulty 0: 30 HP, 2 u/s, 3 fragments
- Difficulty 50: 180 HP, 7 u/s, 5 fragments
- Difficulty 100: 330 HP, 12 u/s, 8 fragments

##### Enemy UFO Parameters

| Parameter | Base Value | Scaling Formula |
|-----------|------------|-----------------|
| Health | 100 HP | `100 × (1 + Difficulty_Level × 0.15)` |
| Speed | 3 u/s | `3 × (1 + Difficulty_Level × 0.06)` |
| Fire Rate | 1 per 3s | `1 per (3 - min(Difficulty_Level × 0.015, 2))` |
| Shot Damage | 20 | `20 × (1 + Difficulty_Level × 0.12)` |
| Accuracy | 40% | `40% + min(Difficulty_Level × 0.3%, 45%)` (max 85%) |

**Example Scaling:**
- Difficulty 0: 100 HP, 3 u/s, 40% accuracy, 20 damage
- Difficulty 50: 850 HP, 12 u/s, 55% accuracy, 140 damage
- Difficulty 100: 1600 HP, 21 u/s, 70% accuracy, 260 damage

##### Enemy Comet Parameters

| Parameter | Base Value | Scaling Formula |
|-----------|------------|-----------------|
| Health | 60 HP | `60 × (1 + Difficulty_Level × 0.12)` |
| Charge Speed | 8 u/s | `8 × (1 + Difficulty_Level × 0.08)` |
| Collision Damage | 40 | `40 × (1 + Difficulty_Level × 0.15)` |
| Charge Frequency | 1 per 8s | `1 per (8 - min(Difficulty_Level × 0.04, 5))` |

##### Black Hole Parameters

| Parameter | Base Value | Scaling Formula |
|-----------|------------|-----------------|
| Pull Strength | 5 force | `5 × (1 + Difficulty_Level × 0.08)` |
| Pull Radius | 10 units | `10 × (1 + Difficulty_Level × 0.03)` |
| Duration | 30s | `30 + (Difficulty_Level × 0.5)` |
| Spawn Frequency | Every 60s | `Every (60 - min(Difficulty_Level × 0.3, 35))` |

#### Enemy Tier System

At certain difficulty thresholds, new enemy variants appear with enhanced abilities:

- **Tier 1** (Difficulty 0-30): Basic enemies
- **Tier 2** (Difficulty 31-70): Elite variants with +50% stats, special abilities
- **Tier 3** (Difficulty 71-120): Champion variants with +150% stats, unique mechanics
- **Tier 4** (Difficulty 121+): Boss-class enemies with multiple phases

### Parameter Balance System

To prevent runaway power scaling, the game uses **soft caps** and **efficiency curves**:

#### Diminishing Returns Formula

For any stat upgrade:
```
Actual_Benefit = Base_Benefit × (1 / (1 + Total_Investment × 0.01))

Example (Damage):
- First 100 points: ~95% efficiency
- Points 100-200: ~75% efficiency  
- Points 200+: ~50% efficiency
```

This ensures:
- Early upgrades feel impactful
- Late-game requires diversification
- No single stat becomes dominant

#### Power Rating Balance

The game tracks player **Effective Power** vs. **Enemy Power** to maintain challenge:

```
Player_Effective_Power = (Ship_Stats × Item_Multipliers) × Skill_Factor
Enemy_Effective_Power = Base_Enemy_Stats × Difficulty_Multiplier

Target_Ratio = Player_Effective_Power / Enemy_Effective_Power = 1.2 to 1.5
```

If ratio exceeds 1.5, difficulty scales faster. If below 1.2, difficulty scaling slows. This creates a dynamic equilibrium.

### Infinite Progression Goals

#### Short-Term (Runs 1-50)
- Focus on unlocking item slots
- Level items to 10-20
- Reach Difficulty Level 50
- Experiment with different item combinations

#### Mid-Term (Runs 51-200)
- Level key items to 50+
- Unlock all 8+ item slots
- Reach Difficulty Level 100
- Perfect specialized builds

#### Long-Term (Runs 201+)
- Level items to 100+
- Min-max specific builds for high-score runs
- Reach Difficulty Level 200+
- Compete on leaderboards for highest difficulty survived

#### Prestige System (Optional)

At Difficulty Level 100+, players can choose to **Prestige**:
- Reset all upgrades and difficulty
- Gain **Prestige Points** (1 per 10 Difficulty Levels achieved)
- Prestige Points provide permanent 1% bonuses to all stats per point
- Allows infinite meta-progression: `Effective_Power × (1 + Prestige_Points × 0.01)`

### Implementation Considerations

**Performance Optimization:**
- Pre-calculate lookup tables for common levels (1-1000)
- Cache player power calculations
- Update enemy parameters only when difficulty level changes significantly

### Player Communication

Display key information transparently:
- **Ship Stats Screen**: Show current values with formulas
- **Item Details**: Display exact bonus at current level + next level preview
- **Difficulty Indicator**: Show current Difficulty Level and what it means for enemies
- **Upgrade Calculator**: Let players simulate investment outcomes before spending

## 4. Dynamic Difficulty System (Core Feature)

### Overview

The Dynamic Difficulty System is the heart of Void Survivor's gameplay experience. Unlike traditional wave-based games with fixed difficulty spikes, this system continuously adapts to player performance in real-time, creating a personalized challenge curve that keeps players in an optimal "flow state." The system ensures that skilled players face escalating threats while struggling players get natural breathing room - all without artificial pauses or obvious breaks in action.

### Philosophy

- **Invisible Adaptation**: Players should never notice the system working; difficulty changes feel organic and natural
- **Skill-Based Scaling**: Challenge matches player skill level dynamically, not just time survived
- **No Punishment**: Lower difficulty isn't a penalty - it's strategic breathing room for shield regeneration and resource collection
- **Continuous Engagement**: Zero downtime; the game flows from calm to intense and back seamlessly

### Performance Metrics Tracked

The system monitors multiple data points every 5-10 seconds to assess player performance:

#### Primary Metrics
- **Survival Time**: How long the player has stayed alive in current session
- **Shield Status**: Current shield percentage (critical when below 30%)
- **Damage Rate**: How frequently the player is taking hits (hits per minute)
- **Accuracy**: Shot accuracy percentage (hits vs. misses)
- **Crystal Collection Rate**: Crystals collected per minute
- **Destruction Count**: Asteroids and enemies destroyed per minute

#### Secondary Metrics
- **Movement Patterns**: Erratic movement suggests panic; smooth movement suggests control
- **Hyperspace Usage**: Frequent emergency jumps indicate struggle
- **Near-Miss Count**: Close calls without damage (indicates skill)
- **Black Hole Survivability**: Successfully avoiding or overloading black holes

### Difficulty States

The system operates on a continuous scale from 0-100, divided into states:

- **0-20 (Beginner)**: Minimal threats; slow asteroids; rare enemies; extended shield regen
- **21-40 (Learning)**: Moderate spawn rates; introduction of black holes; basic enemy patterns
- **41-60 (Balanced)**: Standard challenge level; mixed hazards; typical game flow
- **61-80 (Intense)**: High spawn rates; faster enemies; frequent black holes; tighter dodge windows
- **81-100 (Extreme)**: Maximum chaos; dense asteroid fields; aggressive enemies; overlapping hazards

### Scaling Mechanics

#### Scaling Up (Player Performing Well)
**Triggers:**
- Shield above 70% for 30+ seconds
- High accuracy (>60%)
- Consistent crystal collection
- No damage taken in 15+ seconds

**Adjustments (Applied Gradually Over 15-30 Seconds):**
- Spawn rate: +5-15% more asteroids and enemies
- Speed multiplier: +5-10% to object velocities
- Black hole frequency: -10 seconds to spawn timer
- Enemy aggression: Tighter aim, faster projectiles
- Hazard density: More objects on screen simultaneously

#### Scaling Down (Player Struggling)
**Triggers:**
- Shield below 30%
- Taking damage 3+ times in 10 seconds
- Low accuracy (<30%)
- Frequent hyperspace usage (3+ in 20 seconds)
- Zero crystal collection in 30 seconds

**Adjustments (Applied Quickly Over 10-15 Seconds):**
- Spawn rate: -20-30% fewer hazards
- Speed multiplier: -10-15% slower objects
- Black hole frequency: +20 seconds to spawn timer
- Enemy aggression: Reduced aim accuracy, slower fire rate
- Safe zones: Increased space between hazard clusters
- Shield regen: +20% faster regeneration rate during low difficulty

### Parameters Affected

| Parameter | Low Difficulty | Medium Difficulty | High Difficulty |
|-----------|---------------|-------------------|-----------------|
| Asteroid Spawn Rate | 1 every 3-4s | 1 every 1.5-2s | 2-3 every 1s |
| Asteroid Speed | 0.5-1.5 units/s | 1.0-2.5 units/s | 2.0-4.0 units/s |
| Enemy Spawn Rate | 1 every 45-60s | 1 every 25-35s | 1 every 10-15s |
| Enemy Accuracy | 30-40% | 50-60% | 70-85% |
| Black Hole Frequency | Every 90-120s | Every 50-70s | Every 30-40s |
| Black Hole Pull Strength | 0.5x | 1.0x | 1.5x |
| Shield Regen Delay | 2 seconds | 3 seconds | 4 seconds |
| Shield Regen Rate | 15%/s | 10%/s | 7%/s |
| Max Objects On Screen | 8-12 | 15-25 | 30-50 |

### Implementation Details

#### Difficulty Calculation Formula
```
Current Difficulty = Base Difficulty + Performance Modifier + Time Modifier

Performance Modifier = 
  (Accuracy × 0.3) + 
  (Survival Rate × 0.4) + 
  (Crystal Rate × 0.2) + 
  (Destruction Rate × 0.1)

Time Modifier = Min(30, Survival Minutes × 2)
// Adds +2 difficulty per minute, capped at +30

Survival Rate = (Current Shield / Max Shield) × 100
```

#### Update Frequency
- Metrics sampled every 5 seconds
- Difficulty recalculated every 10 seconds
- Parameter adjustments applied smoothly over 15-30 second windows (using Lerp)
- Emergency scaling (shield < 20%) activates immediately

#### Smoothing and Transitions
- Use Unity's `Mathf.Lerp()` for gradual parameter changes
- Avoid sudden jumps; maximum change per update cycle: ±5 difficulty points
- Hysteresis: Require sustained performance before major shifts (prevents yo-yo effect)
- Cool-down: After major difficulty drop, wait 20 seconds before scaling back up

### Balancing Goals

- **Target Difficulty Range**: Keep average players between 40-60 difficulty for majority of playtime
- **Time in Flow**: Aim for 70%+ of session time in "balanced" state (41-60 difficulty)
- **Max Difficulty Threshold**: Even extreme players shouldn't exceed 95 difficulty (leave room for challenge)
- **Min Difficulty Floor**: Never drop below 15 difficulty (game should always have some threat)
- **Shield Management**: Ensure players at low difficulty can regenerate to 50%+ shield before ramping back up

### Player Experience Goals

- **Perceived Fairness**: Deaths should feel earned, not cheap or random
- **Reward Skill**: Better players face harder challenges but earn more points/crystals
- **Support Learning**: New players get time to learn mechanics without overwhelming pressure
- **Encourage Risk-Taking**: Brief difficulty drops reward aggressive play (destroy more = collect more)
- **Session Length**: System should naturally extend sessions to 5-15 minutes for average players

### Testing and Tuning

- **Playtest Targets**: Test with players of varying skill levels (beginner, intermediate, advanced)
- **Data Collection**: Track average difficulty levels, session lengths, and player satisfaction
- **Iteration Points**: 
  - Adjust scaling sensitivity if difficulty swings too wildly
  - Tune thresholds if players feel too safe or too pressured
  - Balance shield regen rates with difficulty scaling for optimal flow
- **Success Metrics**: 
  - 80%+ players survive past 2 minutes
  - Average session length: 7-10 minutes
  - Player reports feeling "challenged but fair"

## 5. Story and Setting

### Narrative Overview

Void Survivor has a minimal, emergent story to keep focus on gameplay. Players are a lone explorer in the "Endless Void," a procedurally generated expanse of space filled with ancient asteroids and anomalous black holes. As survival progresses, subtle lore hints (e.g., via upgrade descriptions) reveal a backstory: The void is a remnant of a cosmic cataclysm, and collecting crystals uncovers "artifacts" that enhance the ship, implying a quest for escape or mastery.

### Setting

- **World**: Infinite 2D space arena (procedural generation for asteroid/enemy placement)
- **Background**: Black void with faint star dots and nebula clouds (procedural gradients)
- **Atmosphere**: Tense, exploratory isolation – no allies, just survival against cosmic forces
- **Progression Tie-In**: Upgrades unlock "log entries" (short text pop-ups) that expand lore, e.g., "This shield artifact was forged in a black hole's core."

### Objectives

- Keep story lightweight to avoid distracting from arcade feel; use it to motivate progression (e.g., "Unlock all logs" achievement)
- Ensure lore is age-appropriate: Adventurous and wondrous, no dark themes

## 6. Art Style and Visual Themes

### Style

Minimalist vector art inspired by Asteroids – clean lines, basic shapes, and high contrast for readability on mobile screens. All assets use Unity primitives (no custom sprites needed).

### Visual Themes

#### Color Palette
- Black background with white/gray for ship and asteroids
- Red for enemies
- Blue/green for pickups
- Swirling purple for black holes

#### Key Assets
- **Ship**: White triangle with glow effects
- **Asteroids**: Gray polygons (large to small fragments)
- **Black Holes**: Black circles with distortion effects (particle pull visuals)
- **Enemies**: Red squares (UFOs) or elongated triangles (comets)
- **Pickups/Upgrades**: Colored circles or icons (e.g., shield as square overlay)
- **Effects**: Particle systems for explosions (shape fragments); screen shake on impacts; glow shaders for buffs

### Objectives

- Maintain performance: Limit to low-poly assets for 60 FPS on mid-range devices
- Enhance immersion: Use procedural generation for varied visuals per run, ensuring accessibility (high contrast for color-blind modes)

## 7. Sound Design

### Audio Style

Retro arcade sounds with a cosmic twist – beeps, whooshes, and ambient space hums. Minimalist to match visuals; no voice acting.

### Key Sounds

- **SFX**: Laser shot (high-pitched beep); explosion (low rumble); black hole suck (distorted whoosh); pickup collect (chime); enemy spawn (alert tone)
- **Music**: Looping ambient tracks (synth waves) that intensify with difficulty (faster tempo after 5 minutes). 3-5 tracks for variety
- **Volume Controls**: Adjustable SFX/music sliders; haptic feedback for impacts on mobile

### Objectives

- Create tension: Audio cues for hazards (e.g., warning beep for black hole spawn)
- Source Assets: Use free Unity Asset Store packs or royalty-free libraries; aim for immersive but non-intrusive audio

## 8. User Interface and Controls

### UI Elements

- **HUD**: Top: Score/timer; Bottom: Shield energy bar (visual gradient from blue to red), crystal count; Mini-map for black hole warnings
- **Menus**: Main menu (play, upgrades, settings); Post-game: Score summary, credit earnings, upgrade shop
- **Upgrade Shop**: Grid-based with slots (e.g., weapon icons); tooltips showing pros/cons

### Controls

- **Mobile Touch**: Virtual joystick for rotation/thrust; tap to shoot; double-tap for hyperspace
- **Accessibility**: Customizable sensitivity; auto-fire option for younger players

### Objectives

- Intuitive Design: Ensure 90% of players understand controls in <1 minute (tutorial pop-ups)
- Clean Layout: No clutter; responsive for various screen sizes

## 9. Progression and Rewards Systems

### Overview

Void Survivor features a dual-layer upgrade system that provides both immediate tactical choices during gameplay and long-term strategic progression between sessions. This creates a compelling loop where players make meaningful decisions moment-to-moment while building toward permanent improvements.

### In-Game Upgrades (Temporary Power-Ups)

Temporary upgrades spawn as collectible pickups during gameplay, offering short-term advantages with strategic trade-offs. Players must decide whether the risk of collection is worth the temporary benefit.

#### Pickup Mechanics
- **Spawn Frequency**: 1-2 pickups per minute (based on difficulty level)
- **Spawn Location**: Drop from destroyed asteroids (20% chance), destroyed enemies (40% chance), or random spawn in empty space
- **Visual Indicator**: Glowing colored icons that pulse to attract attention
- **Collection**: Auto-collect when ship is within 2 units radius
- **Duration**: 30-60 seconds (displayed with countdown timer on HUD)
- **Stacking**: Multiple pickups can be active simultaneously (max 3 at once)

#### Available In-Game Upgrades

| Pickup Name | Icon Color | Effect | Pro | Con | Duration |
|-------------|-----------|--------|-----|-----|----------|
| **Speed Burst** | Yellow | +40% movement speed | Easier evasion, faster repositioning | Harder to control, overshooting targets | 45s |
| **Rapid Fire** | Orange | +100% fire rate | More destruction potential | Harder to aim, depletes ammo faster | 40s |
| **Shield Boost** | Cyan | +50% shield capacity | More survivability | False confidence may lead to risks | 60s |
| **Magnet Field** | Green | 3x collection radius | Easier crystal collection | May pull unwanted attention | 50s |
| **Time Warp** | Purple | 30% slow-motion | Easier dodging, better aim | Lower score multiplier during effect | 30s |
| **Explosive Rounds** | Red | Shots create AoE damage | Destroy multiple asteroids | Can damage yourself if too close | 35s |
| **Ghost Phase** | White | Pass through asteroids | Safe repositioning | Can't collect crystals while active | 20s |
| **Double Points** | Gold | 2x score/credits earned | Higher rewards | Attracts more enemy spawns | 45s |

#### Strategic Considerations
- **Risk vs. Reward**: High-value pickups spawn in dangerous locations (near black holes, dense asteroid fields)
- **Combo Potential**: Certain combinations are powerful (Speed Burst + Rapid Fire = mobile destroyer)
- **Situational Use**: Some pickups are better at high/low shield (Ghost Phase when critical, Explosive Rounds when safe)
- **Visual Clarity**: Active pickups show icons and timers on left side of HUD

### Post-Game Upgrades (Permanent Progression)

Permanent upgrades are purchased between gameplay sessions using Void Credits earned during runs. These create meaningful build variety through a limited-slot system that forces strategic choices.

#### Currency System
- **Void Credits**: Primary currency earned from gameplay
  - Base rate: 1 credit per second survived
  - Bonus: +2 credits per asteroid destroyed
  - Bonus: +5 credits per enemy destroyed
  - Bonus: +1 credit per crystal collected
  - Multiplier: +10% for consecutive runs without upgrade purchases (risk/reward)
  
- **Premium Crystals** (optional IAP): Used to unlock cosmetic skins or extra upgrade slots

#### Upgrade Slot System
- **Starting Slots**: 4 slots total (2 weapon, 1 defensive, 1 utility)
- **Unlockable Slots**: +2 additional slots (unlock at 500 and 2000 total credits spent)
- **Slot Types**: Each slot has a category restriction to prevent overpowered builds
- **Customization**: Players choose which upgrades to equip before each run

#### Permanent Upgrade Categories

##### Weapon Upgrades (2-3 Slots Available)

| Upgrade Name | Cost | Max Level | Effect Per Level | Description |
|--------------|------|-----------|------------------|-------------|
| **Homing Missiles** | 150 | 3 | Fires 1/2/3 missiles every 5s | Missiles track nearest enemy/asteroid |
| **Spread Shot** | 120 | 3 | +1/2/3 additional projectiles | Fan pattern, lower damage per shot |
| **Laser Beam** | 200 | 2 | Damage 50/100 per second | Continuous beam, drains energy |
| **Piercing Rounds** | 100 | 3 | Penetrate 1/2/3 targets | Shots go through asteroids |
| **Charge Cannon** | 180 | 2 | Hold to charge, 2x/3x damage | Slower fire rate, high burst |
| **Mine Launcher** | 130 | 3 | Deploy 1/2/3 proximity mines | Stationary traps, last 15s |

##### Defensive Upgrades (1-2 Slots Available)

| Upgrade Name | Cost | Max Level | Effect Per Level | Description |
|--------------|------|-----------|------------------|-------------|
| **Energy Shield** | 100 | 5 | +20/40/60/80/100% max shield | Higher capacity |
| **Rapid Regeneration** | 150 | 3 | +25/50/75% regen rate | Faster shield recovery |
| **Armor Plating** | 180 | 3 | -10/20/30% damage taken | Damage reduction |
| **Emergency Barrier** | 200 | 2 | Auto-shield at 20% HP (1/2 per run) | Prevents death once |
| **Deflector Field** | 160 | 2 | 20/40% chance to reflect projectiles | Enemy shots bounce back |

##### Utility Upgrades (1-2 Slots Available)

| Upgrade Name | Cost | Max Level | Effect Per Level | Description |
|--------------|------|-----------|------------------|-------------|
| **Thruster Boost** | 110 | 3 | +15/30/45% acceleration | Faster movement response |
| **Crystal Magnet** | 90 | 3 | +50/100/150% collection radius | Easier resource gathering |
| **Scanner Array** | 140 | 2 | Show hazards 5s/10s early | Warning for incoming threats |
| **Hyperspace Cooldown** | 120 | 3 | -20/40/60% jump cooldown | More frequent escapes |
| **Lucky Charm** | 170 | 3 | +10/20/30% pickup spawn rate | More temporary upgrades |
| **Score Multiplier** | 160 | 3 | +25/50/75% base score gain | Higher rewards |

#### Upgrade Progression Strategy

**Early Game Focus (0-500 credits):**
- Priority: Energy Shield (Level 1-2) for survivability
- Secondary: Crystal Magnet (Level 1) to earn credits faster
- Avoid: Expensive weapons until core defense is solid

**Mid Game Focus (500-2000 credits):**
- Diversify: Add 1-2 weapon upgrades (Homing Missiles or Piercing Rounds recommended)
- Unlock: Purchase 5th upgrade slot at 500 credits
- Balance: Maintain defensive/offensive ratio

**Late Game Focus (2000+ credits):**
- Specialize: Build specific playstyle (aggressive DPS, tanky survivor, or resource farmer)
- Max Out: Focus on upgrading existing items to max level rather than spreading thin
- Unlock: Purchase 6th upgrade slot at 2000 credits for complete build

#### Build Archetypes (Example Loadouts)

**1. Tank Survivor Build**
- Energy Shield (Level 5)
- Armor Plating (Level 3)
- Rapid Regeneration (Level 2)
- Piercing Rounds (Level 2) - for efficiency
- **Playstyle**: Face-tank hazards, outlast difficulty spikes, slow but steady

**2. Glass Cannon Build**
- Spread Shot (Level 3)
- Homing Missiles (Level 3)
- Charge Cannon (Level 2)
- Score Multiplier (Level 3)
- **Playstyle**: High risk/reward, maximize score, requires skilled dodging

**3. Resource Farmer Build**
- Crystal Magnet (Level 3)
- Lucky Charm (Level 3)
- Energy Shield (Level 3)
- Scanner Array (Level 2)
- **Playstyle**: Optimize credit earning, safe play, prepare for future runs

**4. Mobility Specialist Build**
- Thruster Boost (Level 3)
- Hyperspace Cooldown (Level 3)
- Deflector Field (Level 2)
- Piercing Rounds (Level 2)
- **Playstyle**: Never stop moving, escape-focused, high-skill ceiling

### Upgrade Economy Balance

#### Credit Earning Rates (Target Values)
- **Beginner**: 80-120 credits per run (3-5 minutes survival)
- **Intermediate**: 200-350 credits per run (8-12 minutes survival)
- **Advanced**: 500+ credits per run (15+ minutes survival)

#### Unlock Progression Timeline
- **Run 1-3**: Earn first upgrade (Energy Shield or Crystal Magnet)
- **Run 5-8**: Have 2-3 Level 1 upgrades, experiment with combinations
- **Run 10-15**: Unlock 5th slot, have 1-2 Level 2 upgrades
- **Run 20-30**: Have focused build with 4-5 upgrades, some at max level
- **Run 40+**: Multiple max-level builds, experimenting with all archetypes

### Rewards and Achievements

#### Achievement System
Achievements unlock bonus credits and cosmetic rewards.

**Survival Achievements:**
- "First Flight" - Survive 1 minute (Reward: 50 credits)
- "Space Cadet" - Survive 5 minutes (Reward: 100 credits)
- "Void Walker" - Survive 10 minutes (Reward: 250 credits)
- "Eternal Wanderer" - Survive 20 minutes (Reward: 500 credits)

**Combat Achievements:**
- "Asteroid Smasher" - Destroy 100 asteroids (Reward: 100 credits)
- "Enemy Ace" - Destroy 50 enemies (Reward: 200 credits)
- "Black Hole Master" - Overload 10 black holes (Reward: 300 credits)

**Collection Achievements:**
- "Crystal Collector" - Collect 1000 crystals (Reward: 150 credits)
- "Treasure Hunter" - Collect 10,000 crystals (Reward: 500 credits)

**Skill Achievements:**
- "Marksman" - Achieve 80% accuracy for full run (Reward: 200 credits + Gold Ship Skin)
- "Untouchable" - Complete run without shield damage (Reward: 300 credits + Phantom Skin)
- "Speed Demon" - Destroy 100 asteroids in 2 minutes (Reward: 250 credits)

#### Daily Challenges
Rotate daily for extra engagement; offer 2x credit rewards.

- **Monday**: "Collector's Day" - Collect 500 crystals (Reward: 200 credits)
- **Tuesday**: "Marksman's Test" - Achieve 70% accuracy (Reward: 200 credits)
- **Wednesday**: "Survival Challenge" - Survive 8 minutes (Reward: 250 credits)
- **Thursday**: "Enemy Hunter" - Destroy 20 enemies (Reward: 200 credits)
- **Friday**: "Black Hole Chaos" - Overload 3 black holes (Reward: 250 credits)
- **Weekend Bonus**: "Double or Nothing" - Complete run with 2x difficulty (Reward: 500 credits)

### Progression Objectives

- **Balanced Economy**: Ensure players earn 1 meaningful upgrade every 2-3 runs to maintain motivation
- **No Dead Ends**: All upgrade paths should be viable; no trap choices
- **Build Variety**: Track player loadouts; if >60% use same build, rebalance
- **Engagement Loop**: Target 5-10 runs before players complete first "build archetype"
- **Long-term Goals**: Unlocking all upgrades at max level should take 100+ runs (20-30 hours)

### Progression Simulation (Player Journey)

This simulation shows realistic progression timelines based on the upgrade economy, demonstrating how many runs and total playtime players need to reach each game phase.

#### Simulation Assumptions
- Average player starts as beginner, improves to intermediate, then advanced
- Players spend credits as soon as they can afford meaningful upgrades
- Achievement bonuses included in calculations
- Session lengths increase as player skill improves
- Dynamic difficulty keeps players engaged without frustration

#### Phase 1: Early Game (Runs 1-8)
**Goal**: Reach 500 total credits spent (unlock mid-game)

| Run # | Skill Level | Avg. Survival | Credits Earned | Achievement Bonus | Total Earned | Spent On | Running Total Spent |
|-------|-------------|---------------|----------------|-------------------|--------------|----------|---------------------|
| 1 | Beginner | 2 min | 80 | +50 ("First Flight") | 130 | - | 0 |
| 2 | Beginner | 3 min | 90 | - | 90 | Crystal Magnet L1 (90) | 90 |
| 3 | Beginner | 3.5 min | 95 | - | 95 | - | 90 |
| 4 | Beginner | 4 min | 105 | +100 ("Space Cadet") | 205 | Energy Shield L1 (100) | 190 |
| 5 | Intermediate | 6 min | 180 | +100 ("Asteroid Smasher") | 280 | Energy Shield L2 (100) | 290 |
| 6 | Intermediate | 7 min | 210 | - | 210 | Piercing Rounds L1 (100) | 390 |
| 7 | Intermediate | 8 min | 240 | - | 240 | - | 390 |
| 8 | Intermediate | 9 min | 270 | +250 ("Void Walker") | 520 | **5th Slot Unlock (500)** | **500** |

**Early Game Summary:**
- **Total Runs**: 8 runs
- **Total Playtime**: ~42 minutes (average 5.25 min/run)
- **Total Credits Spent**: 500 credits
- **Upgrades Acquired**: Crystal Magnet L1, Energy Shield L2, Piercing Rounds L1, 5th Upgrade Slot
- **Player Status**: Can now equip 5 upgrades; basic build functional

#### Phase 2: Mid Game (Runs 9-25)
**Goal**: Reach 2000 total credits spent (unlock late-game)

| Run # | Skill Level | Avg. Survival | Credits Earned | Achievement Bonus | Cumulative Spent | Notable Purchase |
|-------|-------------|---------------|----------------|-------------------|------------------|------------------|
| 9 | Intermediate | 9 min | 270 | - | 500 | Saving |
| 10 | Intermediate | 10 min | 300 | +150 ("Crystal Collector") | 950 | Homing Missiles L1 (150) |
| 11-12 | Intermediate | 10 min avg | 300 each | - | 1,250 | Thruster Boost L1 (110) |
| 13-15 | Intermediate | 11 min avg | 320 each | +200 ("Enemy Ace") | 2,190 | Energy Shield L3 (100), Rapid Regen L1 (150) |
| 16-20 | Advanced | 13 min avg | 450 each | +300 ("Black Hole Master") | 4,690 | Homing Missiles L2-3 (300), Armor Plating L1 (180) |
| 21-25 | Advanced | 15 min avg | 520 each | +500 ("Eternal Wanderer") | **7,790** | **6th Slot Unlock (2000)** at Run 19 |

**Mid Game Summary:**
- **Total Runs to Reach Mid-Game**: 8 runs (from start)
- **Total Runs to Complete Mid-Game**: ~19 runs (unlock 6th slot at 2000 spent)
- **Additional Runs in Mid-Game**: 11 runs (Runs 9-19)
- **Mid-Game Playtime**: ~125 minutes (11 runs × 11.4 min avg)
- **Total Playtime So Far**: ~167 minutes (~2.8 hours)
- **Total Credits Spent at 2000 Threshold**: 2000 credits
- **Upgrades at Mid-Game End**: 
  - Energy Shield L3
  - Rapid Regen L1
  - Homing Missiles L3
  - Piercing Rounds L1
  - Crystal Magnet L1
  - Thruster Boost L1
  - 6th Upgrade Slot unlocked

#### Phase 3: Late Game (Runs 20-50+)
**Goal**: Build complete specialized loadouts, max out key upgrades

| Run Range | Skill Level | Avg. Survival | Credits/Run | Focus |
|-----------|-------------|---------------|-------------|-------|
| 20-30 | Advanced | 16 min | 550 | Completing first specialized build (Tank or DPS) |
| 31-40 | Advanced | 18 min | 600 | Maxing out 4-5 core upgrades to Level 3-5 |
| 41-50 | Expert | 20 min | 700+ | Experimenting with alternative builds |
| 51-75 | Expert | 22+ min | 800+ | Maxing all owned upgrades, collecting remaining achievements |
| 76-100+ | Master | 25+ min | 1000+ | Perfect builds, achievement hunting, high score chasing |

**Late Game Detailed Breakdown (Runs 20-50):**

**Runs 20-30** (Specialization Phase):
- Credits earned: ~5,500 (10 runs × 550 avg)
- Focus: Complete one build archetype
- Example purchases: Armor Plating L2-3 (360 total), Energy Shield L4-5 (200 total), Spread Shot L1-3 (360 total)
- **Total spent by Run 30**: ~8,500 credits
- **Playtime**: 160 minutes (2.7 hours)
- **Total playtime**: ~5.5 hours

**Runs 31-40** (Optimization Phase):
- Credits earned: ~6,000 (10 runs × 600 avg)
- Focus: Max out primary build, start secondary build
- Example purchases: Rapid Regen L2-3 (300 total), Crystal Magnet L2-3 (180 total), Score Multiplier L1-2 (320 total)
- **Total spent by Run 40**: ~15,300 credits
- **Playtime**: 180 minutes (3 hours)
- **Total playtime**: ~8.5 hours

**Runs 41-50** (Mastery Phase):
- Credits earned: ~7,000 (10 runs × 700 avg)
- Focus: Second/third complete build, experimentation
- Example purchases: Lucky Charm L1-3 (510 total), Scanner Array L1-2 (280 total), Charge Cannon L1-2 (360 total)
- **Total spent by Run 50**: ~23,450 credits
- **Playtime**: 200 minutes (3.3 hours)
- **Total playtime**: ~11.8 hours

#### Complete Progression Timeline Summary

| Milestone | Runs Required | Total Playtime | Credits Spent | Player Build Status |
|-----------|---------------|----------------|---------------|---------------------|
| **First Upgrade** | 2 runs | 5 min | 90 | Basic boost |
| **Early Game Exit** | 8 runs | 42 min | 500 | 3 upgrades + 5th slot |
| **Mid Game Exit** | 19 runs | 2.8 hours | 2,000 | 6-7 upgrades + 6th slot |
| **First Complete Build** | 30 runs | 5.5 hours | ~8,500 | Specialized archetype maxed |
| **Second Build** | 40 runs | 8.5 hours | ~15,300 | Two viable playstyles |
| **All Core Upgrades** | 50 runs | 11.8 hours | ~23,000 | 3+ complete builds |
| **100% Completion** | 100+ runs | 30+ hours | 50,000+ | All upgrades maxed, all achievements |

#### Key Insights from Simulation

**1. Rapid Early Progress**
- Players get first meaningful upgrade after just 2 runs (5 minutes)
- Multiple upgrades acquired within first hour of play
- Maintains motivation through frequent rewards

**2. Mid-Game Sweet Spot (Runs 10-30)**
- Most engaged phase: meaningful choices available, builds taking shape
- Average session length peaks at 15-18 minutes (optimal for mobile)
- Players feel power growth without being overpowered

**3. Late Game Investment**
- Requires significant time commitment (10+ hours for complete builds)
- Targets dedicated players who want to master all playstyles
- Prevents "completion" within first few days, encouraging retention

**4. Balanced Progression Curve**
- **Casual Players** (1-2 sessions/week): Reach mid-game in 2-3 weeks
- **Regular Players** (3-5 sessions/week): Complete first build in 3-4 weeks
- **Hardcore Players** (daily play): Unlock most content in 2-3 weeks, master builds in 6-8 weeks

**5. Credit Economy Health**
- Early upgrades (90-150 credits) achievable in 1-2 runs
- Mid-tier upgrades (150-200 credits) require 2-4 runs of saving
- Expensive upgrades (200+ credits) feel rewarding after effort
- No "grind wall" where progress halts for extended periods

#### Retention Targets Based on Simulation

- **Day 1 Retention**: 70% (players get first upgrade, see progression system)
- **Week 1 Retention**: 50% (players have 3-4 upgrades, experimenting with builds)
- **Week 2 Retention**: 35% (unlocked 5th slot, committed to game loop)
- **Month 1 Retention**: 20% (working on specialized builds, high engagement)
- **Month 3 Retention**: 10% (mastering game, chasing achievements, high LTV players)

## 10. Level Design and World Structure

### Structure

- **Endless Mode**: Single procedural "level" with continuous gameplay and no breaks
- **Procedural Generation**: Random asteroid clusters, enemy paths, and black hole spawns; difficulty scales dynamically based on player performance rather than fixed intervals
- **Adaptive Spawning**: Spawn rates and hazard complexity adjust in real-time (e.g., increase speed/density by 5-15% when player is dominating, decrease when player's shield is critically low)

### Design Principles

- **Variety**: Difficulty progression creates natural variety - easier moments with sparse asteroids, intense moments with dense hazards and multiple enemies
- **Pacing**: Dynamic difficulty creates organic pacing - players get breathing room (and shield regen time) when struggling without artificial breaks
- **Flow State**: System aims to keep players in "flow" by matching challenge to skill level continuously

### Objectives

- Ensure Fairness: Procedural algorithms avoid impossible setups (e.g., no instant black hole on spawn)
- Replayability: Seed-based generation for shareable high scores

## 11. Monetization Strategy

### Model

- **Free-to-Play**: Core game free; in-app purchases (IAP) for convenience
- **Ads**: Interstitial after game over; rewarded videos for x2 credits or revives
- **IAP**: Credit packs ($0.99−$4.99); premium bundle ($2.99) for ad removal + bonus slots

### Objectives

- Non-Intrusive: Ads optional; no paywalls for core content
- Revenue Goals: Aim for 20% conversion rate via balanced economy; track via Unity Analytics
