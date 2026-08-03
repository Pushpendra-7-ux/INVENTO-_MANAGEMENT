import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for the Login Screen
/// Note: This is not a ChangeNotifier as it's meant to be used within 
/// the local state of a StatefulWidget.
class LoginViewModel {
  String email = '';
  String password = '';
  bool rememberMe = false;
  bool obscurePassword = true;
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Toggles the password visibility state
  void togglePasswordVisibility(VoidCallback updateState) {
    obscurePassword = !obscurePassword;
    updateState();
  }

  /// Toggles the remember me state
  void toggleRememberMe(bool? value, VoidCallback updateState) {
    if (value != null) {
      rememberMe = value;
      updateState();
    }
  }

  /// Validates the form and attempts to log in
  Future<bool> validateAndLogin(AuthProvider authProvider, BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      
      final success = await authProvider.login(email, password);
      
      if (success && rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remembered_email', email);
      } else if (success && !rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remembered_email');
      }
      
      return success;
    }
    return false;
  }
}
