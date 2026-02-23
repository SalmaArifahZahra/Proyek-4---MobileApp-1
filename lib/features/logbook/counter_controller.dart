import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;

   String username;

  final List<String> _history = [];

   CounterController(this.username); 

  int get value => _counter;
  List<String> get history => _history;

  List<String> get recentHistory =>
      _history.length <= 5 ? _history : _history.sublist(_history.length - 5);

  void setStep(int step) {
    _step = step;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt('last_counter_$username') ?? 0;

    final savedHistory = prefs.getStringList('history_full_$username') ?? [];
    _history.clear();
    _history.addAll(savedHistory);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('last_counter_$username', _counter);
    await prefs.setStringList('history_full_$username', _history);
  }

  void increment() {
    if (_step <= 0) return;
    _counter += _step;
    _addHistory("menambah +$_step");
    _saveData();
  }

  void decrement() {
    _counter -= _step;
    if (_counter < 0) _counter = 0;
    _addHistory("mengurangi $_step");
    _saveData();
  }

  void reset() {
    _counter = 0;
    _addHistory("mereset");
    _saveData();
  }

  void _addHistory(String action) {
    final time = DateTime.now().toString().substring(11, 16);
    _history.add("user $username $action pada jam $time");

    if (_history.length > 50) {
      _history.removeAt(0);
    }
  }
}
