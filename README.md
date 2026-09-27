# Society Management Platform

Multi-tenant residential society management — **Web · Android · iOS** — Flutter/Dart SaaS.

**Platform Super Admin**: Shrujal Shah | **Seed Society**: Shyam Heights, Near Sargasan Cross Road, Sargasan, Gandhinagar, GJ 382421 | RERA: `PR/GJ/GANDHINAGAR/GANDHINAGAR/OTHERS/MAA10020/130422` | contact@shyamheights.in | +91 9876543210

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x / Dart 3.x — single codebase (Web, Android, iOS, Desktop) |
| State | Flutter Riverpod 2.6+ (`StateNotifierProvider`, reactive invalidation) |
| Routing | GoRouter 14.8+ — path-based, shell nav, role-guarded redirects |
| Design | Bespoke M3 HSL dark/light, glassmorphic nav, micro-interactions, 4K asset support |
| Forms | Custom validators: email, Indian mobile (+91), 6-digit pincode, RERA number |
| Backend | RESTful JSON / GraphQL; JWT + refresh token rotation; biometric auth (mobile) |
| Auth | RBAC: `superAdmin` · `societyAdmin` · `committeeMember` · `resident` · `security` |
| Database | PostgreSQL/MongoDB multi-tenant (Tenant ID scoped); `flutter_secure_storage` for auth tokens; SQLite/Hive/Isar for offline cache |
| Files | AWS S3 / GCS for logos, flat docs, profile photos |
| Hosting | Cloudflare Pages (edge CDN) + Supabase (Postgres + Auth + Storage + RLS) + Firebase (FCM + Analytics) |

## Architecture (Feature-First Clean Architecture)
```
lib/
├── app/          # Init, routes, theme, global providers
├── core/         # Widgets, animations, formatters, tokens
└── features/
    ├── authentication/  # Auth domain, mock/remote sources, notifiers, screens
    ├── role/            # Role & permission matrix (6 roles)
    ├── society/         # Multi-tenant repos, active tenant switcher, towers/floors/flats
    ├── dashboard/       # Real-time analytics, occupancy telemetry, action cards
    └── settings/        # Theme, notifications, platform config
```
- **Domain**: Pure Dart entities + abstract repository contracts.
- **Data**: Concrete repos, mock engines, session storage, REST/GraphQL adapters.
- **Presentation**: StateNotifiers, responsive `AppScaffold`, specialized screens.

## Core Features
1. **Multi-Tenant Hub** (`/societies`): monitor all societies, register new, 1-click society switcher.
2. **Society Profile** (`/society`): RERA tracking, contact management, logo upload, real-time edit.
3. **Infrastructure**: Towers (status toggles) → Floors (relational to towers) → Flats (BHK config, occupancy, search filters).
4. **Dashboard** (`/dashboard`): tenant-scoped occupancy metrics, quick actions, activity feed.
5. **Responsive Layout**: desktop dashboard ↔ mobile bottom nav, full feature parity.

## Getting Started

```bash
# Install deps
flutter pub get

# Web (localhost:8080)
flutter run -d web-server --web-port=8080 --web-hostname=localhost

# Android
flutter devices && flutter run
flutter build apk --release

# Test & analyze
flutter analyze && flutter test
```

## Repository Layout
| Path | Purpose |
|---|---|
| [`design/DESIGN.md`](design/DESIGN.md) | Product & UX specification |
| [`docs/cloud_architecture_and_deployment_guide.md`](docs/cloud_architecture_and_deployment_guide.md) | Cloud/Supabase/Firebase/Cloudflare runbook |
| `lib/` | Flutter source code |
| `test/` | 58 unit, widget, integration tests |
| `android/` | Native Android / Gradle config |
| `web/` | Entry points, manifest, headers, redirects, icons |
| `supabase/` | PostgreSQL migrations, schema, seed data |
