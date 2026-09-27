# MEMORY.md — Persistent Technical Memory (Phase 1)

## 1. Current State
Phase 1 · In Development · Targets: Android, iOS, Web · Flutter v3.47.2 / Dart v3.13.2 (under `scratch/tools/`, on PATH) · Web: `http://localhost:8080`

| Component | Status | Notes |
|---|---|---|
| Docs & Memory | ✅ | AGENTS, MEMORY, SKILLS, ARCHITECTURE, CHANGELOG |
| Flutter Foundation | ✅ | pubspec deps, M3 Light/Dark themes, responsive base |
| Navigation/Routing | ✅ | GoRouter, ShellRoute, guards, responsive AppScaffold |
| Auth & Session | ✅ | Splash, Login, Forgot Password, secure session storage |
| Role Management | ✅ | 6 roles, permission matrix, RoleGuard |
| Society Profile | ✅ | View/Edit, logo via FileStorageService |
| Tower Mgmt | ✅ | CRUD, active/inactive, relational delete protection |
| Floor Mgmt | ✅ | Cascading CRUD under Tower, relational delete protection |
| Flat Mgmt | ✅ | CRUD, search, multi-filter, sort by number/area |
| Dashboard | ✅ | KPIs (Towers/Floors/Flats/Occupied/Vacant), occupancy bar, quick actions |
| User Profile | ✅ | Details, edit name/phone, change password, sign out |
| Settings | ✅ | Theme (System/Light/Dark), About, legal placeholders |
| Testing | ✅ | 58 unit/widget/integration tests passing |
| Dynamic Branding | ✅ | Logo upload (Web/Device/URL), reactive favicon/title, monogram fallback |

**Seed society**: Shyam Heights · Near Sargasan Cross Road, Sargasan, Gandhinagar, GJ 382421 · RERA: `PR/GJ/GANDHINAGAR/GANDHINAGAR/OTHERS/MAA10020/130422` · contact@shyamheights.in · +91 9876543210 · logo = `null` (customizable).

## 2. Architecture Decisions
| Date | Decision | Impact |
|---|---|---|
| 2026-09-26 | **15-Year Architect persona** | Enterprise standards enforced on all engineering. Documented in `.agents/skills/solution-architect/SKILL.md`, `SKILLS.md §0`, `AGENTS.md §0`. |
| 2026-09-26 | **Cloudflare Pages + Supabase + Firebase** | Zero-cold-start CDN hosting; managed Postgres+Auth+Storage+RLS; FCM push + Analytics. Files: `web/_redirects`, `web/_headers`, `wrangler.toml`, `.github/workflows/deploy_cloudflare_pages.yml`, `supabase/migrations/`, `supabase/storage_setup.sql`, hybrid data layer (`SupabaseClientManager`, `SupabaseAuthDataSource`, `SupabaseSocietyDataSource`, `SupabaseFileStorageService`), `web/firebase-messaging-sw.js`. Runbook in `docs/cloud_architecture_and_deployment_guide.md`. |
| 2026-09-09 | **Feature-First Clean Architecture** | `lib/features/<f>/{presentation,domain,data}` with repository abstractions. |
| 2026-09-09 | **Riverpod state management** | Compile-time safety, no BuildContext for mocking, clean AsyncValue. |
| 2026-09-09 | **GoRouter + responsive shell** | Web URL sync, deep linking, auth guards, desktop sidebar vs mobile nav. |
| 2026-09-09 | **Mock & Remote dual data sources** | Presentation layer is data-source-agnostic. |
| 2026-09-09 | **Strict Phase 1 scope** | Resident assignment, maintenance tickets, payment gateways excluded. |

## 3. Project Rules
1. Single Flutter codebase — Android · iOS · Web.
2. Material 3 with centralized theming; no hardcoded colors/padding/styles.
3. RBAC mandatory — enforced in UI and route guards.
4. Society hierarchy `Society→Tower→Floor→Flat` maintains relational integrity via `societyId`.
5. All data screens: 4 states — Loading · Empty · Error (retry) · Success.
6. Security: never store plain-text passwords, tokens, API secrets in repo or memory.
7. 100% Mobile/Desktop feature parity: hamburger drawer with all links (Overview, Infrastructure, Organization, Preferences), active society switcher, profile card + role badge, full Sign Out with confirmation dialog.
