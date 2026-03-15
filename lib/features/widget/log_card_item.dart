import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/features/widget/sync_indicator.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LogCardItem extends StatelessWidget {
  final LogModel log;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LogCardItem({super.key, required this.log, this.onEdit, this.onDelete});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "mechanical":
        return Colors.orange;
      case "electronic":
        return Colors.blue;
      case "software":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return "Baru saja";
    if (difference.inMinutes < 60) return "${difference.inMinutes} menit lalu";
    if (difference.inHours < 24) return "${difference.inHours} jam lalu";
    if (difference.inDays < 7) return "${difference.inDays} hari lalu";

    return DateFormat("dd MMM yyyy", "id_ID").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.description_outlined, color: Colors.grey),
        title: Text(log.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(data: log.description, shrinkWrap: true),
            const SizedBox(height: 6),
            Text(
              _formatTimestamp(log.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(log.category),
                  backgroundColor: _getCategoryColor(log.category),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                SyncIndicator(isSynced: log.isSynced),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
