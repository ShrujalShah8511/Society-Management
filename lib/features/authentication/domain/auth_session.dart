import 'user.dart';

class AuthSession {
  final String token;
  final User user;

  const AuthSession({
    required this.token,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'user': user.toMap(),
    };
  }

  factory AuthSession.fromMap(Map<String, dynamic> map) {
    return AuthSession(
      token: map['token'] as String,
      user: User.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}
