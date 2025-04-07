import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        ingredients TEXT,
        instructions TEXT,
        prepTime INTEGER,
        cookTime INTEGER,
        imagePath TEXT,
        favourite INTEGER,
        dateCreated TEXT NOT NULL
      )
    ''');
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }
}
