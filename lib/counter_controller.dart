class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  void setStep(int step) {
    if (step > 0) {
      _step = step;
    }
  }

  void increment() {
    _counter += _step;
    _addHistory("Tambah $_step");
  }

  void decrement() {
    _counter -= _step;
    if (_counter < 0) _counter = 0;
    _addHistory("Kurang $_step");
  }

  void reset() {
    _counter = 0;
    _addHistory("Reset");
  }

  void _addHistory(String action) {
    _history.add(action);

    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }
}
