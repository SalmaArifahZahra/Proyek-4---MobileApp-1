import 'package:flutter/material.dart';
import 'package:logbook_app_062/features/logbook/controller/counter_controller.dart';
import 'package:logbook_app_062/component/history_section.dart';
import 'package:logbook_app_062/component/app_bar.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CounterController _controller;
  double _nilaiSlider = 1;

  @override
  void initState() {
    super.initState();

    _controller = CounterController(widget.username);

    _controller.loadData().then((_) {
      setState(() {});
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(username: widget.username),
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
                Column(
                  children: [
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
                                _controller.decrement();
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
                                _controller.increment();
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
                                          _controller.reset();
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

                    const SizedBox(height: 24),
                    HistorySection(
                      recentHistory: _controller.recentHistory,
                      allHistory: _controller.history,
                      getHistoryColor: _getHistoryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
