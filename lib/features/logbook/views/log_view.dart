import 'package:flutter/material.dart';
import 'package:logbook_app_062/features/logbook/controller/log_controller.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/features/logbook/views/counter_view.dart';
import 'package:logbook_app_062/component/app_bar.dart';
import 'package:logbook_app_062/features/logbook/models/user_model.dart';
import 'package:logbook_app_062/helpers/log_helper.dart';
import 'package:logbook_app_062/services/mongo_services.dart';

class LogView extends StatefulWidget {
  final UserModel user;
  const LogView({super.key, required this.user});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  bool _isLoading = true;
  final LogController _controller = LogController();

  @override
  void initState() {
    super.initState();
    // _controller.loadFromDisk(widget.user.id);
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      // Mencoba koneksi ke MongoDB Atlas (Cloud)
      await LogHelper.writeLog(
        "UI: Menghubungi MongoService.connect()...",
        source: "log_view.dart",
      );

      // Mengaktifkan kembali koneksi dengan timeout 15 detik (lebih longgar untuk sinyal HP)
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
      );

      // Mengambil data log dari Cloud
      await LogHelper.writeLog(
        "UI: Memanggil controller.loadFromDisk()...",
        source: "log_view.dart",
      );

      await _controller.loadFromDisk(widget.user.id);

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat ke Notifier.",
        source: "log_view.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "UI: Error - $e",
        source: "log_view.dart",
        level: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 2. INILAH FINALLY: Apapun yang terjadi (Sukses/Gagal/Data Kosong), loading harus mati
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Color _getCategoryColor(String category) {
  //   switch (category.toLowerCase()) {
  //     case "kerja":
  //       return Colors.green;
  //     case "kuliah":
  //       return Colors.blue;
  //     case "urgent":
  //       return Colors.red;
  //     case "pribadi":
  //       return Colors.deepOrange;
  //     default:
  //       return Colors.grey;
  //   }
  // }

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
      builder: (context) => AlertDialog(
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
            onPressed: () {
              _controller.addLog(
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );

              setState(() {
                _selectedCategory = _categories.first;
              });

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
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
      builder: (context) => AlertDialog(
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
            onPressed: () {
              _controller.updateLog(
                index,
                _titleController.text,
                _contentController.text,
                _selectedCategory,
              );

              setState(() {
                _selectedCategory = _categories.first;
              });

              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
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
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, currentLogs, child) {
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Menghubungkan ke MongoDB Atlas..."),
                ],
              ),
            );
          }

          if (currentLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Belum ada catatan di Cloud."),
                  ElevatedButton(
                    onPressed: _showAddLogDialog,
                    child: const Text("Buat Catatan Pertama"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: currentLogs.length,
            itemBuilder: (context, index) {
              final log = currentLogs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.green),
                  title: Text(log.title),
                  subtitle: Text(log.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditLogDialog(index, log),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _controller.removeLog(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
