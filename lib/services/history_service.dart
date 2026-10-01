import 'package:shared_preferences/shared_preferences.dart';
import '../models/matn_model.dart';

class HistoryService {
  static const String _key = 'history_matn_ids';
  static final List<Matn> _history = [];

  static List<Matn> getHistory() {
    return List.unmodifiable(_history);
  }

  // تحميل السجل المخزن محليًا عند بدء تشغيل التطبيق
  static Future<void> loadHistory(List<Matn> allMutoon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds = prefs.getStringList(_key) ?? [];

    _history.clear();
    for (final id in savedIds) {
      final match = allMutoon.where((m) => m.id == id);
      if (match.isNotEmpty) {
        _history.add(match.first);
      }
    }
  }

  // تسجيل المتن وحفظ القائمة في الذاكرة الدائمة
  static Future<void> addToHistory(Matn matn) async {
    _history.removeWhere((item) => item.id == matn.id);
    _history.insert(0, matn);

    final prefs = await SharedPreferences.getInstance();
    final savedIds = _history.map((m) => m.id).toList();
    await prefs.setStringList(_key, savedIds);
  }

  // مسح السجل وتحديث التخزين
  static Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}