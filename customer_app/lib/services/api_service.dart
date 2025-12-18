import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/service_request.dart';
import '../models/service_category.dart';

class ApiService {
  // Auth
  Future<void> requestOtp(String phone) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.otpRequest}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to request OTP');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.otpVerify}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify OTP');
    }

    return jsonDecode(response.body);
  }

  Future<void> updateFcmToken(String fcmToken, String token) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateFcmToken}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );
  }

  // Services
  Future<List<ServiceCategory>> getServiceCategories(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.services}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load service categories');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ServiceCategory.fromJson(json)).toList();
  }

  // Jobs
  Future<ServiceRequest> createServiceRequest(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createServiceRequest}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create service request');
    }

    return ServiceRequest.fromJson(jsonDecode(response.body));
  }

  Future<List<ServiceRequest>> getMyRequests(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myRequests}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load requests');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  Future<ServiceRequest> getJobDetails(String token, String jobId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.jobDetails}/$jobId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load job details');
    }

    return ServiceRequest.fromJson(jsonDecode(response.body));
  }

  Future<void> rateJob(
    String token,
    String jobId,
    int rating,
    String? comment,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rateJob}/$jobId/rate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rating': rating,
        if (comment != null) 'comment': comment,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to rate job');
    }
  }
}
