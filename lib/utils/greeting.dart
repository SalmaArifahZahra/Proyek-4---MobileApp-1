class Greeting {
  static String getGreeting(String username) {
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
}