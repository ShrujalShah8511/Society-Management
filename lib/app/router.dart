import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../core/widgets/app_scaffold.dart';
import '../features/authentication/presentation/auth_notifier.dart';
import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/profile_screen.dart';
import '../features/authentication/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/role/domain/role.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/society/presentation/flat_list_screen.dart';
import '../features/society/presentation/floor_list_screen.dart';
import '../features/society/presentation/society_list_screen.dart';
import '../features/society/presentation/society_profile_screen.dart';
import '../features/society/presentation/tower_list_screen.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: RouteConstants.loginPath,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final isAuth = authState.isAuthenticated;
      final currentLoc = state.uri.toString();

      final isSplash = currentLoc == RouteConstants.splashPath;
      final isLoggingIn = currentLoc == RouteConstants.loginPath;
      final isForgotPassword = currentLoc == RouteConstants.forgotPasswordPath;

      if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
        return null;
      }

      if (!isAuth) {
        if (isLoggingIn || isForgotPassword || isSplash) {
          return null;
        }
        return RouteConstants.loginPath;
      }

      // If user is authenticated and trying to hit login/splash/forgot-password:
      if (isLoggingIn || isSplash || isForgotPassword) {
        return RouteConstants.dashboardPath;
      }

      // Permission Guard for specific route sections
      final userRole = authState.role;
      if (currentLoc.startsWith(RouteConstants.towersPath) &&
          !RolePermissions.hasPermission(userRole, Permission.viewTowers)) {
        return RouteConstants.dashboardPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPasswordPath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Application Shell Route (with sidebar/bottom bar)
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: RouteConstants.dashboardPath,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteConstants.societiesPath,
            builder: (context, state) => const SocietyListScreen(),
          ),
          GoRoute(
            path: RouteConstants.societyProfilePath,
            builder: (context, state) => const SocietyProfileScreen(),
          ),
          GoRoute(
            path: RouteConstants.towersPath,
            builder: (context, state) => const TowerListScreen(),
          ),
          GoRoute(
            path: RouteConstants.floorsPath,
            builder: (context, state) => const FloorListScreen(),
          ),
          GoRoute(
            path: RouteConstants.flatsPath,
            builder: (context, state) => const FlatListScreen(),
          ),
          GoRoute(
            path: RouteConstants.profilePath,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: RouteConstants.settingsPath,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
