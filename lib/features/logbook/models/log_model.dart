import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int iduser;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final int teamId;

  @HiveField(7)
  final bool isDeleted;

  @HiveField(8)
  final bool isSynced;

  LogModel({
    String? id,
    required this.iduser,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.teamId,
    this.isDeleted = false,
    this.isSynced = false,
  }) : id = id ?? ObjectId().oid;

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id']?.toString() ?? ObjectId().oid,
      iduser: map['iduser'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] == null
          ? DateTime.now()
          : (map['timestamp'] is DateTime
                ? map['timestamp']
                : DateTime.tryParse(map['timestamp'].toString()) ??
                      DateTime.now()),
      category: map['category'] ?? '',
      teamId: map['teamId'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,

      isSynced: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'iduser': iduser,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'teamId': teamId,
      'isDeleted': isDeleted,
    };
  }

  LogModel copyWith({
    String? id,
    int? iduser,
    String? title,
    String? description,
    DateTime? timestamp,
    String? category,
    int? teamId,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return LogModel(
      id: id ?? this.id,
      iduser: iduser ?? this.iduser,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      teamId: teamId ?? this.teamId,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
