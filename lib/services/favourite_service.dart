import 'package:shared_preferences/shared_preferences.dart';

class FavoriteStorage {
  static const _key = 'favorite_character_ids';

  static Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.map(int.parse).toList() ?? [];
  }

  static Future<void> addFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    if (!current.contains(id.toString())) {
      current.add(id.toString());
      await prefs.setStringList(_key, current);
    }
  }

  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove(id.toString());
    await prefs.setStringList(_key, current);
  }

  static Future<bool> isFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    return current.contains(id.toString());
  }
}
