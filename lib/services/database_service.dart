import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'satu_ayat_sehari.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorite_verses (
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
        theme TEXT,
        created_at TEXT
      )
    ''');
  }
}
