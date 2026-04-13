# LinguaNeural Kids - Language Learning App

## Reset Direction

The platform is entering a rebuild phase focused on a stable production core before advanced AI features return.

The product model remains four-role and multi-app:

- Student App: core learning experience.
- Teacher App: classroom guidance and intervention.
- Pedagogique App: curriculum and institutional management.
- Admin App: platform governance and control.

The rebuild strategy is student-first outward, rather than evolving all four apps in parallel.

The reset philosophy is `start clean, grow correctly`:

- Do not deeply fix or refactor the current codebase.
- Do not carry over complex or experimental logic.
- Do not implement AI, adaptive, or emotion-aware features yet.
- Recreate the foundation cleanly, keep only proven architecture decisions, and build the product core first.

The target clean monorepo structure is:

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

Architecture principles:

- `packages/core` = brain.
- `packages/design_system` = visual identity.
- Apps = thin layers with UI and role logic only.

See [REBUILD_RESET_PLAN.md](c:\Users\user\OneDrive\Documents\M2 S2\lingua_neural_kids_app_version 1.0\REBUILD_RESET_PLAN.md) for the current reset strategy.

A clean Flutter monorepo for the rebuilt language learning platform.

## Current Scope

- `apps/student_app` is the only active product app.
- `apps/teacher_app`, `apps/pedagogique_app`, and `apps/admin_app` are intentionally minimal.
- `packages/core` contains shared models and services.
- `packages/design_system` contains shared theme and UI components.
- `infrastructure/` holds environment and Firebase support files.

## Quick Start

1. Choose the app or package you want to work on.
2. Install dependencies inside that directory.
3. Run validation from the target directory.
4. For the student app, use `APP_ENVIRONMENT` and `FIREBASE_ENABLED` dart defines when running or building.