import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/validators.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _currentUserRole;
  DateTime? _lastLogin;
  DateTime? _accountCreatedDate;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserRole => _currentUserRole;
  DateTime? get lastLogin => _lastLogin;
  DateTime? get accountCreatedDate => _accountCreatedDate;

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('is_logged_in') ?? false;
    final email = prefs.getString('user_email');

    if (loggedIn && email != null && email.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserEmail = email.trim().toLowerCase();
      _currentUserName = _nameFromEmail(_currentUserEmail!);
      _currentUserRole = 'Administrator';

      final lastLoginStr = prefs.getString('last_login');
      _lastLogin = lastLoginStr != null
          ? (DateTime.tryParse(lastLoginStr) ?? DateTime.now())
          : DateTime.now();

      final createdStr = prefs.getString('created_${_currentUserEmail!}');
      _accountCreatedDate = createdStr != null
          ? (DateTime.tryParse(createdStr) ?? DateTime.now())
          : DateTime.now();

      notifyListeners();
      return true;
    }

    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _currentUserEmail = savedEmail;
    }

    notifyListeners();
    return false;
  }

  // TODO: add proper password hashing and backend auth
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();

      final emailError = Validators.email(cleanEmail);
      if (emailError != null) throw Exception(emailError);

      final passError = Validators.password(password);
      if (passError != null) throw Exception(passError);

      await Future.delayed(const Duration(milliseconds: 600));

      final prefs = await SharedPreferences.getInstance();

      _isLoggedIn = true;
      _currentUserEmail = cleanEmail;
      _currentUserName = _nameFromEmail(cleanEmail);
      _currentUserRole = 'Administrator';
      _lastLogin = DateTime.now();

      // first time? store creation date
      final createdKey = 'created_$cleanEmail';
      if (prefs.getString(createdKey) == null) {
        prefs.setString(createdKey, DateTime.now().toIso8601String());
        _accountCreatedDate = DateTime.now();
      } else {
        _accountCreatedDate = DateTime.tryParse(prefs.getString(createdKey)!) ?? DateTime.now();
      }

      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_email', cleanEmail);
      await prefs.setString('last_login', _lastLogin!.toIso8601String());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_email');
    await prefs.remove('remembered_email');

    _isLoggedIn = false;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserRole = null;
    _lastLogin = null;
    _accountCreatedDate = null;
    notifyListeners();
  }

  // john.doe@gmail.com -> John Doe
  String _nameFromEmail(String email) {
    if (!email.contains('@')) return 'Admin User';
    final parts = email.split('@').first.split(RegExp(r'[._-]'));
    return parts
        .map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '')
        .join(' ')
        .trim();
  }
}
