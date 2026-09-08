# ARCHITECTURE.md — Phase 1 Technical Architecture

## 1. System Overview

The Society Management Application is architected as a cross-platform Flutter application supporting Android, iOS, and Web from a single codebase. It follows **Clean Architecture** and **Feature-First** organizational patterns to achieve high maintainability, testability, and separation of concerns.

```text
┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  (Widgets, Screens, Responsive Shell, Riverpod Notifier) │
└────────────────────────────┬────────────────────────────┘
                             │ calls
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                         │
│  (Entities, Value Objects, Repository Interfaces)        │
└────────────────────────────▲────────────────────────────┘
                             │ implements
┌────────────────────────────┴────────────────────────────┐
│                    Data Layer                           │
│  (Data Models, Repository Implementations)               │
└──────────────┬────────────────────────────┬─────────────┘
               │                            │
               ▼                            ▼
┌──────────────────────────────┐ ┌────────────────────────┐
│      Mock Data Sources       │ │   Remote Data Sources  │
│  (In-memory, Pre-seeded DB)  │ │ (HTTP REST API Client) │
└──────────────────────────────┘ └────────────────────────┘
```

---

## 2. Directory Structure

```text
lib/
├── app/
│   ├── app.dart              # MaterialApp.router configuration & theme bindings
│   └── providers.dart        # Global dependency injection providers
│
├── core/
│   ├── constants/            # App constants, routes, asset paths, storage keys
│   ├── errors/               # Domain failures & exception classes
│   ├── extensions/           # Dart context & string utility extensions
│   ├── network/              # ApiClient interface & HTTP implementation
│   ├── router/               # GoRouter configuration, route guards, shell routes
│   ├── storage/              # SessionStorage interface, secure & shared prefs
│   ├── theme/                # Material 3 design tokens (colors, typography, theme)
│   ├── utils/                # Form validators, currency & date formatters
│   └── widgets/              # Reusable components (AppScaffold, AppButton, Badges)
│
├── features/
│   ├── authentication/       # Splash, Login, Forgot Password, Session
│   │   ├── data/             # UserModel, AuthMockDataSource, AuthRepositoryImpl
│   │   ├── domain/           # User, AuthSession, AuthRepository interface
│   │   └── presentation/     # AuthNotifier, SplashScreen, LoginScreen
│   │
│   ├── role/                 # Role definition, Permissions, Route guards
│   │   ├── domain/           # Role enum, Permission enum, RolePermissions
│   │   └── presentation/     # RoleGuard widget, RoleNotifier
│   │
│   ├── society/              # Society profile, Towers, Floors, Flats
│   │   ├── data/             # Models, MockDataSources, Repositories
│   │   ├── domain/           # Society, Tower, Floor, Flat entities & contracts
│   │   └── presentation/     # Screens & Notifiers for Profile, Towers, Floors, Flats
│   │
│   ├── dashboard/            # Metrics summary (towers, floors, flats, occupancy)
│   │   ├── data/             # DashboardRepositoryImpl
│   │   ├── domain/           # DashboardStats entity & repository contract
│   │   └── presentation/     # DashboardScreen, KPI cards, quick actions
│   │
│   ├── profile/              # User profile details, Edit, Password update
│   │   └── presentation/     # ProfileScreen, EditProfileDialog
│   │
│   └── settings/             # Theme mode (System/Light/Dark), Legal placeholders
│       ├── data/             # SettingsRepositoryImpl
│       ├── domain/           # SettingsModel & repository contract
│       └── presentation/     # SettingsScreen, ThemePicker
│
└── main.dart                 # Application bootstrap
```

---

## 3. Dependency Rule

* **Domain** is the core and has **no dependencies** on Flutter UI, HTTP libraries, or storage plugins.
* **Data** depends on **Domain** and **Core Network/Storage**.
* **Presentation** depends on **Domain** and **Riverpod**. UI widgets never talk directly to Data Sources or Network APIs.

---

## 4. Role-Based Access Control (RBAC)

The application models 6 distinct roles:
1. `SUPER_ADMIN`: Complete system-wide administrative control.
2. `SOCIETY_ADMIN`: Full administrative control over their assigned society.
3. `COMMITTEE_MEMBER`: Management and oversight capabilities.
4. `RESIDENT`: Read-only access to society details and dashboard.
5. `SECURITY`: Read-only operational oversight.
6. `STAFF`: Restricted view for staff functions.

### Permission Architecture
* `Permission` enumeration defines granular actions (`manageSociety`, `manageTowers`, `manageFloors`, `manageFlats`, `viewDashboard`, `editProfile`).
* `RoleGuard` widget conditionally renders UI elements based on current user permissions.
* `GoRouter` redirects unauthorized routes back to `/dashboard`.

---

## 5. Society Relational Hierarchy

Phase 1 maintains strict relational hierarchy:

```text
Society (societyId)
   │
   └── Tower (towerId, societyId)
         │
         └── Floor (floorId, societyId, towerId)
               │
               └── Flat (flatId, societyId, towerId, floorId)
```

* Every sub-entity maintains a `societyId` to support multi-tenant isolation.
* Tower deletions are validated against dependent floors and flats to ensure data integrity.

---

## 6. Data Source Strategy: Dual Architecture

To ensure immediate, fully functional local execution as well as production REST readiness:
* **`MockDataSource`**: In-memory, pre-seeded data store with realistic initial data (e.g., "Grand Palm Heights Society", Tower A & B, Floors 1–5, Flats 101–504). All CRUD operations update the in-memory state seamlessly.
* **`RemoteDataSource`**: Consumes `ApiClient` sending REST requests (`GET`, `POST`, `PUT`, `DELETE`).
* Repositories switch data sources cleanly via Riverpod dependency injection.

---

## 7. Responsive Navigation Structure

* **Desktop / Web**: Persistent Left Sidebar with active route styling, breadcrumb headers, and adaptive content containers.
* **Mobile**: Top AppBar with society badge, responsive content body, and Bottom Navigation Bar for rapid thumb-friendly switching between Dashboard, Society, Profile, and Settings.
