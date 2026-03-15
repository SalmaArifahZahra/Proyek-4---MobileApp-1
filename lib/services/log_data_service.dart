import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/services/mongo_services.dart';
import 'package:logbook_app_062/services/offline_log.dart';

class LogDataService {
  final MongoService cloud = MongoService();
  final OfflineLog local = OfflineLog();

  Future<List<LogModel>> loadLogs() async {
    try {
      final cloudLogs = await cloud.getLogs();

      for (var log in cloudLogs) {
        await local.saveLog(log.copyWith(isSynced: true));
      }
    } catch (_) {}

    final localLogs = await local.getLogs();

    return localLogs.where((l) => !l.isDeleted).toList();
  }

  Future<LogModel> createLog(LogModel log) async {
    await local.saveLog(log);

    try {
      await cloud.insertLog(log);

      final syncedLog = log.copyWith(isSynced: true);

      await local.updateLog(syncedLog);

      return syncedLog;
    } catch (_) {
      return log;
    }
  }

  Future<void> modifyLog(LogModel log) async {
    final updatedLog = log.copyWith(isSynced: false);

    await local.updateLog(updatedLog);

    try {
      await cloud.updateLog(updatedLog);

      await local.updateLog(updatedLog.copyWith(isSynced: true));
    } catch (_) {}
  }

  Future<void> eraseLog(LogModel log) async {
    await local.markDeleted(log);

    try {
      await cloud.deleteLog(log.id);

      await local.deleteLog(log.id);
    } catch (_) {}
  }

  Future<List<LogModel>> getLocalLogs(String teamId) async {
    return await local.fetchLogs(int.parse(teamId));
  }

  Future<List<LogModel>> getCloudLogs() async {
    return await cloud.getLogs();
  }

  Future<void> syncLogs() async {
    final allLogs = await local.retrieveAllLogs();

    final unsynced = allLogs.where((l) => !l.isSynced).toList();

    for (var log in unsynced) {
      try {
        if (log.isDeleted) {
          await cloud.deleteLog(log.id);

          await local.removeLocalLog(log.id);

          continue;
        }

        try {
          await cloud.updateLog(log);
        } catch (_) {
          await cloud.insertLog(log);
        }

        final syncedLog = log.copyWith(isSynced: true);

        await local.updateLog(syncedLog);
      } catch (_) {}
    }
  }
}
