import 'package:flutter/foundation.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';

class JobProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ServiceRequest> _requests = [];
  ServiceRequest? _currentRequest;
  bool _isLoading = false;

  List<ServiceRequest> get requests => _requests;
  ServiceRequest? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;

  Future<void> fetchMyRequests(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _requests = await _apiService.getMyRequests(token);
    } catch (e) {
      print('Error fetching requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createServiceRequest(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final request = await _apiService.createServiceRequest(token, data);
      _currentRequest = request;
      _requests.insert(0, request);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating service request: $e');
      return false;
    }
  }

  Future<void> fetchJobDetails(String token, String jobId) async {
    try {
      _currentRequest = await _apiService.getJobDetails(token, jobId);
      notifyListeners();
    } catch (e) {
      print('Error fetching job details: $e');
    }
  }

  Future<bool> rateJob(
    String token,
    String jobId,
    int rating,
    String? comment,
  ) async {
    try {
      await _apiService.rateJob(token, jobId, rating, comment);
      return true;
    } catch (e) {
      print('Error rating job: $e');
      return false;
    }
  }
}
