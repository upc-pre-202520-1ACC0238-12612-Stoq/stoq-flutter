import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_models.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static Database? _database;
  static const String _databaseName = 'favorites.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'favorites';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER UNIQUE NOT NULL,
        product_data TEXT NOT NULL
      )
    ''');

    // Crear índice para búsquedas rápidas por product_id
    await db.execute('''
      CREATE INDEX idx_product_id ON $_tableName(product_id)
    ''');
  }

  /// Agregar un producto a favoritos
  Future<void> addFavorite(Product product) async {
    final db = await database;
    final productJson = jsonEncode(product.toJson());
    
    await db.insert(
      _tableName,
      {
        'product_id': product.id,
        'product_data': productJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remover un producto de favoritos
  Future<void> removeFavorite(int productId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Verificar si un producto es favorito
  Future<bool> isFavorite(int productId) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Obtener todos los productos favoritos
  Future<List<Product>> getAllFavorites() async {
    final db = await database;
    final result = await db.query(_tableName, orderBy: 'id DESC');

    return result.map((row) {
      final productJson = jsonDecode(row['product_data'] as String);
      return Product.fromJson(productJson);
    }).toList();
  }

  /// Obtener todos los IDs de productos favoritos (para cache rápido)
  Future<Set<int>> getAllFavoriteIds() async {
    final db = await database;
    final result = await db.query(_tableName, columns: ['product_id']);

    return result.map((row) => row['product_id'] as int).toSet();
  }

  /// Cerrar la base de datos
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

