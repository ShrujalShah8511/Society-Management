# MEMORY.md — Persistent Technical Memory (Phase 1)

## 1. Current Project State

* **Current Phase**: Phase 1
* **Status**: In Development
* **Target Platforms**: Android, iOS, Web

### Phase 1 Scope Tracking

| Component | Status | Notes |
|---|---|---|
| Project Documentation & Memory | Completed | `AGENTS.md`, `MEMORY.md`, `SKILLS.md`, `ARCHITECTURE.md`, `CHANGELOG.md` |
| Flutter Foundation & pubspec | Completed | Dependencies, M3 Light/Dark Themes, Responsive foundation |
| Core Navigation & Routing | Completed | GoRouter, ShellRoute, Route guards, Responsive AppScaffold |
| Authentication & Session | Completed | Splash, Login, Forgot Password, Secure Session storage |
| Role Management | Completed | 6 Roles, Permissions matrix, RoleGuard helpers |
| Society Profile | Completed | View/Edit Profile, Logo storage abstraction via FileStorageService |
| Tower Management | Completed | CRUD, active/inactive status, relational delete protection |
| Floor Management | Completed | Cascading CRUD under Tower parent, relational delete protection |
| Flat Management | Completed | CRUD, Search, Multi-Facet Filters, Sort by number & area |
| Dashboard | Completed | KPIs (Towers, Floors, Flats, Occupied, Vacant), Occupancy bar, Quick actions |
| User Profile | Completed | Profile details, Edit name/phone, Change password, Sign out |
| Settings | Completed | Theme mode (System/Light/Dark), About, Legal placeholders |
| Verification & Testing | Completed | Unit tests, widget tests, integration flow tests (58 passing tests) |
| Dynamic Society Branding | Completed | Optional logo upload (Web/Device/URL), reactive favicon/title sync, SocietyLogoWidget monogram fallbacks |

### Known Issues & Constraints
* Environment contains MinGit & Flutter SDK (v3.47.2 / Dart v3.13.2) under `scratch/tools/` and configured in User `PATH`.
* Phase 1 web server runs on `http://localhost:8080`.
* Default seed society (Shyam Heights) logo initialized to `null`; dynamically customizable per society.

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
8. **100% Mobile & Desktop UI Feature Parity**: Mobile screens (`_buildMobileScaffold`) must maintain full feature parity with the desktop layout. This includes the hamburger navigation drawer containing all categorized links (Overview, Infrastructure, Organization, Preferences), the active society switcher, user profile card with role badge, and full Sign Out / Logout capabilities with confirmation dialog.
