import 'package:flutter/material.dart';

class HistorySection extends StatelessWidget {
  final List<String> recentHistory;
  final List<String> allHistory;
  final Color Function(String) getHistoryColor;

  const HistorySection({
    super.key,
    required this.recentHistory,
    required this.allHistory,
    required this.getHistoryColor,
  });

  void _showAllHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("All History"),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: allHistory.isEmpty
              ? const Text("Belum ada aktivitas")
              : ListView.builder(
                  itemCount: allHistory.length,
                  itemBuilder: (context, index) {
                    final item = allHistory[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        item,
                        style: TextStyle(color: getHistoryColor(item)),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          "Riwayat History",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showAllHistoryDialog(context),
          icon: const Icon(Icons.history),
          label: const Text("Lihat Semua History"),
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recentHistory.isEmpty
              ? [
                  const Text(
                    "Belum ada aktivitas",
                    style: TextStyle(color: Colors.grey),
                  ),
                ]
              : recentHistory.map((item) {
                  return Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: getHistoryColor(item),
                    ),
                  );
                }).toList(),
        ),
      ],
    );
  }
}
