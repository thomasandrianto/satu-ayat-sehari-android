import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_verse.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'favorite_verses.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            devotion_date TEXT,
            book TEXT,
            chapter INTEGER,
            verse_start INTEGER,
            verse_end INTEGER,
            verse_text_en TEXT,
            verse_text_id TEXT,
            devotion_title TEXT,
            devotion_text TEXT,
            theme TEXT
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(DailyVerse verse) async {
    final db = await database;
    await db.insert('favorites', {
      'id': verse.id,
      'devotion_date': verse.devotionDate.toIso8601String(),
      'book': verse.book,
      'chapter': verse.chapter,
      'verse_start': verse.verseStart,
      'verse_end': verse.verseEnd,
      'verse_text_en': verse.verseTextEn,
      'verse_text_id': verse.verseTextId,
      'devotion_title': verse.devotionTitle,
      'devotion_text': verse.devotionText,
      'theme': verse.theme,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final res = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty;
  }

  Future<List<DailyVerse>> getAllFavorites() async {
    final db = await database;
    final res = await db.query('favorites', orderBy: 'devotion_date DESC');
    return res.map((e) => DailyVerse.fromMap(e)).toList();
  }
}
