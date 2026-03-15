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

    // Semua role boleh membaca
    if (action == actionRead) return true;

    // Manager boleh update semua catatan
    if (role == 'Manager' && action == actionUpdate) {
      return true;
    }

    // Delete hanya boleh jika pemilik catatan
    if (action == actionDelete) {
      return isOwner;
    }

    // Supervisor dan Karyawan update milik sendiri
    if (action == actionUpdate) {
      return isOwner;
    }

    return true;
  }
}
