import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../core/constants.dart';
import 'home_screen.dart';
import 'profile/profile_setup_screen.dart';

class ProfileCheckScreen extends StatefulWidget {
  const ProfileCheckScreen({super.key});

  @override
  State<ProfileCheckScreen> createState() => _ProfileCheckScreenState();
}

class _ProfileCheckScreenState extends State<ProfileCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final authProvider = context.read<AuthProvider>();

      print('Checking profile with token: ${authProvider.token}');
      print('API URL: ${ApiConstants.baseUrl}/technicians/profile');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/technicians/profile'),
        headers: {'Authorization': 'Bearer ${authProvider.token}'},
      );

      print('Profile check response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (mounted) {
        // Navigate to the appropriate screen based on profile status
        final hasProfile = response.statusCode == 200;
        print('Profile exists: $hasProfile');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                hasProfile ? const HomeScreen() : const ProfileSetupScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error checking profile: $e');
      if (mounted) {
        // On error, assume no profile and go to setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking profile
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
