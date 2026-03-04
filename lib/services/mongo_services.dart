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
        "INFO: Koleksi belum siap, mencoba rekoneksi...",
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
      if (dbUri == null) throw Exception("MONGODB_URI tidak ditemukan di .env");

      _db = await Db.create(dbUri);

      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            "Koneksi Timeout. Cek IP Whitelist (0.0.0.0/0) atau Sinyal HP.",
          );
        },
      );

      _collection = _db!.collection('logs');

      await LogHelper.writeLog(
        "DATABASE: Terhubung & Koleksi Siap",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "DATABASE: Gagal Koneksi - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<List<LogModel>> getLogs() async {
    try {
      await LogHelper.writeLog(
        "[GET] REQUEST: Memulai pengambilan data dari Cloud...",
        source: _source,
        level: 3,
      );

      final collection = await _getSafeCollection();
      final List<Map<String, dynamic>> data = await collection.find().toList();

      await LogHelper.writeLog(
        "[GET] SUCCESS: ${data.length} Data berhasil diambil ",
        source: _source,
        level: 3,
      );

      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog("[GET] ERROR - $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<void> insertLog(
    int id,
    int iduser,
    String title,
    String description,
    String category,
  ) async {
    try {
      await LogHelper.writeLog(
        "[INSERT] REQUEST - User $iduser: Menambahkan '$title' ke Cloud...",
        source: _source,
        level: 3,
      );

      final collection = await _getSafeCollection();

      await collection.insertOne({
        "iduser": iduser,
        "title": title,
        "description": description,
        "category": category,
        "createdAt": DateTime.now().toIso8601String(),
      });

      await LogHelper.writeLog(
        "[INSERT] SUCCESS: Data '$title' Saved to Cloud",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "[INSERT] ERROR: Insert Failed - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<void> updateLog(LogModel log) async {
    try {
      await LogHelper.writeLog(
        "[UPDATE] REQUEST - ID ${log.mongoId}",
        source: _source,
        level: 3,
      );

      final collection = await _getSafeCollection();

      if (log.mongoId == null) {
        // ignore: curly_braces_in_flow_control_structures
        throw Exception("ID Log tidak ditemukan untuk update");
      }

      await collection.replaceOne(where.id(log.mongoId!), log.toMap());

      await LogHelper.writeLog(
        "[UPDATE] SUCCESS: Update '${log.title}' Berhasil",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "[UPDATE] ERROR: Update Gagal - $e",
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  Future<void> deleteLog(ObjectId id) async {
    try {
      await LogHelper.writeLog(
        "[DELETE] REQUEST - ID $id: Menghapus data dari Cloud...",
        source: _source,
        level: 3,
      );

      final collection = await _getSafeCollection();
      await collection.remove(where.id(id));

      await LogHelper.writeLog(
        "[DELETE] SUCCESS: Hapus ID $id Berhasil",
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
        "DATABASE: Koneksi ditutup",
        source: _source,
        level: 2,
      );
    }
  }
}
