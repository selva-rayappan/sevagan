import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'home/home_screen.dart';
import 'profile/customer_profile_setup_screen.dart';

class CustomerProfileCheckScreen extends StatefulWidget {
  const CustomerProfileCheckScreen({super.key});

  @override
  State<CustomerProfileCheckScreen> createState() =>
      _CustomerProfileCheckScreenState();
}

class _CustomerProfileCheckScreenState
    extends State<CustomerProfileCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('token'); // Changed from 'auth_token' to 'token'

      print('Checking customer profile with token: $token');
      print('API URL: ${ApiConfig.baseUrl}/customers/profile');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customers/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Profile check response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (mounted) {
        // Navigate to the appropriate screen based on profile status
        final hasProfile = response.statusCode == 200;
        print('Customer profile exists: $hasProfile');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => hasProfile
                ? const HomeScreen()
                : const CustomerProfileSetupScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error checking customer profile: $e');
      if (mounted) {
        // On error, assume no profile and go to setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerProfileSetupScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking profile
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
