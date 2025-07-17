import 'package:get/get.dart';

class Character {
  final int id;
  final String name;
  final String description;
  final int seriesCount;
  final List<String> seriesTitles;
  final List<String> storyNames;
  final List<String> eventNames;
  final List<String> comicNames;
  final String imageUrl;
  RxBool isFavorite;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.seriesCount,
    required this.seriesTitles,
    required this.storyNames,
    required this.eventNames,
    required this.comicNames,
    required this.imageUrl,
    RxBool? isFavorite,
  }) : isFavorite = isFavorite ?? false.obs;

  factory Character.fromJson(Map<String, dynamic> json) {
    List<String> extractNames(Map<String, dynamic> section) {
      return (section['items'] as List<dynamic>)
          .map((e) => e['name'] as String)
          .take(5)
          .toList();
    }

    return Character(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      seriesCount: json['series']['available'] ?? 0,
      seriesTitles: extractNames(json['series']),
      storyNames: extractNames(json['stories']),
      eventNames: extractNames(json['events']),
      comicNames: extractNames(json['comics']),
      imageUrl:
          "${json['thumbnail']['path']}.${json['thumbnail']['extension']}",
    );
  }
}
