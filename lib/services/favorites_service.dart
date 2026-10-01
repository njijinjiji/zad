import 'package:shared_preferences/shared_preferences.dart';
import '../models/matn_model.dart';

class FavoritesService {
  static const String _key = 'favorite_matn_ids';
  static final List<Matn> _favorites = [];

  static List<Matn> getFavorites() {
    return List.unmodifiable(_favorites);
  }

  static bool isFavorite(Matn matn) {
    return _favorites.any((item) => item.id == matn.id);
  }

  // تحميل المفضلات المخزنة محليًا عند بدء تشغيل التطبيق
  static Future<void> loadFavorites(List<Matn> allMutoon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds = prefs.getStringList(_key) ?? [];

    _favorites.clear();
    for (final id in savedIds) {
      final match = allMutoon.where((m) => m.id == id);
      if (match.isNotEmpty) {
        _favorites.add(match.first);
      }
    }
  }

  // إضافة أو إزالة المتن مع حفظ التغيير فورًا
  static Future<bool> toggleFavorite(Matn matn) async {
    final index = _favorites.indexWhere((item) => item.id == matn.id);
    bool added;

    if (index >= 0) {
      _favorites.removeAt(index);
      added = false;
    } else {
      _favorites.add(matn);
      added = true;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedIds = _favorites.map((m) => m.id).toList();
    await prefs.setStringList(_key, savedIds);

    return added;
  }
}