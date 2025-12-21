import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/models/job_model.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;

  List<Job> get jobs => _jobs;
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
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/available',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Map response to Job model (assuming Job model matches API response or Needs adaptation)
        // For MVP, simplistic mapping:
        _jobs = data.map((json) => Job(
          id: json['id'],
          customerName: json['customer']?['name'] ?? 'Unknown Customer',
          serviceType: json['serviceCategory']?['name'] ?? 'Service',
          description: json['description'],
          address: json['locationAddress'] ?? 'Unknown Location',
          latitude: (json['locationLat'] as num).toDouble(),
          longitude: (json['locationLng'] as num).toDouble(),
          price: (json['estimatedPrice'] as num).toDouble(),
          createdAt: DateTime.parse(json['createdAt']),
          status: JobStatus.pending, // Explicitly set as pending for this list
        )).toList();
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptJob(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      await Dio().post(
         '${ApiConstants.baseUrl}/jobs/$jobId/accept',
         options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Refresh jobs
      await fetchAvailableJobs();
      return true;
    } catch (e) {
      print('Error accepting job: $e');
      return false;
    }
  }

  // TODO: Implement reject/start/complete similarly
  void rejectJob(String jobId) {}
  void startJob(String jobId) {}
  void completeJob(String jobId) {}
}
