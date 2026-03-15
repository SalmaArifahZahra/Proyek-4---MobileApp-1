import 'package:flutter/foundation.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/services/log_data_service.dart';
import 'package:uuid/uuid.dart';

class LogController {
  final LogDataService service = LogDataService();

  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  Future<List<LogModel>> getLocalLogs(String teamId) async {
    return await service.getLocalLogs(teamId);
  }

  Future<List<LogModel>> getCloudLogs(String teamId) async {
    return await service.getCloudLogs();
  }

  Future<void> fetchLogs(List<int> teamIdx) async {
    loadingNotifier.value = true;

    final Map<String, LogModel> merged = {};

    for (final teamId in teamIdx) {
      final localLogs = await service.getLocalLogs(teamId.toString());

      await service.syncLogs();

      final cloudLogs = await service.getCloudLogs();

      for (var log in cloudLogs) {
        merged[log.id] = log;
      }

      for (var log in localLogs) {
        merged[log.id] = log;
      }
    }

    logsNotifier.value = merged.values.toList();

    loadingNotifier.value = false;
  }

  Future<void> addLog({
    required int iduser,
    required String title,
    required String description,
    required String category,
    required int teamId,
  }) async {
    final newLog = LogModel(
      id: const Uuid().v4(),
      iduser: iduser,
      title: title,
      description: description.trim(),
      timestamp: DateTime.now(),
      category: category,
      teamId: teamId,
      isSynced: false,
      isDeleted: false,
    );

    final insertedLog = await service.createLog(newLog);

    logsNotifier.value = [...logsNotifier.value, insertedLog];
  }

  Future<void> updateLog({
    required LogModel oldLog,
    required String title,
    required String description,
    required String category,
  }) async {
    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      description: description.trim(),
      timestamp: DateTime.now(),
      category: category,
      teamId: oldLog.teamId,
      isSynced: false,
      isDeleted: false,
    );

    await service.modifyLog(updatedLog);

    final logs = [...logsNotifier.value];
    final index = logs.indexWhere((log) => log.id == oldLog.id);

    if (index != -1) {
      logs[index] = updatedLog;
      logsNotifier.value = logs;
    }
  }

  Future<void> removeLog(LogModel log) async {
    await service.eraseLog(log);

    logsNotifier.value = logsNotifier.value
        .where((l) => l.id != log.id)
        .toList();
  }
}
