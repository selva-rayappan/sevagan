import 'package:flutter/material.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import 'auth/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<Locale>(
                    icon: Row(
                      children: [
                        const Icon(Icons.language),
                        const SizedBox(width: 8),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ta'
                              ? 'தமிழ்'
                              : 'English',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    onSelected: (Locale locale) {
                      // Update locale - this will be handled by the main app
                      // For now, we'll need to add a provider or callback
                      _changeLanguage(locale);
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      const PopupMenuItem(
                        value: Locale('ta'),
                        child: Text('தமிழ்'),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // App Logo/Icon
              const Icon(Icons.handyman, size: 100, color: Colors.blue),
              const SizedBox(height: 24),

              // Welcome Text
              Text(
                l10n.welcome,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Register Buttons
              Text(
                'Register',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginScreen(userRole: 'CUSTOMER'),
                    ),
                  );
                },
                icon: const Icon(Icons.person),
                label: Text(l10n.registerAsCustomer),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginScreen(userRole: 'TECHNICIAN'),
                    ),
                  );
                },
                icon: const Icon(Icons.build),
                label: Text(l10n.registerAsTechnician),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Login Buttons
              Text(
                'Login',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginScreen(userRole: 'CUSTOMER'),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline),
                label: Text(l10n.loginAsCustomer),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginScreen(userRole: 'TECHNICIAN'),
                    ),
                  );
                },
                icon: const Icon(Icons.build_outlined),
                label: Text(l10n.loginAsTechnician),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _changeLanguage(Locale locale) {
    // This will need to be implemented with a provider or state management
    // For now, we'll just rebuild the widget
    // In a real app, you'd use Provider or Riverpod to manage locale
    setState(() {
      // The locale change will be handled by the main app
    });
  }
}
