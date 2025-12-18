import 'package:flutter/material.dart';
import '../data/models/job_model.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _jobs = [
    Job(
      id: '1',
      customerName: 'John Doe',
      serviceType: 'AC Repair',
      description: 'AC not cooling properly',
      address: '123, Main Street, Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      price: 500,
      createdAt: DateTime.now(),
      status: JobStatus.pending,
    ),
    Job(
      id: '2',
      customerName: 'Jane Smith',
      serviceType: 'Plumbing',
      description: 'Leaking tap in kitchen',
      address: '45, Anna Nagar, Chennai',
      latitude: 13.0850,
      longitude: 80.2100,
      price: 300,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      status: JobStatus.pending,
    ),
  ];

  List<Job> get jobs => _jobs;

  List<Job> get pendingJobs =>
      _jobs.where((job) => job.status == JobStatus.pending).toList();

  List<Job> get activeJobs => _jobs
      .where(
        (job) => [JobStatus.accepted, JobStatus.started].contains(job.status),
      )
      .toList();

  void acceptJob(String jobId) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _jobs[index].status = JobStatus.accepted;
      notifyListeners();
    }
  }

  void rejectJob(String jobId) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _jobs[index].status = JobStatus.cancelled;
      // In real app, might just remove from list or mark rejected
      notifyListeners();
    }
  }

  void startJob(String jobId) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _jobs[index].status = JobStatus.started;
      notifyListeners();
    }
  }

  void completeJob(String jobId) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _jobs[index].status = JobStatus.completed;
      notifyListeners();
    }
  }
}
