import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();

  Db? _db;
  DbCollection? _collection;

  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;

  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await LogHelper.writeLog(
        "INFO: Koleksi belum siap, mencoba koneksi ulang...",
        source: _source,
        level: 3,
      );

      await connect();
    }

    return _collection!;
  }

  Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGODB_URI'];

      if (dbUri == null) {
        throw Exception("MONGODB_URI tidak ditemukan di .env");
      }

      _db = await Db.create(dbUri);

      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Koneksi MongoDB timeout");
        },
      );

      _collection = _db!.collection('logs');

      await LogHelper.writeLog(
        "DATABASE: Terhubung ke MongoDB",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Gagal koneksi - $e",
        source: _source,
        level: 1,
      );

      rethrow;
    }
  }

  Future<List<LogModel>> getLogs() async {
    try {
      final collection = await _getSafeCollection();

      final data = await collection.find().toList();

      await LogHelper.writeLog(
        "INFO: Mengambil semua log dari cloud",
        source: _source,
        level: 3,
      );

      return data.map((e) => LogModel.fromMap(e)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Fetch log gagal - $e",
        source: _source,
        level: 1,
      );

      return [];
    }
  }

  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();

      await LogHelper.writeLog(
        "[INSERT] Menambahkan '${log.title}' ke MongoDB",
        source: _source,
        level: 3,
      );

      await collection.insertOne({
        "_id": log.id,
        "iduser": log.iduser,
        "title": log.title,
        "description": log.description,
        "category": log.category,
        "teamId": log.teamId,
        "timestamp": log.timestamp,
        "isDeleted": log.isDeleted,
      });

      await LogHelper.writeLog(
        "[INSERT] SUCCESS: '${log.title}' tersimpan",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "[INSERT] ERROR - $e",
        source: _source,
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> updateLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();

      await LogHelper.writeLog(
        "[UPDATE] REQUEST - ID ${log.id}",
        source: _source,
        level: 3,
      );

      await collection.replaceOne(where.eq('_id', log.id), log.toMap());

      await LogHelper.writeLog(
        "[UPDATE] SUCCESS: '${log.title}' berhasil diupdate",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "[UPDATE] ERROR - $e",
        source: _source,
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      final collection = await _getSafeCollection();

      await LogHelper.writeLog(
        "[DELETE] REQUEST - ID $id",
        source: _source,
        level: 3,
      );

      await collection.remove(where.eq('_id', id));

      await LogHelper.writeLog(
        "[DELETE] SUCCESS - ID $id berhasil dihapus",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "[DELETE] ERROR - $e",
        source: _source,
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();

      await LogHelper.writeLog(
        "DATABASE: Koneksi MongoDB ditutup",
        source: _source,
        level: 2,
      );
    }
  }
}
