import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _phoneNumber = prefs.getString('phoneNumber');
    notifyListeners();
  }

  Future<void> login(String mobile) async {
    // Simulate API login
    await Future.delayed(const Duration(seconds: 1));
    _phoneNumber = mobile;
    notifyListeners();
  }

  Future<bool> verifyOtp(String otp) async {
    // Simulate OTP verification
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '1234') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('phoneNumber', _phoneNumber!);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isAuthenticated = false;
    _phoneNumber = null;
    notifyListeners();
  }
}
