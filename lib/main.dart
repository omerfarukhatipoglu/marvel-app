import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marvel/controllers/main_controller.dart';
import 'package:marvel/routes/pages.dart';
import 'package:marvel/routes/routes.dart';

void main() async {
  var mainController = Get.put(MainController());
  await mainController.loadPrefs();
  await mainController.loadCharacters();
  WidgetsFlutterBinding.ensureInitialized();

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
