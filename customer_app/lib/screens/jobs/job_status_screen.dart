import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/service_request.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/payment/payment_screen.dart';

class JobStatusScreen extends StatefulWidget {
  final String jobId;

  const JobStatusScreen({super.key, required this.jobId});

  @override
  State<JobStatusScreen> createState() => _JobStatusScreenState();
}

class _JobStatusScreenState extends State<JobStatusScreen> {
  ServiceRequest? _job;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
    // Poll for status updates every 10 seconds
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _loadJobDetails());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadJobDetails() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final apiService = ApiService();
      final job =
          await apiService.getJobDetails(authProvider.token!, widget.jobId);

      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading job details: $e');
    }
  }

  void _callTechnician() {
    // Phone is in the user object which is a relation of technician
    final phone = _job?.technician?['user']?['phone'];
    if (phone != null) {
      launchUrl(Uri.parse('tel:$phone'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Status')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
              ? const Center(child: Text('Job not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 24),
                      if (_job!.status == 'TECHNICIAN_ASSIGNED')
                        _buildOtpCard(),
                      const SizedBox(height: 24),
                      _buildTechnicianCard(),
                      const SizedBox(height: 24),
                      _buildJobDetailsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_job!.status) {
      case 'REQUESTED':
        statusColor = Colors.orange;
        statusText = 'Looking for Technician';
        statusIcon = Icons.search;
        break;
      case 'TECHNICIAN_ASSIGNED':
        statusColor = Colors.blue;
        statusText = 'Technician Assigned';
        statusIcon = Icons.person;
        break;
      case 'JOB_STARTED':
        statusColor = Colors.green;
        statusText = 'Work in Progress';
        statusIcon = Icons.build;
        break;
      case 'JOB_COMPLETED':
        statusColor = Colors.teal;
        statusText = 'Payment Pending';
        statusIcon = Icons.payment;
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusText = 'Job Closed & Paid';
        statusIcon = Icons.check_circle;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = _job!.status;
        statusIcon = Icons.info;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(height: 16),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (_job!.status == 'JOB_COMPLETED') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PaymentScreen(job: _job!)),
                  );
                  if (result == true) {
                    _loadJobDetails(); // Refresh to see updated status
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('PAY NOW'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Share this OTP with technician to start job',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              _job!.startJobOtp ?? '---',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard() {
    if (_job!.technician == null) return const SizedBox();

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(_job!.technician!['name'] ?? 'Unknown Technician'),
        subtitle: Text(
            'Rating: ${(_job!.technician!['rating'] ?? 0.0).toStringAsFixed(1)} ★'),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          onPressed: _callTechnician,
        ),
      ),
    );
  }

  Widget _buildJobDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Details', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildDetailRow(
                'Category', _job!.serviceCategory?['nameEn'] ?? 'Unknown'),
            _buildDetailRow('Description', _job!.description),
            _buildDetailRow('Estimated Price', '₹${_job!.estimatedPrice}'),
            if (_job!.finalPrice != null)
              _buildDetailRow('Final Price', '₹${_job!.finalPrice}',
                  isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
