# Void Survivor - Prototype Development Plan
**Version:** 1.0  
**Date:** January 3, 2026  
**Target Duration:** 4 Weeks  
**Goal:** Create a playable vertical slice demonstrating core gameplay loop

---

## 1. Prototype Objectives

### 1.1 Primary Goals

✅ **Prove Core Mechanics**
- Validate inertia-based movement feels good
- Confirm shooting and destruction is satisfying
- Test basic difficulty scaling system
- Verify progression loop is engaging

✅ **Test Key Features**
- Ship controls with screen wrap-around
- Asteroid destruction and fragmentation
- Basic shield system with regeneration
- Simple upgrade system (1-2 upgrades)
- Dynamic difficulty (basic version)

✅ **Gather Feedback**
- Is the game fun in the first 5 minutes?
- Does progression feel rewarding?
- Is difficulty curve appropriate?
- Are controls intuitive?

### 1.2 Out of Scope (For Later)

❌ **Not in Prototype**
- Full item system (only 2-3 test items)
- All enemy types (only asteroids + 1 enemy)
- Black holes
- Complete UI/UX polish
- Audio/music
- Advanced VFX
- Save system
- Achievements
- Daily challenges
- Meta-progression/prestige

---

## 2. Prototype Features Breakdown

### 2.1 Must Have (Week 1-2)

**Core Gameplay**
- ✅ Player ship with inertia physics
- ✅ Rotation and thrust controls
- ✅ Screen wrap-around
- ✅ Basic shooting (line projectiles)
- ✅ Asteroid spawning
- ✅ Asteroid fragmentation (3 sizes)
- ✅ Shield system (deplete on hit, regenerate)
- ✅ Game over on shield depleted
- ✅ Basic score system

**Minimal Difficulty**
- ✅ Time-based difficulty increase
- ✅ Spawn rate increases over time
- ✅ Asteroid speed increases over time

**Basic UI**
- ✅ Shield bar
- ✅ Score counter
- ✅ Survival timer
- ✅ Game over screen with restart

### 2.2 Should Have (Week 3)

**Enhanced Gameplay**
- ✅ 1 enemy type (UFO that shoots)
- ✅ Void crystals (collectible resource)
- ✅ 1 temporary pickup (Speed Boost)
- ✅ Hyperspace jump (emergency teleport)

**Progression (Simplified)**
- ✅ Post-game credits earned
- ✅ 2-3 permanent upgrades purchasable
  - Energy Shield (increase max shield)
  - Rapid Fire (increase fire rate)
  - Piercing Rounds (shots go through asteroids)
- ✅ Upgrade menu between runs

**Difficulty Evolution**
- ✅ Basic dynamic difficulty
  - Reduce spawn rate when shield < 30%
  - Increase spawn rate when shield > 70%

### 2.3 Nice to Have (Week 4)

**Polish**
- ✅ Simple particle effects (explosions)
- ✅ Screen shake on impacts
- ✅ Placeholder sound effects
- ✅ Visual feedback for damage/collection
- ✅ Minimap showing threats

**Additional Content**
- ✅ 1-2 more upgrades
- ✅ 1 more temporary pickup
- ✅ High score tracking (session-based)

---

## 3. Development Schedule

### Week 1: Foundation (Jan 3-9, 2026)

#### Day 1-2: Project Setup
- [ ] Create Unity 6.3 LTS project
- [ ] Set up project folders structure
- [ ] Create basic scene (black background, minimal setup)
- [ ] Set up version control (Git)
- [ ] Create initial GameObject structure

**Deliverable:** Empty project with proper structure

#### Day 3-4: Player Ship Movement
- [ ] Create player ship (white triangle sprite)
- [ ] Implement Rigidbody2D physics
- [ ] Add rotation controls (touch/keyboard)
- [ ] Add thrust controls
- [ ] Implement screen wrap-around
- [ ] Test and tune movement feel

**Deliverable:** Playable ship with good feel

#### Day 5-7: Basic Shooting & Asteroids
- [ ] Create projectile system
- [ ] Implement firing mechanic
- [ ] Create asteroid prefab (gray polygon)
- [ ] Implement asteroid spawning
- [ ] Add asteroid fragmentation (split into 3 smaller)
- [ ] Implement collision detection
- [ ] Add score on asteroid destruction

**Deliverable:** Ship can shoot and destroy asteroids

**Week 1 Milestone:** Player can fly around, shoot, and destroy asteroids that fragment

---

### Week 2: Core Loop (Jan 10-16, 2026)

#### Day 8-9: Shield System
- [ ] Implement shield component
- [ ] Add shield UI bar
- [ ] Shield depletes on collision
- [ ] Shield regenerates after delay
- [ ] Game over when shield = 0
- [ ] Game over screen with restart button

**Deliverable:** Complete life/death cycle

#### Day 10-11: Spawn System & Difficulty
- [ ] Create SpawnManager
- [ ] Implement time-based spawn rate
- [ ] Add difficulty scaling over time
- [ ] Increase asteroid speed with time
- [ ] Test and balance spawn patterns

**Deliverable:** Escalating challenge over time

#### Day 12-14: Basic Progression
- [ ] Implement credit earning system
- [ ] Create UpgradeManager
- [ ] Create 3 ScriptableObject upgrades
  - Energy Shield SO
  - Rapid Fire SO
  - Piercing Rounds SO
- [ ] Build simple upgrade menu UI
- [ ] Implement upgrade purchase flow
- [ ] Apply upgrades to ship stats

**Deliverable:** Working upgrade loop between runs

**Week 2 Milestone:** Complete core loop - play, die, upgrade, replay

---

### Week 3: Expanded Content (Jan 17-23, 2026)

#### Day 15-16: Enemy System
- [ ] Create Enemy base class
- [ ] Create UFO enemy prefab
- [ ] Implement chase behavior
- [ ] Add UFO shooting
- [ ] Spawn UFOs based on difficulty
- [ ] Award credits on UFO destruction

**Deliverable:** Second threat type

#### Day 17-18: Pickups & Resources
- [ ] Create crystal pickup prefab
- [ ] Crystals drop from destroyed objects
- [ ] Auto-collect on proximity
- [ ] Display crystal count in UI
- [ ] Crystals contribute to credits earned
- [ ] Create 1 temporary pickup (Speed Boost)
- [ ] Implement pickup effects system

**Deliverable:** Resource collection and temporary buffs

#### Day 19-21: Dynamic Difficulty (Basic)
- [ ] Create DifficultyManager (simplified)
- [ ] Track shield percentage
- [ ] Reduce spawn rate when shield < 30%
- [ ] Increase spawn rate when shield > 70%
- [ ] Smooth transitions between difficulty states
- [ ] Display difficulty indicator (optional)

**Deliverable:** Adaptive difficulty system

**Week 3 Milestone:** Expanded gameplay with enemies, pickups, and adaptive difficulty

---

### Week 4: Polish & Testing (Jan 24-30, 2026)

#### Day 22-23: Visual Polish
- [ ] Add particle systems for explosions
- [ ] Implement screen shake
- [ ] Add glow effects to ship/pickups
- [ ] Visual feedback for damage (flash red)
- [ ] Visual feedback for collection (pulse)
- [ ] Minimap implementation (simple)

**Deliverable:** Improved visual feedback

#### Day 24-25: Audio & Juice
- [ ] Find/create placeholder SFX
  - Laser shot
  - Explosion
  - Pickup collect
  - Shield hit
- [ ] Implement AudioManager (simple)
- [ ] Add haptic feedback (mobile)
- [ ] Tweak particle effects timing

**Deliverable:** Basic audio feedback

#### Day 26-28: Balance & Testing
- [ ] Playtest 10+ runs
- [ ] Balance difficulty curve
- [ ] Tune upgrade costs and effects
- [ ] Adjust spawn rates
- [ ] Fix bugs and edge cases
- [ ] Optimize performance (60 FPS target)

**Deliverable:** Balanced, bug-free prototype

#### Day 29-30: Build & Documentation
- [ ] Build for PC (Windows/Mac)
- [ ] Build for Android (test device)
- [ ] Create playtest instructions
- [ ] Document known issues
- [ ] Prepare feedback form
- [ ] Package and distribute to testers

**Deliverable:** Playable builds ready for feedback

**Week 4 Milestone:** Polished prototype ready for external testing

---

## 4. Technical Implementation Priority

### 4.1 Core Architecture (Week 1)

**Keep It Simple!**

```
Prototype Architecture:
- MonoBehaviour-based (no complex patterns yet)
- Direct references (no event bus initially)
- Hard-coded values (no ScriptableObjects yet)
- Simple managers (GameManager, SpawnManager)
```

**Why Simple?**
- Faster iteration
- Easier debugging
- Can refactor later based on learnings

### 4.2 Data Structure (Week 2-3)

**Minimal Data-Driven**

Only introduce ScriptableObjects when needed:
- Week 2: Upgrade definitions
- Week 3: Enemy definitions (if needed)

Keep everything else hard-coded for speed.

### 4.3 Optimization Focus

**Performance Targets**
- 60 FPS on mid-range mobile device
- < 50 objects on screen at once
- Pool only if needed (asteroids, projectiles)

**Don't Over-Optimize**
- Profile first, optimize later
- Focus on gameplay feel over perfect code

---

## 5. Playtesting Plan

### 5.1 Internal Testing (Week 2-3)

**Daily Playtests**
- Play 2-3 full runs every day
- Document issues immediately
- Tweak and iterate based on feel

**Test Checklist**
- [ ] Controls feel responsive
- [ ] Difficulty feels fair
- [ ] Upgrades make noticeable difference
- [ ] Session length is 3-5 minutes average
- [ ] Want to play "one more run"

### 5.2 External Alpha Test (Week 4)

**Target Testers:** 5-10 people
- Mix of gamers and non-gamers
- Include target age range (8-17 if possible)
- Both mobile and PC users

**Feedback Questions**
1. How fun is the game (1-10)?
2. How long did your first run last?
3. Were the controls intuitive?
4. Did you understand the upgrade system?
5. What frustrated you?
6. What did you enjoy most?
7. Would you play again?

**Data to Collect**
- Average session length
- Number of runs per tester
- Difficulty level reached
- Most purchased upgrades
- Common death causes

---

## 6. Success Criteria

### 6.1 Prototype is Successful If:

✅ **Gameplay**
- Playtesters rate fun > 6/10
- Average session length: 3-5 minutes
- 70%+ want to play multiple runs
- Controls understood in < 1 minute

✅ **Technical**
- Maintains 60 FPS on target devices
- No game-breaking bugs
- Builds run on Windows, Mac, Android

✅ **Progression**
- Players understand upgrade system
- Upgrades feel impactful
- Want to earn credits for next upgrade

✅ **Difficulty**
- Players survive 2+ minutes average
- Difficulty ramps feel fair
- Deaths feel earned, not cheap

### 6.2 Go/No-Go Decision Points

**After Week 2:**
- Is core loop fun? (play → die → upgrade → replay)
- If NO → Pivot or iterate core mechanics
- If YES → Continue to Week 3

**After Week 4:**
- Do playtesters want more content?
- Are they willing to pay for full version?
- If NO → Re-evaluate concept
- If YES → Proceed to production

---

## 7. Resource Requirements

### 7.1 Development Tools

**Required**
- Unity 6.3 LTS (free)
- Visual Studio Code / Visual Studio
- Git + GitHub (free)
- Figma (for UI mockups, free)

**Optional**
- Unity Asset Store (free assets)
- Audacity (free SFX editing)
- Paint.NET / GIMP (free sprite editing)

### 7.2 Assets Needed

**Art (Primitives Only)**
- Ship: White triangle
- Asteroids: Gray polygons
- Projectiles: White lines
- Enemies: Red squares
- Pickups: Colored circles
- UI: Colored rectangles/bars

**Audio (Week 4)**
- 5-8 placeholder SFX from free libraries
- No music needed for prototype

### 7.3 Team (Solo Developer Assumed)

**Time Commitment**
- 4-6 hours per day
- 5-6 days per week
- Total: ~120 hours over 4 weeks

**Skills Needed**
- Unity basics
- C# programming
- Basic 2D physics knowledge
- UI/UX fundamentals

---

## 8. Risk Management

### 8.1 Potential Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Controls feel unresponsive | Medium | High | Iterate daily, test on multiple devices |
| Difficulty too hard/easy | High | Medium | Playtest frequently, adjust parameters |
| Upgrades don't feel impactful | Medium | High | Use larger percentage increases (50%+) |
| Performance issues on mobile | Low | Medium | Profile early, limit on-screen objects |
| Scope creep | High | High | Strict feature lock after Week 2 |
| Motivation/burnout | Medium | High | Set realistic daily goals, take breaks |

### 8.2 Contingency Plans

**If Behind Schedule:**
- Cut nice-to-have features from Week 4
- Focus on core loop quality over content quantity
- Extend by 3-5 days if absolutely necessary

**If Ahead of Schedule:**
- Add 1-2 more upgrade options
- Polish visual effects more
- Add simple background music
- Start on stretch goals (black holes, etc.)

---

## 9. Daily Task Template

### Example Day Structure

**Morning (2-3 hours)**
- Review yesterday's progress
- Pick 1-2 tasks from milestone
- Implement features
- Commit code

**Afternoon (2-3 hours)**
- Playtest implemented features
- Fix bugs found
- Iterate based on feel
- Document issues

**Evening (30 min)**
- Quick playtest
- Update task list
- Plan tomorrow's work
- Push to Git

---

## 10. Post-Prototype Next Steps

### If Prototype is Successful:

**Immediate (Week 5-6)**
1. Analyze all playtest feedback
2. Create prioritized feature backlog
3. Refactor prototype code with proper architecture
4. Implement ScriptableObject system fully
5. Set up proper project structure

**Production Planning (Week 7-8)**
1. Define full feature set from GDD
2. Create production timeline (8-12 weeks)
3. Design complete progression system
4. Plan monetization integration
5. Set quality bar for art/audio

**Production Phase (Week 9+)**
- Implement remaining game systems
- Create all content (10+ items, 5+ enemies)
- Full UI/UX design and implementation
- Professional audio/music
- Comprehensive testing
- Soft launch and iteration

---

## 11. Success Metrics Summary

### Week 1 Success
- ✅ Ship movement feels good
- ✅ Can shoot and destroy asteroids
- ✅ Asteroids fragment properly
- ✅ Playable for 1+ minute

### Week 2 Success  
- ✅ Shield system works
- ✅ Game over and restart flow
- ✅ Can earn credits and buy upgrades
- ✅ Upgrades apply to next run
- ✅ Complete loop functional

### Week 3 Success
- ✅ Enemies add challenge
- ✅ Pickups add variety
- ✅ Dynamic difficulty feels adaptive
- ✅ 5+ minutes of engaging gameplay

### Week 4 Success
- ✅ Polished visuals and audio
- ✅ 60 FPS performance
- ✅ Builds run on all platforms
- ✅ Positive playtester feedback
- ✅ Clear path to production

---

## 12. Prototype Deliverables Checklist

### Code Deliverables
- [ ] Unity project (zipped or Git repo)
- [ ] Source code with comments
- [ ] Build files (Windows, Mac, Android)
- [ ] README with build instructions

### Documentation
- [ ] Feature list (implemented vs. planned)
- [ ] Known issues log
- [ ] Playtesting results summary
- [ ] Performance benchmark report

### Assets
- [ ] All art assets (sprites, particles)
- [ ] All audio files
- [ ] UI mockups/wireframes

### Presentation
- [ ] Gameplay video (2-3 minutes)
- [ ] Screenshot gallery (5-10 images)
- [ ] Pitch deck (10 slides)
  - Problem/solution
  - Core gameplay
  - Unique mechanics
  - Progression system
  - Target audience
  - Monetization plan
  - Competition analysis
  - Development roadmap
  - Team/skills
  - Ask/next steps

---

## Conclusion

This 4-week prototype plan focuses on **rapid iteration** and **proving the core fun** of Void Survivor. By keeping scope minimal and focusing on the essential gameplay loop, we can quickly determine if the game concept is viable before committing to full production.

**Key Principles:**
- 🎯 **Focus:** Core loop first, content later
- ⚡ **Speed:** Simple architecture for fast iteration
- 🎮 **Playability:** Daily playtests to ensure fun
- 📊 **Data:** Collect feedback to inform decisions
- 🚀 **Momentum:** Ship something playable every week

**Remember:** The goal is not perfection—it's learning and validation. Ship early, test often, iterate quickly!
