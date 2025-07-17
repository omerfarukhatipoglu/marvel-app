import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modules/character.dart'; // Character modelini import etmeyi unutma
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class FavoriteStorage {
  static Database? _db;

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'favorite_characters.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorite_characters (
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            seriesCount INTEGER,
            seriesTitles TEXT,
            storyNames TEXT,
            eventNames TEXT,
            comicNames TEXT,
            base64Image TEXT
          )
        ''');
      },
    );
  }

  static Future<List<int>> getFavoriteIds() async {
    final db = await _database;
    final result = await db.query('favorite_characters', columns: ['id']);
    return result.map((row) => row['id'] as int).toList();
  }

  static Future<void> addFavorite(Character character) async {
    final db = await _database;
    await db.insert(
      'favorite_characters',
      character.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeFavorite(int id) async {
    final db = await _database;
    await db.delete('favorite_characters', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> isFavorite(int id) async {
    final db = await _database;
    final result = await db.query(
      'favorite_characters',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  static Future<List<Character>> getAllCharacters() async {
    final db = await _database;
    final result = await db.query('favorite_characters');
    return result.map((map) => Character.fromMap(map)).toList();
  }

  static Future<Character> convertCharacterWithBase64(
    Character character,
  ) async {
    try {
      final response = await http.get(Uri.parse(character.imageUrl));

      if (response.statusCode == 200) {
        final base64Image = base64Encode(response.bodyBytes);

        return Character(
          id: character.id,
          name: character.name,
          description: character.description,
          seriesCount: character.seriesCount,
          seriesTitles: character.seriesTitles,
          storyNames: character.storyNames,
          eventNames: character.eventNames,
          comicNames: character.comicNames,
          imageUrl: character.imageUrl,
          base64Image: base64Image,
          isFavorite: true.obs,
        );
      }
    } catch (e) {
      print('Resim encode hatası: $e');
    }

    return character; // Başarısız olursa orijinali döner
  }
}
