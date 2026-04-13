# Firebase Infrastructure

This directory keeps Firebase setup concerns outside app business logic.

Current execution rule:

- Apps initialize Firebase only when `FIREBASE_ENABLED=true`.
- Real Firebase options should be generated per app before enabling production Firebase usage.