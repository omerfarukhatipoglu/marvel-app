import 'package:get/get.dart';
import 'package:marvel/modules/character.dart';
import 'package:translator/translator.dart';

class ProfileController extends GetxController {
  late Character character;
  final translatedText = ''.obs;
  final isTranslating = true.obs;

  final _translator = GoogleTranslator();

  @override
  void onInit() {
    super.onInit();
    character = Get.arguments;

    final desc = character.description?.toString().trim() ?? '';
    if (desc.isNotEmpty) {
      _translateDescription(desc);
    } else {
      translatedText.value = '--';
      isTranslating.value = false;
    }
  }

  Future<void> _translateDescription(String description) async {
    try {
      isTranslating.value = true; // 🔹 Başladı

      final translation = await _translator.translate(
        description,
        from: 'en',
        to: 'tr',
      );

      final sanitized = translation.text
          .replaceAll('ğ', 'g')
          .replaceAll('Ğ', 'G');

      translatedText.value = sanitized;
    } catch (e) {
      translatedText.value = character.description;
    } finally {
      isTranslating.value = false; // 🔹 Bitti
    }
  }

  List<String?> splitName(String raw) {
    final match = RegExp(r'^(.*?)\s*\((.*?)\)\s*$').firstMatch(raw);
    if (match != null) {
      return [match.group(1)!.trim(), match.group(2)!.trim()];
    }
    return [raw.trim(), null];
  }
}
