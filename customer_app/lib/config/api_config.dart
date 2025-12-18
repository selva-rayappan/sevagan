class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  
  // Auth endpoints
  static const String otpRequest = '/auth/otp';
  static const String otpVerify = '/auth/verify';
  static const String updateFcmToken = '/auth/fcm-token';
  
  // Service endpoints
  static const String services = '/services';
  static const String createServiceRequest = '/jobs';
  static const String myRequests = '/jobs/my-requests';
  static const String jobDetails = '/jobs';
  static const String rateJob = '/jobs';
  
  // Payment endpoints
  static const String createPayment = '/payments/create';
  static const String verifyPayment = '/payments/verify';
}
