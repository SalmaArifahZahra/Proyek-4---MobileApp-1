import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logbook Salma: SRP Version"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  '${_controller.value}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "Total Hitungan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: 120,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Step',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final step = int.tryParse(value) ?? 1;
                      setState(() {
                        _controller.setStep(step);
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 45,
                      child: ElevatedButton(
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
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.reset();
                          });
                        },
                        child: const Text('Reset'),
                        
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  "History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),
                Column(
                  children: _controller.history.isEmpty
                      ? [
                          const Text(
                            "Belum ada aktivitas",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ]
                      : _controller.history
                            .map(
                              (item) => Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            )
                            .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
