import 'package:library_system_sqflite/library_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  static const _dbName = 'shopping';
  static const _dbVersion = 1;

  static const tableName = 'shopping_items';

  static const shopId = 'shop_id';
  static const shopName = 'shop_name';
  static const items = 'items';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    
    CREATE TABLE $tableName(
    $shopId INTEGER PRIMARY KEY AUTOINCREMENT,
    $shopName TEXT NOT NULL,
    $items TEXT NOT NULL
    )
    ''');
  }

  Future<int> insert(ShoppingModel shoppingModel) async {
    Database database = await instance.database;
    return await database.insert(tableName, {
      'shop_id': shoppingModel.shopId,
      'shop_name': shoppingModel.shopName,
      'items': shoppingModel.items
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database database = await instance.database;
    return await database.query(tableName);
  }

  Future<List<Map<String, dynamic>>> queryRows(shopName) async {
    Database database = await instance.database;
    return await database.query(tableName,
        where: "$shopName LIKE '%$shopName%");
  }

  Future<int?> queryRowCount() async {
    Database database = await instance.database;
    return Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) '
        'FROM $tableName'));
  }

  Future<int> update(ShoppingModel shoppingModel) async {
    Database database = await instance.database;
    int shopId = shoppingModel.toMap()['shop_id'];
    return await database.update(tableName, shoppingModel.toMap(),
        where: '$shopId = ?', whereArgs: [shopId]);
  }

  Future<int> delete(int shopId) async {
    Database database = await instance.database;
    return database
        .delete(tableName, where: '$shopId = ?', whereArgs: [shopId]);
  }
}
