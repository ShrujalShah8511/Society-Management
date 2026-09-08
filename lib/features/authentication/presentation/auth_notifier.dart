import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../role/domain/role.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  Role get role => user?.role ?? Role.resident;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> with ChangeNotifier {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    notifyListeners();
    try {
      final user = await _repository.restoreSession();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
    notifyListeners();
  }

  Future<bool> login({
    required String emailOrMobile,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();
    try {
      final session = await _repository.login(
        emailOrMobile: emailOrMobile,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
        errorMessage: null,
      );
      notifyListeners();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset({required String emailOrMobile}) async {
    try {
      await _repository.sendPasswordReset(emailOrMobile: emailOrMobile);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String mobile,
    String? profilePhotoUrl,
  }) async {
    if (state.user == null) return false;
    try {
      final updated = await _repository.updateProfile(
        userId: state.user!.id,
        name: name,
        mobile: mobile,
        profilePhotoUrl: profilePhotoUrl,
      );
      state = state.copyWith(user: updated);
      notifyListeners();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.user == null) return false;
    try {
      await _repository.changePassword(
        userId: state.user!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
