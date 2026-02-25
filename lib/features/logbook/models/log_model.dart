class LogModel {
  final int id;
  final int iduser;
  final String title;
  final String description;
  final String timestamp;
  final String category;

  LogModel({
    required this.id,
    required this.iduser,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'],
      iduser: map['iduser'],
      title: map['title'],
      description: map['description'],
      timestamp: map['timestamp'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iduser': iduser,
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'category': category,
    };
  }
}
