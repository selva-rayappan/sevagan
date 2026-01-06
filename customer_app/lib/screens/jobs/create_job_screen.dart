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
  bool _scheduleForLater = false;
  DateTime? _selectedDateTime;

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

      final requestData = {
        'serviceCategoryId': widget.category.id,
        'description': _descriptionController.text,
        'locationLat': locationProvider.latitude ?? 13.0827,
        'locationLng': locationProvider.longitude ?? 80.2707,
        'locationAddress':
            locationProvider.currentAddress ?? 'Unknown Location',
        'imageUrls': [],
      };

      // Add preferred date/time if scheduled
      if (_scheduleForLater && _selectedDateTime != null) {
        requestData['preferredDateTime'] = _selectedDateTime!.toIso8601String();
      }

      final request = await apiService.createServiceRequest(
        authProvider.token!,
        requestData,
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
            _buildSchedulingSection(),
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

  Widget _buildSchedulingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Schedule for later',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _scheduleForLater,
                  onChanged: (value) {
                    setState(() {
                      _scheduleForLater = value;
                      if (!value) {
                        _selectedDateTime = null;
                      }
                    });
                  },
                ),
              ],
            ),
            if (_scheduleForLater) ...[
              const Divider(height: 24),
              if (_selectedDateTime != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDateTime(_selectedDateTime!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _pickDateTime,
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.access_time),
                  label: const Text('Select Date & Time'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Pick date
    final date = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date == null) return;

    // Pick time
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Validate time is in future
    if (selectedDateTime.isBefore(now.add(const Duration(hours: 1)))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time at least 1 hour from now'),
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedDateTime = selectedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, ${hour == 0 ? 12 : hour}:$minute $period';
  }
}
