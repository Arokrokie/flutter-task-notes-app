import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/task_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      // sqflite is not supported on web; avoid initializing a native DB.
      throw UnsupportedError('sqflite is not supported on the web.');
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'task_items.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        priority TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTask(TaskItem task) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('tasks');
      final List<Map<String, dynamic>> list = raw == null
          ? []
          : List<Map<String, dynamic>>.from(jsonDecode(raw));

      // assign incremental id
      final currentIds = list.map((m) => m['id'] as int?).whereType<int>();
      final nextId =
          (currentIds.isEmpty
              ? 0
              : currentIds.reduce((a, b) => a > b ? a : b)) +
          1;
      final map = task.toJson();
      map['id'] = nextId;
      list.insert(0, map);
      await prefs.setString('tasks', jsonEncode(list));
      return nextId;
    }

    final db = await database;
    return await db.insert('tasks', task.toJson());
  }

  Future<List<TaskItem>> getTasks() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('tasks');
      if (raw == null) return [];
      final List<dynamic> parsed = jsonDecode(raw);
      final maps = List<Map<String, dynamic>>.from(parsed);
      return maps.map((m) => TaskItem.fromJson(m)).toList();
    }

    final db = await database;
    final maps = await db.query('tasks', orderBy: 'id DESC');

    return maps.map((m) => TaskItem.fromJson(m)).toList();
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('tasks');
      if (raw == null) return 0;
      final List<dynamic> parsed = jsonDecode(raw);
      final list = List<Map<String, dynamic>>.from(parsed);
      final before = list.length;
      list.removeWhere((m) => m['id'] == id);
      await prefs.setString('tasks', jsonEncode(list));
      return before - list.length;
    }

    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
