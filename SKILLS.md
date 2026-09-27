# SKILLS.md — Phase 1 Reusable Patterns

## 0. Lead Solution Architect Persona (15+ Years)
**Standards**: Simplicity over over-engineering · High cohesion/low coupling (Clean Architecture/SOLID) · Defensive by default (edge cases, races, permission boundaries) · Zero unnecessary re-renders · 100% type safety, full test coverage, zero lint warnings, living docs.

## 1. Flutter & Dart Conventions
- Strict typing; `dynamic` only for raw JSON decoding.
- Immutable models: `@immutable`, `final` fields, `copyWith`, `toMap`/`fromMap`.
- Naming: `Tower`/`FlatRepository`/`TowerNotifier`/`FlatListScreen`.
- `build()` lean/declarative; decompose large widgets; no controllers/side-effects in `build()`; use `ConsumerWidget`/`ConsumerStatefulWidget`; descriptive `Key`s.
- **Shared components** (`lib/core/widgets/`): `AppButton` (primary/secondary/text/danger + spinner) · `AppTextField` (validation, icons, password toggle) · `AppScaffold` (desktop sidebar vs mobile nav) · `StatusBadge` (OCCUPIED/VACANT/ACTIVE) · `StateViews` (`LoadingView`/`EmptyStateView`/`ErrorRetryView`) · `ConfirmDialog`.

## 2. Responsive UI
Breakpoints: mobile <600px · tablet 600–1024px · desktop >1024px.
```dart
class ResponsiveBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < mobileMax;
  static bool isTablet(BuildContext c) =>
      MediaQuery.of(c).size.width >= mobileMax && MediaQuery.of(c).size.width <= tabletMax;
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width > tabletMax;
}
```
- **Desktop**: 260px persistent sidebar, max-width ~1400px, card grids, modal dialogs for forms.
- **Mobile**: bottom nav / AppBar+drawer, full-width cards/lists, full-screen dialogs or bottom sheets.

## 3. State Management — Riverpod
Notifiers extend `StateNotifier<AsyncValue<T>>` or `AsyncNotifier<T>`. Providers declared top-level.
```dart
final flatListProvider = StateNotifierProvider<FlatListNotifier, AsyncValue<List<Flat>>>((ref) {
  return FlatListNotifier(ref.watch(flatRepositoryProvider));
});
```
Handle all 3 `AsyncValue` branches:
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

## 4. Navigation — GoRouter
Central: `lib/core/router/app_router.dart`; constants in `route_constants.dart`. `ShellRoute` wraps authenticated screens in `AppScaffold`. Redirect: unauthenticated → `/login`; authenticated on `/login`/`/splash` → `/dashboard`; admin-only routes verify roles.

## 5. Forms & Validation
`Form` + `TextEditingController` in `ConsumerStatefulWidget`. Validators in `lib/core/utils/validators.dart`: `Validators.required · .email · .phone · .positiveInt`. Disable submit + show spinner in-flight; auto-display field errors.

## 6. Data Flow
`Widget → Notifier (Riverpod) → Repository Interface (Domain) → Repository Impl (Data) → Mock/RemoteDataSource → ApiClient`
- UI never parses raw JSON or instantiates HTTP clients.
- Repos return domain entities + `AppFailure`; Mock and Remote implement the same contract.

## 7. Testing
```bash
flutter analyze && flutter test
```
- **Unit**: `Validators`, `RolePermissions`, `AuthRepository`, `TowerRepository`, `FlatRepository`
- **Widget**: `LoginScreen`, `DashboardScreen`, `SocietyProfileScreen`, `TowerListScreen`, `FlatListScreen`, `SettingsScreen` — pumped in `ProviderScope` with mock repos.
- **Integration**: Launch → Login → Dashboard → Society → Tower → Floor → Flat.
