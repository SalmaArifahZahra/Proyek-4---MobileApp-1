import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/features/logbook/models/user_model.dart';
import 'package:logbook_app_062/features/logbook/views/log_editor_page.dart';
import 'package:logbook_app_062/features/logbook/controller/log_controller.dart';
import 'package:logbook_app_062/component/app_bar.dart';
import 'package:logbook_app_062/features/logbook/views/counter_view.dart';
import 'package:logbook_app_062/services/access_control_service.dart';
import 'package:logbook_app_062/services/hive_service.dart';

class LogView extends StatefulWidget {
  final UserModel user;

  const LogView({super.key, required this.user});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  late final HiveService hiveService;

  String _searchQuery = "";

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

  @override
  void initState() {
    super.initState();

    _controller = LogController();
    hiveService = HiveService();

    _controller.fetchLogs(widget.user.teamId);

    hiveService.syncTrigger.addListener(() {
      _controller.fetchLogs(widget.user.teamId);
    });
  }

  void _goToEditor({LogModel? log}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LogEditorPage(log: log, controller: _controller, user: widget.user),
      ),
    ).then((_) {
      _controller.fetchLogs(widget.user.teamId);
    });
  }

  @override
  void dispose() {
    _controller.logsNotifier.dispose();
    _controller.loadingNotifier.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return "Baru saja";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} menit lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} jam lalu";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} hari lalu";
    } else {
      return DateFormat("dd MMM yyyy", "id_ID").format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(username: widget.user.username),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search Logbook...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {
                List<LogModel> logs = currentLogs;

                logs = logs.where((log) {
                  return log.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      log.description.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                }).toList();
                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text("Belum ada catatan."),
                        ElevatedButton(
                          onPressed: () => _goToEditor(),
                          child: const Text("Buat Catatan Pertama"),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _controller.fetchLogs(widget.user.teamId);
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final canEdit = AccessPolicy.canPerform(
                        widget.user.role,
                        AccessPolicy.actionUpdate,
                        isOwner: log.iduser == widget.user.id,
                      );

                      final canDelete = AccessPolicy.canPerform(
                        widget.user.role,
                        AccessPolicy.actionDelete,
                        isOwner: log.iduser == widget.user.id,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            log.isSynced
                                ? Icons.cloud_done
                                : Icons.cloud_upload_outlined,
                            color: log.isSynced ? Colors.green : Colors.orange,
                          ),

                          title: Text(log.title),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.description),

                              const SizedBox(height: 6),

                              Text(
                                _formatTimestamp(log.timestamp),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Chip(
                                label: Text(log.category),
                                backgroundColor: _getCategoryColor(
                                  log.category,
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canEdit)
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _goToEditor(log: log),
                                ),

                              if (canDelete)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Konfirmasi Hapus"),
                                        content: const Text(
                                          "Hapus catatan ini?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _controller.removeLog(log);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "addLog",
            onPressed: () => _goToEditor(),
            child: const Icon(Icons.add),
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: "goCounter",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CounterView(username: widget.user.username),
                ),
              );
            },
            child: const Icon(Icons.calculate),
          ),
        ],
      ),
    );
  }
}
