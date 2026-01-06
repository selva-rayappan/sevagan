import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/models/job_model.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  final Set<String> _rejectedJobIds =
      {}; // Track rejected jobs for this session
  bool _isLoading = false;

  List<Job> get jobs =>
      _jobs.where((job) => !_rejectedJobIds.contains(job.id)).toList();
  bool get isLoading => _isLoading;

  List<Job> get pendingJobs =>
      _jobs.where((job) => job.status == JobStatus.pending).toList();

  List<Job> get activeJobs => _jobs
      .where(
        (job) => [JobStatus.accepted, JobStatus.started].contains(job.status),
      )
      .toList();

  Future<void> fetchAvailableJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'token',
      ); // Fixed: changed from 'auth_token' to 'token'

      if (token == null) {
        print('No token found, user not authenticated');
        return;
      }

      print('Fetching available jobs with token: ${token.substring(0, 20)}...');
      print('API URL: ${ApiConstants.baseUrl}/jobs/available');

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/available',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Jobs API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Received ${data.length} jobs from API');

        // Map response to Job model (assuming Job model matches API response or Needs adaptation)
        // For MVP, simplistic mapping:
        _jobs = data
            .map(
              (json) => Job(
                id: json['id'],
                customerName: json['customer']?['name'] ?? 'Unknown Customer',
                serviceType: json['serviceCategory']?['name'] ?? 'Service',
                description: json['description'],
                address: json['locationAddress'] ?? 'Unknown Location',
                latitude: (json['locationLat'] as num).toDouble(),
                longitude: (json['locationLng'] as num).toDouble(),
                price: (json['estimatedPrice'] as num).toDouble(),
                createdAt: DateTime.parse(json['createdAt']),
                status: JobStatus
                    .pending, // Explicitly set as pending for this list
                preferredDateTime: json['preferredDateTime'] != null
                    ? DateTime.parse(json['preferredDateTime'])
                    : null,
                proposedDateTime: json['proposedDateTime'] != null
                    ? DateTime.parse(json['proposedDateTime'])
                    : null,
                schedulingStatus: json['schedulingStatus'],
                schedulingNote: json['schedulingNote'],
              ),
            )
            .toList();

        print('Successfully mapped ${_jobs.length} jobs');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        print('Dio error response: ${e.response?.data}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found, user not authenticated');
        return;
      }

      print('Fetching my jobs with token: ${token.substring(0, 20)}...');
      print('API URL: ${ApiConstants.baseUrl}/jobs/my-jobs');

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/my-jobs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('My jobs API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Received ${data.length} assigned jobs from API');

        _jobs = data
            .map(
              (json) => Job(
                id: json['id'],
                customerName: json['customer']?['name'] ?? 'Unknown Customer',
                serviceType: json['serviceCategory']?['name'] ?? 'Service',
                description: json['description'],
                address: json['locationAddress'] ?? 'Unknown Location',
                latitude: (json['locationLat'] as num).toDouble(),
                longitude: (json['locationLng'] as num).toDouble(),
                price: (json['estimatedPrice'] as num).toDouble(),
                createdAt: DateTime.parse(json['createdAt']),
                status: _parseJobStatus(json['status']),
                preferredDateTime: json['preferredDateTime'] != null
                    ? DateTime.parse(json['preferredDateTime'])
                    : null,
                proposedDateTime: json['proposedDateTime'] != null
                    ? DateTime.parse(json['proposedDateTime'])
                    : null,
                schedulingStatus: json['schedulingStatus'],
                schedulingNote: json['schedulingNote'],
              ),
            )
            .toList();

        print('Successfully mapped ${_jobs.length} assigned jobs');
      }
    } catch (e) {
      print('Error fetching my jobs: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        print('Dio error response: ${e.response?.data}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  JobStatus _parseJobStatus(String status) {
    switch (status) {
      case 'TECHNICIAN_ASSIGNED':
        return JobStatus.accepted;
      case 'JOB_STARTED':
        return JobStatus.started;
      case 'JOB_COMPLETED':
        return JobStatus.completed;
      default:
        return JobStatus.pending;
    }
  }

  Future<bool> acceptJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'token',
      ); // Fixed: changed from 'auth_token' to 'token'

      if (token == null) {
        print('No token found, cannot accept job');
        return false;
      }

      print('Accepting job $jobId...');
      print('API URL: ${ApiConstants.baseUrl}/jobs/$jobId/accept');

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/jobs/$jobId/accept',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Accept job response status: ${response.statusCode}');
      print('Accept job response: ${response.data}');

      // Refresh jobs
      await fetchAvailableJobs();
      return true;
    } catch (e) {
      print('Error accepting job: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        print('Dio error response status: ${e.response?.statusCode}');
        print('Dio error response data: ${e.response?.data}');
        print('Dio error request path: ${e.requestOptions.path}');
      }
      return false;
    }
  }

  // TODO: Implement reject/start/complete similarly
  Future<bool> rejectJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found, cannot reject job');
        return false;
      }

      print('Rejecting job $jobId...');
      print('API URL: ${ApiConstants.baseUrl}/jobs/$jobId/reject');

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/jobs/$jobId/reject',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Reject job response status: ${response.statusCode}');
      print('Reject job response: ${response.data}');

      // Add to rejected jobs set to filter it out
      _rejectedJobIds.add(jobId);

      // Notify listeners to update UI
      await fetchAvailableJobs();
      return true;
    } catch (e) {
      print('Error rejecting job: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        print('Dio error response status: ${e.response?.statusCode}');
        print('Dio error response data: ${e.response?.data}');
      }
      return false;
    }
  }

  void startJob(String jobId) {}
  void completeJob(String jobId) {}
}
