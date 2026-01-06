import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/location_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/customer_profile_check_screen.dart';
import 'package:sevagan_customer/l10n/app_localizations.dart';

/*
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Uncomment when running on Android/iOS or upgrade Firebase packages for web
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const SevaganCustomerApp());
}

class SevaganCustomerApp extends StatelessWidget {
  const SevaganCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<AuthProvider, LocaleProvider>(
        builder: (context, authProvider, localeProvider, _) {
          return MaterialApp(
            title: 'Sevagan',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ta', ''),
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            home: authProvider.isAuthenticated
                ? CustomerProfileCheckScreen(key: UniqueKey())
                : const LandingScreen(), // Changed from LoginScreen to LandingScreen
          );
        },
      ),
    );
  }
}
