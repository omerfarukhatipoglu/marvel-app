import 'package:get/get.dart';
import 'package:marvel/modules/character.dart';
import 'package:marvel/services/favourite_service.dart';
import 'package:marvel/services/my_api.dart';

class FavouriteController extends GetxController {
  final characters = <Character>[].obs;
  final isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    isLoading.value = true;
    final ids = await FavoriteStorage.getFavoriteIds();
    characters.clear();

    final api = MyApi();
    for (final id in ids) {
      final ch = await api.fetchCharacterById(id);
      if (ch != null) characters.add(ch);
    }

    isLoading.value = false;
  }
}
