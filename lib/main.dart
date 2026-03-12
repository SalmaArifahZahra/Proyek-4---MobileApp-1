import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/logbook/views/splash_view.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  // Registrasi adapter LogModel
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LogModelAdapter()); // index 0
  }

  // Buka box sesuai dengan LogLocalService
  await Hive.openBox<LogModel>('logs');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const SplashView(),
    );
  }
}
