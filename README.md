# Society Management Platform

A modern, multi-tenant residential society management platform built for **Web, Android, and iOS**. Empowering housing societies and super administrators to manage infrastructure, flats, towers, floors, residents, committee members, security, and administrative operations seamlessly.

---

## 🏛️ Platform Architecture & Multi-Tenant Infrastructure

- **Platform Super Admin**: Shrujal Shah
- **Initial Seed Society**: **Shyam Heights**
  - **Location**: Near Sargasan Cross Road, Sargasan, Gandhinagar, Gujarat - 382421
  - **RERA Number**: `PR/GJ/GANDHINAGAR/GANDHINAGAR/OTHERS/MAA10020/130422`
  - **Official Contact**: contact@shyamheights.in | +91 9876543210
- **Multi-Tenant SaaS Hub**: Register, configure, and switch between multiple residential societies with isolated databases and scoped access.

---

## 🛠️ Technical Stack & Architecture

### 1. Frontend (Mobile & Web)
- **Framework**: **Flutter 3.x (Dart 3.x)** — Single unified codebase targeting Web, Android, iOS, and Desktop.
- **State Management**: **Flutter Riverpod 2.6+** (`StateNotifierProvider`, `Provider`, reactive invalidation).
- **Navigation & Routing**: **GoRouter 14.8+** with path-based routing, shell navigation, and role-guarded redirects.
- **Design System & Styling**:
  - Bespoke Vanilla CSS-grade Flutter theme with curated HSL dark/light modes.
  - Glassmorphic top navigation bar, collapsible desktop sidebar, and fluid mobile bottom navigation.
  - Micro-interactions, pulsing indicators, and subtle transitions.
  - Ultra-sharp 4K HD branding asset integration for society logos.
- **Form Handling & Validation**: Regex-backed custom validator engine for emails, Indian mobile numbers (+91), pincodes (6-digit), and RERA numbers.

### 2. Architecture Pattern (Clean Architecture)
The codebase adheres strictly to **Domain-Driven Clean Architecture**:
```
lib/
├── app/                  # App initialization, routes, theme & global providers
├── core/                 # Shared widgets, animation utilities, formatters, tokens
└── features/
    ├── authentication/   # Auth domain, mock/remote data sources, Riverpod notifiers, screens
    ├── role/             # Role & permission matrix (Super Admin, Society Admin, Resident, Security)
    ├── society/          # Multi-tenant society repository, active tenant switcher, towers, floors, flats
    ├── dashboard/        # Real-time analytics, occupancy telemetry, operational cards
    └── settings/         # Theme toggling, notification preferences, platform configuration
```
- **Domain Layer**: Pure Dart entities and abstract repository contracts (independent of UI and external libraries).
- **Data Layer**: Concrete repository implementations, mock data engines, session storage, and REST/GraphQL adapters.
- **Presentation Layer**: StateNotifiers, responsive layouts (`AppScaffold`), and specialized screens.

### 3. Backend & API Services (Architecture Spec)
- **API Protocol**: RESTful JSON / GraphQL API endpoints.
- **Authentication**: JWT (JSON Web Tokens) with refresh token rotation and biometric authentication support for mobile devices.
- **Authorization Engine**: Role-Based Access Control (RBAC) with granular permissions:
  - `superAdmin`: Platform-level management, create/delete societies, global telemetry.
  - `societyAdmin`: Full management within assigned society (infrastructure, flats, residents).
  - `committeeMember`: Financial reviews, facility approvals, meeting logs.
  - `resident`: Own flat profile, maintenance payments, visitor pre-approvals, complaint tracking.
  - `security`: Gate pass, visitor logging, delivery tracking.

### 4. Database Architecture
- **Primary Database**: PostgreSQL / MongoDB with Multi-Tenant schema isolation (Tenant ID scoping).
- **Local Cache & Offline Storage**:
  - `flutter_secure_storage`: Encrypted keystore/keychain for auth tokens and user sessions.
  - SQLite / Hive / Isar: Local caching for offline gate pass verification and cached society directory.
- **File & Media Storage**: AWS S3 / Google Cloud Storage for high-resolution society logos, flat documents, and user profile photos.

---

## ✨ Core Features

1. **Multi-Tenant SaaS Hub (`/societies`)**:
   - Platform Super Admin view to monitor all societies across Gujarat.
   - Dynamic onboarding via the **"+ Register New Society"** workflow.
   - Instant 1-click active society switcher in the top navigation bar.

2. **Society Profile & RERA Compliance (`/society`)**:
   - Certified RERA registration number tracking.
   - Address, contact phone, official email, and website management.
   - Real-time profile editing and society logo upload.

3. **Infrastructure Management**:
   - **Towers**: Dynamic creation, status toggles (Active, Maintenance), and floor capacity tracking.
   - **Floors**: Relational linking to parent towers, custom numbering, and flat allocation.
   - **Flat Inventory**: Flat management with BHK configurations, occupancy status (Occupied, Vacant, Maintenance), and search filters.

4. **Interactive Dashboard (`/dashboard`)**:
   - Tenant-scoped occupancy rates and operational metrics.
   - Quick action shortcuts for daily operations.
   - Recent activity feed and system status monitors.

5. **Responsive Multi-Platform Layout**:
   - Adaptive UI transitioning from expansive desktop dashboard to mobile layout with bottom navigation.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19.0 or newer)
- Google Chrome (for Web)
- Android Studio / Android SDK (for Android build)

### Run on Local Web Server
```bash
flutter pub get
flutter run -d web-server --web-port=8080 --web-hostname=localhost
```
Open **http://localhost:8080** in your browser.

### Run on Android
```bash
# Verify connected Android device
flutter devices

# Run on physical phone or emulator
flutter run

# Build release APK
flutter build apk --release
```

### Run Tests & Validation
```bash
flutter analyze
flutter test
```

---

## 📁 Repository Structure
- [`design/DESIGN.md`](design/DESIGN.md): Product and UX specification document.
- [`Society_Management_Tech_Stack_Interactive.docx`](Society_Management_Tech_Stack_Interactive.docx): Interactive technology stack breakdown.
- [`lib/`](lib/): Production Flutter application source code.
- [`test/`](test/): 43 comprehensive unit, widget, and integration test suites.
- [`android/`](android/): Native Android build files and Gradle configuration.
- [`web/`](web/): Web entry points, manifest, and icons.
