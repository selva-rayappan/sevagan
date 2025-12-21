import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';

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

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Future<void> login(String mobile) async {
    try {
      await _dio.post(
        ApiConstants.authOtp,
        data: {'phone': mobile},
      );
      _phoneNumber = mobile;
      notifyListeners();
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.authVerify,
        data: {
          'phone': _phoneNumber,
          'code': otp,
          'role': 'TECHNICIAN'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('phoneNumber', _phoneNumber!);
        await prefs.setString('token', token);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Verify Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isAuthenticated = false;
    _phoneNumber = null;
    notifyListeners();
  }
}
