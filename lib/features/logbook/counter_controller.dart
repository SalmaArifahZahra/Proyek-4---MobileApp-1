import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  List<String> get recentHistory =>
      _history.length <= 5 ? _history : _history.sublist(_history.length - 5);

  void setStep(int step) {
    _step = step;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt('last_counter') ?? 0;

    final savedHistory = prefs.getStringList('history_full') ?? [];
    _history.clear();
    _history.addAll(savedHistory);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('last_counter', _counter);
    await prefs.setStringList('history_full', _history);
  }

  void increment(String username) {
    if (_step <= 0) return;
    _counter += _step;
    _addHistory("menambah +$_step", username);
    _saveData();
  }

  void decrement(String username) {
    _counter -= _step;
    if (_counter < 0) _counter = 0;
    _addHistory("mengurangi $_step", username);
    _saveData();
  }

  void reset(String username) {
    _counter = 0;
    _addHistory("mereset", username);
    _saveData();
  }

  void _addHistory(String action, String username) {
    final time = DateTime.now().toString().substring(11, 16);
    _history.add("user $username $action pada jam $time");

    if (_history.length > 50) {
      _history.removeAt(0);
    }
  }
}
