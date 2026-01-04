# Module 12: Hyperspace Jump Mechanic

**Priority**: Low
**Dependencies**: None
**Estimated Duration**: 2-3 days

## Purpose
Add emergency teleport ability with risk/reward.

## Core Components

### 12.1 Hyperspace Logic
- **File**: Extend `player.gd`
- **Behavior**:
  - Input action "hyperspace" (e.g., Shift key)
  - Teleport to random screen position
  - Brief invulnerability (0.5s)
  - Cooldown (10s base, upgradeable)
  - Risk: Can land near asteroids/enemies

### 12.2 Visual Effect
- Particle burst at departure and arrival
- Screen flash
- Trail effect during teleport

### 12.3 Upgrade Items
- "Hyperspace Stabilizer" (reduces cooldown)
- "Safe Jump" (scans landing area, avoids hazards)

## Integration Points
- Player input handling
- HUD shows cooldown indicator
- Upgrades affect cooldown

## Extensibility
- Chain jumps (rapid multiple teleports)
- Tactical teleport (target position)
- Leave clone/decoy behind

## Testing Checklist
- [ ] Teleport works correctly
- [ ] Can't teleport off screen
- [ ] Cooldown enforced
- [ ] Invulnerability period works
- [ ] Visual effects clean

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
