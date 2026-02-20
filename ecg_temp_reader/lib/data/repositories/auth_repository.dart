import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/user.dart';

class AuthRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<AppUser?> getUserByUsername(String username) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> createUser({
    required String username,
    required String passwordHash,
  }) async {
    final db = await _db;
    final now = DateTime.now();
    final id = await db.insert('users', {
      'username': username,
      'password_hash': passwordHash,
      'created_at': now.toIso8601String(),
    });
    return AppUser(
      id: id,
      username: username,
      passwordHash: passwordHash,
      createdAt: now,
    );
  }

  Future<AppUser?> validateUser({
    required String username,
    required String passwordHash,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, passwordHash],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }
}

