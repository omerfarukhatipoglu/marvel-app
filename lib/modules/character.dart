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
  final String imageUrl; // API'den gelen görsel URL
  final String?
  base64Image; // SQLite için, favorilere eklendiğinde doldurulacak
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
    this.base64Image,
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
      base64Image: null, // API'den gelmiyor, sonra eklenir
    );
  }

  /// SQLite için karakteri Map’e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'seriesCount': seriesCount,
      'seriesTitles': seriesTitles.join('|'),
      'storyNames': storyNames.join('|'),
      'eventNames': eventNames.join('|'),
      'comicNames': comicNames.join('|'),
      'base64Image': base64Image,
    };
  }

  /// SQLite’ten geri `Character` üret
  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      seriesCount: map['seriesCount'],
      seriesTitles: (map['seriesTitles'] as String).split('|'),
      storyNames: (map['storyNames'] as String).split('|'),
      eventNames: (map['eventNames'] as String).split('|'),
      comicNames: (map['comicNames'] as String).split('|'),
      imageUrl: '', // SQLite’ten gelmiyor, gerekirse boş bırakılır
      base64Image: map['base64Image'],
      isFavorite: true.obs,
    );
  }
}
