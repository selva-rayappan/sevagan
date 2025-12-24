import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class AvailabilityProvider with ChangeNotifier {
  bool _isOnline = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AvailabilityProvider() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnline = prefs.getBool('isOnline') ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading online status: $e');
    }
  }

  Future<void> toggleOnlineStatus() async {
    final newStatus = !_isOnline;
    await setOnlineStatus(newStatus);
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _errorMessage = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/technicians/toggle-online',
        data: {'isOnline': isOnline},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isOnline = isOnline;
        await prefs.setBool('isOnline', isOnline);
        print('Online status updated to: $isOnline');
      }
    } catch (e) {
      print('Error updating online status: $e');
      _errorMessage = 'Failed to update status. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
