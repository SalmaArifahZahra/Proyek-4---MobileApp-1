class LoginController {
  // final String _validUsername = "admin";
  // final String _validPassword = "123";

  final Map<String, String> _users = {
    "admin": "123", 
    "salma": "666"
  };

  int _failedAttempts = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  bool login(String username, String password) {
    if (_isLocked) return false;

    // if (username == _validUsername && password == _validPassword) {
    //   _failedAttempts = 0;
    //   return true;
    // }

    if (_users.containsKey(username) && _users[username] == password) {
      _failedAttempts = 0;
      return true;
    }

    _failedAttempts++;

    if (_failedAttempts >= 3) {
      _lockLogin();
    }

    return false;
  }

  void _lockLogin() {
    _isLocked = true;

    Future.delayed(const Duration(seconds: 10), () {
      _failedAttempts = 0;
      _isLocked = false;
    });
  }
}
