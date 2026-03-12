// import 'package:logbook_app_062/features/logbook/models/log_model.dart';
// import 'package:logbook_app_062/services/mongo_services.dart';
// import 'package:logbook_app_062/services/offline_log.dart';
// import 'package:logbook_app_062/services/hive_service.dart';
// import 'package:logbook_app_062/features/logbook/controller/log_controller.dart';
// class LogDataService {
//   final MongoService cloud = MongoService();
//   final OfflineLog local = OfflineLog();

//   Future<List<LogModel>> loadLogs(int teamId) async {
//     try {
//       final cloudLogs = await cloud.getLogs(teamId);
//       final localLogs = await local.retrieveAllLogs();

//       for (var cloudLog in cloudLogs) {
//         final exists = localLogs.any((l) => l.id == cloudLog.id);

//         if (!exists) {
//           await local.storeLog(cloudLog);
//         }
//       }

//       return await local.fetchLogs(teamId);
//     } catch (e) {
//       return await local.fetchLogs(teamId);
//     }
//   }

//   Future<LogModel> createLog(LogModel log) async {
//     await local.saveLog(log);

//     try {
//       await cloud.insertLog(log);

//       final syncedLog = LogModel(
//         id: log.id,
//         iduser: log.iduser,
//         title: log.title,
//         description: log.description,
//         timestamp: log.timestamp,
//         category: log.category,
//         teamId: log.teamId,
//         isSynced: true,
//       );

//       await local.updateLog(syncedLog);

//       return syncedLog;
//     } catch (_) {
//       return log;
//     }
//   }

//   Future<void> modifyLog(LogModel log) async {
//     await local.updateLog(log);

//     try {
//       await cloud.updateLog(log);
//     } catch (_) {}
//   }

//   Future<void> eraseLog(LogModel log) async {
//     await local.markDeleted(log);

//     try {
//       if (log.id != null) {
//         await cloud.deleteLog(log.id!);
//       }

//       await local.deleteLog(log);
//     } catch (_) {}
//   }

//   Future<void> synchronizeLogs() async {
//     final allLogs = await local.retrieveAllLogs();

//     final unsynced = allLogs.where((l) => !l.isSynced).toList();

//     for (var log in unsynced) {
//       try {
//         if (log.isDeleted) {
//           await cloud.deleteLog(log.id!);
//           await local.removeLocalLog(log.id!);
//           continue;
//         }

//         await cloud.insertLog(log);

//         final syncedLog = LogModel(
//           id: log.id,
//           iduser: log.iduser,
//           title: log.title,
//           description: log.description,
//           timestamp: log.timestamp,
//           category: log.category,
//           teamId: log.teamId,
//           isSynced: true,
//         );

//         await local.storeLog(syncedLog);
//       } catch (_) {}
//     }
//   }

//   Future<void> syncLogs() async {
//     final offlineLogs = await hiveService.getUnsyncedLogs();

//     for (var log in offlineLogs) {
//       if (log.isDeleted) {
//         if (log.mongoId != null) {
//           await mongoService.deleteLog(log.mongoId!);
//         }
//         await hiveService.deleteLog(log.id);
//       } else if (!log.isSynced) {
//         final result = await mongoService.addLog(log);

//         final updated = log.copyWith(isSynced: true, mongoId: result.mongoId);

//         await hiveService.updateLog(updated);
//       }
//     }
//   }  
// }
