# NEXII — Context for Development Agents

> Read this file first. It is the compact product + architecture contract for Nexii.
> It exists to prevent every development generation from rediscovering the project from scratch.
> For any task, read this file, inspect only the directly relevant files, implement, validate, and stop.

---

## 1. PRODUCT

**Nexii** is an adaptive personal intelligence / productivity platform.

Core idea:

> **Nexii should not show everything it knows. It should use what it knows to decide what deserves to be shown.**

Nexii is designed to reduce decision fatigue, not become another information-heavy dashboard.

The product should feel like:
- calm intelligence;
- warm technology;
- context-aware assistance;
- a personal companion rather than a generic chatbot or dashboard;
- an interface that adapts without feeling like a machine is taking control.

The long-term product promise is simple:

> **Nexii helps the user understand what matters now, act with less friction, and see meaningful progress.**

---

## 2. CURRENT TECH STACK

### Mobile
- **Dart**
- **Flutter**

### Web
- **JavaScript / TypeScript**
- **React + Vite**

### Backend
- **Node.js / Express**
- Main backend entry: `server.ts`

### Data / Auth
- **Firebase Authentication**
- **Firestore**
- Current Flutter data layer uses a **hand-written Firebase REST service**, not a full Firebase Flutter SDK architecture.

### AI
- **Gemini**, used server-side for AI capabilities such as Coach.

### Push notifications
- Planned/being implemented with **Firebase Cloud Messaging (FCM)**.

Do not introduce another framework/provider unless a task explicitly requires it and the existing architecture cannot support the requirement.

---

## 3. CANONICAL ARCHITECTURE

The canonical decision pipeline is:

```text
Raw application state
    ↓
ContextSnapshotBuilder
    ↓
ContextSnapshot
    ↓
IntelligenceService
    ↓
N1DecisionEngine
    ↓
N1Summary
    ↓
ExperienceEngine
    ↓
ExperienceState
    ↓
UI / presentation
```

### Single decision authority
`N1DecisionEngine`

N1 is the **only** canonical decision authority.

### Single Experience-mode authority
`ExperienceEngine`

ExperienceEngine is the **only** authority that determines the canonical Experience mode.

### UI rule
Screens consume canonical intelligence / `ExperienceState`.

Screens must NOT recreate:
- priority decisions;
- Experience modes;
- task ranking;
- pressure/recovery logic;
- intelligence-node decisions.

---

## 4. EXPERIENCE MODES

Nexii currently has exactly five canonical modes:

1. **Recovery**
2. **Pressure**
3. **CheckIn**
4. **Priority**
5. **Calm**

Conceptual meaning:

### Recovery
Quieter, more spacious, less demanding. The interface reduces pressure and lets secondary information recede.

### Pressure
Simplification and stabilization. Competing information becomes quieter; the important action becomes easier to identify.

### CheckIn
Reflective and conversational. The interface opens space without forcing an action.

### Priority
Concentrated attention around the existing canonical primary action.

### Calm
Balanced baseline. Normal density and restrained motion.

**Do not create a sixth mode.**

Do not select these modes locally in a screen.

---

## 5. INTELLIGENCE CAPABILITIES

Nexii's intelligence layer contains specialized capabilities including:

- **Observe** — structured factual observation of current context.
- **Understand** — context/workload interpretation.
- **Pulse** — present-state/recovery-oriented signal.
- **Living Goals** — goal state / goal-risk understanding.
- **Anticipate** — forward-looking workload/risk signals.
- **Recommend** — advisory recommendations subordinate to canonical decision-making.
- **Measure** — truthful measurement of progress/state/change supported by available data.
- **Aura** — structured representation of current state, not a second mode engine.

Important:

> A node/file existing does not prove it is production-active. When a task depends on a node's active status, verify only that node's direct execution path.

Do not re-audit the whole intelligence system for every screen task.

---

## 6. ABSOLUTE INTELLIGENCE RULES

### A. ZERO HEURISTIC PRODUCT INTELLIGENCE

Never introduce:
- arbitrary thresholds;
- weighted scores;
- points;
- hidden rankings;
- rule-of-thumb ladders;
- screen-local `if/else` intelligence;
- arbitrary confidence formulas;
- local priority engines;
- local mode-selection logic.

Forbidden examples:

```text
battery < 35 → Recovery

number of tasks > 5 → Pressure

taskScore = urgency * 0.4 + priority * 0.6
```

These are not acceptable substitutes for canonical intelligence.

### B. ZERO SHALLOW / UNDER-DEVELOPED INTELLIGENCE

Do not replace real intelligence with one-input → one-output mappings such as:

```text
low battery → Recovery
many tasks → Pressure
goal near deadline → recommend goal
battery → Aura score
completed/total → productivity intelligence
```

Use the richest relevant canonical context already available.

The target is:

**RICH + STRUCTURED + CONTEXTUAL + JUSTIFIABLE + HONEST**

Do not create unnecessary complexity just to look intelligent.

### C. HONEST DATA

Never invent:
- user history;
- long-term memory;
- trends without history;
- percentages without valid denominators;
- emotions or psychological states not supported by actual data;
- AI confidence values that do not have a real semantic basis.

---

## 7. VISUAL PHILOSOPHY

Nexii's visual identity is behavioral, not decorative.

The interface should feel:
- intelligent;
- calm;
- deep;
- refined;
- warm;
- responsive;
- memorable;
- restrained.

The visual "✨" comes from:
- hierarchy;
- spacing;
- depth;
- typography;
- controlled surfaces;
- semantic emphasis;
- meaningful motion;
- continuity between screens.

NOT from:
- excessive glassmorphism;
- random gradients;
- particles;
- shimmer;
- permanent glow;
- futuristic HUD decoration;
- constant animation.

The governing principle is:

> **Intelligence changes emphasis before it changes structure.**

The user should feel:

> **"Nexii adapted."**

not:

> "The app played an animation."

---

## 8. NEXII PULSE

**Pulse** is the visual response to a meaningful ExperienceState change.

Conceptual flow:

```text
Context
  ↓
Intelligence
  ↓
ExperienceState changes
  ↓
Pulse
  ↓
Hierarchy / density / emphasis / motion shift
  ↓
UI settles
```

Preferred motion tools:
- `AnimatedSwitcher`
- `AnimatedOpacity`
- `AnimatedPadding`
- subtle translation
- subtle scale
- existing `NexiiMotion` tokens

Do NOT create an animation storm.
Do NOT animate every child.
Do NOT create continuous decorative motion.

Reduced motion must respect:
`MediaQuery.disableAnimations`

---

## 9. EXISTING VISUAL SYSTEM

Reuse the existing design system:

- `NexiiColors`
- `NexiiSpacing`
- `NexiiRadii`
- `NexiiMotion`
- `AdaptiveSurface`
- existing typography / shared widgets

Do not create a second color palette or a second design system.

Common visual grammar:

### Standard density
Normal information visibility and normal spacing.

### Reduced density
Secondary information visually recedes while important controls remain fully available.

### Minimal density
Secondary information becomes very quiet; essential controls remain visible and interactive.

There should be no unnecessary fourth density category.

---

## 10. CURRENT CORE NAVIGATION

Primary navigation is intended to be:

1. **Home**
2. **Tasks**
3. **Focus**
4. **Progression**
5. **Coach**
6. **Hub**

The **Hub** is the canonical home for secondary functionality such as:
- Goals
- Missions
- Agenda
- Aura
- Finance

**Profile is not a primary tab.**
It remains accessible from the Profile icon on Home.

Do not add every secondary surface to bottom navigation.

---

## 11. CORE SURFACE ROLES

### Home
"What matters now?"

Home is the **visual reference surface** for Nexii.
Its primary experience should make the user's current important context feel obvious without becoming a dashboard.

### Tasks
"What do I need to do?"

Tasks consumes canonical `ExperienceState`, especially `dominantFocus`, `primaryAction`, and canonical reason where relevant.
It must not independently rank tasks.

### Focus
"Help me act."

Focus consumes canonical `ExperienceState` and adapts visual emphasis, density, and motion while preserving timer semantics.

Actual timer modes currently verified in code are:
- **Pomodoro — 25 min**
- **Cohérence — 2 min**
- **Flow — 50 min**

Do not assume older documentation values are still valid.

### Progression
"What is changing?"

Progression should use truthful Measure/Aura data and avoid dashboard overload.

### Coach
"Help me understand / decide / act."

Coach is contextual, not a generic chatbot. It uses canonical context and keeps all actions user-triggered.

### Hub
"Everything else I may need."

Hub contains secondary capabilities without turning them into competing primary destinations.

---

## 12. TRUST / AUTH / DATA DIRECTION

Nexii is moving toward a real first-run experience built around:

```text
Welcome
→ understand Nexii
→ understand data use
→ trust / control
→ sign in / register
→ essential profile
→ essential preferences
→ personalized explanation based on real data
→ Home
→ interactive first-run product guide
```

The first-run guide must teach Nexii through REAL interaction, not slides like:
"Home = Home".

The guide should let the user:
- interact with Home;
- discover Tasks;
- understand Focus;
- experience Progression;
- interact with Coach explicitly;
- discover Hub;
while avoiding automatic destructive/product actions.

Only ask for data that the current product actually uses.

---

## 13. DATA USE PRINCIPLE

For every important user datum, Nexii should be explainable through:

```text
User data
↓
Where it is stored
↓
How it enters context
↓
Which intelligence can use it
↓
Which experience it can influence
```

If a field is collected but not actually used:
- do not claim it powers intelligence;
- do not invent a reason after the fact;
- report the gap when relevant.

---

## 14. COACH INTEGRATION RULES

Coach should have ONE canonical request path where consolidation is safe.

Coach must not use fabricated:
- `aiLongTermMemory`
- `personalTimeline`

as real user memory.

Coach actions must be grounded in genuine canonical context.

Coach must not create a second priority or Experience-mode system.

Backend authentication/security is a separate infrastructure concern and should not be mixed into UI/experience tasks.

---

## 15. EXTERNAL NOTIFICATIONS

External push notifications are a distinct system from in-app notifications.

Planned architecture:

```text
Canonical Intelligence
↓
Notification Decision
↓
SEND / SILENCE / DEFER
↓
FCM
↓
Notification
↓
Deep link into Nexii
```

Rules:
- silence is a valid outcome;
- no engagement spam;
- no streak pressure;
- no "we miss you" messages;
- no repeated notifications because the user did not open the app;
- no notification driven by arbitrary heuristics.

---

## 16. DATA / SYNC PRINCIPLES

Firestore synchronization must preserve data integrity.

Required invariants:
- no silent data loss;
- no blind stale overwrite;
- one controlled write path per user document;
- failed writes remain observable/retryable;
- polling must not erase unsaved changes;
- account switching invalidates old sync work;
- sync failures are distinguishable;
- no uncontrolled concurrent full-document writes.

Current Flutter persistence architecture uses a hand-written Firebase REST service. Do not casually migrate it during unrelated feature work.

---

## 17. SECURITY PRINCIPLES

For protected backend APIs:

```text
Firebase ID token
→ server-side verification
→ verified UID
→ endpoint
```

Never trust a client-provided `userId` as proof of identity.

Production backend should use:
- explicit CORS allowlist;
- route-appropriate rate limiting for expensive AI endpoints;
- targeted input validation;
- server-side secrets;
- safe error responses;
- no token/credential logging.

Security changes belong to security generations, not random UI tasks.

---

## 18. ENGINEERING RULES FOR AGENTS

### Scope first
Every generation must define its file scope.

### Analyze proportionally
Read enough to act correctly.
Do not reconstruct all of Nexii every time.

### Code quickly once context is sufficient
The expected rhythm is:

```text
Targeted inspection
→ implementation
→ focused validation
→ fix concrete failures
→ STOP
```

### Keep command-to-code ratio low
Do NOT turn implementation into:

```text
find → grep → cat → grep → find → analysis → grep → ...
```

Once relevant facts are known, edit the code.

### Preserve working code
Do not rewrite existing working systems for stylistic reasons.

### No giant refactors
Prefer the smallest coherent patch.

### No fake progress
Do not create placeholder intelligence just to make a feature appear complete.

### No invented APIs
Use actual project types and methods.

### No broad test campaigns during every generation
Run focused tests for the changed area and `flutter analyze`.
Reserve full-suite validation for major checkpoints / Release Candidate.

### Always stop
When success criteria are met, STOP.
Do not continue exploring or refactoring without a concrete reason.

---

## 19. CURRENT DEVELOPMENT ROADMAP

The current intended sequence is:

01 — Coach
02 — Visual Experience System
03 — Observe / Recommend / Measure / Aura
04 — Progression Experience
05 — Hub + Navigation
06 — Secondary Surfaces
07 — Trust Onboarding + Authentication + Data Use + Interactive First-Run Guide
08 — External Intelligent Notifications
09 — Backend Security Hardening
10 — Firestore Sync Hardening
11 — Data / Session / Privacy Lifecycle
12 — Network Resilience
13 — Performance
14 — Accessibility + Adaptive UI
15 — Localization + Content Integrity
16 — Final ✨ Experience Polish
17 — Release Candidate Audit
18 — Google Play Release Readiness

Do not combine these generations unless explicitly instructed.
One generation = one focused objective.

---

## 20. RELEASE PHILOSOPHY

The goal is not "more features".

The goal is:

**A coherent, intelligent, trustworthy, visually memorable, technically reliable product that can be used by real people.**

The final product should feel:

> **Nexii, not a collection of features.**

The interface should feel:

> **alive because intelligence changes its behavior, not because the screen contains more effects.**

And the engineering should feel:

> **careful because the architecture is understood, not slow because the repository is endlessly re-explored.**

---

## 21. GOLDEN RULE

When uncertain during a task:

1. preserve the existing canonical architecture;
2. use the richest real context already available;
3. do not invent intelligence;
4. do not introduce heuristics;
5. do not make a shallow substitute;
6. make the smallest coherent change;
7. validate the changed area;
8. stop.

**Nexii should become more intelligent, more beautiful, and more reliable without becoming more chaotic.**
