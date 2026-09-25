# SKILLS.md — Phase 1 Reusable Development Patterns

This guide documents established code conventions, architecture patterns, and reusable practices for Phase 1 of the Society Management Application.

---

## 0. Lead Solution Architect & Senior Developer Persona (15+ Years Experience)

### Professional Profile
* **Title**: Lead Solution Architect & Principal Full-Stack Developer
* **Experience**: 15+ years architecting enterprise SaaS platforms, distributed systems, clean modular architectures, and cross-platform native/web ecosystems.
* **Architectural Guiding Principles**:
  1. **Simplicity Over Over-Engineering**: The cleanest architecture is the one that solves requirements with maximum clarity, minimum moving parts, and zero unnecessary boilerplate.
  2. **High Cohesion & Low Coupling**: Strict segregation of Presentation, Domain, and Data layers (Clean Architecture / SOLID principles).
  3. **Defensive by Default**: Proactively handle edge cases, race conditions, network failures, permission boundaries, and device/form-factor constraints.
  4. **Performance & Scalability**: Zero unnecessary re-renders, efficient memory management, and responsive layout resilience across all device viewports.
  5. **Enterprise Craftsmanship**: Production-ready code quality—100% type safety, comprehensive testing (Unit, Widget, Flow), zero lint warnings, and living technical documentation.

---

## 1. Flutter & Dart Development Conventions

### Dart Conventions
* Use strict typing. Avoid `dynamic` unless interacting with dynamic JSON decoding.
* Prefer immutable data models (`@immutable` classes with `final` fields, `copyWith`, and `toMap`/`fromMap`).
* Use meaningful names:
  * Entities: `Tower`, `Floor`, `Flat`, `Society`, `User`
  * Repositories: `TowerRepository`, `FlatRepository`
  * Notifiers: `TowerNotifier`, `FlatNotifier`
  * Screens: `TowerListScreen`, `FlatListScreen`
* Always specify types for function parameters and return types.
* Document public APIs and complex business rules.

### Widget Conventions
* Keep widget `build` methods lean and declarative.
* Decompose large widgets into smaller private helper widgets or dedicated classes.
* Never instantiate controllers or perform side effects directly within `build()`.
* Use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod integration.
* Always provide descriptive `Key`s for testability.

### Reusable Component Rules
* Shared components live in `lib/core/widgets/`:
  * `AppButton`: Unified primary, secondary, text, and danger action buttons with loading spinners.
  * `AppTextField`: Standardized input field with validation, prefix/suffix icons, and password toggles.
  * `AppScaffold`: Responsive container managing Desktop Sidebar vs Mobile Navigation.
  * `StatusBadge`: Colored status indicator chips (e.g. `OCCUPIED`, `VACANT`, `ACTIVE`).
  * `StateViews`: `LoadingView`, `EmptyStateView`, `ErrorRetryView`.
  * `ConfirmDialog`: Unified modal for destructive confirmations (delete, logout).

---

## 2. Responsive UI System

The application must support Android, iOS, and Web without layout clipping or horizontal overflow.

### Breakpoints
```dart
class ResponsiveBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMax &&
      MediaQuery.of(context).size.width <= tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMax;
}
```

### Layout Adaptation
* **Desktop / Web (>1024px)**:
  * Persistent left navigation sidebar (260px wide).
  * Main content area with max width constraining (e.g. 1400px), card grids, and responsive data tables.
  * Modal dialogs for creation and editing forms.
* **Mobile (<600px)**:
  * Bottom navigation bar or top App Bar with drawer.
  * Full-width cards and vertical list views.
  * Full-screen dialogs or bottom sheets for forms.

---

## 3. State Management with Riverpod

State is managed strictly via `flutter_riverpod`.

### Provider Conventions
* Notifiers extend `StateNotifier<AsyncValue<T>>` or `AsyncNotifier<T>` to handle async lifecycles natively.
* Providers are declared top-level in feature presentation files or `lib/app/providers.dart`.
* Example pattern:
```dart
final flatListProvider = StateNotifierProvider<FlatListNotifier, AsyncValue<List<Flat>>>((ref) {
  final repository = ref.watch(flatRepositoryProvider);
  return FlatListNotifier(repository);
});
```

### Async State Handling
* Handle all three `AsyncValue` branches in UI widgets:
```dart
state.when(
  data: (items) => items.isEmpty ? EmptyStateView(...) : ListView(...),
  loading: () => const LoadingView(),
  error: (err, stack) => ErrorRetryView(
    message: err.toString(),
    onRetry: () => ref.read(flatListProvider.notifier).load(),
  ),
);
```

---

## 4. Navigation with GoRouter

Navigation is declared centrally in `lib/core/router/app_router.dart`.

### Route Architecture
* Use named route constants from `lib/core/router/route_constants.dart`.
* Use `ShellRoute` to wrap authenticated screens inside `AppScaffold` (sidebar/bottom nav).
* Use `redirect` callback for route guards:
  * Redirect unauthenticated users to `/login`.
  * Redirect authenticated users away from `/login` or `/splash` to `/dashboard`.
  * Verify user roles for admin-only routes (e.g., society editing, tower deletion).

---

## 5. Form Handling & Validation

* Forms use Flutter `Form` and `TextEditingController`s inside `ConsumerStatefulWidget`.
* Use reusable validators from `lib/core/utils/validators.dart`:
  * `Validators.required(value, fieldName)`
  * `Validators.email(value)`
  * `Validators.phone(value)`
  * `Validators.positiveInt(value)`
* Disable submit buttons and show loading spinners when submission is in flight.
* Display field-level validation errors automatically under input fields.

---

## 6. API & Data Architecture

```text
UI (Widget)
    ↓
Notifier / Controller (Riverpod)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Sources (MockDataSource / RemoteDataSource)
    ↓
ApiClient (Core Network)
```

* **Rule**: UI code must **never** instantiate HTTP clients or parse raw JSON responses.
* **Rule**: Repositories return domain entities and domain `AppFailure` errors.
* **Rule**: Both `MockDataSource` and `RemoteDataSource` implement the same data source contract to allow seamless backend connectivity.

---

## 7. Testing Strategy

### Validation Commands
```powershell
flutter analyze
flutter test
```

### Test Categories
1. **Unit Tests**:
   * Pure business logic: `Validators`, `RolePermissions`, `AuthRepository`, `TowerRepository`, `FlatRepository`.
2. **Widget Tests**:
   * Component rendering and interactions: `LoginScreen`, `DashboardScreen`, `SocietyProfileScreen`, `TowerListScreen`, `FlatListScreen`, `SettingsScreen`.
   * Pumping widgets inside `ProviderScope` with mock repositories.
3. **Integration Tests**:
   * End-to-end Phase 1 user journey: Launch -> Login -> Dashboard -> Society -> Tower -> Floor -> Flat.
