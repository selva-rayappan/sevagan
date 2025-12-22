import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _phone;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get phone => _phone;

  Map<String, dynamic>? get user =>
      _userId != null ? {'id': _userId, 'phone': _phone, 'email': null} : null;

  final ApiService _apiService = ApiService();

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _phone = prefs.getString('phone');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<bool> requestOtp(String phone) async {
    try {
      await _apiService.requestOtp(phone);
      return true;
    } catch (e) {
      print('Error requesting OTP: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    try {
      final response = await _apiService.verifyOtp(phone, code);
      _token = response['accessToken'];
      _userId = response['user']['id'];
      _phone = phone;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userId', _userId!);
      await prefs.setString('phone', _phone!);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiService.updateFcmToken(fcmToken, _token!);
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _phone = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
