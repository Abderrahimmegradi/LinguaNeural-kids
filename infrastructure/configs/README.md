# Infrastructure Configs

This directory holds environment-oriented configuration inputs for the rebuilt monorepo.

Runtime keys:

- `APP_ENVIRONMENT`
- `FIREBASE_ENABLED`

Example:

```bash
flutter run --dart-define=APP_ENVIRONMENT=development --dart-define=FIREBASE_ENABLED=false
```