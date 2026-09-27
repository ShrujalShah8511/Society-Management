# ARCHITECTURE.md — Phase 1 Technical Architecture

## 1. Layers
```
Presentation (Widgets · Screens · Riverpod Notifier)
    ↓ calls
Domain (Entities · Value Objects · Repository Interfaces)
    ↑ implements
Data (Models · Repository Implementations)
    ↓                        ↓
MockDataSource         RemoteDataSource (HTTP REST)
```

## 2. Directory Structure
```
lib/
├── app/            # MaterialApp.router config, global DI providers
├── core/
│   ├── constants/  # Routes, asset paths, storage keys
│   ├── errors/     # Domain failures & exception classes
│   ├── extensions/ # Dart/context/string utilities
│   ├── network/    # ApiClient interface & HTTP impl
│   ├── router/     # GoRouter config, guards, shell routes
│   ├── storage/    # SessionStorage, secure & shared prefs
│   ├── theme/      # Material 3 tokens (colors, typography, theme)
│   ├── utils/      # Form validators, formatters
│   └── widgets/    # AppScaffold, AppButton, Badges, StateViews
├── features/
│   ├── authentication/  # Splash, Login, Forgot Password, Session
│   │   ├── data/        # UserModel, AuthMockDataSource, AuthRepositoryImpl
│   │   ├── domain/      # User, AuthSession, AuthRepository interface
│   │   └── presentation/# AuthNotifier, SplashScreen, LoginScreen
│   ├── role/            # Role enum, Permission enum, RolePermissions, RoleGuard
│   ├── society/         # Society, Tower, Floor, Flat CRUD
│   │   ├── data/        # Models, MockDataSources, Repositories
│   │   ├── domain/      # Entities & contracts
│   │   └── presentation/# Screens & Notifiers
│   ├── dashboard/       # KPI metrics, occupancy bar, quick actions
│   ├── profile/         # Details, edit, password update
│   └── settings/        # Theme (System/Light/Dark), legal placeholders
└── main.dart
```

## 3. Dependency Rule
- **Domain**: no Flutter UI / HTTP / storage dependencies.
- **Data**: depends on Domain + Core (network/storage).
- **Presentation**: depends on Domain + Riverpod. Never touches Data Sources directly.

## 4. RBAC — 6 Roles
| Role | Access |
|---|---|
| SUPER_ADMIN | Complete system-wide control |
| SOCIETY_ADMIN | Full control over assigned society |
| COMMITTEE_MEMBER | Management & oversight |
| RESIDENT | Read-only society + dashboard |
| SECURITY | Read-only operational oversight |
| STAFF | Restricted staff view |

- `Permission` enum: `manageSociety · manageTowers · manageFloors · manageFlats · viewDashboard · editProfile`
- `RoleGuard` widget gates UI; GoRouter redirects unauthorized routes → `/dashboard`

## 5. Society Hierarchy
```
Society (societyId)
└── Tower (towerId, societyId)
    └── Floor (floorId, societyId, towerId)
        └── Flat (flatId, societyId, towerId, floorId)
```
- Every entity carries `societyId` for multi-tenant isolation.
- Cascade-delete guard: cannot delete Tower with Floors; cannot delete Floor with Flats.

## 6. Dual Data Source Strategy
- **MockDataSource**: In-memory, pre-seeded ("Grand Palm Heights", Tower A & B, Floors 1–5, Flats 101–504). All CRUD updates in-memory.
- **RemoteDataSource**: `ApiClient` with `GET/POST/PUT/DELETE`. Swapped via Riverpod DI.

## 7. Responsive Navigation
- **Desktop/Web**: Persistent left sidebar, breadcrumb headers, adaptive containers.
- **Mobile**: Top AppBar + society badge, bottom nav (Dashboard · Society · Profile · Settings).
