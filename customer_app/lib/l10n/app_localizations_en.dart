// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sevagan';

  @override
  String get login => 'Login';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get selectService => 'Select Service';

  @override
  String get serviceLocation => 'Service Location';

  @override
  String get requestService => 'Request Service';

  @override
  String get myRequests => 'My Requests';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get rateService => 'Rate Service';

  @override
  String get payment => 'Payment';

  @override
  String get cashPayment => 'Cash Payment';

  @override
  String get upiPayment => 'UPI Payment';
}
