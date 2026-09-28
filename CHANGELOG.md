# CHANGELOG.md — Phase 1 Development History

## [Unreleased] — Current Sprint (2026-09-28)
- **Live Supabase Auth & User CRUD**: Switched all authentication and user management to live Supabase backend; removed mock fallbacks.
- **Supabase Migration**: Added `20260928000002_live_users_crud_and_rls.sql` for user management table columns and permissive development RLS.
- **Super Admin isolation**: `societyId: ''` — platform-level, no society binding.
- **Impersonation**: Super Admin can login-as any user; persistent gold banner; `exitImpersonation()`.
- **Auto-generate button**: hidden when search/filter is active on Flat Inventory.

## [1.1.0] — Multi-Tenancy & User Management (2026-09-27)
- **Notifications**: right-drawer (`NotificationDrawer`), unread badge, filter chips.
- **Multi-tenancy isolation**: `ActiveSocietyNotifier` locks non-super-admins to assigned society.
- **User Management**: `UserManagementScreen` + `UserFormDialog`; Super Admin provisions users across societies; Society Admin manages own members; flat exclusivity enforced.
- **User IDs**: `usr-[CITY_3]-[seq_3digit]`; username = mobile number; temp password = `Welcome@<mobile>`.
- **Force password change**: `mustChangePassword` flag; route guard → `/force-change-password`.
- **Society creation**: Admin details (name, mobile, email) required; credentials shown in success dialog.
- **Tower creation**: Number of floors and flats per floor default to blank.
- **Flat filter**: `Auto-Generate` button hidden when filter/search is active.

## [1.0.0] — Complete Phase 1 (2026-09-09)
- AI agent docs: AGENTS, MEMORY, SKILLS, ARCHITECTURE, CHANGELOG.
- `lib/core/`: M3 themes, responsive layout, AppButton, AppTextField, StatusBadge, StateViews, AppScaffold, session storage, validators.
- `lib/features/authentication/`: Login (quick-login role selector), Forgot Password, Profile.
- `lib/features/role/`: 6 roles, permission matrix, role guard.
- `lib/features/society/`: Society/Tower/Floor/Flat CRUD; relational integrity; search/filter/sort.
- `lib/features/dashboard/`: KPIs, occupancy bar, quick actions.
- `lib/features/settings/`: Theme selector (System/Light/Dark).
- Dynamic branding: logo upload, reactive favicon/title, monogram fallback.
- 58 passing tests (unit + widget + integration).
- Cloudflare Pages + Supabase + Firebase deployment pipeline.
