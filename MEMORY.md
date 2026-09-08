# MEMORY.md — Persistent Technical Memory (Phase 1)

## 1. Current Project State

* **Current Phase**: Phase 1
* **Status**: In Development
* **Target Platforms**: Android, iOS, Web

### Phase 1 Scope Tracking

| Component | Status | Notes |
|---|---|---|
| Project Documentation & Memory | Completed | `AGENTS.md`, `MEMORY.md`, `SKILLS.md`, `ARCHITECTURE.md`, `CHANGELOG.md` |
| Flutter Foundation & pubspec | In Progress | Setting up dependencies, theme, responsive foundation |
| Core Navigation & Routing | In Progress | GoRouter, ShellRoute, Route guards |
| Authentication & Session | Pending | Splash, Login, Forgot Password, Secure Session |
| Role Management | Pending | 6 Roles, Permissions matrix, RoleGuard |
| Society Profile | Pending | View/Edit Profile, Logo storage abstraction |
| Tower Management | Pending | CRUD, status, delete protection |
| Floor Management | Pending | CRUD under Tower parent |
| Flat Management | Pending | CRUD, Search, Multi-Filter, Sorting |
| Dashboard | Pending | KPIs (Towers, Floors, Flats, Occupancy), Quick actions |
| User Profile | Pending | Profile details, Edit, Change password, Logout |
| Settings | Pending | Theme mode (System/Light/Dark), About, Legal placeholders |
| Verification & Testing | Pending | Unit tests, widget tests, integration tests |

### Known Issues & Constraints
* Environment contains Git via GitHub Desktop (`git version 2.53.0.windows.4`).
* Dart/Flutter SDK needs to be in environment path to execute `flutter test` and `flutter analyze`.

---

## 2. Architecture Decisions

### Decision: Feature-First Clean Architecture
* **Reason**: Separates UI, state management, domain rules, and data sources cleanly, preventing tight coupling and enabling independent testing.
* **Date**: 2026-09-09
* **Impact**: All features are organized under `lib/features/<feature_name>/{presentation, domain, data}` with explicit repository abstractions.

### Decision: State Management using Riverpod
* **Reason**: Compile-time safety, effortless test mocking without `BuildContext`, clean asynchronous state handling (`AsyncValue`).
* **Date**: 2026-09-09
* **Impact**: UI widgets remain purely declarative; controllers/notifiers manage business logic.

### Decision: Declarative Routing with GoRouter & Responsive Shell
* **Reason**: Supports Web URL synchronization, deep linking, authentication route guards, and desktop sidebar vs mobile navigation scaffolding.
* **Date**: 2026-09-09
* **Impact**: Clean navigation transitions and role-aware access controls.

### Decision: Repository Abstraction with Mock & Remote Data Sources
* **Reason**: Allows immediate, rich in-memory CRUD operations for all Phase 1 features while maintaining full readiness for a REST API client.
* **Date**: 2026-09-09
* **Impact**: Presentation layer has zero awareness of data source origin.

### Decision: Strictly Isolated Phase 1 Scope
* **Reason**: Ensure stability, maintainability, and zero contamination from subsequent phases.
* **Date**: 2026-09-09
* **Impact**: Features like resident assignment, maintenance tickets, and payment gateways are excluded.

---

## 3. Important Project Rules

1. **Flutter is the single codebase** across Android, iOS, and Web.
2. **Material 3 with centralized theming** must be used across all screens.
3. **No hardcoded colors, padding, or styles** inside widgets; use theme tokens.
4. **Role-based access control** is mandatory; both UI presentation and route guards enforce permissions.
5. **Society data hierarchy** (`Society -> Tower -> Floor -> Flat`) must maintain relational integrity with `societyId`.
6. **All data-driven screens** must explicitly handle 4 states: Loading, Empty, Error (with retry), and Success.
7. **Security**: Never store plain-text passwords, tokens, API secrets, or private credentials in repository files or memory.
