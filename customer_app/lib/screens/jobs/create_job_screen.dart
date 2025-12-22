import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/api_service.dart';
import 'job_status_screen.dart';

class CreateJobScreen extends StatefulWidget {
  final ServiceCategory category;

  const CreateJobScreen({super.key, required this.category});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _descriptionController = TextEditingController();
  final apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final locationProvider = context.read<LocationProvider>();

      // Ensure we have location
      if (locationProvider.latitude == null ||
          locationProvider.longitude == null) {
        await locationProvider.getCurrentLocation();
      }

      final request = await apiService.createServiceRequest(
        authProvider.token!,
        {
          'serviceCategoryId': widget.category.id,
          'description': _descriptionController.text,
          'locationLat': locationProvider.latitude ?? 13.0827,
          'locationLng': locationProvider.longitude ?? 80.2707,
          'locationAddress':
              locationProvider.currentAddress ?? 'Unknown Location',
          'imageUrls': [],
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request created successfully!')),
        );
        // Replace current screen so back button goes to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobStatusScreen(jobId: request.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.nameEn),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Describe your issue',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g., Tap is leaking in kitchen...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Estimated Base Price: ₹${widget.category.basePrice}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Request Technician'),
            ),
          ],
        ),
      ),
    );
  }
}
