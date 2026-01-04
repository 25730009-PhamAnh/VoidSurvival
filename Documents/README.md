# Void Survivor - Documentation Index

This folder contains all design and planning documentation for the Void Survivor game project.

## 📚 Core Documentation

### [Game Design Document (GDD)](VoidSurvivor_GDD.md)
**Complete game design specification**
- Game overview, features, and objectives
- Core gameplay mechanics and loop
- Infinite progression parameter system
- Dynamic difficulty system
- Story, art style, and sound design
- UI/UX design and controls
- Progression and rewards systems
- Level design and monetization strategy

### [Technical Specification](VoidSurvivor_TechnicalSpec_Godot.md)
**Godot 4 implementation architecture**
- Architecture overview and design principles
- Project structure and file organization
- Core systems (autoloads and singletons)
- Data layer (Resources for data-driven design)
- Component system and gameplay systems
- Infinite progression implementation
- Performance optimization strategies
- Extensibility patterns and testing strategy

### ~~[Prototype Plan](archive/VoidSurvivor_PrototypePlan.md)~~ ✅ **COMPLETED & ARCHIVED**
**Week 1 prototype implementation** - Successfully completed!
- Minimal viable gameplay validation
- Core mechanics implementation checklist
- Player ship, projectile, and asteroid systems
- Basic HUD and game manager
- Testing criteria and success metrics
- **Status**: Archived - see [archive folder](archive/) for reference

## 🗺️ Development Plan

### [Development Plan Overview](Development_Plan_Overview.md)
**High-level development strategy**
- Development philosophy and current state
- Implementation phases (1-4)
- Technical debt and refactoring plan
- Testing strategy and risk management
- Success metrics and future expansion

### Development Modules

The development plan is organized into **12 independent, modular features**. Each module can be implemented incrementally:

#### Phase 1: Foundation (Weeks 2-3)
1. [Module 1: Resource System & Item Pickups](modules/Module_01_Resource_System.md) - High Priority
2. [Module 2: Save/Load System](modules/Module_02_Save_Load_System.md) - High Priority
3. [Module 3: Credit Economy & Post-Game Flow](modules/Module_03_Credit_Economy.md) - High Priority
4. [Module 4: Upgrade Shop UI](modules/Module_04_Upgrade_Shop_UI.md) - High Priority
5. [Module 5: Stat Calculation & Upgrade System](modules/Module_05_Stats_Upgrade_System.md) - High Priority

**Milestone**: Earn credits, buy upgrades, see stats change in-game

#### Phase 2: Content Expansion (Weeks 4-5)
6. [Module 6: Enemy Variety & Spawning](modules/Module_06_Enemy_Variety_Spawning.md) - Medium Priority
7. [Module 7: Black Hole Hazard System](modules/Module_07_Black_Hole_System.md) - Medium Priority
8. [Module 8: Dynamic Difficulty System](modules/Module_08_Dynamic_Difficulty.md) - Medium Priority

**Milestone**: Game feels varied, difficulty adapts, enemies challenge player

#### Phase 3: Polish & Depth (Weeks 6-7)
9. [Module 9: Weapon Variety System](modules/Module_09_Weapon_Variety.md) - Low-Medium Priority
10. [Module 10: Visual Effects & Juice](modules/Module_10_Visual_Effects.md) - Low Priority
11. [Module 11: Main Menu & Game Flow](modules/Module_11_Main_Menu_Flow.md) - Medium Priority
12. [Module 12: Hyperspace Jump Mechanic](modules/Module_12_Hyperspace_Jump.md) - Low Priority

**Milestone**: Game feels polished, complete core loop

#### Phase 4: Balance & Testing (Week 8)
- Playtest all systems together
- Balance item costs and stat formulas
- Optimize performance and fix bugs

## 📁 Folder Structure

```
Documents/
├── README.md (this file)
├── VoidSurvivor_GDD.md
├── VoidSurvivor_TechnicalSpec_Godot.md
├── Development_Plan_Overview.md
├── modules/
│   ├── Module_01_Resource_System.md
│   ├── Module_02_Save_Load_System.md
│   ├── Module_03_Credit_Economy.md
│   ├── Module_04_Upgrade_Shop_UI.md
│   ├── Module_05_Stats_Upgrade_System.md
│   ├── Module_06_Enemy_Variety_Spawning.md
│   ├── Module_07_Black_Hole_System.md
│   ├── Module_08_Dynamic_Difficulty.md
│   ├── Module_09_Weapon_Variety.md
│   ├── Module_10_Visual_Effects.md
│   ├── Module_11_Main_Menu_Flow.md
│   └── Module_12_Hyperspace_Jump.md
└── archive/
    ├── VoidSurvivor_DevelopmentPlan_ORIGINAL.md
    └── VoidSurvivor_PrototypePlan.md ✅
```

## 🎯 Quick Navigation

**Starting Development?**
1. Read the [GDD](VoidSurvivor_GDD.md) for game vision
2. Review the [Technical Spec](VoidSurvivor_TechnicalSpec_Godot.md) for architecture
3. Check [Development Plan Overview](Development_Plan_Overview.md) for current phase
4. Pick a module from the appropriate phase above

**Looking for a Specific Feature?**
- Browse the [modules/](modules/) folder
- Each module has clear dependencies, integration points, and testing criteria

**Understanding the Prototype?**
- See [Prototype Plan](archive/VoidSurvivor_PrototypePlan.md) (archived) for Week 1 implementation details
- ✅ Week 1 prototype completed and validated

**Archived Documents?**
- See [archive/](archive/) folder for completed plans and original documents

## 📊 Project Status

- **Current Phase**: Week 1 Prototype ✅ Complete
- **Next Phase**: Phase 1 Foundation (Modules 1-5)
- **Target Platform**: Mobile (iOS/Android), PC
- **Engine**: Godot 4.5+
- **Language**: GDScript

## 🏗️ Architecture Highlights

- **Data-Driven**: All gameplay parameters in Resource files
- **Signal-Based**: Decoupled systems using Godot's signal system
- **Modular**: Reusable components and scenes
- **Infinite Progression**: Mathematical formulas for endless scaling
- **Extensible**: Add items/enemies via resources, no code changes needed

---

**Last Updated**: January 2026
**Documentation Version**: 1.0
