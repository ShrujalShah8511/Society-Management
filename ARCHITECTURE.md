# ARCHITECTURE.md — Phase 1 Technical Architecture

## 1. Layers
```
Presentation (Widgets · Screens · Riverpod Notifier)
    ↓ calls
Domain (Entities · Repository Interfaces)
    ↑ implements
Data (Repository Implementations)
    ↓                   ↓
MockDataSource    RemoteDataSource
```

## 2. Directory Structure
```
lib/
├── app/            # MaterialApp.router, global DI providers
├── core/
│   ├── constants/  # Routes, storage keys
│   ├── errors/     # AppFailure, NetworkFailure, AuthFailure, ValidationFailure
│   ├── router/     # GoRouter, guards, ShellRoute
│   ├── storage/    # SessionStorage (secure + shared prefs)
│   ├── theme/      # M3 tokens (colors, typography)
│   ├── utils/      # Validators, formatters
│   └── widgets/    # AppScaffold, AppButton, StatusBadge, StateViews
└── features/
    ├── authentication/  # Splash, Login, ForceChangePassword, Session, AuthNotifier
    ├── role/            # Role enum, Permission enum, RolePermissions, RoleGuard
    ├── society/         # Society, Tower, Floor, Flat CRUD + ActiveSocietyNotifier
    ├── users/           # UserManagementScreen, UserFormDialog, UserProvider
    ├── notifications/   # NotificationDrawer, NotificationNotifier
    ├── dashboard/       # KPI metrics, occupancy bar, quick actions
    ├── profile/         # Details, edit, password update
    └── settings/        # Theme (System/Light/Dark)
```

## 3. Dependency Rule
- **Domain**: pure Dart — no Flutter UI / HTTP / storage.
- **Data**: depends on Domain + Core (network/storage).
- **Presentation**: depends on Domain + Riverpod. Never touches DataSources directly.

## 4. RBAC — 6 Roles
| Role | Access |
|---|---|
| SUPER_ADMIN | Platform-wide; no societyId; can impersonate any user |
| SOCIETY_ADMIN | Full control over assigned society only |
| COMMITTEE_MEMBER | Management & oversight |
| RESIDENT | Read-only society + dashboard |
| SECURITY | Read-only operational |
| STAFF | Restricted staff view |

- `Permission` enum: `manageAllSocieties · manageTowers · manageFloors · manageFlats · viewDashboard · manageUsers · editProfile …`
- `RoleGuard` widget gates UI; GoRouter redirects unauthorized → `/dashboard`

## 5. Society Hierarchy & Multi-Tenancy
```
Society (societyId)
└── Tower (towerId, societyId)
    └── Floor (floorId, societyId, towerId)
        └── Flat (flatId, societyId, towerId, floorId)
```
- `ActiveSocietyNotifier`: locks non-super-admins to their `societyId`.
- Cascade-delete guard: cannot delete Tower with Floors; cannot delete Floor with Flats.
- Super Admin (`societyId: ''`) sees all societies; others see only their own.

## 6. Key Providers & Notifiers
| Provider | File | Role |
|---|---|---|
| `authNotifierProvider` | `auth_notifier.dart` | Login, logout, impersonation, session restore |
| `activeSocietyProvider` | `active_society_provider.dart` | Active society selection + isolation |
| `userManagementProvider` | `user_provider.dart` | User CRUD, provisioning, role filter |
| `notificationNotifierProvider` | `notification_notifier.dart` | Notifications, unread count |
| `flatNotifierProvider` | `flat_notifier.dart` | Flat list, filters, auto-generate |

## 7. Responsive Navigation
- **Desktop**: 260px persistent sidebar, breadcrumb top bar, endDrawer for notifications.
- **Mobile**: AppBar + hamburger drawer, bottom nav (4 items), endDrawer for notifications.
