import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  bool get isAuthenticated => _supabase.auth.currentUser != null;
  String? get token => _supabase.auth.currentSession?.accessToken;

  String get userName =>
      (_supabase.auth.currentUser?.userMetadata?['full_name'] as String?) ??
      _supabase.auth.currentUser?.email ??
      'Kullanıcı';

  String get userEmail => _supabase.auth.currentUser?.email ?? '';

  String get userInitials {
    final name = userName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'MN';
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Bağlantı hatası. Backend çalışıyor mu?';
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
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Kayıt başarısız. Tekrar deneyin.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
