import 'package:get/get.dart';
import 'package:marvel/controllers/favourite_controller.dart';

class FavouriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FavouriteController());
  }
}
