# Module 10: Visual Effects & Juice

**Priority**: Low
**Dependencies**: All gameplay systems
**Estimated Duration**: 4-6 days

## Purpose
Enhance game feel with particles, screen shake, trails, and feedback.

## Core Components

### 10.1 Particle Effects
- **Explosion Effect**: `scenes/vfx/explosion.tscn`
  - CPUParticles2D or GPUParticles2D
  - Used for asteroid destruction, enemy death
  - Color-coded by type (white for asteroids, red for enemies)

- **Thrust Trail**: Attached to player
  - Particle trail when accelerating

- **Pickup Shine**: Crystal collection flash

- **Black Hole Swirl**: Particles orbiting black hole

### 10.2 Screen Shake Component
- **File**: `scripts/components/screen_shake.gd`
- **Purpose**: Reusable camera shake
- **Usage**:
  ```gdscript
  ScreenShake.shake(intensity: float, duration: float)
  ```
- Attached to Camera2D

### 10.3 Impact Feedback
- Freeze frames on big explosions (0.05s pause)
- Player ship flash white when hit
- Hit particles at collision point

### 10.4 Audio Integration
- Placeholder for sound effects
- Positional audio for explosions
- Engine thrust sound loop

## Integration Points
- All destruction events spawn particles
- Camera shake on player hit, large asteroid destroyed
- VFX pool for performance (object pooling)

## Extensibility
- Different VFX for weapon types
- Customizable player ship trails (cosmetics)
- Screen filters/shaders (damage vignette)

## Testing Checklist
- [ ] Explosions spawn at correct positions
- [ ] Screen shake feels good (not nauseating)
- [ ] Particles don't tank performance (100+ on screen)
- [ ] Trails follow player smoothly
- [ ] Can toggle effects off (accessibility)

---

[← Back to Development Plan Overview](../Development_Plan_Overview.md)
