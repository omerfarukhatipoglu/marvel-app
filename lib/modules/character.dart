import 'package:get/get.dart';

class Character {
  final int id;
  final String name;
  final String description;
  final int seriesCount;
  final List<String> seriesTitles;
  final String imageUrl;
  RxBool isFavorite;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.seriesCount,
    required this.seriesTitles,
    required this.imageUrl,
    RxBool? isFavorite,
  }) : isFavorite = isFavorite ?? false.obs;

  factory Character.fromJson(Map<String, dynamic> json) {
    final items = (json['series']['items'] as List<dynamic>)
        .map((e) => e['name'] as String)
        .take(5)
        .toList();

    return Character(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      seriesCount: json['series']['available'] ?? 0,
      seriesTitles: items,
      imageUrl:
          "${json['thumbnail']['path']}.${json['thumbnail']['extension']}",
    );
  }
}
