import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_062/features/logbook/controller/log_controller.dart';
import 'package:logbook_app_062/features/logbook/models/log_model.dart';
import 'package:logbook_app_062/features/logbook/models/user_model.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final LogController controller;
  final UserModel user;

  const LogEditorPage({
    super.key,
    this.log,
    required this.controller,
    required this.user,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  String _selectedCategory = "Mechanical";

  final List<String> _categories = ["Mechanical", "Electronic", "Software"];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.log?.title ?? '');

    _descController = TextEditingController(
      text: widget.log?.description ?? '',
    );

    if (widget.log != null) {
      _selectedCategory = widget.log!.category;
    }

    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Judul tidak boleh kosong")));
      return;
    }

    if (widget.log == null) {
      widget.controller.addLog(
        iduser: widget.user.id,
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        teamId: widget.user.teamId.first,
      );
    } else {
      widget.controller.updateLog(
        oldLog: widget.log!,
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
        ),
        body: TabBarView(
          children: [
            // Editor
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: "Kategori"),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporan dengan format Markdown...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Preview
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _descController,
              builder: (context, value, child) {
                return Markdown(
                  data: value.text,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    p: const TextStyle(fontSize: 16),
                    listBullet: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
