# MEMORY.md — Persistent Technical Memory (Phase 1)

## 1. Current State
Phase 1 · In Development · Flutter v3.47.2 / Dart v3.13.2 · Web: `http://localhost:8080`

| Component | Status | Notes |
|---|---|---|
| Docs & Memory | ✅ | AGENTS, MEMORY, ARCHITECTURE, CHANGELOG |
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
| Testing | ✅ | 61 unit/widget/integration tests passing |
| Dynamic Branding | ✅ | Logo upload (Web/Device/URL), reactive favicon/title, monogram fallback |
| Notifications | ✅ | Right-drawer, unread count badge, filter chips |
| User Management | ✅ | Super Admin provisions users; Society Admin manages members; flat exclusivity |
| Multi-Tenancy | ✅ | Society isolation; non-super-admins locked to assigned society |
| Impersonation | ✅ | Super Admin can login-as any user; persistent banner; exit button |
| Force PW Change | ✅ | `mustChangePassword` flag; route guard redirects to `/force-change-password` |

**Seed society**: Shyam Heights · Near Sargasan Cross Road, Sargasan, Gandhinagar, GJ 382421 · RERA: `PR/GJ/GANDHINAGAR/GANDHINAGAR/OTHERS/MAA10020/130422` · contact@shyamheights.in · +91 9876543210

**Super Admin**: Shrujal Shah (`usr-super-001` · mobile `9998887776`) — platform-level, NO societyId.

**User ID format**: `usr-[CITY_3]-[incremental_3digit]` (master sequence in `AuthMockDataSource._masterUserSequence`).
**Temp password**: `Welcome@<mobileNumber>`. Username = mobile number. `mustChangePassword: true` on creation.

## 2. Architecture Decisions
| Date | Decision | Impact |
|---|---|---|
| 2026-09-28 | **Pure Live Supabase (No Mock)** | Auth & User Management wired to live Supabase backend; zero mock fallbacks |
| 2026-09-28 | Super Admin has `societyId: ''` | Platform-level; not tied to any society |
| 2026-09-28 | Impersonation via `AuthNotifier.impersonateUser()` | SA switches session without password; `exitImpersonation()` restores |
| 2026-09-27 | Multi-tenant isolation in `ActiveSocietyNotifier` | Non-super admins locked to assigned societyId |
| 2026-09-27 | Notification right-drawer | `NotificationDrawer` in `AppScaffold.endDrawer` |
| 2026-09-26 | **Cloudflare Pages + Supabase + Firebase** | CDN hosting; managed Postgres+Auth+Storage+RLS; FCM push. Runbook: `docs/cloud_architecture_and_deployment_guide.md` |
| 2026-09-09 | Feature-First Clean Architecture | `lib/features/<f>/{presentation,domain,data}` |
| 2026-09-09 | Riverpod state management | Compile-time safety, clean AsyncValue |
| 2026-09-09 | GoRouter + responsive shell | Web URL sync, deep linking, auth guards |
| 2026-09-09 | Mock & Remote dual data sources | Presentation layer is data-source-agnostic |

## 3. Project Rules
1. Single Flutter codebase — Android · iOS · Web.
2. Material 3 with centralized theming; no hardcoded colors/padding/styles.
3. RBAC mandatory — enforced in UI and route guards.
4. Society hierarchy `Society→Tower→Floor→Flat` maintains relational integrity via `societyId`.
5. All data screens: 4 states — Loading · Empty · Error (retry) · Success.
6. Security: never store plain-text passwords, tokens, or API secrets in repo.
7. 100% Mobile/Desktop feature parity.
