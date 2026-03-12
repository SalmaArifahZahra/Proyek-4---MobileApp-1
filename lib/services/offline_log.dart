import 'package:hive/hive.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';

class OfflineLog {
  static const String boxName = "logs";

  Future<Box<LogModel>> _openBox() async {
    return await Hive.openBox<LogModel>(boxName);
  }

  Future<List<LogModel>> getLogs() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> saveLog(LogModel log) async {
    final box = await _openBox();

    await box.put(log.id, log);
  }

  Future<void> updateLog(LogModel log) async {
    final box = await _openBox();

    await box.put(log.id, log);
  }

  Future<void> deleteLog(String id) async {
    final box = await _openBox();

    await box.delete(id);
  }

  Future<void> markDeleted(LogModel log) async {
    final box = await _openBox();

    final updatedLog = log.copyWith(isDeleted: true, isSynced: false);

    await box.put(log.id, updatedLog);
  }

  Future<List<LogModel>> fetchLogs(int teamId) async {
    final logs = await retrieveAllLogs();

    return logs.where((log) => log.teamId == teamId && !log.isDeleted).toList();
  }

  Future<List<LogModel>> retrieveAllLogs() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> removeLocalLog(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}

