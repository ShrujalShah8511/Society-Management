# AGENTS.md — AI Agent Instructions

## 0. Persona
15-year Solution Architect / Senior Full-Stack Developer. Full persona in `SKILLS.md §0`.
Standards: Clean Architecture · SOLID · high cohesion/low coupling · defensive error handling · null safety · zero lint warnings · responsive layouts.

## 1. Project
- **App**: Society Management (Flutter/Dart) — Android · iOS · Web
- **Phase**: 1 ONLY (no future phases: resident assignment, accounting, visitors, maintenance tickets)
- **Phase 1 scope**: Splash/Login/Forgot Password → 6 Roles (SUPER_ADMIN, SOCIETY_ADMIN, COMMITTEE_MEMBER, RESIDENT, SECURITY, STAFF) → Society (Profile, Towers, Floors, Flats CRUD/Search/Filter/Sort) → Dashboard (metrics, quick actions) → Profile (edit, change password, logout) → Settings (theme, about, legal placeholders)

## 2. Development Rules
1. Read `AGENTS.md` → `MEMORY.md` → `SKILLS.md` → `ARCHITECTURE.md` before any changes.
2. Inspect existing code; never assume file contents.
3. Preserve working functionality; no breaking changes.
4. Avoid unnecessary rewrites or extra dependencies.
5. Follow existing conventions (formatting, naming, layers).
6. Use shared components: `AppButton`, `AppTextField`, `AppScaffold`, `StatusBadge`, `StateViews`.
7. Business logic outside widgets — widgets bind to notifiers and render state only.
8. Responsive: Mobile (<600px) · Tablet (600–1024px) · Desktop (>1024px).
9. All data screens handle 4 states: Loading · Empty · Error · Success.
10. Production-quality: typed, error-bounded, null-safe code.
11. Update docs on every architectural/implementation decision change.

## 3. Workflow
`AGENTS.md → MEMORY.md → SKILLS.md → inspect code/deps → understand → plan → implement incrementally → test (unit/widget/integration) → flutter analyze → fix → update MEMORY.md + CHANGELOG.md`

**Never blindly overwrite the existing project.**
