import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:logbook_app_062/services/mongo_services.dart';
import 'package:logbook_app_062/services/offline_log.dart';

class HiveService {
  final Connectivity _connectivity = Connectivity();
  final OfflineLog _local = OfflineLog();
  final MongoService _mongo = MongoService();

  final ValueNotifier<bool> syncTrigger = ValueNotifier(false);

  bool _isSyncing = false;

  void viaConnectivity() {
    _connectivity.onConnectivityChanged.listen((results) async {
      if (!results.contains(ConnectivityResult.none)) {
        await syncLogs();

        syncTrigger.value = !syncTrigger.value;
      }
    });
  }

  Future<void> syncLogs() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final logs = await _local.getLogs();

      for (var log in logs) {
        if (!log.isSynced && !log.isDeleted) {
          try {
            await _mongo.updateLog(log);

            await _local.updateLog(log.copyWith(isSynced: true));
          } catch (_) {
            continue;
          }
        }

        if (log.isDeleted) {
          try {
            await _mongo.deleteLog(log.id);
            await _local.deleteLog(log.id);
          } catch (_) {
            continue;
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
