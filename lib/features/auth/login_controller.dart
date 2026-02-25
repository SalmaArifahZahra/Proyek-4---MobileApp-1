import 'package:logbook_app_062/features/logbook/models/user_model.dart';
class LoginController {

  final List<UserModel> _users = [
    UserModel(id: 1, username: "admin", password: "123"),
    UserModel(id: 2, username: "salma", password: "666"),
  ];

  int _failedAttempts = 0;
  bool _isLocked = false;
  bool get isLocked => _isLocked;

   UserModel? login(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return null;
    }

    if (_isLocked) return null;

    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );

      _failedAttempts = 0;
      return user;

    } catch (e) {
      _failedAttempts++;

      if (_failedAttempts >= 3) {
        _lockLogin();
      }
      return null;
    }
  }

  void _lockLogin() {
    _isLocked = true;

    Future.delayed(const Duration(seconds: 10), () {
      _failedAttempts = 0;
      _isLocked = false;
    });
  }
}
