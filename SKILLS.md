# SKILLS.md — Phase 1 Reusable Patterns

## 0. Persona
15+ year Solution Architect. Standards: simplicity · high cohesion/low coupling · defensive defaults · full type safety · zero lint warnings · living docs.

## 1. Flutter & Dart Conventions
- Strict typing; `dynamic` only for raw JSON.
- Immutable models: `@immutable`, `final` fields, `copyWith`, `toMap`/`fromMap`.
- Naming: `Tower` / `FlatRepository` / `TowerNotifier` / `FlatListScreen`.
- `build()` lean/declarative; decompose large widgets; use `ConsumerWidget`/`ConsumerStatefulWidget`; descriptive `Key`s.
- **Shared components** (`lib/core/widgets/`): `AppButton` · `AppTextField` (use `isPassword:` not `obscureText:`) · `AppScaffold` · `StatusBadge` · `StateViews` (`LoadingView`/`EmptyStateView`/`ErrorRetryView`) · `ConfirmDialog`.

## 2. Responsive UI
Breakpoints: mobile <600px · tablet 600–1024px · desktop >1024px.
- **Desktop**: 260px persistent sidebar, modal dialogs for forms.
- **Mobile**: bottom nav / AppBar+drawer, full-width cards.

## 3. State Management — Riverpod
- Notifiers extend `StateNotifier<T>` or `AsyncNotifier<T>`. Providers declared top-level.
- Handle all `AsyncValue` branches: `data` / `loading` / `error` (with retry).
- 4 explicit states: Loading · Empty · Error (retry) · Success.

## 4. Navigation — GoRouter
Central: `lib/app/router.dart`; constants in `route_constants.dart`. `ShellRoute` wraps authenticated screens in `AppScaffold`. Redirects: unauthenticated → `/login`; `mustChangePassword` → `/force-change-password`.

## 5. Forms & Validation
`Form` + `TextEditingController` in `ConsumerStatefulWidget`. Validators in `lib/core/utils/validators.dart`: `Validators.required · .email · .phone · .positiveInt`. Disable submit + show spinner in-flight.

## 6. Data Flow
`Widget → Notifier → Repository Interface (Domain) → Repository Impl (Data) → Mock/RemoteDataSource`
- UI never parses raw JSON or instantiates HTTP clients.
- Repos return domain entities + `AppFailure`.

## 7. User Provisioning
- ID format: `usr-[CITY_3]-[seq_3digit]` via `AuthNotifier.generateNextUserId(city)`.
- Temp password: `Welcome@<mobile>`. Username = mobile number. `mustChangePassword: true`.
- Super Admin: `societyId: ''`, `societyName: 'Platform Admin'` — NOT tied to any society.
- Flat assignment: validate exclusivity before saving (one flat → one user).

## 8. Testing
```bash
flutter analyze && flutter test
```
- Unit: `Validators`, `RolePermissions`, `AuthRepository`, `TowerRepository`, `FlatRepository`, `UserManagement`
- Widget: `LoginScreen`, `DashboardScreen`, `FlatManagementScreen`
- Integration: Login → Role → Tower → Floor → Flat
