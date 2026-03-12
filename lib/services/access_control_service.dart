import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessPolicy {
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ?? ['Karyawan'];

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static final Map<String, List<String>> _rolePermissions = {
    'Manager': [actionCreate, actionRead, actionUpdate, actionDelete],
    'Supervisor': [actionCreate, actionRead, actionUpdate, actionDelete],
    'Karyawan': [actionCreate, actionRead, actionUpdate, actionDelete],

  };

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    final permissions = _rolePermissions[role] ?? [];
    if (!permissions.contains(action)) return false;

    // Manager bebas akses semua
    if (role == 'Manager') return true;

    // Supervisor & Karyawan hanya bisa Update & Delete jika dia pemiliknya (isOwner)
    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    // Untuk Create dan Read, mereka selalu diizinkan
    return true;
  }
}
