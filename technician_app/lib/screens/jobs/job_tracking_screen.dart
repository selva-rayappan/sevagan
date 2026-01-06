import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../data/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobTrackingScreen extends StatefulWidget {
  final String jobId;

  const JobTrackingScreen({super.key, required this.jobId});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  Job? _job;
  bool _isLoading = true;
  final _otpController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadJobDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await Dio().get(
        '${ApiConstants.baseUrl}/jobs/${widget.jobId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        setState(() {
          _job = Job(
            id: json['id'],
            customerName: json['customer']?['name'] ?? 'Unknown Customer',
            serviceType: json['serviceCategory']?['name'] ?? 'Service',
            description: json['description'],
            address: json['locationAddress'] ?? 'Unknown Location',
            latitude: (json['locationLat'] as num).toDouble(),
            longitude: (json['locationLng'] as num).toDouble(),
            price: (json['estimatedPrice'] as num).toDouble(),
            createdAt: DateTime.parse(json['createdAt']),
            status: _parseStatus(json['status']),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading job: $e');
      setState(() => _isLoading = false);
    }
  }

  JobStatus _parseStatus(String status) {
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

  Future<void> _startJob() async {
    if (_otpController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid 4-digit OTP')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await Dio().post(
        '${ApiConstants.baseUrl}/jobs/${widget.jobId}/start',
        data: {'otp': _otpController.text},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job Started!')));
      _loadJobDetails(); // Refresh status
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting job: $e')));
    }
  }

  Future<void> _completeJob() async {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter final price')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await Dio().post(
        '${ApiConstants.baseUrl}/jobs/${widget.jobId}/complete',
        data: {'finalPrice': double.parse(_priceController.text)},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job Completed!')));
      Navigator.pop(context); // Return to home list
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error completing job: $e')));
    }
  }

  void _callCustomer() {
    // In real app, fetch customer phone
    launchUrl(Uri.parse('tel:9876543210'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Tracking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
          ? const Center(child: Text('Job Error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomerCard(),
                  const SizedBox(height: 24),
                  if (_job!.status == JobStatus.accepted)
                    _buildStartJobCard()
                  else if (_job!.status == JobStatus.started)
                    _buildCompleteJobCard(),

                  if (_job!.status == JobStatus.completed)
                    const Card(
                      color: Colors.green,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Job Completed Successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _job!.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: _callCustomer,
                ),
              ],
            ),
            const Divider(),
            Text('Address: ${_job!.address}'),
            const SizedBox(height: 8),
            Text('Issue: ${_job!.description}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStartJobCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Enter OTP from Customer to Start Job',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Enter 4-digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('START JOB'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteJobCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Job in Progress',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Enter Final Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _completeJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('COMPLETE JOB'),
            ),
          ],
        ),
      ),
    );
  }
}
