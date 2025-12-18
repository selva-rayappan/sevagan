// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sevagan Technician';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Enter your mobile number to continue';

  @override
  String get phoneLabel => 'Mobile Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get homeTitle => 'Dashboard';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get newJobRequest => 'New Job Request';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get startJob => 'Start Job';

  @override
  String get completeJob => 'Complete Job';

  @override
  String get earnings => 'Earnings';

  @override
  String get profile => 'Profile';
}
