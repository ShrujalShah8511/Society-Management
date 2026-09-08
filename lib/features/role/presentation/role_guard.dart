import 'package:flutter/material.dart';
import '../domain/role.dart';

class RoleGuard extends StatelessWidget {
  final Role userRole;
  final Permission requiredPermission;
  final Widget child;
  final Widget fallback;

  const RoleGuard({
    super.key,
    required this.userRole,
    required this.requiredPermission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (RolePermissions.hasPermission(userRole, requiredPermission)) {
      return child;
    }
    return fallback;
  }
}
