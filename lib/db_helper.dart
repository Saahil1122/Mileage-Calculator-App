import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDB();
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mileage.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mileage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleType TEXT,
        distance REAL,
        fuel REAL,
        mileage REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertMileage(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('mileage', row);
  }

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await database;
    return await db.query('mileage', orderBy: 'id DESC');
  }
}
