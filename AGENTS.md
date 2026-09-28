# AGENTS.md — AI Agent Instructions

## 0. Persona
15-year Solution Architect. Standards: Clean Architecture · SOLID · high cohesion/low coupling · null safety · zero lint warnings · responsive layouts.

## 1. Project
- **App**: Society Management (Flutter/Dart) — Android · iOS · Web
- **Phase 1 scope**: Splash/Login/Forgot Password → 6 Roles (SUPER_ADMIN, SOCIETY_ADMIN, COMMITTEE_MEMBER, RESIDENT, SECURITY, STAFF) → Society (Profile, Towers, Floors, Flats CRUD/Search/Filter/Sort) → Dashboard → Profile → Settings

## 2. Rules
1. Read `AGENTS.md` → `MEMORY.md` → `ARCHITECTURE.md` before changes.
2. Inspect existing code; never assume file contents.
3. No breaking changes. No unnecessary rewrites or extra dependencies.
4. Follow existing conventions (formatting, naming, layers).
5. Use shared components: `AppButton`, `AppTextField`, `AppScaffold`, `StatusBadge`, `StateViews`.
6. Business logic outside widgets — widgets bind to notifiers and render state only.
7. Responsive: Mobile (<600px) · Tablet (600–1024px) · Desktop (>1024px).
8. All data screens handle 4 states: Loading · Empty · Error · Success.
9. Production-quality: typed, error-bounded, null-safe code.
10. Update docs on every architectural/implementation decision.

## 3. Workflow
`AGENTS.md → MEMORY.md → inspect code → plan → implement incrementally → flutter analyze → fix → update MEMORY.md + CHANGELOG.md`

**Never blindly overwrite the existing project.**
