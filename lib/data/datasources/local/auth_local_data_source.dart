import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<Map<String, dynamic>?> getUserData();
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<void> clearUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyUserGoogleAccount = 'userGoogleAccount';

  SharedPreferences? _cachedPrefs;

  Future<SharedPreferences> get _prefs async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _prefs;
    final userDataString = prefs.getString(_keyUserGoogleAccount);

    if (userDataString == null || userDataString.isEmpty) {
      return null;
    }

    try {
      return json.decode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      // Se houver erro ao decodificar, retorna null
      return null;
    }
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _prefs;

    // Remove campos nulos antes de salvar
    final cleanedData = Map<String, dynamic>.from(userData)
      ..removeWhere((key, value) => value == null);

    final userDataString = json.encode(cleanedData);
    await prefs.setString(_keyUserGoogleAccount, userDataString);
  }

  @override
  Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyUserGoogleAccount);
    print('🗑️ Dados do usuário removidos do SharedPreferences');
  }
}
