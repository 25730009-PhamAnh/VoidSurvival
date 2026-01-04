# Void Survivor - Development Plan Overview

**Version**: 1.1
**Last Updated**: January 4, 2026
**Status**: Phase 1 In Progress (3/5 modules complete)

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

✅ **Module 1: Resource System Complete** (archived):
- Crystal pickups spawn from destroyed asteroids
- CollectionComponent for player item attraction
- ResourceManager singleton tracks crystals and credits
- Crystals auto-convert to credits on game over

✅ **Module 2: Save/Load System Complete** (archived):
- SaveSystem singleton with JSON persistence
- Credits, stats, and settings persist across sessions
- Save validation and corruption handling
- Auto-save on game over and credit transactions

✅ **Module 3: Credit Economy Complete** (archived):
- SessionManager tracks detailed session stats (accuracy, survival time, etc.)
- Credit calculation with bonuses (time, combat, accuracy)
- Professional game over screen with stats breakdown
- Navigation to upgrades and main menu (placeholders ready)

---

## Feature Modules

The remaining development is organized into **12 independent feature modules**, each building upon the prototype foundation without tight coupling. See the [modules/](modules/) folder for detailed documentation on each module.

### Module Overview

| # | Module | Priority | Duration | Status | Dependencies |
|---|--------|----------|----------|--------|--------------|
| 1 | Resource System & Item Pickups | High | 3-5 days | ✅ Complete | None |
| 2 | Save/Load System | High | 2-4 days | ✅ Complete | None |
| 3 | Credit Economy & Post-Game Flow | High | 2-3 days | ✅ Complete | Modules 1, 2 |
| 4 | Upgrade Shop UI | High | 4-6 days | 🔄 Next | Module 3 |
| 5 | Stat Calculation & Upgrade System | High | 3-5 days | ⏳ Pending | Module 4 |
| 6 | Enemy Variety & Spawning | Medium | 5-7 days | ⏳ Pending | None |
| 7 | Black Hole Hazard System | Medium | 3-4 days | ⏳ Pending | None |
| 8 | Dynamic Difficulty System | Medium | 4-5 days | ⏳ Pending | Modules 6, 5 |
| 9 | Weapon Variety System | Low-Medium | 5-7 days | ⏳ Pending | Module 5 |
| 10 | Visual Effects & Juice | Low | 4-6 days | ⏳ Pending | All gameplay |
| 11 | Main Menu & Game Flow | Medium | 3-4 days | ⏳ Pending | Modules 2, 4 |
| 12 | Hyperspace Jump Mechanic | Low | 2-3 days | ⏳ Pending | None |

---

## Implementation Order

### Phase 1: Foundation (Weeks 2-3) - 60% Complete
Focus on core systems that other features depend on:

1. ✅ **Module 1**: Resource System & Pickups (Complete)
2. ✅ **Module 2**: Save/Load System (Complete)
3. ✅ **Module 3**: Credit Economy (Complete)
4. 🔄 **Module 4**: Upgrade Shop UI (Next)
5. ⏳ **Module 5**: Stat Calculation & Upgrades

**Milestone**: Can earn credits, buy upgrades, see stats change in-game.
**Current Progress**: Players can collect crystals, earn credits with bonuses, and credits persist across sessions.

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
Each module includes testing checklist in its documentation.

### Integration Testing
- **After Phase 1**: Test upgrade→stat→gameplay flow
- **After Phase 2**: Test difficulty scaling with multiple hazards
- **After Phase 3**: Full playtest from menu to game over to upgrades

### Performance Testing
- **Target**: 60 FPS on mid-range mobile devices
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
- **Items**: Just create new `.tres` files
- **Enemies**: New scenes + enemy_definition resources
- **Weapons**: Extend WeaponBase class
- **Progression**: Add new stats to ShipStats resource

---

## Appendix: Development Tools & Workflows

### Recommended Godot Plugins
- **GUT** (Godot Unit Testing): For automated testing
- **Dialogic**: If adding tutorial/story elements
- **AsepriteWizard**: If using Aseprite for sprites

### Asset Pipeline
- **Sprites**: Export to `assets/sprites/` as PNG
- **Audio**: Export to `assets/audio/` as OGG (compressed)
- **Fonts**: Place in `assets/fonts/`

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

**Next Steps**: Continue Phase 1 implementation with Module 4 (Upgrade Shop UI). Modules 1-3 complete and archived.

---

## Archived Plans

Completed implementation plans can be found in [archive/](archive/):
- ✅ [VoidSurvivor_PrototypePlan.md](archive/VoidSurvivor_PrototypePlan.md) - Week 1 Prototype
- ✅ [module_01_02_plan.md](archive/module_01_02_plan.md) - Modules 1 & 2 (Resource System + Save/Load)
- ✅ [module_03_plan.md](archive/module_03_plan.md) - Module 3 (Credit Economy)

---

## Module Documentation

For detailed documentation on each module, see:
- [Module 1: Resource System & Item Pickups](modules/Module_01_Resource_System.md)
- [Module 2: Save/Load System](modules/Module_02_Save_Load_System.md)
- [Module 3: Credit Economy & Post-Game Flow](modules/Module_03_Credit_Economy.md)
- [Module 4: Upgrade Shop UI](modules/Module_04_Upgrade_Shop_UI.md)
- [Module 5: Stat Calculation & Upgrade System](modules/Module_05_Stats_Upgrade_System.md)
- [Module 6: Enemy Variety & Spawning](modules/Module_06_Enemy_Variety_Spawning.md)
- [Module 7: Black Hole Hazard System](modules/Module_07_Black_Hole_System.md)
- [Module 8: Dynamic Difficulty System](modules/Module_08_Dynamic_Difficulty.md)
- [Module 9: Weapon Variety System](modules/Module_09_Weapon_Variety.md)
- [Module 10: Visual Effects & Juice](modules/Module_10_Visual_Effects.md)
- [Module 11: Main Menu & Game Flow](modules/Module_11_Main_Menu_Flow.md)
- [Module 12: Hyperspace Jump Mechanic](modules/Module_12_Hyperspace_Jump.md)
