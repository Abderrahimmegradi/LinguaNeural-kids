# LinguaNeural Kids Rebuild Reset Plan

## Purpose

LinguaNeural Kids is entering a reset phase. This is a rebuild from a clean foundation, not another round of incremental fixes on the current implementation.

The objective is to produce a stable, production-ready learning platform core before reintroducing advanced features such as adaptive learning, emotion-aware behavior, face analysis, or AI-driven personalization.

This plan preserves the product vision and lessons learned, while intentionally discarding unstable implementation baggage.

## Product Vision Reconfirmed

LinguaNeural Kids remains a multi-role educational platform composed of four applications:

- Student App: core learning experience.
- Teacher App: classroom guidance and intervention.
- Pedagogique App: curriculum and institutional management.
- Admin App: platform governance and control.

The strategic change is not the role model. The strategic change is sequencing.

The platform will now be rebuilt from the student experience outward, instead of trying to evolve all four apps in parallel.

## Reset Strategy

This rebuild follows a `start clean, grow correctly` philosophy.

### Do Not

- Do not try to fix or deeply refactor the current codebase.
- Do not carry over complex, unstable, or experimental logic.
- Do not implement AI, adaptive learning, emotion-aware behavior, or other intelligence features yet.
- Do not treat legacy code as a shortcut to the new product core.

### Instead

- Recreate the project foundation from scratch.
- Keep only proven architecture decisions.
- Focus on clarity, simplicity, and stability.
- Build a strong product core first, then expand.

### Practical Meaning

- The current repository is a reference source, not the implementation base.
- Reuse is allowed only for validated concepts, stable assets, and proven structural decisions.
- Rewriting a feature cleanly is preferred over untangling a partially successful legacy implementation.
- Advanced intelligence returns only after the core product is coherent, testable, and operationally stable.

## Current Reality

The repository already shows useful direction, but it also shows why a reset is necessary:

- A deprecated root app still exists alongside the four role-based apps.
- Shared packages exist, but responsibilities are still mixed.
- Several implementation-summary documents describe partial fixes rather than a stable product baseline.
- Firebase, audio, lessons, and UI flows have been improved in pieces, but the platform still reflects uneven product maturity across student, teacher, pedagogique, and admin experiences.

The result is a codebase that contains valuable knowledge, but should no longer be treated as the implementation foundation for the next product phase.

## Reset Principles

1. Rebuild the product, not the current code.
2. Keep the vision, discard accidental complexity.
3. Start clean rather than performing deep salvage work.
4. Ship one solid core before expanding capability.
5. Prefer shared domain and UI architecture over role-specific duplication.
6. No advanced intelligence features until the deterministic product loop is stable.
7. Every feature must justify its place in the first production core.

## What Survives The Reset

These items should be preserved conceptually and used as inputs for the new build:

- Product mission: a high-quality language learning platform for children.
- Core roles: student, teacher, pedagogique, and admin.
- Student-first prioritization.
- The four-app product model, rebuilt outward from the student app.
- Only proven architecture decisions should be carried into the rebuild.
- Existing lesson and progress concepts.
- Firebase as the initial backend platform, unless a later audit proves otherwise.
- The monorepo direction with multiple apps and shared packages.
- Lessons learned from audio, auth, onboarding, and curriculum work already done.

## What Does Not Survive The Reset

These items should not be carried forward automatically:

- Legacy screens, providers, and services copied directly into the new core.
- The deprecated root application as an active runtime target.
- Mixed experimental features bundled into the base learning loop.
- One-off fixes treated as architecture.
- Any feature that exists without clear ownership, tests, or acceptance criteria.
- Any UI flow that was added before the domain model was made coherent.

Code may be referenced for learning, but nothing is inherited by default.

## Product Scope For The New Core

The new core is intentionally narrow.

### In Scope

- Stable authentication and role routing.
- Clean student onboarding.
- Deterministic lesson discovery and lesson playback.
- Core exercise types with reliable progression.
- Progress tracking, streaks or XP only if implemented simply and consistently.
- Content retrieval and content publishing flows that support the student experience.
- Minimal operational interfaces for teacher, pedagogique, and admin where required to support the student product.
- Production-grade design system, navigation, error handling, and offline-aware loading states.

### Explicitly Postponed

- Adaptive learning logic.
- Emotion-aware or face-based reactions.
- AI tutors, AI scoring, or AI-generated lesson behavior.
- Personalization engines.
- Complex gamification layers beyond what is needed for a coherent first release.
- Any feature whose success depends on non-deterministic model output.

### Boundary Rule

Speaking exercises may remain in scope only as a deterministic product mechanic, such as record, replay, or simple completion flow. AI evaluation of speech quality is out of scope for the reset core.

## Target Architecture

The rebuilt platform should keep the Flutter monorepo model, but with stricter discipline and clearer boundaries.

### Clean Version

```text
linguaneural_kids/
|
+-- apps/
|   +-- student_app/
|   +-- teacher_app/
|   +-- pedagogique_app/
|   +-- admin_app/
|
+-- packages/
|   +-- core/
|   +-- design_system/
|
+-- infrastructure/
    +-- firebase/
    +-- configs/
```

This is the target structure for the rebuilt product core. It is intentionally smaller and stricter than the current repository shape.

### Workspace Roles

- `apps/student_app`: first-class product app and first release target.
- `apps/teacher_app`: empty or minimal at first, then expanded only when the student core is stable.
- `apps/pedagogique_app`: empty or minimal at first, then used for curriculum and institutional management.
- `apps/admin_app`: content, configuration, and platform operations.
- `packages/core`: models, services, repositories, use cases, and business logic.
- `packages/design_system`: UI components, themes, tokens, and shared visual identity.
- `infrastructure/firebase`: Firebase initialization, rules, environment wiring, and deployment-related setup.
- `infrastructure/configs`: shared environment and platform configuration.

### Layering Principles

- `core` package = brain.
- `design_system` = visual identity.
- Apps = thin layers containing UI composition and role-specific behavior only.

### Practical Rules

- Business logic belongs in `packages/core`, not inside app screens.
- Shared visual components belong in `packages/design_system`, not duplicated across apps.
- Apps should stay small and role-focused.
- `student_app` is the only app that should receive full product investment at the start.
- `teacher_app`, `pedagogique_app`, and `admin_app` may remain empty or minimal until their turn in the rebuild sequence.
- Infrastructure concerns should live outside app and package feature code where possible.

### Transition Note For The Current Repository

The repository has now completed the hard-clean phase.

Legacy `apps/school_app`, `packages/backend_core`, and `packages/shared_ui` have been removed.

The target clean version is:

- `apps/pedagogique_app` instead of `apps/school_app`.
- `packages/core` instead of fragmented or legacy backend-sharing structures.
- `packages/design_system` instead of generic shared UI packaging.
- `infrastructure/` as a first-class top-level layer.

### Architectural Rules

1. Domain models do not depend on Flutter widgets.
2. Screens do not talk directly to Firebase.
3. Business logic lives in `packages/core`.
4. Shared visual logic lives in `packages/design_system`.
5. Apps own composition, not shared business logic.
6. Navigation, auth, and theme setup must be consistent across apps.
7. Experimental features stay behind clean interfaces and are not compiled into the core loop.

## Rebuild Sequence

The reset should be executed in waves with hard gates.

### Wave 0: Freeze And Audit

Goal: stop adding incremental product features to the legacy implementation.

Deliverables:

- Mark the legacy root app as archived, not recoverable as the main app.
- Audit current assets, models, lesson data, Firebase collections, and reusable UI parts.
- Produce a keep, rewrite, or discard inventory.
- Define the canonical product vocabulary for users, lessons, exercises, progress, assignments, and organizations.

Exit criteria:

- The team agrees that no legacy module is automatically trusted for reuse.
- A concise inventory exists for data, flows, and UI assets.

### Wave 1: Foundation Scaffold

Goal: create the new platform skeleton.

Deliverables:

- Fresh app shell for `student_app`.
- Empty or minimal shells for `teacher_app`, `pedagogique_app`, and `admin_app`.
- Shared design tokens and component baseline in `packages/design_system`.
- Core models, services, and business logic boundaries in `packages/core`.
- Environment configuration and Firebase bootstrapping under `infrastructure/firebase` and `infrastructure/configs`.
- Monorepo folder structure aligned with the clean version target.
- Linting, formatting, CI checks, and test conventions.

Exit criteria:

- A new engineer can run the student app from clean checkout without legacy setup ambiguity.
- Auth, routing, theming, and environment loading all work predictably.

### Wave 2: Student Core Product

Goal: build one excellent student experience end to end.

Deliverables:

- Welcome, login, and onboarding.
- Home and lesson catalog.
- Lesson player with a limited set of exercise types.
- Progress persistence.
- Stable loading, empty, retry, and error states.
- Accessibility and responsive behavior for the target devices.

Exit criteria:

- A student can sign in, start lessons, complete lessons, and see progress without dead ends or partial screens.
- The student flow is usable without any advanced AI feature enabled.

### Wave 3: Content And Operations Minimum

Goal: enable the system to support real content operations.

Deliverables:

- Admin content creation or import pipeline.
- Published versus draft lesson states.
- Basic validation for curriculum data.
- Safe edit and release workflow for lessons.

Exit criteria:

- Content can be created, reviewed, published, and consumed by the student app without manual database patching.

### Wave 4: Teacher And School Minimum

Goal: add only the operational capabilities needed around the student product.

Deliverables:

- Teacher class or learner overview.
- Assignment or recommendation flow if required for the core release.
- Pedagogique-level curriculum and institutional management only where operationally necessary.

Exit criteria:

- Teacher and pedagogique workflows support student success and do not introduce duplicated backend logic.

### Wave 5: Hardening

Goal: make the rebuilt product production-ready.

Deliverables:

- Integration tests for critical flows.
- Crash and error monitoring.
- Performance budget for startup and lesson load.
- Security review of auth, Firestore rules, and role permissions.
- Data migration and seed strategy.

Exit criteria:

- The platform is stable enough for real pilot usage.
- Release confidence does not depend on manual heroics.

### Wave 6: Advanced Intelligence Reintroduction

Goal: reintroduce postponed intelligence features only after the core is proven stable.

Potential candidates:

- Adaptive lesson sequencing.
- Voice-signal analysis.
- Emotion-aware feedback.
- AI-assisted tutoring or content support.

Gate:

- No advanced feature proceeds unless the deterministic core remains stable with it removed.

## App Prioritization

The rebuild should be sequenced by business dependency, not by symmetry.

1. Student app.
2. Admin content workflow needed to feed the student app.
3. Teacher workflow needed to support usage and oversight.
4. Pedagogique workflow needed for curriculum and institutional control.

This order prevents the platform from spending effort on polished control surfaces before the learner experience is dependable.

## Data Strategy

The reset should treat data as a first-class design concern.

Rules:

- Define canonical entities before rebuilding screens.
- Normalize role relationships and permissions early.
- Separate draft content from published content.
- Design migrations and seeds as repeatable scripts, not manual console work.
- Keep analytics and adaptive inputs outside the core transactional schema until needed.

## Engineering Guardrails

1. No direct carryover of legacy modules without review.
2. No screen is considered complete without loading, empty, and error states.
3. No role app may fork shared logic that belongs in a package.
4. No new feature enters scope without a written acceptance definition.
5. No AI dependency is allowed inside the first production loop.
6. Documentation must describe the new architecture, not legacy fixes.

## Definition Of Done For The Reset Core

The reset phase is complete only when all of the following are true:

- The student app is coherent, stable, and pilot-ready.
- Teacher, pedagogique, and admin surfaces exist only to the degree required by the core product.
- Shared packages have clear ownership and boundaries.
- The deprecated root app is no longer part of normal development.
- Critical flows are covered by automated tests.
- Deployment, configuration, and data seeding are reproducible.
- The platform can operate successfully without adaptive or emotional AI layers.

## Immediate Next Actions

1. Freeze incremental feature work in the legacy implementation.
2. Create a short keep, rewrite, or discard audit for current modules and assets.
3. Select the canonical new package structure before further coding.
4. Start the rebuild with `apps/student_app` as the only first-class delivery target.
5. Define the minimum admin content workflow required to support student lessons.

## Final Direction

LinguaNeural Kids should now be treated as a product being rebuilt around a stable learning core.

The old repository remains useful as research material, reference flows, and lesson extraction input. It should not remain the architectural baseline.

The next successful version of LinguaNeural Kids will be simpler, narrower, and more disciplined than the current one. That is the point of the reset.