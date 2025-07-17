import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marvel/controllers/favourite_controller.dart';
import 'package:marvel/controllers/main_controller.dart';
import 'package:marvel/routes/pages.dart';
import 'package:marvel/routes/routes.dart';
import 'package:marvel/services/favourite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoriteStorage.getFavoriteIds(); // bu otomatik olarak DB'yi init eder

  Get.put(MainController());
  await Get.find<MainController>().loadPrefs();
  await Get.find<MainController>().loadCharacters();

  Get.put(FavouriteController()); // ❗ Sadece burada put et, başka yerde değil!
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: Pages.pages,
      initialRoute: Routes.SPLASH_PAGE,
      debugShowCheckedModeBanner: false,
    );
  }
}
