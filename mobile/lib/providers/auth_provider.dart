import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();

  String? _token;
  Map<String, dynamic>? _user;
  bool _loading = false;
  String? _error;

  bool get isAuthenticated => _token != null;
  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  String get userName => _user?['full_name'] ?? 'Kullanıcı';
  String get userEmail => _user?['email'] ?? '';
  String get userInitials {
    final name = userName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'KL';
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.login(email, password);
      _token = result['access_token'];
      _user = result['user'];
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.register(fullName, email, password);
      _token = result['access_token'];
      _user = result['user'];
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _user = null;
    notifyListeners();
  }

  String? get token => _token;
}
