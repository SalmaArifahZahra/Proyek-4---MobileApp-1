import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/features/logbook/views/counter_view.dart';
import 'package:logbook_app_062/component/app_bar.dart';
import 'package:logbook_app_062/features/logbook/models/user_model.dart';
import 'package:logbook_app_062/services/mongo_services.dart';
import 'package:logbook_app_062/features/logbook/controller/log_controller.dart';

class LogView extends StatefulWidget {
  final UserModel user;
  const LogView({super.key, required this.user});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  late Future<List<LogModel>> _logsFuture;

  String _searchQuery = "";

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "kerja":
        return Colors.green;
      case "kuliah":
        return Colors.blue;
      case "urgent":
        return Colors.red;
      case "pribadi":
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.loadFromDisk(widget.user.id);
    _logsFuture = _fetchLogs();
  }

  Future<List<LogModel>> _fetchLogs() async {
    final allLogs = await MongoService().getLogs();

    return allLogs
        .where((log) => log.iduser.toString() == widget.user.id.toString())
        .toList();
  }

  void _refreshLogs() {
    setState(() {
      _logsFuture = _fetchLogs();
    });
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return "Baru saja";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} menit yang lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} jam yang lalu";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} hari yang lalu";
    } else {
      return DateFormat("dd MMM yyyy", "id_ID").format(date);
    }
  }

  String _selectedCategory = "Pribadi";
  final List<String> _categories = [
    "Pribadi",
    "Kuliah",
    "Kerja",
    "Urgent",
    "Lainnya",
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _showAddLogDialog() {
    _selectedCategory = _categories.first;
    _titleController.clear();
    _contentController.clear();

    showDialog(
      context: context,
      builder: (dialogcontext) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _controller.addLog(
                widget.user.id,
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );

              if (!mounted) return;

              Navigator.of(context).pop();
              _refreshLogs();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Catatan berhasil ditambahkan"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (dialogcontext) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            const SizedBox(height: 25),
            TextField(controller: _contentController),
            const SizedBox(height: 25),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedLog = LogModel(
                id: log.id,
                iduser: log.iduser,
                title: _titleController.text,
                description: _contentController.text,
                category: _selectedCategory,
                timestamp: log.timestamp,
                mongoId: log.mongoId,
              );

              await MongoService().updateLog(updatedLog);

              if (!mounted) return;

              Navigator.pop(context);
              _refreshLogs();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
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
            child: FutureBuilder<List<LogModel>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Mengambil data dari MongoDB Atlas..."),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Anda sedang Offline",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Periksa koneksi internet Anda dan coba lagi.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshLogs,
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  );
                }

                final allLogs = snapshot.data ?? [];

                final logs = allLogs.where((log) {
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
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text("Data Kosong"),
                        ElevatedButton(
                          onPressed: _showAddLogDialog,
                          child: const Text("Buat Catatan Pertama"),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshLogs();
                    await _logsFuture;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];

                      return Dismissible(
                        key: ValueKey(log.mongoId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Konfirmasi Hapus"),
                              content: const Text(
                                "Apakah Anda yakin ingin menghapus catatan ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await MongoService().deleteLog(log.mongoId!);
                          _refreshLogs();
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.cloud_done,
                              color: Colors.green,
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    _showEditLogDialog(index, log);
                                  },
                                ),
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
                                          "Apakah Anda yakin ingin menghapus catatan ini?",
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
                                      await MongoService().deleteLog(
                                        log.mongoId!,
                                      );
                                      _refreshLogs();
                                    }
                                  },
                                ),
                              ],
                            ),
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
            onPressed: _showAddLogDialog,
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
