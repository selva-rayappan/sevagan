import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../../providers/job_provider.dart';
import '../../data/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'job_tracking_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  Future<void> _openMap(double lat, double lng) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jobProvider = Provider.of<JobProvider>(context);
    final job = jobProvider.jobs.firstWhere((j) => j.id == jobId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jobDetails)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.serviceType,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${job.customerName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Address: ${job.address}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Description:', style: Theme.of(context).textTheme.titleSmall),
            Text(job.description),
            const SizedBox(height: 16),
            Text(
              'Price: â‚¹${job.price}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.green),
            ),

            const Spacer(),

            if (job.status == JobStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        jobProvider.rejectJob(job.id);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.reject),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await jobProvider.acceptJob(job.id);
                        if (context.mounted) {
                           Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobTrackingScreen(jobId: job.id),
                            ),
                          );
                        }
                      },
                      child: Text(l10n.accept),
                    ),
                  ),
                ],
              ),
            ] else if (job.status == JobStatus.accepted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(job.latitude, job.longitude),
                  icon: const Icon(Icons.map),
                  label: const Text('Navigate to Location'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobTrackingScreen(jobId: job.id),
                        ),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(l10n.startJob),
                ),
              ),
            ] else if (job.status == JobStatus.started) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobTrackingScreen(jobId: job.id),
                        ),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(l10n.completeJob),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

