import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? mongoId;
  final int id;
  final int iduser;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;

  LogModel({
    this.mongoId,
    required this.id,
    required this.iduser,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      mongoId: map['_id'] as ObjectId?,
      id: map['id'] ?? 0,
      iduser: map['iduser'] ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      timestamp: map['timestamp'] == null
          ? DateTime.now()
          : (map['timestamp'] is DateTime
                ? map['timestamp']
                : DateTime.tryParse(map['timestamp'].toString()) ??
                      DateTime.now()),
      category: map['category']?.toString() ?? 'Lainnya',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': mongoId ?? ObjectId(),
      'id': id,
      'iduser': iduser,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }
}
