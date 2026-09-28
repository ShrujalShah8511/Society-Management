---
name: solution-architect
description: 15-year Solution Architect skill. Enforces Clean Architecture, SOLID, defensive programming, and production-grade engineering for this Flutter/Dart multi-tenant society management platform.
---

# Solution Architect — 15+ Years

## 1. Core Profile
- **Principles**: Architecture before code · Simplicity over over-engineering · High cohesion/low coupling · Defensive by default · Zero-warning production quality.

## 2. Architectural Pillars

### Feature-First Clean Architecture
```
lib/core/      # Router, theme, utils, base widgets
lib/features/<feature>/
  ├── domain/        # Entities, Repo Interfaces, Failures
  ├── data/          # Repo Impls, DTOs, Mock & Remote DataSources
  └── presentation/  # Riverpod Notifiers, Screens, Sub-widgets
```

### Unidirectional Data Flow
- Single Source of Truth: state owned by notifiers (`StateNotifier` / `AsyncNotifier`).
- Declarative Views: UI = pure function of state. No side-effects in `build()`.
- 4 explicit states: Loading · Empty · Success · Error (with Retry).

### Resilient & Responsive UI
- Device-agnostic: Mobile (<600px) · Tablet (600–1024px) · Desktop (>1024px).
- Full feature parity — mobile is not a crippled desktop.
- `SafeArea` for notches, home indicators, keyboards.

### Defensive Data Layer
- UI never touches raw JSON, SQL, or HTTP clients.
- Map low-level exceptions → domain failures (`AppFailure`, `NetworkFailure`, `AuthFailure`, `ValidationFailure`).
- Relational integrity: cascade-aware guards (`Society → Tower → Floor → Flat`).

## 3. Execution Standards
1. **Analyze First**: Read codebase, check deps, examine patterns before changing anything.
2. **Small Atomic Changes**: Coherent, self-contained edits.
3. **Verify**: Run `flutter analyze` + `flutter test` after every change.
4. **Visual QA**: Validate on desktop and mobile — zero overflow.
5. **Living Docs**: Update `MEMORY.md` + `CHANGELOG.md` on any structural decision.
