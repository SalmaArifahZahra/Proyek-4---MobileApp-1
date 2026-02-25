import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:logbook_app_062/features/logbook/views/log_view.dart';
import 'package:logbook_app_062/features/logbook/models/user_model.dart';

class WelcomeView extends StatefulWidget {
  final UserModel user;

  const WelcomeView({super.key, required this.user});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LogView(user: widget.user)),
      );
    });
  }

  static String _getGreeting(String username) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi, $username!';
    } else if (hour >= 12 && hour < 16) {
      return 'Selamat Siang, $username!';
    } else if (hour >= 16 && hour < 18) {
      return 'Selamat Sore, $username!';
    } else {
      return 'Selamat Malam, $username!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/animation/welcome_cat.json", width: 220),

            const SizedBox(height: 20),

            Text(
              _getGreeting(widget.user.username),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              "Selamat datang di Logbook App",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
