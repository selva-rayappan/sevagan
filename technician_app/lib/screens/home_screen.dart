import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/availability_provider.dart';
import 'landing_screen.dart';
import 'jobs/job_requests_screen.dart';
import 'jobs/job_tracking_screen.dart';
import 'jobs/active_jobs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch assigned jobs when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchMyJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LandingScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(context, jobProvider),
                const SizedBox(height: 24),
                _buildDashboardItem(
                  context,
                  title: l10n.newJobRequest,
                  count: jobProvider.pendingJobs.length,
                  icon: Icons.notifications_active,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobRequestsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardItem(
                  context,
                  title: 'Active Jobs',
                  count: jobProvider.activeJobs.length,
                  icon: Icons.work,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActiveJobsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildDashboardItem(
                  context,
                  title: l10n.earnings,
                  count: 0, // Placeholder
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to Earnings
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, JobProvider provider) {
    return Consumer<AvailabilityProvider>(
      builder: (context, availabilityProvider, _) {
        return Card(
          color: availabilityProvider.isOnline ? Colors.green : Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  availabilityProvider.isOnline
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      availabilityProvider.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                availabilityProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Switch(
                        value: availabilityProvider.isOnline,
                        onChanged: (val) {
                          availabilityProvider.setOnlineStatus(val);
                        },
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.green[300],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (count > 0)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
