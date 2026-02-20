import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AppUser? _currentUser;

  AuthProvider(this._repo);

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('current_user_id');
    if (id == null) return;
    final user = await _repo.getUserById(id);
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final hash = sha256.convert(utf8.encode(password)).toString();
    final user = await _repo.validateUser(
      username: username,
      passwordHash: hash,
    );
    if (user == null) return false;
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', user.id);
    notifyListeners();
    return true;
  }

  Future<String?> register(String username, String password) async {
    if (username.trim().isEmpty) return 'Username required';
    if (password.isEmpty) return 'Password required';
    final existing = await _repo.getUserByUsername(username);
    if (existing != null) return 'Username already exists';
    final hash = sha256.convert(utf8.encode(password)).toString();
    final user = await _repo.createUser(username: username, passwordHash: hash);
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', user.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    notifyListeners();
  }
}
