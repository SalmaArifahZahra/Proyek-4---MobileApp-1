import 'package:flutter/material.dart';
import 'package:logbook_app_062/features/onboarding/onboarding_view.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  double _nilaiSlider = 1;

  Color _getHistoryColor(String text) {
    if (text.contains("menambah")) {
      return Colors.green;
    } else if (text.contains("mengurangi")) {
      return Colors.red;
    } else if (text.contains("mereset")) {
      return Colors.grey;
    }
    return Colors.black;
  }

  @override
  void initState() {
    super.initState();
    _controller.loadData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: const Color.fromARGB(255, 56, 189, 248),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text("Apakah Anda yakin ingin keluar?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingView(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Ya, Keluar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Counter App",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_controller.value}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Total Hitungan",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _nilaiSlider,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _nilaiSlider.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _nilaiSlider = value;
                      _controller.setStep(value.round());
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.decrement(widget.username);
                          });
                        },
                        child: const Text('-'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 60,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.increment(widget.username);
                          });
                        },
                        child: const Text('+'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Konfirmasi Reset"),
                              content: const Text(
                                "Apakah kamu yakin ingin mereset?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _controller.reset(widget.username);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Reset"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  "Riwayat History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => HistoryDialog(
                        history: _controller.history,
                        getHistoryColor: _getHistoryColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("Lihat Semua History"),
                ),
                const SizedBox(height: 15),
                // 5 data terakhir
                Column(
                  children: _controller.recentHistory.isEmpty
                      ? [
                          const Text(
                            "Belum ada aktivitas",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ]
                      : _controller.recentHistory.map((item) {
                          return Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: _getHistoryColor(item),
                            ),
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  class HistoryDialog extends StatelessWidget {
    final List<String> history;
    final Color Function(String) getHistoryColor;

    const HistoryDialog({
      super.key,
      required this.history,
      required this.getHistoryColor,
    });

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        title: const Text("Seluruh History"),
        content: SizedBox(
          width: double.maxFinite,
          height: 200, 
          child: history.isEmpty
              ? const Text("Belum ada aktivitas")
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index]; 
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
      );
    }
}
