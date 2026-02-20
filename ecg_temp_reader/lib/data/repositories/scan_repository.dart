import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/scan_session.dart';

class ScanRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insertScan(ScanSession scan) async {
    final db = await _db;
    final map = scan.toMap();
    final id = await db.insert('scans', {
      'user_id': map['user_id'],
      'created_at': map['created_at'],
      'temperature': map['temperature'],
      'ecg_payload': map['ecg_payload'],
      'note': map['note'],
    });
    return id;
  }

  Future<List<ScanSession>> getScansForUser(int userId) async {
    final db = await _db;
    final rows = await db.query(
      'scans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => ScanSession.fromMap(r)).toList();
  }

  Future<void> deleteScan(int id) async {
    final db = await _db;
    await db.delete(
      'scans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

