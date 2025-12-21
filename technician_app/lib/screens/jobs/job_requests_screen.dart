import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../../providers/job_provider.dart';
import 'job_detail_screen.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchAvailableJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newJobRequest),
        actions: [
          IconButton(
             icon: const Icon(Icons.refresh),
             onPressed: () => context.read<JobProvider>().fetchAvailableJobs(),
          )
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          if (jobProvider.isLoading) {
             return const Center(child: CircularProgressIndicator());
          }

          final jobs = jobProvider.pendingJobs;

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No new job requests'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                     onPressed: () => jobProvider.fetchAvailableJobs(),
                     child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => jobProvider.fetchAvailableJobs(),
            child: ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(job.serviceType),
                    subtitle: Text('${job.customerName}\n${job.address}'),
                    isThreeLine: true,
                    trailing: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          Text('₹${job.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                       ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailScreen(jobId: job.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
