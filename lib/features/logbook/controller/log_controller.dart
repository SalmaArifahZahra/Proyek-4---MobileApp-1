import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  static const String _storageKey = 'user_logs_data';
  static const String _idKey = 'id_log_counter';

  final List<LogModel> _logList = [];

  int? _activeUserId;

  Future<void> addLog(String title, String desc, String category) async {
    final newId = await _getNextLogId();

    final newLog = LogModel(
      id: newId,
      iduser: _activeUserId!,
      title: title,
      description: desc,
      timestamp: DateTime.now().toString(),
      category: category,
    );
    _logList.add(newLog);
    _updateNotifier();
    await saveToDisk();
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc,
    String category,
  ) async {
    final oldLog = _logList[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      timestamp: DateTime.now().toString(),
      description: desc,
      category: category,
    );

    _logList[index] = updatedLog;
    _updateNotifier();
    await saveToDisk();
  }

  void removeLog(int index) {
    _logList.removeAt(index);
    _updateNotifier();
    saveToDisk();
  }

  Future<int> _getNextLogId() async {
    final prefs = await SharedPreferences.getInstance();
    int currentId = prefs.getInt(_idKey) ?? 0;

    currentId++;
    await prefs.setInt(_idKey, currentId);

    return currentId;
  }

  void searchLog(String query) {
    if (_activeUserId == null) return;

    final logUser = _logList
        .where((log) => log.iduser == _activeUserId)
        .toList();

    if (query.isEmpty) {
      logsNotifier.value = logUser;
    } else {
      logsNotifier.value = logUser
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _updateNotifier() {
    if (_activeUserId == null) return;

    logsNotifier.value = _logList
        .where((log) => log.iduser == _activeUserId)
        .toList();
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _logList.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk(int iduser) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);

    _activeUserId = iduser;

    if (data != null) {
      final List decoded = jsonDecode(data);
      _logList.clear();
      _logList.addAll(decoded.map((e) => LogModel.fromMap(e)).toList());
      _updateNotifier();
    }
  }

  Future<void> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String? rawJson = prefs.getString('saved_logs');

    if (rawJson != null) {
      Iterable decoded = jsonDecode(rawJson);

      logsNotifier.value = decoded
          .map((item) => LogModel.fromMap(item))
          .toList();
    }
  }
}
