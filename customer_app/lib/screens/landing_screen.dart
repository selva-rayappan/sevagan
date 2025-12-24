import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevagan_customer/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
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
    final localeProvider = Provider.of<LocaleProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
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
                            localeProvider.locale.languageCode == 'ta'
                                ? 'தமிழ்'
                                : 'English',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      onSelected: (Locale locale) {
                        localeProvider.setLocale(locale);
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

                // Role Selection Buttons
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
                  label: const Text('Customer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
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
                  label: const Text('Technician'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
