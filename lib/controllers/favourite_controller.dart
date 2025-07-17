import 'package:get/get.dart';
import 'package:marvel/modules/character.dart';
import 'package:marvel/services/favourite_service.dart';

class FavouriteController extends GetxController {
  final characters = <Character>[].obs;
  final isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    loadFavoritesFromDB();
  }

  Future<void> loadFavoritesFromDB() async {
    isLoading.value = true;
    characters.clear();

    final dataList = await FavoriteStorage.getAllCharacters();
    characters.addAll(dataList);

    isLoading.value = false;
  }

  Future<void> removeFromFavorites(Character ch) async {
    await FavoriteStorage.removeFavorite(ch.id);
    characters.removeWhere((c) => c.id == ch.id);
  }

  Future<void> reload() async {
    await loadFavoritesFromDB();
  }
}
