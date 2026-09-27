# CHANGELOG.md — Phase 1 Development History

## [1.0.0] — Complete Phase 1 (2026-09-09)

### Added
- AI agent docs: `AGENTS.md`, `MEMORY.md`, `SKILLS.md`, `ARCHITECTURE.md`, `CHANGELOG.md`; Git on `main`.
- **`lib/core/`**: M3 light/dark themes, typography, responsive layout, `AppButton`, `AppTextField`, `StatusBadge`, `StateViews`, `ConfirmDialog`, `AppScaffold`, secure session storage, mock file storage, formatters, validators.
- **`lib/features/authentication/`**: DataSources, repository, `AuthNotifier`, Splash, Login (quick-login role selector), Forgot Password, Profile (edit name/phone, change password, sign out).
- **`lib/features/role/`**: 6 roles (`SUPER_ADMIN`, `SOCIETY_ADMIN`, `COMMITTEE_MEMBER`, `RESIDENT`, `SECURITY`, `STAFF`), permission matrix, role guard helpers.
- **`lib/features/society/`**:
  - Entities: `Society`, `Tower`, `Floor`, `Flat`.
  - Relational data sources & repos with integrity enforcement (no delete Tower with Floors; no delete Floor with Flats).
  - Screens: `SocietyProfileScreen` (view/edit, logo upload), `TowerListScreen` (search, responsive grid, modal form), `FloorListScreen` (tower-filter, cascading dialog, CRUD), `FlatListScreen` (multi-filter: tower/floor/occupancy/type, search by number, sort by number/area, detail modal, form dialog).
- **`lib/features/dashboard/`**: `DashboardNotifier`, KPIs (Towers/Floors/Flats/Occupied/Vacant), occupancy distribution bar, society banner, quick actions.
- **`lib/features/settings/`**: `SettingsNotifier`, theme selector (System/Light/Dark + SharedPrefs), about modal, legal placeholders.
- **`lib/app/`**: GoRouter + route guards, ShellRoute, desktop sidebar vs mobile bottom nav, global Riverpod DI (`providers.dart`).
- **Dynamic Society Branding**: logo upload (Web/Device/URL), reactive favicon/title sync, monogram fallback.
- **Tests** (58 passing): unit (`role`, `auth`, `society`, `flat`, `validators`), widget (`login`, `dashboard`, `flat_management`), integration flow (Login → Role → Tower → Floor → Flat + relational delete protection).

### Decisions
- Phase 1 scope strictly isolated; no resident assignment, payments, or maintenance tickets.
- Riverpod: compile-time safe, context-free mocking, clean `AsyncValue` handling.
- Dual data source (Mock + Remote) behind abstract repositories; presentation has zero data-origin awareness.
- Zero external UI dependencies — pure Flutter Material 3.
