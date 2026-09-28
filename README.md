# Society Management Platform

Multi-tenant residential society management — **Web · Android · iOS** — Flutter/Dart.

**Super Admin**: Shrujal Shah | **Seed Society**: Shyam Heights, Sargasan, Gandhinagar, GJ 382421 | contact@shyamheights.in | +91 9876543210

## Tech Stack
| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x / Dart 3.x — single codebase (Web, Android, iOS) |
| State | Flutter Riverpod 2.6+ |
| Routing | GoRouter 14.8+ — role-guarded, shell nav |
| Design | Material 3 HSL dark/light, glassmorphic nav, micro-interactions |
| Auth | RBAC: `superAdmin · societyAdmin · committeeMember · resident · security · staff` |
| Hosting | Cloudflare Pages + Supabase (Postgres + Auth + Storage + RLS) + Firebase (FCM) |

## Architecture (Feature-First Clean Architecture)
```
lib/
├── app/          # Init, routes, theme, global providers
├── core/         # Widgets, animations, formatters, tokens
└── features/
    ├── authentication/  # Auth, session, impersonation, force-change-password
    ├── role/            # Role & permission matrix (6 roles)
    ├── society/         # Multi-tenant repos, active tenant switcher, towers/floors/flats
    ├── users/           # User management & provisioning
    ├── notifications/   # Right-drawer notification center
    ├── dashboard/       # Occupancy analytics, action cards
    └── settings/        # Theme, platform config
```

## Getting Started
```bash
flutter pub get
flutter run -d web-server --web-port=8080 --web-hostname=localhost
flutter analyze && flutter test
```

## Repository Layout
| Path | Purpose |
|---|---|
| `MEMORY.md` | Current state, decisions, rules |
| `ARCHITECTURE.md` | Technical architecture reference |
| `AGENTS.md` | AI agent workflow instructions |
| `design/DESIGN.md` | Product & UX specification |
| `docs/cloud_architecture_and_deployment_guide.md` | Cloud/Supabase/Firebase runbook |
| `lib/` | Flutter source |
| `test/` | Unit, widget, integration tests |
| `supabase/` | PostgreSQL migrations & schema |
