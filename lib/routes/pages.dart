import 'package:get/get.dart';
import 'package:marvel/bindings/favourite_binding.dart';
import 'package:marvel/bindings/main_binding.dart';
import 'package:marvel/bindings/profile_binding.dart';
import 'package:marvel/pages/favourite_page.dart';
import 'package:marvel/pages/main_page.dart';
import 'package:marvel/pages/profile_page.dart';
import 'package:marvel/pages/splash_page.dart';
import 'package:marvel/routes/routes.dart';

abstract class Pages {
  static List<GetPage> pages = [
    GetPage(
      name: Routes.MAIN_PAGE,
      page: () => MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.FAVOURITE_PAGE,
      page: () => FavouritePage(),
      binding: FavouriteBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_PAGE,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(name: Routes.SPLASH_PAGE, page: () => SplashVideoPage()),
  ];
}
