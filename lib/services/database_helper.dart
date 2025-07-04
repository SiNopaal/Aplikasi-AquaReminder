import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/consumption_model.dart';
import '../models/reminder_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aquareminder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create tb_user table with authentication fields
    await db.execute('''
      CREATE TABLE tb_user (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        berat_badan INTEGER NOT NULL,
        aktivitas INTEGER NOT NULL,
        target_harian INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create tb_konsumsi table with user_id reference
    await db.execute('''
      CREATE TABLE tb_konsumsi (
        id_log INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        waktu TEXT NOT NULL,
        volume INTEGER NOT NULL,
        tanggal TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES tb_user (id_user)
      )
    ''');

    // Create tb_pengingat table with user_id reference
    await db.execute('''
      CREATE TABLE tb_pengingat (
        id_reminder INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        interval_jam INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES tb_user (id_user)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('tb_user', user.toMap());
  }

  Future<UserModel?> getUser() async {
    final db = await instance.database;
    final maps = await db.query('tb_user', limit: 1);
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await instance.database;
    return await db.update(
      'tb_user',
      user.toMap(),
      where: 'id_user = ?',
      whereArgs: [user.idUser],
    );
  }

  // Consumption operations
  Future<int> insertConsumption(ConsumptionModel consumption) async {
    final db = await instance.database;
    return await db.insert('tb_konsumsi', consumption.toMap());
  }

  Future<List<ConsumptionModel>> getConsumptionByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_konsumsi',
      where: 'tanggal = ?',
      whereArgs: [date],
      orderBy: 'waktu ASC',
    );

    return List.generate(maps.length, (i) {
      return ConsumptionModel.fromMap(maps[i]);
    });
  }

  Future<List<ConsumptionModel>> getWeeklyConsumption(String startDate, String endDate) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_konsumsi',
      where: 'tanggal BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'tanggal ASC, waktu ASC',
    );

    return List.generate(maps.length, (i) {
      return ConsumptionModel.fromMap(maps[i]);
    });
  }

  // Reminder operations
  Future<int> insertReminder(ReminderModel reminder) async {
    final db = await instance.database;
    return await db.insert('tb_pengingat', reminder.toMap());
  }

  Future<ReminderModel?> getActiveReminder() async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_pengingat',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ReminderModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateReminder(ReminderModel reminder) async {
    final db = await instance.database;
    return await db.update(
      'tb_pengingat',
      reminder.toMap(),
      where: 'id_reminder = ?',
      whereArgs: [reminder.idReminder],
    );
  }

  // Authentication methods
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> registerUser(UserModel user) async {
    final db = await instance.database;
    try {
      await db.insert('tb_user', user.toMap());
      return true;
    } catch (e) {
      return false; // Email already exists or other error
    }
  }

  Future<bool> isEmailExists(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_user',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<UserModel?> getUserById(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_user',
      where: 'id_user = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_user',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Update consumption methods to include user_id
  Future<List<ConsumptionModel>> getConsumptionByDateAndUser(String date, int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_konsumsi',
      where: 'tanggal = ? AND user_id = ?',
      whereArgs: [date, userId],
      orderBy: 'waktu ASC',
    );

    return List.generate(maps.length, (i) {
      return ConsumptionModel.fromMap(maps[i]);
    });
  }

  Future<List<ConsumptionModel>> getWeeklyConsumptionByUser(String startDate, String endDate, int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_konsumsi',
      where: 'tanggal BETWEEN ? AND ? AND user_id = ?',
      whereArgs: [startDate, endDate, userId],
      orderBy: 'tanggal ASC, waktu ASC',
    );

    return List.generate(maps.length, (i) {
      return ConsumptionModel.fromMap(maps[i]);
    });
  }

  // Update reminder methods to include user_id
  Future<ReminderModel?> getActiveReminderByUser(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'tb_pengingat',
      where: 'is_active = ? AND user_id = ?',
      whereArgs: [1, userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ReminderModel.fromMap(maps.first);
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
