import 'package:flutter/material.dart';
import 'package:logbook_app_062/features/onboarding/onboarding_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;

  const CustomAppBar({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Logbook: $username"),
      backgroundColor: const Color.fromARGB(255, 56, 189, 248),
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Konfirmasi Logout"),
                content: const Text("Apakah Anda yakin ingin keluar?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingView(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Ya, Keluar",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}