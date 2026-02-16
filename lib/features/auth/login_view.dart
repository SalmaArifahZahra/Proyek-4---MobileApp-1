import 'package:flutter/material.dart';
import 'package:logbook_app_062/features/auth/login_controller.dart';
import 'package:logbook_app_062/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscurePassword = true;
  
    void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    if (user.isEmpty || pass.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username & Password wajib diisi")),
      );
      return;
    }

    if (_controller.isLocked){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("percobaan hanya 3x, Tunggu sebentar"))
      );
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Gagal! Gunakan admin/123")),
      );
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Login Gatekeeper"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: "Username",
            ),
          ),

          TextField(
            controller: _passController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _handleLogin,
            child: const Text("Masuk"),
          ),
        ],
      ),
    ),
  );
}
}